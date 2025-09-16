import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class JournalEntry {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final String mood;
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    required this.mood,
    required this.tags,
  });
}

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final List<JournalEntry> _entries = [
    JournalEntry(
      id: '1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      title: 'Great progress today!',
      content:
          'Completed all my habits and felt really productive. Waddles seems happy too!',
      mood: 'Happy',
      tags: ['productive', 'habits'],
    ),
    JournalEntry(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 3)),
      title: 'Meditation session',
      content:
          'Had a wonderful 15-minute meditation. Feeling more centered and calm.',
      mood: 'Peaceful',
      tags: ['meditation', 'wellness'],
    ),
    JournalEntry(
      id: '3',
      date: DateTime.now().subtract(const Duration(days: 5)),
      title: 'Started my journey',
      content:
          'First day using Pocket Penguin! Excited to build better habits with Waddles.',
      mood: 'Excited',
      tags: ['start', 'motivation'],
    ),
  ];

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

  void _addEntry() {
    if (_titleController.text.trim().isNotEmpty &&
        _contentController.text.trim().isNotEmpty) {
      setState(() {
        _entries.insert(
            0,
            JournalEntry(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              date: DateTime.now(),
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              mood: _selectedMood,
              tags: [],
            ));
        _titleController.clear();
        _contentController.clear();
        _selectedMood = 'Neutral';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Stats
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'How was your day?',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Mood: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedMood,
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedMood = newValue!;
                          });
                        },
                        items:
                            _moods.map<DropdownMenuItem<String>>((String mood) {
                          return DropdownMenuItem<String>(
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

          // Journal Entries
          if (_entries.isEmpty)
            ArcticCard(
              child: Column(
                children: [
                  const Icon(Icons.book, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No journal entries yet!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start reflecting on your daily journey',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildJournalEntryCard(entry),
                )),

          const SizedBox(height: 16),

          // Writing Prompts
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
                        onTap: () {
                          _titleController.text = prompt;
                        },
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.purple[700],
                                  ),
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
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
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
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Text(
                _formatDate(entry.date),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PenguinBadge(
                text: entry.mood,
                icon: _moodIcons[entry.mood],
                backgroundColor: Colors.purple[100],
                textColor: Colors.purple[700],
              ),
              const SizedBox(width: 8),
              ...entry.tags.map((tag) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: PenguinBadge(
                      text: tag,
                      backgroundColor: Colors.grey[100],
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return '${difference} days ago';
    }
  }

  int _getCurrentStreak() {
    if (_entries.isEmpty) return 0;

    // Simple streak calculation - consecutive days with entries
    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (int i = 0; i < 7; i++) {
      // Check last 7 days
      final hasEntry = _entries.any((entry) =>
          entry.date.year == checkDate.year &&
          entry.date.month == checkDate.month &&
          entry.date.day == checkDate.day);

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
