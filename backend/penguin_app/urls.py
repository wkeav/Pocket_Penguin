"""
URL routing for penguin_app API endpoints.

This module defines all URL patterns for the Pocket Penguin API.
Organized by feature area (users, auth, etc.)

Author: Astra
"""

from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views.user_views import RegisterView, LoginView, CurrentUserView, CurrentUserGameProfile, LogOutView
from .views.calendar_views import calendar_events, calendar_event_detail, calendar_user_profile

app_name = 'penguin_app'

urlpatterns = [
    # User Management
    path('users/', RegisterView.as_view(), name='register'),
    path('users/me/', CurrentUserView.as_view(), name='current-user'),
    path('users/me/game-profile/', CurrentUserGameProfile.as_view(), name='current-user-game-profile'),
    
    path('calendar/events/', calendar_events, name='calendar-events'),
    path('calendar/events/<int:pk>/', calendar_event_detail, name='calendar-event-detail'),
    path('calendar/user/profile/', calendar_user_profile, name='calendar-user-profile'),
    # Authentication
    path('auth/token/', LoginView.as_view(), name='token_obtain_pair'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/token/revoke/', LogOutView.as_view(), name='token_revoke'),
]

