from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from django.utils import timezone

from penguin_app.models.user_models import User, UserGameProfile
from penguin_app.models.progress_models import Progress


class ProgressViewTests(APITestCase):

    def setUp(self):
        # Create user
        self.user = User.objects.create_user(
            email="test@example.com",
            username="testuser",
            password="password123"
        )
        self.profile = UserGameProfile.objects.create(user=self.user)

        # Authenticate
        self.client.force_authenticate(user=self.user)

        # Create sample weekly progress entries
        self.p1 = Progress.objects.create(
            profile=self.profile,
            week_start=timezone.localdate().replace(day=1),
            habits_completed=5,
            todos_completed=2,
            fish_coins_earned=10,
        )

        self.p2 = Progress.objects.create(
            profile=self.profile,
            week_start=timezone.localdate().replace(day=8),
            habits_completed=3,
            todos_completed=4,
            fish_coins_earned=7,
        )

    # Weekly Progress Tests
    def test_weekly_progress_view(self):
        url = reverse("weekly-progress")
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)

        # Ensure ordering: most recent first
        self.assertGreaterEqual(
            response.data[0]["week_start"],
            response.data[1]["week_start"]
        )

    # Monthly Progress Tests
    def test_monthly_progress_view(self):
        url = reverse("monthly-progress")
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        # Check aggregation
        self.assertEqual(response.data["total_habits"], 8)      # 5 + 3
        self.assertEqual(response.data["total_todos"], 6)       # 2 + 4
        self.assertEqual(response.data["total_fish_coins"], 17) # 10 + 7

    # All-Time Progress Tests
    def test_all_time_progress_view(self):
        url = reverse("alltime-progress")
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.assertEqual(response.data["total_habits"], 8)
        self.assertEqual(response.data["total_todos"], 6)
        self.assertEqual(response.data["total_fish_coins"], 17)
