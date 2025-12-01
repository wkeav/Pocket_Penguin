import pytest
from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APIClient
from django.contrib.auth import get_user_model

from penguin_app.models.habit_models import Habit

User = get_user_model()

# Uses mock data


pytestmark = pytest.mark.django_db

# Model tests
def test_habit_models():
    user = User.objects.create_user (
        email="findmypages@examail.com",
        username="Slender",
        password="EightPages12348"
    )

    habit = Habit.objects.create(
        user=user,
        name="Find my eight pages"
    )
    assert habit.id is not None
    assert habit.user == user
    assert habit.name == "Find my eight pages"
    assert habit.created_at <= timezone.now()

# Serializers tests
def test_habit_serializers():
    user = User.objects.create_user(
        email="findmypages@examail.com",
        username="Slender",
        password="EightPages12348"
    )

    habit = Habit.objects.create(
        user=user,
        name="Find my eight pages",
        daily_goal=1,
        today_count=1,
    )

    from penguin_app.serializers.habit_serializers import HabitSerializer
    serializer = HabitSerializer(habit)

    assert "progress" in serializer.data
    assert float(serializer.data["progress"]) == 1.0

"""
# Views tests
def test_habit_views():
    client = APIClient()

    user = User.objects.create_user(
        email="findmypages@examail.com",
        username="Slender",
        password="EightPages12348"
    )

    habit = Habit.objects.create (
        user=user,
        name="Find my eight pages"
    )
    
    assert habit.id is not None
    assert habit.user == user
    assert habit.name == "Find my eight pages"
    assert habit.created_at <= timezone.now()

# Permission tests
def test_user_perms():
    client = APIClient()

    user1 = User.objects.create_user(
        email="SacrimoniJohn@examail.com",
        username="ILoveGinny",
        password="WhatisthistheUN"
    )

    user2 = User.objects.create_user(
        email="SopranoTony@examail.com",
        username="StrongSilentType",
        password="ColdCuts123"
    )

    habit = Habit.objects.create(
        user=user1,
        name="Stop Smoking"
    )

    client.force_authenticate(user=user2)

    response = client.get(f"/api/habits/{habit.id}/")

    assert response.status_code == 403

# Update tests
def test_habit_update_progress():
    client = APIClient()

    user = User.objects.create_user(
        email="findmypages@examail.com",
        username="Slender",
        password="EightPages12348"
    )

    client.force_authenticate(user=user)

    habit = Habit.objects.create(
        user=user,
        name="Find my eight pages",
        daily_goal=3,
        today_count=1
    )

    response = client.put(
        f"/api/habits/{habit.id}/",
        {"name": "Find my eight pages", "daily_goal": 1, "today_count": 1},
        format="json"
    )

    habit.refresh_from_db()

    assert response.status_code == 200
    assert habit.today_count == 1

"""