from rest_framework import serializers
from penguin_app.models.progress_models import Progress

class ProgressSerializer(serializers.ModelSerializer):
    class Meta:
        model = Progress
        fields = [
            "id",
            "week_start",
            "habits_completed",
            "todos_completed",
            "completion_rate",
            "fish_coins_earned",
            "created_at",
            "updated_at",
        ]
