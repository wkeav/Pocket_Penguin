from django.db import models
import uuid
from django.utils import timezone
from .user_models import User  # Link journal entries to users

"""
Journal models for Pocket Penguin application.

This module defines the JournalEntry model which handles user journal entries, moods, 
tags, and timestamps for reflection and tracking daily progress.

Model:
JournalEntry: Stores individual journal entries for each user with metadata 
              such as mood, tags, creation date, and update timestamps.

Database Design:
- Each journal entry is linked to a User via ForeignKey.
- Tags are stored as a JSON list.
- UUID is used as the primary key for uniqueness and security.
- Automatic timestamps track creation and last update of entries.

Author: Kaitlyn
"""

class JournalEntry(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Link journal entry to a user
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="journal_entries")
    
    # Entry content
    title = models.CharField(max_length=200)
    content = models.TextField()
    mood = models.CharField(max_length=50)
    
    # Optional tags stored as a list
    tags = models.JSONField(default=list, blank=True)
    
    # Date of the journal entry
    date = models.DateTimeField(default=timezone.now)
    
    # Automatic timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "journal_entries"

    def __str__(self):
        return f"{self.user.email} - {self.title[:20]}"
