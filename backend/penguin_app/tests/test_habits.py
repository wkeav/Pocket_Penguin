from django.test import TestCase
from django.utils import timezone
from django.contrib.auth import get_user_model
from penguin_app.models.habit_models import Habit


class HabitModelTests(TestCase):
    """Simple TestCase wrapper so Django's test runner discovers the test."""

    def test_create_habit_instance(self):
        User = get_user_model()
        user = User.objects.create_user("selend", "selend@example.com", "pass")
        h = Habit.objects.create(user=user, name="Collect 8 pages")
        self.assertIsNotNone(h.id)
        self.assertEqual(h.user, user)
        self.assertEqual(h.name, "Collect 8 pages")
        self.assertLessEqual(h.created_at, timezone.now())
