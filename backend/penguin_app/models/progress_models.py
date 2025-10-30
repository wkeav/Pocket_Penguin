from django.db import models
from django.forms import ValidationError
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
    
    def clean(self):
        """Validate that completion_rate is between 0 and 1."""
        if not (0.0 <= self.completion_rate <= 1.0):
            raise ValidationError(
                {"completion_rate": "Completion rate must be between 0 and 1."}
            )

    def save(self, *args, **kwargs):
        """Ensure validation runs before saving."""
        self.full_clean()
        super().save(*args, **kwargs)