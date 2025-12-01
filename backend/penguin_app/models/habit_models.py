from django.db import models
import uuid
from django.utils import timezone
from .user_models import User

"""
Habit model for the Pocket Penguin Application
"""

class Habit(models.Model):

    # Habit IDs
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # Linking Users to Habit IDs
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="habits")

    # Habit descriptions
    name = models.CharField(max_length=120)
    description = models.TextField(blank=True)

    category = models.CharField(max_length=100, blank=True)
    emoji = models.CharField(max_length=8, blank=True)
    color = models.CharField(max_length=16, blank=True)

    # Progress tracking
    daily_goal = models.PositiveIntegerField(default=1)
    today_count = models.PositiveIntegerField(default=0)
    last_completed = models.DateTimeField(null=True, blank=True)

    # Habit activity
    is_active = models.BooleanField(default=True)
    is_archived = models.BooleanField(default=False)

    # Creation/update timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    start_date = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = "habits"
        ordering = ("created_at",)

    def __str__(self):
        return f"{self.user.email} - {self.name[:20]}"