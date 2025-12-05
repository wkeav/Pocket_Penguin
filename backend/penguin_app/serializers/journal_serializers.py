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
        fields = ['id', 'user', 'title', 'content', 'mood', 'tags', 'date', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at', 'user']  # auto-generated fields
        
    def create(self, validated_data):
        """Create a new JournalEntry instance, with automatically attatched user"""
        user = self.context['request'].user
        return JournalEntry.objects.create(**validated_data)
