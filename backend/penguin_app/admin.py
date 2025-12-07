from django.contrib import admin
from .models.user_models import User, UserGameProfile
from .models.journal_entry_model import JournalEntry
from .models.progress_models import Progress
from .models.calendar_models import CalendarEvent

# User Management
@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('username', 'email', 'is_verified', 'created_at')
    list_filter = ('is_verified', 'created_at')
    search_fields = ('username', 'email')
    readonly_fields = ('created_at', 'updated_at', 'id')

@admin.register(UserGameProfile)
class UserGameProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'level', 'streak_days', 'created_at')
    list_filter = ('created_at', 'level')
    search_fields = ('user__username', 'user__email')

# Journal Management
@admin.register(JournalEntry)
class JournalEntryAdmin(admin.ModelAdmin):
    list_display = ('user', 'date', 'mood', 'created_at')
    list_filter = ('mood', 'date', 'created_at')
    search_fields = ('user__username', 'content')
    readonly_fields = ('created_at', 'updated_at', 'id')

# Progress Management
@admin.register(Progress)
class ProgressAdmin(admin.ModelAdmin):
    list_display = ('profile', 'week_start', 'completion_rate', 'created_at')
    list_filter = ('created_at', 'completion_rate')
    search_fields = ('profile__user__username',)

# Calendar Management
@admin.register(CalendarEvent)
class CalendarEventAdmin(admin.ModelAdmin):
    list_display = ('user', 'title', 'start_time', 'end_time')
    list_filter = ('start_time', 'user')
    search_fields = ('user__username', 'title', 'description')
    readonly_fields = ('user',)
