import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Where your JWT token is stored

class CalendarService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Fetch all events for the logged-in user
  static Future<List<dynamic>> getEvents() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/calendar/events/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load events: ${response.body}');
    }
  }

  // Add a new event for the logged-in user
  static Future<void> addEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/calendar/events/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description, // Required now
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add event: ${response.body}');
    }
  }
}
