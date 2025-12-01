from rest_framework import serializers
from penguin_app.models.calendar_models import CalendarEvent

class CalendarEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = CalendarEvent
        # Remove 'user' here because it will be added automatically
        fields = ['id', 'title', 'description', 'start_time', 'end_time']

