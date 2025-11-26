from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from ..models.user_models import UserGameProfile

"""
Django REST Framework serializers for user authentication and management in the Pocket Penguin API.

This module handles data validation, serialization, and deserialization for:
- User registration with email verification
- Password strength validation  
- Username uniqueness and format validation
- Secure password confirmation matching

Security considerations:
- Passwords are write-only and validated using Django's built-in validators
- Email addresses are normalized to lowercase for consistency
- Usernames are validated for uniqueness and format compliance

Author: Astra
"""

User = get_user_model()
class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for user registration data validation."""
    
    password = serializers.CharField(
        write_only = True,
        required = True,
        style = {'input_type': 'password'},
        validators = [validate_password]
    )
    
    password_confirm = serializers.CharField(
        write_only = True,
        required = True,
        style = {'input_type': 'password'}
    )
    
    class Meta:
        model = User
        fields = ['id', 'email', 'username', 'password' , 'password_confirm']
        read_only_fields = ['id'] # id is auto-generated, ensure user can't modify it 
        extra_kwargs = {
            'email': {'required': True, 'allow_blank': False},
            'username': {'required': True, 'allow_blank': False, 'min_length': 5}
        }
        
    def validate_email(self,value):
        """Validate user email."""
        value = value.lower()
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("A user with this email already exists.")
        return value
    
    def validate_username(self,value):
        """Check username format."""
        value = value.lower()
        if not value.replace('_', '').replace('-', '').isalnum():
            raise serializers.ValidationError("Username can only contain letters, numbers, underscores, and hyphens.")
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("A user with this username already exists.")
        return value
    
    def validate(self,data):
        """Validate password confirmation matching."""
        password = data.get('password')
        password_confirmed = data.get('password_confirm')
        
        if password != password_confirmed:
            raise serializers.ValidationError('Passwords do not match, try again!')
        
        return data 
    
    def create(self,validated_data):
        """Create user register in the database."""
        # Remove password_confirm from validated_data as it's not a model field
        validated_data.pop('password_confirm', None)
        
        # Extract password before creating user for security reason 
        password = validated_data.pop('password')
        
        user = User.objects.create_user(**validated_data) # create user info from user model + validated data from this file
        
        # Set the password using Django's built-in hashing for security 
        user.set_password(password)
        user.save()
        
        # Create associated UserGameProfile
        UserGameProfile.objects.create(user=user) #linking the game profile to this specific user
        
        return user
    
class UserProfileSerializer(serializers.ModelSerializer):
    """Serializer for reading/updating user profile data ."""
    
    class Meta:
        model = User 
        
        #PUT request (note: Id, email, is_verified, created_at, updated_at is read only)
        fields = [
            'id', 
            'email', 
            'username', 
            'is_verified',
            'profile_picture',
            'bio',
            'date_of_birth',
            'created_at',
            'updated_at'
        ]
        # GET request (read only)
        read_only_fields = ['id', 'email', 'is_verified', 'created_at', 'updated_at']
        extra_kwargs = {
            "bio": {'max_length': 700}, # Match model constraint
            "username": {'min_length': 5}
        }
        
    def validate_username(self,value):
        """Validate username on update (check uniqueness if changed)."""
        value = value.lower()
        
        user = self.instance 
        if user and user.username.lower() == value:
            return value 
        
        # Check format 
        if not value.replace('_', '').replace('-', '').isalnum():
            raise serializers.ValidationError(
                "Username can only contain letters, numbers, underscores, and hyphens."
            )
        
        # Check uniqueness (if changed or new)
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError(
                "A user with this username already exists."
            )
        
        return value
    
    def validate_profile_picture(self, value):
        """Validate profile picture URL format."""
        if value and not (value.startswith('http://') or value.startswith('https://')):
            raise serializers.ValidationError(
                "Profile picture must be a valid HTTP/HTTPS URL."
            )
        return value

    def validate_date_of_birth(self, value):
        """Validate date of birth is in the past and reasonable."""
        if value: 
            from django.utils import timezone 
            today = timezone.now().date()
            
            # Must be in the past
            if value >= today:
                raise serializers.ValidationError(
                    "Date of birth must be in the past."
                )
                
            # Age check 
            age = (today - value).days / 365.25
            if age < 5:
                raise serializers.ValidationError(
                    "User must be at least 5 years old."
                )
            if age > 150:
                raise serializers.ValidationError(
                    "Please enter a valid date of birth."
                )
        return value 

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Custom serializer that uses email instead of username for login."""
    
    username_field = 'email'  # Use email instead of username
    
    def validate(self, attrs):
        # Convert email to lowercase for case-insensitive login
        if 'email' in attrs:
            attrs['email'] = attrs['email'].lower().strip()
        
        # This will use email to find the user
        data = super().validate(attrs)
        return data
        
class UserGameProfileSerializer(serializers.ModelSerializer):
    """Serializer for reading user game profile data."""
    
    class Meta:
        model = UserGameProfile
        fields = [
            'fish_coins',
            'level',
            'streak_days',
            'total_habits',
            'completed_tasks',
            'notification_settings',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']  # Timestamps are auto-generated
        
        
        
    