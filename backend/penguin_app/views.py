"""
API views for user authentication in Pocket Penguin.

<<<<<<< HEAD:backend/penguin_app/views.py
# Create your views here.
=======
This module provides REST API endpoints for:
- User registration
- User login with JWT tokens
- Token refresh
- User profile management (get and update)

Security Features:
- JWT-based authentication
- Password hashing via Django's built-in methods
- Automatic UserGameProfile creation on registration

Author: Astra
"""

from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenRefreshView, TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.views import APIView 
from django.contrib.auth import get_user_model
from django.contrib.auth import authenticate
from django.utils import timezone

from ..serializers.user_serializers import UserRegistrationSerializer, UserProfileSerializer, CustomTokenObtainPairSerializer, UserGameProfileSerializer

User = get_user_model()

class RegisterView(generics.CreateAPIView):
    """
    User registration endpoint.
    
    Creates a new user account and automatically initializes their
    UserGameProfile. Password is validated and hashed automatically
    via the serializer
    
    See API.md for complete request/response documentation.
    """
    queryset = User.objects.all()
    serializer_class = UserRegistrationSerializer
    permission_classes = [permissions.AllowAny]  # Anyone can register
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Return user data (excluding password)
        response_data = {
            'id': str(user.id),
            'email': user.email,
            'username': user.username,
            'message': 'User registered successfully!'
        }
        return Response(response_data, status=status.HTTP_201_CREATED)

class LoginView(TokenObtainPairView):
    """
    User login endpoint that returns JWT tokens.
        
    Authenticates user credentials and returns access/refresh token pair.
    Automatically handles password validation and token generation.
    
    See API.md for complete request/response documentation.
    """
    serializer_class = CustomTokenObtainPairSerializer
    permission_classes = [permissions.AllowAny]
    
    def post(self, request, *args, **kwargs):
        """
        Returns tokens plus user information including is_verified status.
        """
        
        # Get the default response from parent (TokenObtainPairView)
        response = super().post(request, *args, **kwargs)
        
        # Add user's profile 
        if response.status_code == 200:
            # Get serializer to access authenticated user
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid()
            
            user = serializer.user 
            response.data['user'] = {
                "id": str(user.id),
                "email": user.email,
                "username": user.username,
                "is_verified": user.is_verified
            }
        return response 
    
class CurrentUserView(generics.RetrieveUpdateAPIView):
    """
    Get and update current authenticated user's profile.
    
    Supports:
    - GET: Retrieve current user's profile information
    - PUT/PATCH: Update current user's profile (username, bio, profile_picture, date_of_birth)
    
    Requires JWT authentication.
    See API.md for complete request/response documentation.
    """
    
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self):
        """Return the current authenticated user."""
        return self.request.user

class CurrentUserGameProfile(generics.RetrieveAPIView):
    """
    Get current authenticated user's game profile.
    
    Returns game statistics (fish_coins, level, streak_days, etc.)
    for the authenticated user making the request.
    
    Requires JWT authentication.
    See API.md for complete request/response documentation.
    """
    
    serializer_class = UserGameProfileSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self):
        """Return the current authenticated user's game profile."""
        # Access game profile via the OneToOne relationship
        return self.request.user.profile 
    
class LogOutView(APIView):
    """
    User logout endpoint.
    
    Invalidates the refresh token and logs out the user.
    Client should delete access token from storage.
    
    Requires JWT authentication.
    See API.md for complete request/response documentation.
    """
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        """Logout user. Return successful messages."""
        return Response(
            {'message': 'Successfully logged out.'},
            status=status.HTTP_200_OK
        )
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95:backend/penguin_app/views/user_views.py
