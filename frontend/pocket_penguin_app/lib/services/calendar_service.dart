import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'api_service.dart';

class CalendarService {
  static const String baseUrl = "$api/calendar/events/";

  // Get all events for user (supports optional test token)
  static Future<List<dynamic>> getEvents({String? testToken}) async {
    final token = testToken ?? await AuthService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load events');
  }

  // Add a new event
  static Future<void> addEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add event: ${response.body}');
    }
  }

  // Delete an event by id
  static Future<void> deleteEvent(int id) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await http.delete(
      Uri.parse("$baseUrl$id/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete event: ${response.body}');
    }
  }
}
