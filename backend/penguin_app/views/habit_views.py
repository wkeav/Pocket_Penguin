# API Views of Habit Tracker for Pocket Penguin

from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.exceptions import PermissionDenied

from ..models.habit_models import Habit
from ..serializers.habit_serializers import HabitSerializer

class HabitListCreateView(generics.ListCreateAPIView):

    serializer_class = HabitSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Habit.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):

        serializer.save(user=self.request.user)

class HabitDetailView(generics.RetrieveUpdateDestroyAPIView):
        
        serializer_class = HabitSerializer
        permission_classes = [permissions.IsAuthenticated]
        queryset = Habit.objects.all()

        def get_object(self):
            habit = super().get_object()
            if habit.user != self.request.user:
                raise PermissionDenied("You do not have permission to access this habit.")
            return habit
        


        


