import 'package:flutter/material.dart';
import 'package:pocket_penguin_app/models/journal.dart';
import '../theme/app_theme.dart';
import '../services/journal_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  // List of all journal entries fetched from backend
  List<JournalEntry> _entries = [];
  // Loading state to show spinner while fetching data
  bool _loading = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedMood = 'Neutral';

  final List<String> _moods = [
    'Happy',
    'Peaceful',
    'Excited',
    'Neutral',
    'Tired',
    'Anxious'
  ];

  final Map<String, IconData> _moodIcons = {
    'Happy': Icons.sentiment_very_satisfied,
    'Peaceful': Icons.self_improvement,
    'Excited': Icons.star,
    'Neutral': Icons.sentiment_neutral,
    'Tired': Icons.sentiment_dissatisfied,
    'Anxious': Icons.sentiment_very_dissatisfied,
  };

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  // Load all journal entries from the backend
  // Displays newest entries first by reversing the list
  Future<void> loadEntries() async {
    try {
      final entries = await JournalApi.fetchEntries();
      setState(() {
        _entries = entries.reversed.toList(); // newest first
        _loading = false;
      });
    } catch (e) {
      print("Error fetching entries: $e");
      setState(() => _loading = false);
    }
  }

  // Delete a journal entry without confirmation
  // Reloads the list after successful deletion
  Future<void> _deleteEntry(JournalEntry entry) async {
    try {
      await JournalApi.deleteEntry(entry.id);
      await loadEntries();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted successfully!')),
        );
      }
    } catch (e) {
      print("Error deleting entry: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete entry: $e')),
        );
      }
    }
  }

  // Create a new journal entry from the form data
  // Validates that title and content are not empty before submitting
  Future<void> _addEntry() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) return;

    final newEntry = JournalEntry(
      id: '',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      mood: _selectedMood,
      tags: [],
      date: DateTime.now(),
    );

    try {
      await JournalApi.createEntry(newEntry);
      await loadEntries();

      _titleController.clear();
      _contentController.clear();
      _selectedMood = 'Neutral';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry saved successfully!')),
        );
      }
    } catch (e) {
      print("Error creating entry: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save entry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card
          ArcticCard(
            gradientColors: const [Color(0xFFFDF4FF), Color(0xFFFAE8FF)],
            child: Column(
              children: [
                const Text(
                  'My Journal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Reflect on your daily journey',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                        '${_entries.length}', 'Entries', Colors.purple),
                    const SizedBox(width: 16),
                    _buildStatCard(
                        '${_getCurrentStreak()}', 'Day Streak', Colors.orange),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // New Entry Form
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'New Entry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Entry Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'How was your day?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Mood: ',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedMood,
                        isExpanded: true,
                        onChanged: (value) =>
                            setState(() => _selectedMood = value!),
                        items: _moods.map((mood) {
                          return DropdownMenuItem(
                            value: mood,
                            child: Row(
                              children: [
                                Icon(_moodIcons[mood], size: 16),
                                const SizedBox(width: 8),
                                Text(mood),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addEntry,
                    child: const Text('Save Entry'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Entries List
          if (_entries.isEmpty)
            ArcticCard(
              child: Column(
                children: const [
                  Icon(Icons.book, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No journal entries yet!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text('Start reflecting on your daily journey'),
                ],
              ),
            )
          else
            ..._entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildJournalEntryCard(entry),
                )),

          const SizedBox(height: 16),

          // Prompts
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Writing Prompts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 12),
                ...[
                  'What made you smile today?',
                  'What habit are you most proud of?',
                  'How did you take care of yourself today?',
                  'What challenge did you overcome?',
                ].map((prompt) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => _titleController.text = prompt,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb,
                                  size: 16, color: Colors.purple[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  prompt,
                                  style: TextStyle(color: Colors.purple[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 24, color: color, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalEntryCard(JournalEntry entry) {
    return ArcticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_moodIcons[entry.mood], color: Colors.purple[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(_formatDate(entry.date),
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red[400],
                onPressed: () => _deleteEntry(entry),
                tooltip: 'Delete entry',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(entry.content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              PenguinBadge(
                text: entry.mood,
                icon: _moodIcons[entry.mood],
                backgroundColor: Colors.purple[100],
                textColor: Colors.purple[700],
              ),
            ],
          )
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  // Calculate the current journaling streak (consecutive days with entries)
  // Checks up to 7 days back from today
  int _getCurrentStreak() {
    if (_entries.isEmpty) return 0;
    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (int i = 0; i < 7; i++) {
      bool hasEntry = _entries.any((e) =>
          e.date.year == checkDate.year &&
          e.date.month == checkDate.month &&
          e.date.day == checkDate.day);

      if (hasEntry) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}