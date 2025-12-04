# backend/penguin_app/views.py
from rest_framework import generics, permissions
from rest_framework.exceptions import PermissionDenied
from .models.journal_entry_model import JournalEntry
from .serializers import JournalEntrySerializer

class JournalEntryListCreateView(generics.ListCreateAPIView):
    """
    GET: list all journal entries belonging to the authenticated user
    POST: create a new journal entry, automatically setting user=request.user
    """
    serializer_class = JournalEntrySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Only return entries that belong to the current user
        return JournalEntry.objects.filter(user=self.request.user).order_by('-date', '-created_at')

    def perform_create(self, serializer):
        # Save the current user as the owner of the entry
        serializer.save(user=self.request.user)


class JournalEntryDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    GET: retrieve a single JournalEntry (only if it belongs to the user)
    PUT/PATCH: update the entry (only if it belongs to the user)
    DELETE: delete the entry (only if it belongs to the user)
    """
    serializer_class = JournalEntrySerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'pk'  # UUID primary key

    def get_queryset(self):
        # Restrict queryset to the user's entries so users can't access others' entries
        return JournalEntry.objects.filter(user=self.request.user)

    def perform_update(self, serializer):
        # Optional, enforce extra checks if needed
        if serializer.instance.user != self.request.user:
            raise PermissionDenied("Cannot modify an entry you don't own.")
        serializer.save()

    def perform_destroy(self, instance):
        if instance.user != self.request.user:
            raise PermissionDenied("Cannot delete an entry you don't own.")
        instance.delete()
