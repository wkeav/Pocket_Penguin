from rest_framework import serializers
from ..models.journal_entry_model import JournalEntry

"""
Django REST Framework serializer for the Pocket Penguin Journal feature.

This module handles data validation, serialization, and deserialization for:
- Creating new journal entries
- Validating required fields: title, content, mood
- Optional fields: tags (stored as a list), date (defaults to current time)

Author: Kaitlyn
"""

class JournalEntrySerializer(serializers.ModelSerializer):
    """Serializer for creating and representing journal entries."""
    
    class Meta:
        model = JournalEntry
        fields = ['id', 'title', 'content', 'mood', 'tags', 'date', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']  # auto-generated fields
        extra_kwargs = {
            'user': {'required': False}  # user is set by the view, not by the client
        }
