import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Alias for isAuthenticated (for consistency)
  static Future<bool> isLoggedIn() async {
    return await isAuthenticated();
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get stored user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Get user data as map
  static Future<Map<String, String>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    final email = prefs.getString(_userEmailKey);

    if (userId != null && email != null) {
      return {
        'userId': userId,
        'email': email,
        // Note: We don't store name locally, it comes from API
      };
    }
    return null;
  }

  // Store authentication data
  static Future<void> setAuthData(String token, String userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
  }

  // Clear authentication data (logout)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
  }

  // Check authentication and redirect if needed
  static Future<bool> checkAuthAndRedirect(BuildContext context, Map<String, String> translations) async {
    final isAuth = await isAuthenticated();
    if (!isAuth) {
      // Show login required dialog
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(translations['loginRequired'] ?? 'Login Required'),
              content: Text(translations['loginRequiredMessage'] ?? 'Please login to continue with this action.'),
              actions: [
                CupertinoDialogAction(
                  child: Text(translations['cancel'] ?? 'Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text(translations['login'] ?? 'Login'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate to login page
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(translations['loginRequired'] ?? 'Login Required'),
              content: Text(translations['loginRequiredMessage'] ?? 'Please login to continue with this action.'),
              actions: [
                TextButton(
                  child: Text(translations['cancel'] ?? 'Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(translations['login'] ?? 'Login'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate to login page
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            );
          },
        );
      }
      return false;
    }
    return true;
  }
}