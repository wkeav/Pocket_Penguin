from django.db import models
from django.conf import settings

# This model is for one calendar event
class CalendarEvent(models.Model):
    # This links the event to the user who made it
    # Think: "this event belongs to this person"
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)

    title = models.CharField(max_length=255)  # the name of the event
    description = models.TextField(blank=True)  # little story about the event (can be empty)
    start_time = models.DateTimeField()  # when the event starts
    end_time = models.DateTimeField()    # when the event ends

    # this is what we show when we print the event
    def __str__(self):
        return self.title

# You can make more models under here if you need more things in your app
