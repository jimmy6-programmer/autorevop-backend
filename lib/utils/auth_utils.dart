import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthUtils {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userCountryKey = 'user_country';

  // Create secure storage instance
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      return false;
    }
  }

  // Alias for isAuthenticated (for consistency)
  static Future<bool> isLoggedIn() async {
    return await isAuthenticated();
  }

  // Get stored token
  static Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  // Get stored user ID
  static Future<String?> getUserId() async {
    try {
      return await _secureStorage.read(key: _userIdKey);
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  // Get stored user email
  static Future<String?> getUserEmail() async {
    try {
      return await _secureStorage.read(key: _userEmailKey);
    } catch (e) {
      debugPrint('Error getting user email: $e');
      return null;
    }
  }

  // Get stored user name
  static Future<String?> getUserName() async {
    try {
      return await _secureStorage.read(key: _userNameKey);
    } catch (e) {
      debugPrint('Error getting user name: $e');
      return null;
    }
  }

  // Get stored user phone
  static Future<String?> getUserPhone() async {
    try {
      return await _secureStorage.read(key: _userPhoneKey);
    } catch (e) {
      debugPrint('Error getting user phone: $e');
      return null;
    }
  }

  // Get stored user country
  static Future<String?> getUserCountry() async {
    try {
      return await _secureStorage.read(key: _userCountryKey);
    } catch (e) {
      debugPrint('Error getting user country: $e');
      return null;
    }
  }

  // Get user data as map
  static Future<Map<String, String>?> getUserData() async {
    try {
      final userId = await _secureStorage.read(key: _userIdKey);
      final email = await _secureStorage.read(key: _userEmailKey);
      final name = await _secureStorage.read(key: _userNameKey);
      final phone = await _secureStorage.read(key: _userPhoneKey);
      final country = await _secureStorage.read(key: _userCountryKey);

      if (userId != null && email != null) {
        return {
          'userId': userId,
          'email': email,
          'name': name ?? '',
          'phone': phone ?? '',
          'country': country ?? '',
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // Store authentication data
  static Future<void> setAuthData(String token, String userId, String email, {String? name, String? phone, String? country}) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _userIdKey, value: userId);
      await _secureStorage.write(key: _userEmailKey, value: email);
      if (name != null) await _secureStorage.write(key: _userNameKey, value: name);
      if (phone != null) await _secureStorage.write(key: _userPhoneKey, value: phone);
      if (country != null) await _secureStorage.write(key: _userCountryKey, value: country);
    } catch (e) {
      debugPrint('Error storing auth data: $e');
      rethrow;
    }
  }

  // Clear authentication data (logout)
  static Future<void> clearAuthData() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _userEmailKey);
      await _secureStorage.delete(key: _userNameKey);
      await _secureStorage.delete(key: _userPhoneKey);
      await _secureStorage.delete(key: _userCountryKey);
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
      rethrow;
    }
  }

  // Check authentication and redirect if needed
  static Future<bool> checkAuthAndRedirect(BuildContext context, Map<String, String> translations) async {
    final isAuth = await isAuthenticated();

    if (!isAuth) {
      // For iOS CupertinoTabScaffold, we need to use a different navigation approach
      // since pushNamed doesn't work within CupertinoTabView
      if (Platform.isIOS) {
        // Find the root navigator context
        final navigator = Navigator.of(context, rootNavigator: true);
        navigator.pushNamed('/login');
      } else {
        Navigator.of(context).pushNamed('/login');
      }
      return false;
    }

    return true;
  }
}