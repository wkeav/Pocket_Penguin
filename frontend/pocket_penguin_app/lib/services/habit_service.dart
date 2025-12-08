import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pocket_penguin_app/models/habit.dart';
import 'auth_service.dart';
import 'api_service.dart';

/// Service class for handling all habit-related API calls
/// Communicates with the backend to fetch, create, update, and delete habits
class HabitApi {
  /// Get the base URL for habit API endpoints
  static String get baseUrl {
    return '${ApiConfig.baseUrl}/habits/';
  }

  /// Fetch all habits for the authenticated user
  /// Returns a list of Habit objects
  /// Excludes archived habits by default (handled by backend)
  static Future<List<Habit>> fetchHabits() async {
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
      final data = json.decode(response.body);
      // Handle paginated response from Django REST Framework
      final List jsonList =
          data is Map && data.containsKey('results') ? data['results'] : data;
      return jsonList.map((e) => Habit.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch habits: ${response.statusCode}');
    }
  }

  /// Fetch a single habit by its ID
  /// Returns a Habit object
  static Future<Habit> fetchHabit(String id) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Habit.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch habit: ${response.statusCode}');
    }
  }

  /// Create a new habit in the backend
  /// Requires authentication token and a Habit object
  /// Returns the created Habit with server-generated ID
  static Future<Habit> createHabit(Habit habit) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    print('Creating habit with token: ${token.substring(0, 20)}...');
    print('Habit data: ${json.encode(habit.toJson())}');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(habit.toJson()),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      return Habit.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to create habit: ${response.statusCode} - ${response.body}');
    }
  }

  /// Update an existing habit (partial update - PATCH)
  /// Only sends the fields that changed
  /// Returns the updated Habit
  static Future<Habit> updateHabit(String id, Map<String, dynamic> updates) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    print('Updating habit $id with: ${json.encode(updates)}');

    final response = await http.patch(
      Uri.parse('$baseUrl$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updates),
    );

    print('Update response status: ${response.statusCode}');
    print('Update response body: ${response.body}');

    if (response.statusCode == 200) {
      return Habit.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to update habit: ${response.statusCode} - ${response.body}');
    }
  }

  /// Update an existing habit (full update - PUT)
  /// Requires all fields
  /// Returns the updated Habit
  static Future<Habit> replaceHabit(String id, Habit habit) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.put(
      Uri.parse('$baseUrl$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(habit.toJson()),
    );

    if (response.statusCode == 200) {
      return Habit.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to replace habit: ${response.statusCode} - ${response.body}');
    }
  }

  /// Increment the current value of a habit
  /// Convenience method for updating progress
  static Future<Habit> incrementProgress(String id, int currentValue) async {
    return updateHabit(id, {'currentValue': currentValue});
  }

  /// Mark a habit as completed for today
  /// Updates the current value to meet the target
  static Future<Habit> completeHabit(String id) async {
    // Note: You might want to add a dedicated completion endpoint in the backend
    // that handles streak updates, fish coins, and progress tracking
    final habit = await fetchHabit(id);
    return updateHabit(id, {'currentValue': habit.targetValue});
  }

  /// Delete a habit by its ID
  /// Requires authentication and the habit's UUID
  static Future<void> deleteHabit(String id) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Delete response status: ${response.statusCode}');
    // 204 No Content indicates successful deletion
    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete habit: ${response.statusCode} - ${response.body}');
    }
  }

  /// Archive a habit instead of deleting it
  /// Sets is_archived flag to true
  static Future<Habit> archiveHabit(String id) async {
    return updateHabit(id, {'is_archived': true});
  }

  /// Restore an archived habit
  /// Sets is_archived flag to false
  static Future<Habit> restoreHabit(String id) async {
    return updateHabit(id, {'is_archived': false});
  }
}
