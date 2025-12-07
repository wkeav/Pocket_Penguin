import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pocket_penguin_app/models/journal.dart';
import 'auth_service.dart';
import 'api_service.dart';

class JournalApi {
  static final String baseUrl = '$api/journal/';

  static Future<List<JournalEntry>> fetchEntries() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Handle paginated response (DRF pagination returns {results: [...]})
      final List jsonList =
          data is Map && data.containsKey('results') ? data['results'] : data;
      return jsonList.map((e) => JournalEntry.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch entries');
    }
  }

  static Future<void> createEntry(JournalEntry entry) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('User not authenticated');

    print('Creating entry with token: ${token.substring(0, 20)}...');
    print('Entry data: ${json.encode(entry.toJson())}');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(entry.toJson()),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception(
          'Failed to create entry: ${response.statusCode} - ${response.body}');
    }
  }
}
