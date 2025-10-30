"""
Unit tests for user authentication feature in Pocket Penguin.

Author: Astra
"""
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.db import IntegrityError
from ..models.user_models import UserGameProfile
from ..serializers.user_serializers import UserRegistrationSerializer

User = get_user_model()


class UserRegistrationSerializerTests(TestCase):
    """Tests for UserRegistrationSerializer."""
    
    def setUp(self):
        """Set up test data."""
        self.valid_data = {
            'email': 'test@example.com',
            'username': 'testuser',
            'password': 'Pass123!',
            'password_confirm': 'Pass123!'
        }
    
    def test_valid_registration_creates_user(self):
        """Test that valid data creates a user successfully."""
        serializer = UserRegistrationSerializer(data=self.valid_data)
        self.assertTrue(serializer.is_valid(), f"Errors: {serializer.errors}")
        
        user = serializer.save()
        self.assertIsNotNone(user.id)
        self.assertEqual(user.email, 'test@example.com')
        self.assertEqual(user.username, 'testuser')
        self.assertTrue(user.check_password('Pass123!'))
    
    def test_password_is_hashed(self):
        """Test that password is hashed securely."""
        serializer = UserRegistrationSerializer(data=self.valid_data)
        self.assertTrue(serializer.is_valid())
        
        user = serializer.save()
        self.assertNotEqual(user.password, 'Pass123!')
        self.assertTrue(user.check_password('Pass123!'))
    
    def test_user_game_profile_created(self):
        """Test that UserGameProfile is created automatically."""
        serializer = UserRegistrationSerializer(data=self.valid_data)
        self.assertTrue(serializer.is_valid())
        
        user = serializer.save()
        self.assertTrue(hasattr(user, 'profile'))
        self.assertIsInstance(user.profile, UserGameProfile)
    
    def test_passwords_must_match(self):
        """Test that passwords must match."""
        data = self.valid_data.copy()
        data['password_confirm'] = 'DifferentPass123!'
        
        serializer = UserRegistrationSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn('non_field_errors', serializer.errors)



class UserModelTests(TestCase):
    """Tests for User model."""
    
    def test_user_creation(self):
        """Test basic user creation."""
        user = User.objects.create_user(
            email='user@example.com',
            username='testuser',
            password='TestPass123!'
        )
        
        self.assertIsNotNone(user.id)
        self.assertEqual(user.email, 'user@example.com')
        self.assertTrue(user.check_password('TestPass123!'))

class UserGameProfileTests(TestCase):
    """Tests for UserGameProfile."""
    
    def setUp(self):
        """Set up test user."""
        self.user = User.objects.create_user(
            email='test@example.com',
            username='testuser',
            password='TestPass123!'
        )
    
    def test_profile_creation(self):
        """Test profile can be created."""
        profile = UserGameProfile.objects.create(user=self.user)
        
        self.assertIsNotNone(profile.id)
        self.assertEqual(profile.user, self.user)
        self.assertEqual(profile.level, 1)
        self.assertEqual(profile.fish_coins, 0)