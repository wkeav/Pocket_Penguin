from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views.user_views import RegisterView, LoginView, CurrentUserView, CurrentUserGameProfile, LogOutView
<<<<<<< HEAD
from .views.calendar_views import CalendarEventListCreate, CalendarEventRetrieveUpdateDestroy
=======
from .views.journal_views import JournalEntryListCreateView, JournalEntryDetailView
from penguin_app.views.progress_views import WeeklyProgressView, MonthlyProgressView, AllTimeProgressView

>>>>>>> origin/main

app_name = 'penguin_app'

urlpatterns = [
    # User Management
    path('users/', RegisterView.as_view(), name='register'),
    path('users/me/', CurrentUserView.as_view(), name='current-user'),
    path('users/me/game-profile/', CurrentUserGameProfile.as_view(), name='current-user-game-profile'),
    
    # Authentication
    path('auth/token/', LoginView.as_view(), name='token_obtain_pair'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/token/revoke/', LogOutView.as_view(), name='token_revoke'),
<<<<<<< HEAD
=======
    
    # Journal feature
    path('journal/', JournalEntryListCreateView.as_view(), name='journal-list-create'),
    path('journal/<uuid:pk>/', JournalEntryDetailView.as_view(), name='journal-detail'),
    
    # Progress and stats
    path("api/progress/weekly/", WeeklyProgressView.as_view(), name="weekly-progress"),
    path("api/progress/monthly/", MonthlyProgressView.as_view(), name="monthly-progress"),
    path("api/progress/all-time/", AllTimeProgressView.as_view(), name="all-time-progress"),
]
>>>>>>> origin/main

    # Calendar Events
    path('calendar/events/', CalendarEventListCreate.as_view(), name='calendar-list-create'),
    path('calendar/events/<int:pk>/', CalendarEventRetrieveUpdateDestroy.as_view(), name='calendar-detail'),
]
