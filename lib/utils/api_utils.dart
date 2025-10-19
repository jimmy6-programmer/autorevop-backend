import 'dart:io' show Platform;

// API Base URL configuration
String getApiBaseUrl() {
  // Using live Render backend
  return 'https://autorevop-backend.onrender.com';

  // For local development (uncomment when needed):
  // if (Platform.isAndroid) {
  //   return 'http://10.0.2.2:5001'; // Android emulator
  // } else {
  //   return 'http://localhost:5001'; // iOS simulator, web, etc.
  // }
}