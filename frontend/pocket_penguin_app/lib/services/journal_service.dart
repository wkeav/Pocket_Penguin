import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pocket_penguin_app/models/journal.dart';

class JournalApi {
  final String baseUrl = 'http://10.0.2.2:8000/api/journal/';
  final String token; // JWT token for authentication

  JournalApi(this.token);

  Future<List<JournalEntry>> fetchEntries() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => JournalEntry.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch entries');
    }
  }

  Future<void> createEntry(JournalEntry entry) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(entry.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create entry');
    }
  }
}
