// lib/models/calendar_event.dart

class CalendarEvent {
  final String id; // UUID from backend
  final String title; // Name of the event
  final String description; // Description (required)
  final DateTime startDate; // Start time
  final DateTime endDate; // End time

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['start_time'] as String),
      endDate: DateTime.parse(json['end_time'] as String),
    );
  }
}
