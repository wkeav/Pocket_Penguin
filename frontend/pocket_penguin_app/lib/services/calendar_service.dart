import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calendar_event.dart';
import 'auth_service.dart';
import 'api_service.dart';

class CalendarService {
  static String get baseUrl {
    final url = '${ApiConfig.calendarUrl}/events/';
    return url;
  }

  // Get all events for the authenticated user
  static Future<List<CalendarEvent>> getEvents() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      // Handle paginated response (DRF pagination returns {results: [...]})
      final List<dynamic> eventsList =
          data is Map && data.containsKey('results') ? data['results'] : data;
      return eventsList.map((json) => CalendarEvent.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load events: ${response.statusCode} - ${response.body}');
    }
  }

  // Add a new event
  static Future<CalendarEvent> addEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final eventData = {
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(eventData),
    );

    if (response.statusCode == 201) {
      return CalendarEvent.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to add event: ${response.statusCode} - ${response.body}');
    }
  }

  // Delete an event by id
  static Future<void> deleteEvent(String id) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final deleteUrl = '$baseUrl$id/';
    print('DEBUG: Deleting calendar event at URL: $deleteUrl');
    print('DEBUG: Event ID: $id');
    print('DEBUG: Base URL: $baseUrl');

    final response = await http.delete(
      Uri.parse(deleteUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('DEBUG: Delete response status: ${response.statusCode}');
    print('DEBUG: Delete response body: ${response.body}');

    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete event: ${response.statusCode} - ${response.body}');
    }
  }
}