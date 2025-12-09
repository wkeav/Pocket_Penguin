import logging
from datetime import timedelta

from django.utils import timezone
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from penguin_app.models.habit_models import Habit
from penguin_app.models.progress_models import Progress
from penguin_app.models.user_models import UserGameProfile
from penguin_app.serializers.habit_serializers import HabitSerializer

logger = logging.getLogger(__name__)


class HabitListCreateView(generics.ListCreateAPIView):
    """
    GET  /api/habits/      -> list habits for the authenticated user
    POST /api/habits/      -> create a new habit for the authenticated user
    """
    serializer_class = HabitSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        """Return only the authenticated user's non-archived habits."""
        return Habit.objects.filter(
            user=self.request.user,
            is_archived=False
        ).order_by("created_at")

    def perform_create(self, serializer):
        """Ensure the habit is always created for the authenticated user."""
        serializer.save(user=self.request.user)


class HabitDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    GET    /api/habits/<uuid:pk>/   -> retrieve a single habit
    PUT    /api/habits/<uuid:pk>/   -> full update
    PATCH  /api/habits/<uuid:pk>/   -> partial update
    DELETE /api/habits/<uuid:pk>/   -> delete habit
    """
    serializer_class = HabitSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        """Restrict to authenticated user's habits."""
        return Habit.objects.filter(user=self.request.user)


class HabitCompleteView(APIView):
    """
    POST /api/habits/<uuid:pk>/complete/
    
    Mark a habit as completed for today.
    - Updates today_count to daily_goal
    - Updates last_completed date
    - Calculates and updates streak
    - Awards fish coins to user's profile
    - Updates weekly Progress model
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk=None):
        try:
            habit = Habit.objects.get(pk=pk, user=request.user)
        except Habit.DoesNotExist:
            logger.warning(f"Habit {pk} not found for user {request.user.id}")
            return Response(
                {"error": "Habit not found."},
                status=status.HTTP_404_NOT_FOUND
            )

        try:
            is_new_completion = habit.complete_for_today()

            if is_new_completion:
                self._award_coins_and_update_progress(request.user, habit)
                message = f"Completed! Earned {habit.reward} coins. Streak: {habit.streak} days."
            else:
                message = "Already completed today."

            serializer = HabitSerializer(habit, context={'request': request})
            return Response({
                "message": message,
                "habit": serializer.data,
                "coins_earned": habit.reward if is_new_completion else 0,
                "new_completion": is_new_completion
            }, status=status.HTTP_200_OK)

        except Exception as e:
            logger.error(f"Error completing habit {pk}: {str(e)}")
            return Response(
                {"error": "Failed to complete habit."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @staticmethod
    def _calculate_completion_rate(user, week_start):
        """
        Calculate weekly completion rate.
        
        completion_rate = habits_completed / total_active_habits
        Returns float between 0.0 and 1.0 (decimal format for Progress model).
        """
        # Count total active habits user had before or during this week
        total_habits = Habit.objects.filter(
            user=user,
            start_date__lte=week_start,
            is_archived=False
        ).count()
        
        if total_habits == 0:
            return 0.0
        
        # Get habits completed this week from Progress
        from penguin_app.models.progress_models import Progress as ProgressModel
        try:
            progress = ProgressModel.objects.get(
                profile=user.profile,
                week_start=week_start
            )
            completion_rate = progress.habits_completed / total_habits
            return min(1.0, completion_rate)  # Cap at 1.0 (100%)
        except ProgressModel.DoesNotExist:
            # If Progress not found yet, return 0
            return 0.0

    @staticmethod
    def _award_coins_and_update_progress(user, habit):
        """Award coins and update weekly progress."""
        profile, _ = UserGameProfile.objects.get_or_create(user=user)
        profile.fish_coins += habit.reward
        profile.save()

        today = timezone.now().date()
        week_start = today - timedelta(days=today.weekday())
        
        progress, _ = Progress.objects.get_or_create(
            profile=profile,
            week_start=week_start,
            defaults={
                'habits_completed': 0,
                'todos_completed': 0,
                'fish_coins_earned': 0,
                'completion_rate': 0.0
            }
        )
        
        progress.habits_completed += 1
        progress.fish_coins_earned += habit.reward
        
        # Calculate and set completion rate
        progress.completion_rate = HabitCompleteView._calculate_completion_rate(
            user,
            week_start
        )
        
        progress.save()
