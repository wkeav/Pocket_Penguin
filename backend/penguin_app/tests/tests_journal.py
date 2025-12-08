from django.test import TestCase
from django.contrib.auth import get_user_model
from ..models.journal_entry_model import JournalEntry
from ..serializers.journal_serializers import JournalEntrySerializer
from django.utils import timezone
import time
from datetime import timedelta

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

    def test_serializer_invalid_missing_required_fields(self):
        """Serializer should be invalid when required fields are missing."""
        data = {
            'user': self.user.id,
            # 'title' omitted
            'content': 'No title here',
            # 'mood' omitted
        }

        serializer = JournalEntrySerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn('title', serializer.errors)
        self.assertIn('mood', serializer.errors)

    def test_tags_default_when_missing(self):
        """When tags are not provided, they should default to an empty list."""
        data = {
            'user': self.user.id,
            'title': 'Entry Without Tags',
            'content': 'This entry has no tags.',
            'mood': 'neutral',
            # no 'tags' key
        }

        serializer = JournalEntrySerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        journal_entry = serializer.save()

        self.assertIsInstance(journal_entry.tags, list)
        self.assertEqual(journal_entry.tags, [])

    def test_str_and_timestamps_and_date_default(self):
        """Verify __str__, date default, and timestamps behave as expected."""
        data = {
            'user': self.user.id,
            'title': 'Timestamp Test Entry',
            'content': 'Checking timestamps and __str__',
            'mood': 'curious',
        }

        before = timezone.now()
        serializer = JournalEntrySerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        journal_entry = serializer.save()
        after = timezone.now()

        # __str__ should include the user's email and the title prefix
        self.assertIn(self.user.email, str(journal_entry))
        self.assertIn(journal_entry.title[:10], str(journal_entry))

        # date should be between before and after
        self.assertTrue(before - timedelta(seconds=1) <= journal_entry.date <= after + timedelta(seconds=1))

        # created_at and updated_at should be set and updated_at >= created_at
        self.assertIsNotNone(journal_entry.created_at)
        self.assertIsNotNone(journal_entry.updated_at)
        self.assertGreaterEqual(journal_entry.updated_at, journal_entry.created_at)

    def test_updated_at_changes_on_save(self):
        """Saving a modified journal entry should update `updated_at`."""
        data = {
            'user': self.user.id,
            'title': 'Update Test',
            'content': 'Initial',
            'mood': 'meh',
        }

        serializer = JournalEntrySerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        journal_entry = serializer.save()

        original_updated = journal_entry.updated_at

        # Ensure a measurable time gap so updated_at will differ
        time.sleep(0.05)

        journal_entry.content = 'Changed content'
        journal_entry.save()

        journal_entry.refresh_from_db()
        self.assertGreater(journal_entry.updated_at, original_updated)
