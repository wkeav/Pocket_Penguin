# Migration for Habit tests


from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import django.utils.timezone
import uuid


class Migration(migrations.Migration):

    dependencies = [
        ("penguin_app", "0002_journalentry"),
    ]

    operations = [
        migrations.CreateModel(
            name="Habit",
            fields=[
                (
                    "id",
                    models.UUIDField(
                        default=uuid.uuid4, editable=False, primary_key=True, serialize=False
                    ),
                ),
                ("name", models.CharField(max_length=120)),
                ("description", models.TextField(blank=True)),
                ("category", models.CharField(blank=True, max_length=100)),
                ("emoji", models.CharField(blank=True, max_length=8)),
                ("color", models.CharField(blank=True, max_length=16)),
                ("daily_goal", models.PositiveIntegerField(default=1)),
                ("today_count", models.PositiveIntegerField(default=0)),
                ("last_completed", models.DateTimeField(blank=True, null=True)),
                ("is_active", models.BooleanField(default=True)),
                ("is_archived", models.BooleanField(default=False)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                ("start_date", models.DateTimeField(default=django.utils.timezone.now)),
                (
                    "user",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="habits",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
            options={
                "db_table": "habits",
                "ordering": ("created_at",),
            },
        ),
    ]
