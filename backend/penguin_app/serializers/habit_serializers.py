from django.utils import timezone
from rest_framework import serializers
from penguin_app.models.habit_models import Habit


class HabitSerializer(serializers.ModelSerializer):
    """
    Serializers for Habit model.

    """

    # Expose UUID as string so Flutter can use it
    id = serializers.UUIDField(read_only=True)

    # Map backend fields to frontend field names
    title = serializers.CharField(source='name')
    targetValue = serializers.IntegerField(source='daily_goal')
    currentValue = serializers.IntegerField(source='today_count')
    icon = serializers.CharField(required=False, allow_blank=True)
    unit = serializers.CharField(required=False, allow_blank=True)

    # Computed progress (today_count / daily_goal)
    progress = serializers.SerializerMethodField(read_only=True)

    # Week progress (7-day boolean array)
    weekProgress = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Habit
        fields = [
            "id",
            "title",  
            "description",
            "icon",
            "targetValue",  # daily_goal
            "unit",
            "currentValue",  # today_count
            "reward",
            "category",
            "emoji",
            "color",
            "schedule",
            "last_completed",
            "streak",
            "weekProgress",
            "is_active",
            "is_archived",
            "created_at",
            "updated_at",
            "start_date",
            "progress",
        ]
        read_only_fields = [
            "id",
            "is_active",
            "is_archived",
            "created_at",
            "updated_at",
            "start_date",
            "progress",
            "weekProgress",
            "streak",
        ]

    def get_progress(self, obj):
        "Return a floating number between 0 and 1."
        if obj.daily_goal <= 0:
            return 0.0
        return min(1.0, obj.today_count / obj.daily_goal)

    def get_weekProgress(self, obj):
        "Return 7-day completion history (placeholder: all false for now)."
        # TODO: Implement actual week progress tracking from database
        # For now, return array based on whether completed today
        today = timezone.now().date()
        
        # Simple placeholder: mark today as completed if goal met
        week = [False] * 7
        if obj.last_completed and obj.last_completed == today:
            week[today.weekday()] = True
        
        return week

    def validate_targetValue(self, value):
        "Validate that targetValue (daily_goal) is greater than 0."
        if value <= 0:
            raise serializers.ValidationError("targetValue must be greater than 0.")
        return value

    def create(self, validated_data):
        request = self.context.get("request")
        user = getattr(request, "user", None)

        if user is None or not user.is_authenticated:
            raise serializers.ValidationError("Authentication required.")

        validated_data["user"] = user
        return super().create(validated_data)
