from django.test import TestCase
from django.utils import timezone
from penguin_app.models.user_models import User, UserGameProfile
from penguin_app.models.progress_models import Progress
from django.core.exceptions import ValidationError

#This test file ensures the progress model saves valid user data and rejects invalid data
class ProgressModelTest(TestCase):
    def setUp(self):
        # Create a mock user
        self.user = User.objects.create_user(
            email="test@example.com",
            username="testuser",
            password="password123"
        )

        # Create a related UserGameProfile
        self.profile = UserGameProfile.objects.create(user=self.user)

        # Create a Progress record
        self.progress = Progress.objects.create(
            profile=self.profile,
            week_start=timezone.now().date(),
            habits_completed=5,
            todos_completed=3,
            completion_rate=0.8,
            fish_coins_earned=25
        )

    def test_progress_creation(self):
        """Ensure a Progress record saves correctly."""
        self.assertEqual(self.progress.profile, self.profile)
        self.assertEqual(self.progress.habits_completed, 5)
        self.assertEqual(self.progress.todos_completed, 3)
        self.assertEqual(self.progress.completion_rate, 0.8)
        self.assertEqual(self.progress.fish_coins_earned, 25)

    def test_str_representation(self):
        """Check the string representation is readable."""
        expected_str = f"{self.profile.user.email} Progress ({self.progress.week_start})"
        self.assertEqual(str(self.progress), expected_str)

    def test_progress_creation_invalid_rate(self):
        """Ensure invalid completion_rate raises an error."""
        with self.assertRaises(ValidationError) as context:
            Progress.objects.create(
                profile=self.profile,
                week_start=timezone.now().date(),
                habits_completed=2,
                todos_completed=1,
                completion_rate=-0.5,  # invalid
                fish_coins_earned=5
        )

        self.assertIn("Completion rate must be between 0 and 1", str(context.exception))
