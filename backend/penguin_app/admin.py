from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.admin import AdminSite
from .models.user_models import User, UserGameProfile
from .models import CalendarEvent
from django.utils.html import format_html
from django.utils import timezone


# Custom Admin Site with dashboard stats
class PocketPenguinAdminSite(AdminSite):
    site_header = "🐧 Pocket Penguin Administration"
    site_title = "Pocket Penguin Admin"
    index_title = "Welcome to Pocket Penguin Admin Dashboard"
    
    def index(self, request, extra_context=None):
        # Add custom statistics to the dashboard
        extra_context = extra_context or {}
        extra_context['user_count'] = User.objects.count()
        extra_context['verified_count'] = User.objects.filter(is_verified=True).count()
        extra_context['profile_count'] = UserGameProfile.objects.count()
        return super().index(request, extra_context)

# Use custom admin site
admin_site = PocketPenguinAdminSite(name='admin')


## Built in web interface for managing databases 
@admin.register(User, site=admin_site)
class UserAdmin(BaseUserAdmin):
    """Enhanced admin interface for User model with better UI."""
    
    # Customize list display with color coding
    list_display = [
        'email_display', 
        'username', 
        'verification_status', 
        'staff_status',
        'active_status', 
        'created_display',
        'last_login_display'
    ]
    list_filter = ['is_verified', 'is_staff', 'is_active', 'created_at', 'last_login']
    search_fields = ['email', 'username', 'id']
    ordering = ['-created_at']
    readonly_fields = ['id', 'created_at', 'updated_at', 'last_login', 'date_joined']
    
    # Enhanced display with icons and colors
    def email_display(self, obj):
        return format_html(
            '<strong style="color: #1e3a8a;">📧 {}</strong>',
            obj.email
        )
    email_display.short_description = 'Email Address'
    
    def verification_status(self, obj):
        if obj.is_verified:
            return format_html(
                '<span style="color: #16a34a; font-weight: bold;">✅ Verified</span>'
            )
        else:
            # Check if token expired
            if obj.verification_token_expires and obj.verification_token_expires < timezone.now():
                return format_html(
                    '<span style="color: #dc2626; font-weight: bold;">Expired</span>'
                )
            return format_html(
                '<span style="color: #ea580c; font-weight: bold;">Pending</span>'
            )
    verification_status.short_description = 'Email Status'
    
    def staff_status(self, obj):
        if obj.is_staff:
            return format_html(
                '<span style="color: #7c3aed; font-weight: bold;">Admin</span>'
            )
        return format_html(
            '<span style="color: #64748b;">User</span>'
        )
    staff_status.short_description = 'Role'
    
    def active_status(self, obj):
        if obj.is_active:
            return format_html(
                '<span style="color: #16a34a;">Active</span>'
            )
        return format_html(
            '<span style="color: #dc2626;">Inactive</span>'
        )
    active_status.short_description = 'Status'
    
    def created_display(self, obj):
        return format_html(
            '<span style="color: #64748b;">{}</span>',
            obj.created_at.strftime('%b %d, %Y')
        )
    created_display.short_description = 'Joined'
    
    def last_login_display(self, obj):
        if obj.last_login:
            return format_html(
                '<span style="color: #64748b;">{}</span>',
                obj.last_login.strftime('%b %d, %Y %H:%M')
            )
        return format_html('<span style="color: #94a3b8;">Never</span>')
    last_login_display.short_description = 'Last Login'
    
    fieldsets = (
        ('Account Information', {
            'fields': ('id', 'email', 'username', 'password'),
            'description': 'Core user authentication details'
        }),
        ('Personal Information', {
            'fields': ('bio', 'profile_picture', 'date_of_birth'),
            'classes': ('collapse',),
        }),
        ('Permissions', {
            'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions'),
            'classes': ('collapse',),
        }),
        ('Email Verification', {
            'fields': ('is_verified', 'verification_token_expires'),
            'description': 'Email verification status and expiry'
        }),
        ('Security & Tracking', {
            'fields': ('failed_login_attempts', 'locked_until', 'last_login_ip'),
            'classes': ('collapse',),
        }),
        ('Important Dates', {
            'fields': ('last_login', 'date_joined', 'created_at', 'updated_at'),
            'classes': ('collapse',),
        }),
    )
    
    add_fieldsets = (
        ('Create New User', {
            'classes': ('wide',),
            'fields': ('email', 'username', 'password1', 'password2'),
            'description': 'Enter user details to create a new account'
        }),
    )

@admin.register(UserGameProfile, site=admin_site)
class UserGameProfileAdmin(admin.ModelAdmin):
    """Enhanced admin interface for UserGameProfile model."""
    
    list_display = [
        'user_display', 
        'coins_display', 
        'level_display', 
        'streak_display', 
        'habits_display',
        'tasks_display', 
        'created_display'
    ]
    list_filter = ['level', 'created_at']
    search_fields = ['user__email', 'user__username']
    readonly_fields = ['created_at', 'updated_at']
    
    # Enhanced display with icons and formatting
    def user_display(self, obj):
        return format_html(
            '<strong style="color: #1e3a8a;"> {}</strong>',
            obj.user.email
        )
    user_display.short_description = 'User'
    
    def coins_display(self, obj):
        return format_html(
            '<span style="color: #eab308; font-weight: bold;">{} coins</span>',
            obj.fish_coins
        )
    coins_display.short_description = 'Fish Coins'
    
    def level_display(self, obj):
        # Color based on level
        if obj.level >= 10:
            color = '#dc2626'  # red for high level
        elif obj.level >= 5:
            color = '#ea580c'  # orange for medium
        else:
            color = '#16a34a'  # green for beginner
        return format_html(
            '<span style="color: {}; font-weight: bold;"> Level {}</span>',
            color, obj.level
        )
    level_display.short_description = 'Level'
    
    def streak_display(self, obj):
        if obj.streak_days >= 7:
            return format_html(
                '<span style="color: #dc2626; font-weight: bold;"> {} days</span>',
                obj.streak_days
            )
        elif obj.streak_days >= 3:
            return format_html(
                '<span style="color: #ea580c; font-weight: bold;"> {} days</span>',
                obj.streak_days
            )
        else:
            return format_html(
                '<span style="color: #64748b;"> {} days</span>',
                obj.streak_days
            )
    streak_display.short_description = 'Streak'
    
    def habits_display(self, obj):
        return format_html(
            '<span style="color: #7c3aed;"> {}</span>',
            obj.total_habits
        )
    habits_display.short_description = 'Habits'
    
    def tasks_display(self, obj):
        return format_html(
            '<span style="color: #16a34a;"> {}</span>',
            obj.completed_tasks
        )
    tasks_display.short_description = 'Completed'
    
    def created_display(self, obj):
        return format_html(
            '<span style="color: #64748b;"> {}</span>',
            obj.created_at.strftime('%b %d, %Y')
        )
    created_display.short_description = 'Created'
    
    fieldsets = (
        ('User Profile', {
            'fields': ('user',),
            'description': 'Associated user account'
        }),
        ('Game Statistics', {
            'fields': ('fish_coins', 'level', 'streak_days', 'total_habits', 'completed_tasks'),
            'description': 'In-game progress and achievements'
        }),
        ('Settings', {
            'fields': ('notification_settings',),
            'classes': ('collapse',),
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',),
        }),
    )

# Register CalendarEvent to custom admin site
@admin.register(CalendarEvent, site=admin_site)
class CalendarEventAdmin(admin.ModelAdmin):
    list_display = ('title', 'start_time', 'end_time', 'get_user')

    # Show the username in admin instead of the raw user object
    def get_user(self, obj):
        return obj.user.username  # or str(obj.user) if username doesn't exist
    get_user.short_description = 'User'
