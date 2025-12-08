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
    "Tests for Habit API endpoints."
    
    def setUp(self):
        "Set up test client and authentication."
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='testuser@example.com',
            username='testuser',
            password='TestPass123!'
        )
        self.other_user = User.objects.create_user(
            email='otheruser@example.com',
            username='otheruser',
            password='TestPass123!'
        )
        
        # Authenticate the main test user
        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        
        self.list_url = '/api/habits/'
        self.valid_habit_data = {
            'title': 'Exercise',
            'description': 'Daily workout',
            'category': 'Fitness',
            'icon': 'fitness_center',
            'color': 'green',
            'targetValue': 1,
            'unit': 'session',
            'currentValue': 0,
            'reward': 15,
            'streak': 0
        }
    
    def test_list_habits_authenticated(self):
        "Test authenticated user can list their habits."
        # Clear any existing habits first
        Habit.objects.all().delete()
        
        Habit.objects.create(
            user=self.user,
            name='Drink Water',
            daily_goal=8,
            unit='glasses',
            reward=5
        )
        
        response = self.client.get(self.list_url)
        
        # Debug: print what we got
        print(f"\nTotal habits in DB: {Habit.objects.count()}")
        print(f"Habits returned by API: {len(response.data)}")
        for habit_data in response.data:
            print(f"  - {habit_data['title']} (user: {habit_data.get('user', 'N/A')})")
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['title'], 'Drink Water')
    
    def test_list_habits_unauthenticated(self):
        "Test unauthenticated user cannot list habits."
        self.client.credentials()  # Remove authentication
        response = self.client.get(self.list_url)
        
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
    
    def test_create_habit_success(self):
        "Test authenticated user can create a habit."
        response = self.client.post(self.list_url, self.valid_habit_data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('id', response.data)
        self.assertEqual(response.data['title'], 'Exercise')
        self.assertEqual(response.data['targetValue'], 1)
        self.assertEqual(response.data['unit'], 'session')
        self.assertEqual(response.data['reward'], 15)
        
        # Verify habit is created in database
        habit = Habit.objects.get(id=response.data['id'])
        self.assertEqual(habit.user, self.user)
        self.assertEqual(habit.name, 'Exercise')
    
    def test_create_habit_invalid_daily_goal(self):
        "Test creating habit with invalid daily_goal."
        invalid_data = self.valid_habit_data.copy()
        invalid_data['targetValue'] = 0
        
        response = self.client.post(self.list_url, invalid_data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    def test_user_can_only_see_own_habits(self):
        "Test users can only see their own habits."
        # Create habit for main user
        Habit.objects.create(
            user=self.user,
            name='User Habit',
            daily_goal=5,
            reward=5
        )
        
        # Create habit for other user
        Habit.objects.create(
            user=self.other_user,
            name='Other User Habit',
            daily_goal=3,
            reward=5
        )
        
        response = self.client.get(self.list_url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['title'], 'User Habit')
    
    def test_retrieve_habit_success(self):
        "Test retrieving a specific habit."
        habit = Habit.objects.create(
            user=self.user,
            name='Meditation',
            daily_goal=10,
            unit='minutes',
            reward=8
        )
        
        url = f'/api/habits/{habit.id}/'
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['title'], 'Meditation')
        self.assertEqual(response.data['id'], str(habit.id))
    
    def test_retrieve_other_user_habit_fails(self):
        "Test user cannot retrieve another user's habit."
        habit = Habit.objects.create(
            user=self.other_user,
            name='Other Habit',
            daily_goal=5,
            reward=5
        )
        
        url = f'/api/habits/{habit.id}/'
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
    
    def test_update_habit_success(self):
        "Test updating a habit."
        habit = Habit.objects.create(
            user=self.user,
            name='Reading',
            daily_goal=30,
            today_count=0,
            unit='minutes',
            reward=10
        )
        
        url = f'/api/habits/{habit.id}/'
        update_data = {'currentValue': 15}
        
        response = self.client.patch(url, update_data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['currentValue'], 15)
        
        # Verify in database
        habit.refresh_from_db()
        self.assertEqual(habit.today_count, 15)
    
    def test_update_habit_full(self):
        "Test full update of a habit (PUT)."
        habit = Habit.objects.create(
            user=self.user,
            name='Steps',
            daily_goal=10000,
            unit='steps',
            reward=10
        )
        
        url = f'/api/habits/{habit.id}/'
        update_data = {
            'title': 'Daily Steps',
            'description': 'Walk more every day',
            'category': 'Fitness',
            'icon': 'directions_walk',
            'color': 'blue',
            'targetValue': 12000,
            'unit': 'steps',
            'currentValue': 5000,
            'reward': 12,
            'streak': 3
        }
        
        response = self.client.put(url, update_data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['title'], 'Daily Steps')
        self.assertEqual(response.data['targetValue'], 12000)
        self.assertEqual(response.data['currentValue'], 5000)
    
    def test_delete_habit_success(self):
        "Test deleting a habit."
        habit = Habit.objects.create(
            user=self.user,
            name='Test Habit',
            daily_goal=5,
            reward=5
        )
        
        url = f'/api/habits/{habit.id}/'
        response = self.client.delete(url)
        
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Habit.objects.filter(id=habit.id).exists())
    
    def test_archived_habits_not_listed(self):
        "Test archived habits don't appear in list view."
        Habit.objects.create(
            user=self.user,
            name='Active Habit',
            daily_goal=5,
            reward=5
        )
        Habit.objects.create(
            user=self.user,
            name='Archived Habit',
            daily_goal=5,
            reward=5,
            is_archived=True
        )
        
        response = self.client.get(self.list_url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['title'], 'Active Habit')
    
    def test_habit_progress_calculation(self):
        "Test progress field is calculated correctly."
        habit = Habit.objects.create(
            user=self.user,
            name='Water',
            daily_goal=8,
            today_count=4,
            unit='glasses',
            reward=5
        )
        
        url = f'/api/habits/{habit.id}/'
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['progress'], 0.5)
    
    def test_habit_serializer_field_mapping(self):
        "Test serializer correctly maps backend to frontend field names."
        habit = Habit.objects.create(
            user=self.user,
            name='Test Habit',
            daily_goal=10,
            today_count=5,
            unit='reps',
            reward=8,
            streak=2
        )
        
        url = f'/api/habits/{habit.id}/'
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Check frontend field names
        self.assertIn('title', response.data)
        self.assertIn('targetValue', response.data)
        self.assertIn('currentValue', response.data)
        self.assertEqual(response.data['title'], 'Test Habit')
        self.assertEqual(response.data['targetValue'], 10)
        self.assertEqual(response.data['currentValue'], 5)
    
    def test_week_progress_field_exists(self):
        "Test weekProgress field is included in response."
        habit = Habit.objects.create(
            user=self.user,
            name='Test Habit',
            daily_goal=5,
            reward=5
        )
        
        url = f'/api/habits/{habit.id}/'
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('weekProgress', response.data)
        self.assertIsInstance(response.data['weekProgress'], list)
        self.assertEqual(len(response.data['weekProgress']), 7)
