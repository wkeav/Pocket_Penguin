from rest_framework import generics, permissions
from penguin_app.models.habit_models import Habit
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
