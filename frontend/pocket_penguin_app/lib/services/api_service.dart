// Using centralize configuration for API endpoints
// This file defines the base URL used by other services to communicate with the backend API.
// It helps maintain consistency and makes it easier to switch between development and production environments. 
import 'package:flutter/foundation.dart';
class ApiConfig {
  static String get baseUrl {
    if (kDebugMode) {
      // For web, use localhost. For mobile emulators, you'd use different IPs
      return 'http://localhost:8000/api';
    } else {
      // Production
      return 'https://pocket-penguin.onrender.com/api';
    }
  }

  // Convenience getters for specific endpoints
  static String get authUrl => '$baseUrl/auth';
  static String get usersUrl => '$baseUrl/users';
  static String get calendarUrl => '$baseUrl/calendar';
  static String get journalUrl => '$baseUrl/journal';
}

