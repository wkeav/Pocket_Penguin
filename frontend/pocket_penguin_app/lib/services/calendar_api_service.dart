// lib/services/calendar_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class CalendarEvent {
  final int id;
  final String title;
  final EventType type;
  final String time;
  final String date;
  final bool completed;
  final int userId;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.time,
    required this.date,
    required this.completed,
    required this.userId,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      type: json['type'] == 'habit' ? EventType.habit : EventType.todo,
      time: json['time'],
      date: json['date'],
      completed: json['completed'],
      userId: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'event_type': type == EventType.habit ? 'habit' : 'todo',
      'time': time,
      'date': date,
      'completed': completed,
    };
  }
}

enum EventType { habit, todo }

class CalendarApiService {
    static const String baseUrl = 'http://10.0.2.2:8004/api';
  static Future<List<CalendarEvent>> getEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/calendar/events/'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final events = (data['events'] as List).map((eventJson) {
            return CalendarEvent.fromJson(eventJson);
          }).toList();
          return events;
        } else {
          throw Exception('API error: ${data['error']}');
        }
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getEvents: $e');
      rethrow;
    }
  }
  
  static Future<CalendarEvent> addEvent(CalendarEvent event) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/calendar/events/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(event.toJson()),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return CalendarEvent.fromJson(data['event']);
        } else {
          throw Exception('API error: ${data['error']}');
        }
      } else {
        throw Exception('Failed to add event: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in addEvent: $e');
      rethrow;
    }
  }

  static Future<void> deleteEvent(int eventId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/calendar/events/$eventId/'),
      );
      
      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception('Failed to delete event: ${data['error']}');
      }
    } catch (e) {
      print('Error in deleteEvent: $e');
      rethrow;
    }
  }
}