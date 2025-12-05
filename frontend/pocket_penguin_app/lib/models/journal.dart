class JournalEntry {
  final String id;
  final String title;
  final String content;
  final String mood;
  final List<String> tags;
  final DateTime date;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.tags,
    required this.date,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      mood: json['mood'],
      tags: List<String>.from(json['tags'] ?? []),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'mood': mood,
      'tags': tags,
    };
  }
}
