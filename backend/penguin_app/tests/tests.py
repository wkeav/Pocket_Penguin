from django.test import TestCase
import unittest
from unittest.mock import patch

class TestIsUserExist(unittest.TestCase):
    def setUp(self):
        self.valid_user_ids = {"user123", "A", "Z" * 50}

    @patch('user_profile.isUserExist')
    def test_correct_user_exists(self, mock_isUserExist):
        """Correct: userID exists in the user database (registered, active, valid)."""
        mock_isUserExist.side_effect = lambda uid: uid in self.valid_user_ids

        self.assertTrue(mock_isUserExist("user123"))
        self.assertTrue(mock_isUserExist("A"))
        self.assertTrue(mock_isUserExist("Z" * 50))

    @patch('user_profile.isUserExist')
    def test_incorrect_user_does_not_exist(self, mock_isUserExist):
        """Incorrect: userID does not exist (unregistered, deleted, or invalid)."""
        mock_isUserExist.return_value = False

        self.assertFalse(mock_isUserExist("ghostUser"))
        self.assertFalse(mock_isUserExist("deletedUser"))

if __name__ == "__main__":
    unittest.main()

