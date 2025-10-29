from django.db import models
from .user_models import UserGameProfile

# Weekly progress table
class Progress(models.Model):
    profile = models.ForeignKey(UserGameProfile, on_delete=models.CASCADE, related_name='progress')
    week_start = models.DateField()  # For tracking weekly stats
    habits_completed = models.IntegerField(default=0)
    todos_completed = models.IntegerField(default=0)
    completion_rate = models.FloatField(default=0.0)
    fish_coins_earned = models.IntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'user_progress'
        ordering = ['-week_start']

    def __str__(self):
        return f"{self.profile.user.email} Progress ({self.week_start})"
