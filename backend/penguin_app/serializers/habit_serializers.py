from rest_framework import serializers
from ..models.habit_models import Habit

"""
Django REST Framework serializer for the Pocket Penguin Habit Tracker feature

"""

class HabitSerializer(serializers.ModelSerializer):
    
    progress = serializers.SerializerMethodField()

    class Meta:
        model = Habit
        fields = [
            "id",
            "user",
            "name",
            "description",
            "category",
            "emoji",
            "color",
            "daily_goal",
            "today_count",
            "last_completed",
            "is_active",
            "is_archived",
            "created_at",
            "updated_at",
            "start_date",
            "progress",
            ]
        read_only_fields = [
            "id",
            "user",
            "created_at",
            "updated_at",
            "start_date",
            "progress",
            ]
        
    def get_progress(self, obj):

        if obj.daily_goal <= 0:
            return 0.0
        return round(obj.today_count / obj.daily_goal, 3)
    
    def validate_daily_goal(self, value):
        # Check if daily goal is positive
        if value <= 0:
            raise serializers.ValidationError("Daily goal must be greater than zero")
        return value
    
    def create(self, validated_data):
        # Creates new habit
        return Habit.objects.create(**validated_data)
    
    