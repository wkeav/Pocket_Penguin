# backend/penguin_app/views.py
from rest_framework import generics, permissions
from rest_framework.pagination import PageNumberPagination
from rest_framework.exceptions import PermissionDenied
from penguin_app.models.journal_entry_model import JournalEntry
from penguin_app.serializers.journal_serializers import JournalEntrySerializer



class JournalEntryPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = "page_size"
    max_page_size = 100


class JournalEntryListCreateView(generics.ListCreateAPIView):
    """
    GET: list all journal entries belonging to the authenticated user
    POST: create a new journal entry, automatically setting user=request.user
    """
    serializer_class = JournalEntrySerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = JournalEntryPagination

    def get_queryset(self):
        # Only return entries that belong to the current user
        return (
            JournalEntry.objects.filter(user=self.request.user)
            .select_related("user")
            .order_by('-date', '-created_at')
        )

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
        # Only allow update if the entry belongs to user
        if serializer.instance.user != self.request.user:
            raise PermissionDenied("Cannot modify an entry you don't own.")
        serializer.save()

    def perform_destroy(self, instance):
        # Only allow deletion if entry belongs to user
        if instance.user != self.request.user:
            raise PermissionDenied("Cannot delete an entry you don't own.")
        instance.delete()
