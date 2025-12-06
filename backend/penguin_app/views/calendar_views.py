# from rest_framework import generics, permissions
# from penguin_app.models.calendar_models import CalendarEvent
# from penguin_app.serializers.calendar_serializers import CalendarEventSerializer

# # List all events for the logged-in user or create a new event
# class CalendarEventListCreate(generics.ListCreateAPIView):
#     serializer_class = CalendarEventSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     def get_queryset(self):
#         # Only return events belonging to the logged-in user
#         return CalendarEvent.objects.filter(user=self.request.user)

#     def perform_create(self, serializer):
#         # Automatically attach the logged-in user to the new event
#         serializer.save(user=self.request.user)


# # Retrieve, update, or delete a single event belonging to the logged-in user
# class CalendarEventRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
#     serializer_class = CalendarEventSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     def get_queryset(self):
#         # Only allow operations on events belonging to the logged-in user
#         return CalendarEvent.objects.filter(user=self.request.user)

from rest_framework import generics, permissions
from penguin_app.models.calendar_models import CalendarEvent
from penguin_app.serializers.calendar_serializers import CalendarEventSerializer

# This class is for showing all the user's events AND making new ones
class CalendarEventListCreate(generics.ListCreateAPIView):
    serializer_class = CalendarEventSerializer
    permission_classes = [permissions.IsAuthenticated]  # only logged-in people allowed

    def get_queryset(self):
        # give back ONLY the events that belong to the person who is logged in
        return CalendarEvent.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        # when we make a new event, we stick the logged-in user onto it
        serializer.save(user=self.request.user)


# This class is for looking at ONE event, changing it, or deleting it
class CalendarEventRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = CalendarEventSerializer
    permission_classes = [permissions.IsAuthenticated]  # only logged-in people allowed

    def get_queryset(self):
        # same thing here — only let the user touch their own events
        return CalendarEvent.objects.filter(user=self.request.user)
