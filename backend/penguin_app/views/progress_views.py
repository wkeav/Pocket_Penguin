from rest_framework import generics, permissions
from penguin_app.models.progress_models import Progress
from penguin_app.serializers.progress_serializers import ProgressSerializer


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
