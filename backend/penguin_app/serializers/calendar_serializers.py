from rest_framework import serializers
from penguin_app.models.calendar_models import CalendarEvent

class CalendarEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = CalendarEvent
        # these are the pieces we want to show
        # no "user" here because we add the user ourselves in the view
        fields = ['id', 'title', 'description', 'start_time', 'end_time']

