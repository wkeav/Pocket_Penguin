import 'dart:convert';
import 'package:http/http.dart' as http;

class ProgressApi {
  static const String baseUrl = 'YOUR_BACKEND_URL_HERE';

  static Future<Map<String, dynamic>> fetchMonthlyProgress(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/progress/monthly/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch monthly progress');
    }
  }
}
