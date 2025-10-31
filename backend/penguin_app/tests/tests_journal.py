from django.test import TestCase
from django.contrib.auth import get_user_model
from ..models.journal_entry_model import JournalEntry
from ..serializers.journal_serializers import JournalEntrySerializer
from django.utils import timezone

"""
unit tests for journal feature of pocket penguin app
only one exists for testing journal entry creation right now, but more to come

Author: Kaitlyn
"""

User = get_user_model()

class JournalEntrySerializerTest(TestCase):
    """Tests for JournalEntrySerializer to ensure entries can be created properly."""

    def setUp(self):
        """Create a test user for linking journal entries."""
        self.user = User.objects.create_user(
            email='testuser@example.com',
            username='testuser',
            password='securepassword123'
        )

    def test_create_journal_entry(self):
        """Test creating a journal entry via the serializer."""
        data = {
            'user': self.user.id,  # link to test user
            'title': 'My First Entry',
            'content': 'Today I learned something new!',
            'mood': 'happy',
            'tags': ['learning', 'fun'],
            'date': timezone.now()
        }

        serializer = JournalEntrySerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)  # ensure data is valid
        journal_entry = serializer.save()  # create entry

        # Check that the JournalEntry exists in the database
        self.assertEqual(JournalEntry.objects.count(), 1)
        self.assertEqual(journal_entry.title, data['title'])
        self.assertEqual(journal_entry.user, self.user)
