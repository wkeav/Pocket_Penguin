from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils import timezone
import uuid

""" 
    User models for Pocket Penguin application.
    
    This module defines the core user authentication and game profile models
    that handle user registration, security, and game progression tracking.

    Models:
    User: Extended Django AbstractUser with additional security features
            and profile information for user authentication and management.
    
    UserGameProfile: Game-specific data and statistics linked to each user
                    via OneToOne relationship.
                    
    Security Features:
    - Email verification with secure tokens
    - Password reset with expiration
    - Failed login attempt tracking
    - Account locking mechanism
    - IP address logging for security audits
    
    Database Design:
    - User table: Core authentication and profile data
    - UserGameProfile table: Game statistics and progression
    - OneToOne relationship ensures data integrity

Author: Astra
"""
class User(AbstractUser):
    id = models.UUIDField(primary_key=True,default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True)
    username = models.CharField(max_length=150, unique=True)
    
    # Store secure token for email verification
    is_verified = models.BooleanField(default=False)
    verification_token = models.CharField(max_length=100,blank=True)
    
    # Store secure token for password reset 
    password_reset_token = models.CharField(max_length=100,blank=True)
    password_reset_expires = models.DateTimeField(null=True,blank=True)
    verification_token_expires = models.DateTimeField(null=True, blank=True)
    
    # Timestamps 
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_login_ip = models.GenericIPAddressField(null=True, blank=True)
    
    # Profile views 
    profile_picture = models.URLField(blank=True,null=True)
    bio = models.TextField(max_length=700,blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    
    # Security tracking
    failed_login_attempts = models.IntegerField(default=0)
    locked_until = models.DateTimeField(null=True, blank=True)
    
    # Override AbstractUser fields to avoid related_name conflicts
    groups = models.ManyToManyField(
        'auth.Group',
        verbose_name='groups',
        blank=True,
        help_text='The groups this user belongs to. A user will get all permissions granted to each of their groups.',
        related_name="penguin_user_set",
        related_query_name="penguin_user",
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        verbose_name='user permissions',
        blank=True,
        help_text='Specific permissions for this user.',
        related_name="penguin_user_set",
        related_query_name="penguin_user",
    )
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username'] 
    
    # Sets the database table name
    class Meta:
        db_table = 'users'
        verbose_name = 'User' # updates in Django admin
        verbose_name_plural = 'Users' # updates in Django admin
    
    def __str__(self):
        return self.email
    

# User game profile table 
class UserGameProfile(models.Model):
    # Each user has one profile, and if user is deleted then delete their profile too
    user = models.OneToOneField(User, on_delete=models.CASCADE,related_name='profile') 
    
    fish_coins = models.IntegerField(default=0)
    level = models.IntegerField(default=1)
    streak_days = models.IntegerField(default=0)
    total_habits = models.IntegerField(default=0)
    completed_tasks = models.IntegerField(default=0)
    notification_settings = models.JSONField(default=dict)
    
    # TimeStamp
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'user_game_profiles'
    def __str__(self):
        return f"{self.user.email}'s Profile"
