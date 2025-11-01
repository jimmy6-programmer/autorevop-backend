import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/translations.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  static const List<String> supportedLanguages = ['en', 'fr', 'rw', 'sw'];

  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  // For backward compatibility with existing code
  Locale get locale => Locale(_currentLanguage);

  // For backward compatibility
  Future<void> setLocale(String languageCode) async {
    await setLanguage(languageCode);
  }

  LocaleProvider() {
    _loadSavedLanguage();
  }

  // Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_localeKey) ?? 'en';

      // Validate the saved language code
      if (supportedLanguages.contains(savedLanguageCode)) {
        _currentLanguage = savedLanguageCode;
      } else {
        _currentLanguage = 'en'; // Fallback to English
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved language: $e');
      _currentLanguage = 'en'; // Fallback to English
    }
  }

  // Change language and save to SharedPreferences
  Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguages.contains(languageCode)) {
      throw ArgumentError('Unsupported language: $languageCode');
    }

    try {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);

      // Update current language
      _currentLanguage = languageCode;

      // Notify listeners to rebuild UI
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving language: $e');
      rethrow;
    }
  }

  // Get translation for a key
  String translate(String key) {
    return translations[_currentLanguage]?[key] ?? translations['en']?[key] ?? key;
  }

  // Get language name for display
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'rw':
        return 'Kinyarwanda';
      case 'sw':
        return 'Kiswahili';
      default:
        return 'English';
    }
  }

  // Get current language name
  String get currentLanguageName => getLanguageName(_currentLanguage);

  // Get flag emoji for language
  String getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇬🇧';
      case 'fr':
        return '🇫🇷';
      case 'rw':
        return '🇷🇼';
      case 'sw':
        return '🇰🇪';
      default:
        return '🇺🇳';
    }
  }

  // Get current flag emoji
  String get currentFlagEmoji => getFlagEmoji(_currentLanguage);
}