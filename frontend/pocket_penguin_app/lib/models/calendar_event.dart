// lib/models/calendar_event.dart

class CalendarEvent {
  final String title; // Name of the event
  final String description; // Description (required)
  final DateTime startDate; // Start time
  final DateTime endDate; // End time

  CalendarEvent({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });
}
