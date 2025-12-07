// import 'dart:convert'; //reads json stuff
// import 'package:http/http.dart' as http; //talks to internt
// import 'auth_service.dart'; //gets the token

// class CalendarService {
//   static const String baseUrl = 'https://pocket-penguin.onrender.com/api'; //base url for api

//   //  // get all events for user
//   static Future<List<dynamic>> getEvents() async {
//     final token = await AuthService.getToken(); //grabs token
//     if (token == null) throw Exception('User not authenticated'); //no token throw and exception

//     final response = await http.get(
//       Uri.parse('$baseUrl/calendar/events/'), //goes to events page
//       headers: {
//         'Content-Type': 'application/json', //speaks to json
//         'Authorization': 'Bearer $token',  //shows the token badge
//       },
//     );

//     if (response.statusCode == 200) return jsonDecode(response.body); // got events
//     throw Exception('Failed to load events'); //failed to get events case
//   }

//   // Add a new event
//   static Future<void> addEvent({
//     required String title, // event name
//     required String description, //notes
//     required DateTime startTime, //start time
//     required DateTime endTime, //end time
//   }) async {
//     final token = await AuthService.getToken(); //needs token again
//     if (token == null) throw Exception('User not authenticated'); //no token? needs it!

//     final response = await http.post(
//       Uri.parse('$baseUrl/calendar/events/'), //goes to add event page
//       headers: {
//         'Content-Type': 'application/json', //talks json again
//         'Authorization': 'Bearer $token', //// token badge again
//       },
//       body: jsonEncode({
//         'title': title, // writes name
//         'description': description, //writes notes
//         'start_time': startTime.toIso8601String(), //writes start time
//         'end_time': endTime.toIso8601String(), //writes end time
//       }),
//     );

//     if (response.statusCode != 201) {
//       throw Exception('Failed to add event: ${response.body}'); //can't add event case
//     }
//   }

//   // Delete an event by id
//   static Future<void> deleteEvent(int id) async {
//     final token = await AuthService.getToken(); //// token one more time
//     if (token == null) throw Exception('User not authenticated'); // no token? stuck

//     final response = await http.delete(
//       Uri.parse('$baseUrl/calendar/events/$id/'), //goes to delete it
//       headers: {
//         'Content-Type': 'application/json', // json talk again
//         'Authorization': 'Bearer $token', // token badge again
//       },
//     );

//     if (response.statusCode != 204) {
//       throw Exception('Failed to delete event: ${response.body}'); //// deletion failed
//     }
//   }
// }

import 'dart:convert'; // reads json stuff
import 'package:http/http.dart' as http; // talks to internet
import 'auth_service.dart'; // gets the token
import 'api_service.dart';

class CalendarService {
  static final String baseUrl = api; // base url for API

  // Get all events for user (supports optional test token)
  static Future<List<dynamic>> getEvents({String? testToken}) async {
    final token =
        testToken ?? await AuthService.getToken(); // use test token if provided
    if (token == null)
      throw Exception('User not authenticated'); // no token? stop

    final response = await http.get(
      Uri.parse('$baseUrl/calendar/events/'), // API endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // use token for auth
      },
    );

    if (response.statusCode == 200) return jsonDecode(response.body); // success
    throw Exception('Failed to load events'); // failed to get events
  }

  // Add a new event
  static Future<void> addEvent({
    required String title, // event name
    required String description, // notes
    required DateTime startTime, // start time
    required DateTime endTime, // end time
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/calendar/events/'), // API endpoint to add event
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
      Uri.parse(
          '$baseUrl/calendar/events/$id/'), // API endpoint to delete event
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
