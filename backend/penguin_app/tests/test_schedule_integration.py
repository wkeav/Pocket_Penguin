"""
Quick integration test to verify weekProgress is correctly saved
Run this with: python test_schedule_integration.py
"""
import os
import django
import sys

# Setup Django
sys.path.insert(0, os.path.dirname(__file__))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'pocket_penguin.settings')
django.setup()

from penguin_app.models import User, Habit
from penguin_app.serializers import HabitSerializer
from rest_framework.test import APIRequestFactory
from django.contrib.auth.hashers import make_password

def test_week_progress_integration():
    """Test that weekProgress is correctly serialized and saved"""
    
    # Clean up any existing test data
    User.objects.filter(email='testschedule@test.com').delete()
    
    # Create test user
    user = User.objects.create(
        email='testschedule@test.com',
        username='testschedule',
        password=make_password('testpass123'),
        is_verified=True
    )
    
    # Prepare habit data with weekProgress
    habit_data = {
        'title': 'Test Habit with Schedule',
        'description': 'Testing weekProgress field',
        'targetValue': 8,
        'unit': 'glasses',
        'currentValue': 0,
        'reward': 5,
        'category': 'Health',
        'icon': 'water_drop',
        'schedule': 'DAILY',
        'weekProgress': [True, True, False, True, False, False, True]  # Mon, Tue, Wed, Thu, Fri, Sat, Sun
    }
    
    # Create a mock request with user
    factory = APIRequestFactory()
    request = factory.post('/api/habits/')
    request.user = user
    
    # Serialize and save
    serializer = HabitSerializer(data=habit_data, context={'request': request})
    
    if serializer.is_valid():
        habit = serializer.save()
        print("✅ Habit created successfully!")
        print(f"   ID: {habit.id}")
        print(f"   Title: {habit.name}")
        print(f"   Week Progress (database): {habit.week_progress}")
        
        # Verify the data was saved correctly
        saved_habit = Habit.objects.get(id=habit.id)
        print(f"   Week Progress (retrieved): {saved_habit.week_progress}")
        
        # Test serialization back to frontend format
        read_serializer = HabitSerializer(saved_habit)
        print(f"   weekProgress (serialized): {read_serializer.data['weekProgress']}")
        
        # Verify they match
        if read_serializer.data['weekProgress'] == habit_data['weekProgress']:
            print("\n✅ SUCCESS: weekProgress correctly saved and retrieved!")
            return True
        else:
            print(f"\n❌ MISMATCH:")
            print(f"   Expected: {habit_data['weekProgress']}")
            print(f"   Got: {read_serializer.data['weekProgress']}")
            return False
    else:
        print(f"❌ Validation errors: {serializer.errors}")
        return False

if __name__ == '__main__':
    print("Testing weekProgress integration...\n")
    success = test_week_progress_integration()
    
    # Cleanup
    User.objects.filter(email='testschedule@test.com').delete()
    
    sys.exit(0 if success else 1)
