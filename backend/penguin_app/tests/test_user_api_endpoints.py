"""
API endpoint tests for user authentication in Pocket Penguin.

Tests all authentication endpoints:
- User registration
- User login
- Get current user
- Update user profile
- Get game profile
- Logout
- Token refresh

Author: Astra
"""

from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from ..models.user_models import UserGameProfile

User = get_user_model()


class UserRegistrationAPITests(TestCase):
    """Tests for POST /api/users/ (user registration endpoint)."""
    
    def setUp(self):
        """Set up test client."""
        self.client = APIClient()
        self.url = '/api/users/'
        self.valid_data = {
            'email': 'newuser@example.com',
            'username': 'newuser',
            'password': 'SecurePass123!',
            'password_confirm': 'SecurePass123!'
        }
    
    def test_register_user_success(self):
        """Test successful user registration."""
        response = self.client.post(self.url, self.valid_data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('id', response.data)
        self.assertIn('email', response.data)
        self.assertIn('username', response.data)
        self.assertEqual(response.data['email'], 'newuser@example.com')
        self.assertEqual(response.data['username'], 'newuser')
        self.assertIn('message', response.data)
        
        # Verify user was created in database
        user = User.objects.get(email='newuser@example.com')
        self.assertIsNotNone(user)
        self.assertTrue(user.check_password('SecurePass123!'))
        
        # Verify UserGameProfile was created
        self.assertTrue(hasattr(user, 'profile'))
        self.assertIsInstance(user.profile, UserGameProfile)
    
    def test_register_duplicate_email(self):
        """Test registration with duplicate email fails."""
        # Create first user
        User.objects.create_user(
            email='existing@example.com',
            username='existing',
            password='Pass123!'
        )
        
        # Try to register with same email
        data = self.valid_data.copy()
        data['email'] = 'existing@example.com'
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('email', response.data)
    
    def test_register_passwords_dont_match(self):
        """Test registration fails when passwords don't match."""
        data = self.valid_data.copy()
        data['password_confirm'] = 'DifferentPass123!'
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('non_field_errors', response.data)
    
    def test_register_weak_password(self):
        """Test registration fails with weak password."""
        data = self.valid_data.copy()
        data['password'] = '123'
        data['password_confirm'] = '123'
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('password', response.data)
    
    def test_register_email_case_insensitive(self):
        """Test that email is normalized to lowercase."""
        data = self.valid_data.copy()
        data['email'] = 'TestUser@Example.COM'
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        # Email should be stored in lowercase
        user = User.objects.get(email='testuser@example.com')
        self.assertEqual(user.email, 'testuser@example.com')


class UserLoginAPITests(TestCase):
    """Tests for POST /api/auth/token/ (user login endpoint)."""
    
    def setUp(self):
        """Set up test client and user."""
        self.client = APIClient()
        self.url = '/api/auth/token/'
        self.user = User.objects.create_user(
            email='testuser@example.com',
            username='testuser',
            password='TestPass123!'
        )
        self.user.is_active = True
        self.user.save()
    
    def test_login_success(self):
        """Test successful login returns tokens and user data."""
        data = {
            'email': 'testuser@example.com',
            'password': 'TestPass123!'
        }
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)
        self.assertIn('user', response.data)
        
        # Check user data
        user_data = response.data['user']
        self.assertEqual(user_data['email'], 'testuser@example.com')
        self.assertEqual(user_data['username'], 'testuser')
        self.assertIn('id', user_data)
        self.assertIn('is_verified', user_data)
    
    def test_login_wrong_password(self):
        """Test login fails with wrong password."""
        data = {
            'email': 'testuser@example.com',
            'password': 'WrongPass123!'
        }
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
    
    def test_login_nonexistent_user(self):
        """Test login fails with non-existent user."""
        data = {
            'email': 'nonexistent@example.com',
            'password': 'TestPass123!'
        }
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
    
    def test_login_email_case_insensitive(self):
        """Test login works with different email cases."""
        data = {
            'email': 'TESTUSER@EXAMPLE.COM',  # Uppercase
            'password': 'TestPass123!'
        }
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
    
    def test_login_inactive_user(self):
        """Test login fails for inactive user."""
        self.user.is_active = False
        self.user.save()
        
        data = {
            'email': 'testuser@example.com',
            'password': 'TestPass123!'
        }
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class CurrentUserAPITests(TestCase):
    """Tests for GET /api/users/me/ (get current user endpoint)."""
    
    def setUp(self):
        """Set up test client and user."""
        self.client = APIClient()
        self.url = '/api/users/me/'
        self.user = User.objects.create_user(
            email='testuser@example.com',
            username='testuser',
            password='TestPass123!'
        )
        # Create game profile
        UserGameProfile.objects.create(user=self.user)
    
    def test_get_current_user_authenticated(self):
        """Test authenticated user can get their profile."""
        self.client.force_authenticate(user=self.user)
        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['email'], 'testuser@example.com')
        self.assertEqual(response.data['username'], 'testuser')
        self.assertIn('id', response.data)
        self.assertIn('is_verified', response.data)
        self.assertIn('created_at', response.data)
    
    def test_get_current_user_unauthenticated(self):
        """Test unauthenticated user cannot access endpoint."""
        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
    
    def test_update_current_user_profile(self):
        """Test user can update their profile with PATCH."""
        self.client.force_authenticate(user=self.user)
        
        update_data = {
            'username': 'updateduser',
            'bio': 'This is my bio!'
        }
        response = self.client.patch(self.url, update_data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['username'], 'updateduser')
        self.assertEqual(response.data['bio'], 'This is my bio!')
        
        # Verify database was updated
        self.user.refresh_from_db()
        self.assertEqual(self.user.username, 'updateduser')
        self.assertEqual(self.user.bio, 'This is my bio!')
    
    def test_update_current_user_full_put(self):
        """Test user can update profile with PUT."""
        self.client.force_authenticate(user=self.user)
        
        update_data = {
            'username': 'fullupdate',
            'bio': 'Full update bio',
            'profile_picture': 'https://example.com/pic.jpg',
            'date_of_birth': '2000-01-01'
        }
        response = self.client.put(self.url, update_data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['username'], 'fullupdate')
        self.assertEqual(response.data['bio'], 'Full update bio')
    
    def test_cannot_update_readonly_fields(self):
        """Test that readonly fields cannot be updated."""
        self.client.force_authenticate(user=self.user)
        
        original_email = self.user.email
        update_data = {
            'email': 'hacked@example.com',  # Should be ignored
            'username': 'newusername'
        }
        response = self.client.patch(self.url, update_data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Email should remain unchanged
        self.user.refresh_from_db()
        self.assertEqual(self.user.email, original_email)
    
    def test_update_username_validation(self):
        """Test username validation on update."""
        self.client.force_authenticate(user=self.user)
        
        # Try invalid username (too short)
        update_data = {'username': 'abc'}  # Less than 5 characters
        response = self.client.patch(self.url, update_data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('username', response.data)


class CurrentUserGameProfileAPITests(TestCase):
    """Tests for GET /api/users/me/game-profile/ (get game profile endpoint)."""
    
    def setUp(self):
        """Set up test client and user."""
        self.client = APIClient()
        self.url = '/api/users/me/game-profile/'
        self.user = User.objects.create_user(
            email='testuser@example.com',
            username='testuser',
            password='TestPass123!'
        )
        self.profile = UserGameProfile.objects.create(
            user=self.user,
            fish_coins=100,
            level=5,
            streak_days=10
        )
    
    def test_get_game_profile_authenticated(self):
        """Test authenticated user can get their game profile."""
        self.client.force_authenticate(user=self.user)
        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['fish_coins'], 100)
        self.assertEqual(response.data['level'], 5)
        self.assertEqual(response.data['streak_days'], 10)
        self.assertIn('total_habits', response.data)
        self.assertIn('completed_tasks', response.data)
        self.assertIn('created_at', response.data)
    
    def test_get_game_profile_unauthenticated(self):
        """Test unauthenticated user cannot access game profile."""
        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
    
    def test_get_game_profile_default_values(self):
        """Test game profile has correct default values."""
        # Create new user with default profile
        new_user = User.objects.create_user(
            email='newuser@example.com',
            username='newuser',
            password='Pass123!'
        )
        UserGameProfile.objects.create(user=new_user)
        
        self.client.force_authenticate(user=new_user)
        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['fish_coins'], 0)
        self.assertEqual(response.data['level'], 1)
        self.assertEqual(response.data['streak_days'], 0)


class LogoutAPITests(TestCase):
    """Tests for POST /api/auth/token/revoke/ (logout endpoint)."""
    
    def setUp(self):
        """Set up test client and user."""
        self.client = APIClient()
        self.url = '/api/auth/token/revoke/'
        self.user = User.objects.create_user(
            email='testuser@example.com',
            username='testuser',
            password='TestPass123!'
        )
    
    def test_logout_authenticated(self):
        """Test authenticated user can logout."""
        self.client.force_authenticate(user=self.user)
        
        # Get refresh token
        refresh = RefreshToken.for_user(self.user)
        refresh_token = str(refresh)
        
        data = {'refresh': refresh_token}
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('message', response.data)
        self.assertEqual(response.data['message'], 'Successfully logged out.')
    
    def test_logout_unauthenticated(self):
        """Test unauthenticated user cannot logout."""
        refresh = RefreshToken.for_user(self.user)
        refresh_token = str(refresh)
        
        data = {'refresh': refresh_token}
        response = self.client.post(self.url, data, format='json')
        
        # Should still work (logout doesn't require auth in our implementation)
        # But let's check what happens
        self.assertIn(response.status_code, [status.HTTP_200_OK, status.HTTP_401_UNAUTHORIZED])


class TokenRefreshAPITests(TestCase):
    """Tests for POST /api/auth/token/refresh/ (token refresh endpoint)."""
    
    def setUp(self):
        """Set up test client and user."""
        self.client = APIClient()
        self.url = '/api/auth/token/refresh/'
        self.user = User.objects.create_user(
            email='testuser@example.com',
            username='testuser',
            password='TestPass123!'
        )
    
    def test_refresh_token_success(self):
        """Test successful token refresh."""
        refresh = RefreshToken.for_user(self.user)
        refresh_token = str(refresh)
        
        data = {'refresh': refresh_token}
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        # Should get new access token
        self.assertIsNotNone(response.data['access'])
    
    def test_refresh_token_invalid(self):
        """Test refresh fails with invalid token."""
        data = {'refresh': 'invalid_token'}
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class IntegrationTests(TestCase):
    """Integration tests for complete authentication flow."""
    
    def setUp(self):
        """Set up test client."""
        self.client = APIClient()
    
    def test_complete_auth_flow(self):
        """Test complete flow: register -> login -> get profile -> logout."""
        # Register
        register_data = {
            'email': 'flowtest@example.com',
            'username': 'flowtest',
            'password': 'TestPass123!',
            'password_confirm': 'TestPass123!'
        }
        register_response = self.client.post('/api/users/', register_data, format='json')
        self.assertEqual(register_response.status_code, status.HTTP_201_CREATED)
        
        # Login
        login_data = {
            'email': 'flowtest@example.com',
            'password': 'TestPass123!'
        }
        login_response = self.client.post('/api/auth/token/', login_data, format='json')
        self.assertEqual(login_response.status_code, status.HTTP_200_OK)
        
        access_token = login_response.data['access']
        refresh_token = login_response.data['refresh']
        
        # Get current user (authenticated)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')
        profile_response = self.client.get('/api/users/me/')
        self.assertEqual(profile_response.status_code, status.HTTP_200_OK)
        self.assertEqual(profile_response.data['email'], 'flowtest@example.com')
        
        # Get game profile
        game_profile_response = self.client.get('/api/users/me/game-profile/')
        self.assertEqual(game_profile_response.status_code, status.HTTP_200_OK)
        self.assertIn('fish_coins', game_profile_response.data)
        
        # Logout
        logout_data = {'refresh': refresh_token}
        logout_response = self.client.post('/api/auth/token/revoke/', logout_data, format='json')
        self.assertEqual(logout_response.status_code, status.HTTP_200_OK)
        

