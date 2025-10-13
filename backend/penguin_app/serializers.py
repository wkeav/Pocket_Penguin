from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password

"""
This file ensure that all data from backend & frontend is properly formatted and valid. 
Flow: Python object -> JSON 
"""

User = get_user_model()
class UserRegistrationSerializer(serializers.ModelSerializer):
    """
    Serializer for user registration.
    """
    
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
        """Check if email is already registered"""
        value = value.lower()
        if User.object.filter(email=value).exists():
            raise serializers.ValidationError("A user with this email already exists.")
        return value
    
    def validate_username(self,value):
        """Check username format"""
        # Only allow alphanumeric, numbers, 
        value = value.lower()
        