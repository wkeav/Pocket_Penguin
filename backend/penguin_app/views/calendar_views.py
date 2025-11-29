# penguin_app/views/calendar_views.py
from rest_framework import serializers
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import get_user_model
from ..models.calendar_models import CalendarEvent


User = get_user_model()

# Serializers - defined in the same file
class CalendarUserSerializer(serializers.ModelSerializer):
    event_count = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'event_count']
        read_only_fields = ['id', 'event_count']
    
    def get_event_count(self, obj):
        return obj.calendar_events.count()

class CalendarEventSerializer(serializers.ModelSerializer):
    type = serializers.CharField(source='event_type', read_only=True)
    
    class Meta:
        model = CalendarEvent
        fields = ['id', 'title', 'type', 'time', 'date', 'completed', 'user']
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']

# Views
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def calendar_user_profile(request):
    """Get current user's calendar profile"""
    serializer = CalendarUserSerializer(request.user)
    return Response({
        'status': 'success',
        'user': serializer.data
    })

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def calendar_events(request):
    """Get all events for user or create new event"""
    if request.method == 'GET':
        events = CalendarEvent.objects.filter(user=request.user).order_by('date', 'time')
        serializer = CalendarEventSerializer(events, many=True)
        return Response({
            'status': 'success',
            'events': serializer.data
        })
    
    elif request.method == 'POST':
        serializer = CalendarEventSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response({
                'status': 'success',
                'event': serializer.data
            }, status=status.HTTP_201_CREATED)
        return Response({
            'status': 'error',
            'error': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'DELETE'])
@permission_classes([IsAuthenticated])
def calendar_event_detail(request, pk):
    """Get or delete specific event"""
    try:
        event = CalendarEvent.objects.get(pk=pk, user=request.user)
    except CalendarEvent.DoesNotExist:
        return Response({
            'status': 'error',
            'error': 'Event not found'
        }, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = CalendarEventSerializer(event)
        return Response({
            'status': 'success',
            'event': serializer.data
        })
    
    elif request.method == 'DELETE':
        event.delete()
        return Response({
            'status': 'success',
            'message': 'Event deleted successfully'
        })