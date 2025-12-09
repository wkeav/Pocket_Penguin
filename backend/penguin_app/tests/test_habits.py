from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from datetime import date, timedelta
from ..models.habit_models import Habit

User = get_user_model()

"""
Unit tests for Habit Tracker feature in Pocket Penguin.

Tests habit CRUD operations, field validations, and API endpoints.
"""


class HabitModelTests(TestCase):
    "Tests for the Habit model."
    
    def setUp(self):
        "Set up test user and habit."
        self.user = User.objects.create_user(
            email='testuser@example.com',
            username='testuser',
            password='TestPass123!'
        )
        self.habit = Habit.objects.create(
            user=self.user,
            name='Drink Water',
            description='Stay hydrated',
            category='Health',
            emoji='💧',
            color='blue',
            icon='water_drop',
            daily_goal=8,
            today_count=0,
            unit='glasses',
            reward=5,
            streak=0
        )
    
    def test_habit_creation(self):
        """Test habit is created with correct fields."""
        self.assertEqual(self.habit.name, 'Drink Water')
        self.assertEqual(self.habit.user, self.user)
        self.assertEqual(self.habit.daily_goal, 8)
        self.assertEqual(self.habit.unit, 'glasses')
        self.assertEqual(self.habit.reward, 5)
        self.assertTrue(self.habit.is_active)
        self.assertFalse(self.habit.is_archived)
    
    def test_habit_string_representation(self):
        """Test the string representation of habit."""
        expected = f"{self.user.email} – {self.habit.name[:30]}"
        self.assertEqual(str(self.habit), expected)
    
    def test_habit_progress_property(self):
        """Test progress calculation."""
        self.habit.today_count = 4
        self.habit.save()
        self.assertEqual(self.habit.progress, 0.5)
        
        self.habit.today_count = 8
        self.habit.save()
        self.assertEqual(self.habit.progress, 1.0)
        
        self.habit.today_count = 10
        self.habit.save()
        self.assertEqual(self.habit.progress, 1.0)  # Capped at 1.0
    
    def test_habit_progress_with_zero_goal(self):
        """Test progress returns 0 when daily_goal is 0."""
        self.habit.daily_goal = 0
        self.habit.save()
        self.assertEqual(self.habit.progress, 0.0)
    
    def test_habit_default_values(self):
        """Test default values are set correctly."""
        habit = Habit.objects.create(
            user=self.user,
            name='Test Habit'
        )
        self.assertEqual(habit.daily_goal, 1)
        self.assertEqual(habit.today_count, 0)
        self.assertEqual(habit.unit, 'times')
        self.assertEqual(habit.reward, 5)
        self.assertEqual(habit.streak, 0)
        self.assertEqual(habit.schedule, 'DAILY')
        self.assertEqual(habit.category, 'General')


class HabitAPITests(TestCase):
    """Essential API endpoint tests."""
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='testuser@example.com',
            username='testuser',
            password='TestPass123!'
        )
        self.other_user = User.objects.create_user(
            email='other@example.com',
            username='other',
            password='TestPass123!'
        )
        
        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        self.list_url = '/api/habits/'
    
    def test_authentication_required(self):
        """Test unauthenticated requests are rejected."""
        self.client.credentials()
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
    
    def test_create_and_list_habit(self):
        """Test creating and listing habits."""
        data = {
            'title': 'Exercise',
            'category': 'Fitness',
            'icon': 'fitness',
            'color': 'blue',
            'targetValue': 1,
            'unit': 'session',
            'currentValue': 0,
            'reward': 10,
            'streak': 0
        }
        response = self.client.post(self.list_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        response = self.client.get(self.list_url)
        self.assertEqual(len(response.data['results']), 1)
        self.assertEqual(response.data['results'][0]['title'], 'Exercise')
    
    def test_user_isolation(self):
        """Test users can only access their own habits."""
        Habit.objects.create(user=self.user, name='My Habit', daily_goal=1)
        Habit.objects.create(user=self.other_user, name='Other Habit', daily_goal=1)
        
        response = self.client.get(self.list_url)
        self.assertEqual(len(response.data['results']), 1)
        self.assertEqual(response.data['results'][0]['title'], 'My Habit')
    
    def test_update_and_delete(self):
        """Test updating and deleting habits."""
        habit = Habit.objects.create(user=self.user, name='Test', daily_goal=5)
        
        url = f'/api/habits/{habit.id}/'
        response = self.client.patch(url, {'currentValue': 3}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['currentValue'], 3)
        
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Habit.objects.filter(id=habit.id).exists())
    
    def test_complete_habit_integration(self):
        """Test habit completion integrates with Progress model."""
        from penguin_app.models.user_models import UserGameProfile
        from penguin_app.models.progress_models import Progress
        
        profile, _ = UserGameProfile.objects.get_or_create(user=self.user)
        initial_coins = profile.fish_coins
        
        habit = Habit.objects.create(
            user=self.user,
            name='Run',
            daily_goal=1,
            reward=10
        )
        
        url = f'/api/habits/{habit.id}/complete/'
        response = self.client.post(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['new_completion'])
        self.assertEqual(response.data['coins_earned'], 10)
        
        # Verify Progress updated
        profile.refresh_from_db()
        self.assertEqual(profile.fish_coins, initial_coins + 10)
        
        week_start = date.today() - timedelta(days=date.today().weekday())
        progress = Progress.objects.get(profile=profile, week_start=week_start)
        self.assertEqual(progress.habits_completed, 1)
        self.assertEqual(progress.fish_coins_earned, 10)
    
    def test_no_duplicate_coin_rewards(self):
        """Test coins awarded only once per day."""
        from penguin_app.models.user_models import UserGameProfile
        
        profile, _ = UserGameProfile.objects.get_or_create(user=self.user)
        initial_coins = profile.fish_coins
        
        habit = Habit.objects.create(user=self.user, name='Water', daily_goal=8, reward=5)
        url = f'/api/habits/{habit.id}/complete/'
        
        self.client.post(url)
        response = self.client.post(url)
        
        self.assertFalse(response.data['new_completion'])
        self.assertEqual(response.data['coins_earned'], 0)
        
        profile.refresh_from_db()
        self.assertEqual(profile.fish_coins, initial_coins + 5)
