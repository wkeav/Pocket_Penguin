from datetime import timedelta
from django.db import models
from django.utils import timezone
import uuid

from .user_models import User

"""
Habit model for the Pocket Penguin application.

Includes:
- Per-user habits
- Daily goal and today's progress
- Optional category/colors/schedule
- Basic active/archive flags

"""


class Habit(models.Model):
    # Primary key 
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False,
    )

    # Link habit to a specific user
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="habits",
    )

    # Basic identity
    name = models.CharField(
        max_length=100,
        help_text="Short name of the habit (e.g. 'Drink Water')",
    )
    description = models.TextField(
        blank=True,
        help_text="Optional description of the habit.",
    )

    category = models.CharField(
        max_length=50,
        blank=True,
        default="General",
        help_text="Category label used for grouping and icons.",
    )
    emoji = models.CharField(
        max_length=10,
        blank=True,
        help_text="Optional emoji representation for the habit.",
    )
    color = models.CharField(
        max_length=20,
        blank=True,
        help_text="Optional color name or hex code for UI styling.",
    )
    icon = models.CharField(
        max_length=50,
        blank=True,
        help_text="Icon name for Flutter IconData (e.g. 'water_drop', 'fitness_center').",
    )

    # Core progress fields 
    daily_goal = models.PositiveIntegerField(
        default=1,
        help_text="Target units per day (e.g. 8 cups of water).",
    )
    unit = models.CharField(
        max_length=20,
        blank=True,
        default="times",
        help_text="Unit of measurement (e.g. 'glasses', 'steps', 'minutes').",
    )
    today_count = models.PositiveIntegerField(
        default=0,
        help_text="Progress for the current day.",
    )

    # Schedule descriptor 
    schedule = models.CharField(
        max_length=32,
        blank=True,
        default="DAILY",
        help_text="Simple frequency label (e.g. DAILY, WEEKDAYS).",
    )

    # Tracking when it was last fully completed 
    last_completed = models.DateField(
        null=True,
        blank=True,
        help_text="Date when the habit was last marked complete.",
    )

    # Gamification
    reward = models.PositiveIntegerField(
        default=5,
        help_text="Fish coins earned when completing this habit.",
    )
    streak = models.PositiveIntegerField(
        default=0,
        help_text="Current consecutive days streak.",
    )

    # Weekly progress tracking (Mon-Sun)
    week_progress = models.JSONField(
        default=list,
        blank=True,
        help_text="Array of 7 booleans representing completion for each day of the week.",
    )

    # Activity flags
    is_active = models.BooleanField(
        default=True,
        help_text="If false, this habit should not appear in active lists.",
    )
    is_archived = models.BooleanField(
        default=False,
        help_text="If true, the habit is archived/hidden instead of deleted.",
    )

    # Creation/update timestamps
    created_at = models.DateTimeField(
        auto_now_add=True,
    )
    updated_at = models.DateTimeField(
        auto_now=True,
    )
    start_date = models.DateField(
        auto_now_add=True,
        help_text="Date when the habit was first created/started.",
    )

    class Meta:
        db_table = "habits"
        ordering = ("created_at",)

    def __str__(self) -> str:
        return f"{self.user.email} – {self.name[:30]}"

    @property
    def progress(self) -> float:
        """
        Convenience property for backend/internal use.
        The API serializer will usually expose this as a read-only field.
        Returns a value between 0.0 and 1.0 (or 0.0 if daily_goal is 0).
        """
        if self.daily_goal <= 0:
            return 0.0
        return min(1.0, self.today_count / self.daily_goal)

    def calculate_streak(self, completion_date=None):
        """
        Calculate and update the streak based on completion date.
        If completed yesterday or today, increment streak.
        If gap in completion, reset to 1.
        """
        if completion_date is None:
            completion_date = timezone.now().date()
        
        if self.last_completed is None:
            # First time completing
            self.streak = 1
        else:
            days_diff = (completion_date - self.last_completed).days
            
            if days_diff == 1:
                # Consecutive day - increment streak
                self.streak += 1
            elif days_diff > 1:
                # Gap in completion - reset to 1
                self.streak = 1
            # If days_diff == 0, don't change streak
        
        return self.streak

    def complete_for_today(self):
        """
        Mark habit as completed for today.
        Updates today_count, last_completed, and streak.
        Returns True if this is a new completion (wasn't already complete).
        """
        today = timezone.now().date()
        was_complete = self.today_count >= self.daily_goal
        
        # Update progress
        self.today_count = self.daily_goal
        
        # Update completion tracking
        if self.last_completed != today:
            self.calculate_streak(today)
            self.last_completed = today
        
        self.save()
        return not was_complete  # Return True if this is a new completion

    def reset_daily_progress(self):
        """
        Reset today_count to 0.
        Should be called daily by a scheduled task.
        """
        self.today_count = 0
        self.save()

    def completion_rate(self):
        """
        Calculate the completion rate for the habit.
        Returns a value between 0.0 and 1.0, representing the proportion of the goal that has been achieved.
        """
        if self.daily_goal <= 0:
            return 0.0
        completion_rate = (self.today_count / self.daily_goal)
        return min(1.0, completion_rate)  # Returns 0-1 decimal