from rest_framework import generics, permissions
from penguin_app.models.progress_models import Progress
from penguin_app.serializers.progress_serializers import ProgressSerializer
from django.db.models import Sum
from django.utils import timezone
from rest_framework.views import APIView
from rest_framework.response import Response




class WeeklyProgressView(generics.ListAPIView):
    """
    Return the authenticated user's progress records,
    ordered from most recent week to oldest.
    """
    serializer_class = ProgressSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # each user has a profile via the OneToOne field user.profile
        profile = self.request.user.profile

        # return all progress rows for that profile,
        return Progress.objects.filter(profile=profile).order_by('-week_start')
    
class MonthlyProgressView(APIView):
    """
    Return a summary of this month's progress for the authenticated user.
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        profile = user.profile  # UserGameProfile

        today = timezone.localdate()
        month_start = today.replace(day=1)

        # all weekly rows whose week_start is in the current month
        qs = Progress.objects.filter(
            profile=profile,
            week_start__gte=month_start,
            week_start__lte=today,
        )

        totals = qs.aggregate(
            total_habits=Sum('habits_completed'),
            total_todos=Sum('todos_completed'),
            total_fish_coins=Sum('fish_coins_earned'),
        )

        # handle None when there is no data yet
        data = {
            "month_start": month_start,
            "month_end": today,
            "total_habits": totals["total_habits"] or 0,
            "total_todos": totals["total_todos"] or 0,
            "total_fish_coins": totals["total_fish_coins"] or 0,
        }

        return Response(data)
