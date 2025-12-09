from django.utils import timezone
from rest_framework import serializers
from penguin_app.models.habit_models import Habit


class HabitSerializer(serializers.ModelSerializer):
    """
    Serializer for Habit model.
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

    # Week progress (7-day boolean array) - now writable
    weekProgress = serializers.ListField(
        child=serializers.BooleanField(),
        required=False,
        allow_null=True,
        source='week_progress'
    )

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
            "streak",
        ]

    def get_progress(self, obj):
        """Return a floating-point number between 0 and 1."""
        if obj.daily_goal <= 0:
            return 0.0
        return min(1.0, obj.today_count / obj.daily_goal)

    def validate_weekProgress(self, value):
        """Validate that weekProgress is exactly 7 booleans if provided."""
        if value is not None and len(value) != 7:
            raise serializers.ValidationError("weekProgress must be an array of exactly 7 booleans.")
        return value

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
