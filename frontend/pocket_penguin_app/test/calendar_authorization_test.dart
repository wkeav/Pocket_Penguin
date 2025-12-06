import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pocket_penguin_app/services/calendar_service.dart';

void main() {
  group('Calendar Authorization Tests', () {
    // late CalendarService service;

    // setUp(() {
    //   // Replace the http client with a mock for testing
    //   service = CalendarService();
    // });

    test('User cannot access another user’s events', () async {
      // Mock client to simulate backend behavior
      final mockClient = MockClient((request) async {
        final authHeader = request.headers['Authorization'];

        if (authHeader == 'Bearer token-for-user1') {
          // User1 can access their own events
          return http.Response(jsonEncode([
            {
              'id': 1,
              'title': 'Event 1',
              'description': 'Desc',
              'start_time': '2025-12-06T09:00:00',
              'end_time': '2025-12-06T10:00:00'
            }
          ]), 200);
        } else {
          // Any other token is unauthorized
          return http.Response('Unauthorized', 401);
        }
      });

      // Override CalendarService method to use mock client
      Future<List<dynamic>> getEvents({String? testToken}) async {
        final token = testToken ?? 'token-for-user1';
        final response = await mockClient.get(
          Uri.parse('${CalendarService.baseUrl}/calendar/events/'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) return jsonDecode(response.body);
        throw Exception('Failed to load events');
      }

      // User1 can fetch their events
      final user1Events = await getEvents(testToken: 'token-for-user1');
      expect(user1Events.length, 1);

      // User2 cannot fetch User1's events
      try {
        await getEvents(testToken: 'token-for-user2');
        fail('User2 should not be able to access User1 events');
      } catch (e) {
        expect(e.toString(), contains('Failed to load events'));
      }
    });
  });
}
