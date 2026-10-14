import 'package:shared_preferences/shared_preferences.dart';

/// Remembers which language the user picked on the language selection page.
/// Used by the splash screen to decide whether to show that page again.
class LanguageStorage {
  static const String _languageKey = 'app_language';

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  Future<bool> hasChosenLanguage() async {
    final language = await getLanguage();
    return language != null && language.isNotEmpty;
  }
}
