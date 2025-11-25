import 'dart:convert'; //JSON encoding/decoding 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/*
  Handles all communications with backend API 
*/

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  // Register a new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
          'password_confirm': passwordConfirm,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error};
      }
    } catch (e) {
      return {'success': false, 'error': {'message': e.toString()}};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) { //backend returns JWT token 
        final data = jsonDecode(response.body);
        final accessToken = data['access'];  // Extract token from response
        final refreshToken = data['refresh'];
        final userData = data['user'];

        // Save tokens and user data
        await _saveTokens(accessToken, refreshToken);  // Save to local storage
        await _saveUserData(userData);

        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error};
      }
    } catch (e) {
      return {'success': false, 'error': {'message': e.toString()}};
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    // Backend verifies token and returns user data
    try {
      final token = await getAccessToken();
      if (token == null) {
        return {'success': false, 'error': {'message': 'Not authenticated'}};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveUserData(data);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': {'message': 'Failed to get user'}};
      }
    } catch (e) {
      return {'success': false, 'error': {'message': e.toString()}};
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(refreshTokenKey);
    await prefs.remove(userKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  // Save tokens
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, accessToken);
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  // Save user data
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(userData));
  }
}

