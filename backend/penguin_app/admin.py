from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models.user_models import User, UserGameProfile

## Built in web interface for managing databases 
@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """Admin interface for User model."""
    list_display = ['email', 'username', 'is_verified', 'is_staff', 'is_active', 'created_at']
    list_filter = ['is_verified', 'is_staff', 'is_active', 'created_at']
    search_fields = ['email', 'username']
    ordering = ['-created_at']
    readonly_fields = ['id', 'created_at', 'updated_at']  # Add 'id' here
    
    fieldsets = (
        (None, {'fields': ('id', 'email', 'username', 'password')}),  # Add 'id' here
        ('Personal info', {'fields': ('bio', 'profile_picture', 'date_of_birth')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Verification', {'fields': ('is_verified', 'verification_token')}),
        ('Security', {'fields': ('failed_login_attempts', 'locked_until', 'last_login_ip')}),
        ('Important dates', {'fields': ('last_login', 'date_joined', 'created_at', 'updated_at')}),
    )
    
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'username', 'password1', 'password2'),
        }),
    )

@admin.register(UserGameProfile)
class UserGameProfileAdmin(admin.ModelAdmin):
    """Admin interface for UserGameProfile model."""
    list_display = ['user', 'fish_coins', 'level', 'streak_days', 'total_habits', 'completed_tasks', 'created_at']
    list_filter = ['level', 'created_at']
    search_fields = ['user__email', 'user__username']
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('User', {'fields': ('user',)}),
        ('Game Stats', {'fields': ('fish_coins', 'level', 'streak_days', 'total_habits', 'completed_tasks')}),
        ('Settings', {'fields': ('notification_settings',)}),
        ('Timestamps', {'fields': ('created_at', 'updated_at')}),
    )
