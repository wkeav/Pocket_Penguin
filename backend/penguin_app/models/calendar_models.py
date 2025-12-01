from django.db import models
from django.conf import settings
# Example: CalendarEvent model
class CalendarEvent(models.Model):
    # Link to the current user model properly    
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)

    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()


    def __str__(self):
        return self.title

# Add other models here if you have any
