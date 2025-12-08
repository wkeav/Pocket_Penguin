from rest_framework import generics, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from django.utils import timezone
from datetime import timedelta

from penguin_app.models.habit_models import Habit
from penguin_app.models.progress_models import Progress
from penguin_app.serializers.habit_serializers import HabitSerializer


class HabitListCreateView(generics.ListCreateAPIView):
    """
    GET  /api/habits/      -> list habits for the authenticated user
    POST /api/habits/      -> create a new habit for the authenticated user

    The serializer's create() method automatically assigns request.user.
    """

    serializer_class = HabitSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        """
        Limit habits to the currently authenticated user.
        You will always get only your own habits.
        """
        user = self.request.user
        return Habit.objects.filter(user=user, is_archived=False).order_by("created_at")

    def get_serializer_context(self):
        """
        Ensure the serializer has access to the request so it can
        attach request.user in create().
        """
        context = super().get_serializer_context()
        context["request"] = self.request
        return context


class HabitDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    GET    /api/habits/<uuid:pk>/   -> retrieve a single habit
    PUT    /api/habits/<uuid:pk>/   -> full update
    PATCH  /api/habits/<uuid:pk>/   -> partial update (e.g. today_count only)
    DELETE /api/habits/<uuid:pk>/   -> delete habit (prototype; later you might archive instead)
    """

    serializer_class = HabitSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        """
        Restrict lookup to habits owned by the authenticated user.
        This prevents accessing or modifying someone else's habit.
        """
        user = self.request.user
        return Habit.objects.filter(user=user)

    def get_serializer_context(self):
        """
        Same as list view: pass request into serializer context.
        """
        context = super().get_serializer_context()
        context["request"] = self.request
        return context


class HabitCompleteView(APIView):
    """
    POST /api/habits/<uuid:pk>/complete/
    
    Mark a habit as completed for today.
    - Updates today_count to daily_goal
    - Updates last_completed date
    - Calculates and updates streak
    - Awards fish coins to user's profile
    - Updates weekly Progress model
    
    Returns the updated habit data.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk=None):
        try:
            # Get the habit (ensure it belongs to the user)
            habit = Habit.objects.get(pk=pk, user=request.user)
        except Habit.DoesNotExist:
            return Response(
                {"error": "Habit not found or does not belong to you."},
                status=status.HTTP_404_NOT_FOUND
            )

        # Complete the habit
        is_new_completion = habit.complete_for_today()

        # Award fish coins and update Progress only if this is a new completion
        if is_new_completion:
            # Get or create user's game profile
            from penguin_app.models.user_models import UserGameProfile
            profile, created = UserGameProfile.objects.get_or_create(user=request.user)

            # Award fish coins
            profile.fish_coins += habit.reward
            profile.save()

            # Update weekly progress tracking
            today = timezone.now().date()
            week_start = today - timedelta(days=today.weekday())  # Monday of current week
            
            progress, created = Progress.objects.get_or_create(
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
            progress.save()

            message = f"Habit completed! Earned {habit.reward} fish coins. Streak: {habit.streak} days."
        else:
            message = "Habit was already completed today."

        # Return updated habit data
        serializer = HabitSerializer(habit, context={'request': request})
        return Response({
            "message": message,
            "habit": serializer.data,
            "coins_earned": habit.reward if is_new_completion else 0,
            "new_completion": is_new_completion
        }, status=status.HTTP_200_OK)
