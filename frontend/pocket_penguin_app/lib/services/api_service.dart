import 'package:flutter/foundation.dart';

const String api = kIsWeb 
  ? 'http://localhost:8000/api'  // Local dev
  : 'https://your-production-api.com/api'; // Production 