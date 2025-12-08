from rest_framework import serializers
from penguin_app.models.calendar_models import CalendarEvent

class CalendarEventSerializer(serializers.ModelSerializer):
    user = serializers.PrimaryKeyRelatedField(read_only=True, required=False)
    
    class Meta:
        model = CalendarEvent
        fields = ['id', 'title', 'description', 'start_time', 'end_time']
        read_only_fields = ['id']

