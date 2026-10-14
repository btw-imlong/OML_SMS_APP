import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _keyToken = 'auth_token';
  static const _keyEmail = 'auth_email';
  static const _keyFullName = 'auth_full_name';
  static const _keyId = 'auth_id';

  Future<void> saveSession({
    required String token,
    required int id,
    required String email,
    required String fullName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setInt(_keyId, id);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyFullName, fullName);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    if (token == null) return null;
    return {
      'token': token,
      'id': prefs.getInt(_keyId),
      'email': prefs.getString(_keyEmail),
      'fullName': prefs.getString(_keyFullName),
    };
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyId);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyFullName);
  }
}
