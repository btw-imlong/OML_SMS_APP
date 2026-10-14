import 'package:flutter_sms/core/network/api_client.dart';
import 'package:flutter_sms/core/services/token_storage.dart';

class AuthRepository {
  AuthRepository({
    required this.api,
    required this.storage,
  });

  final ApiClient api;
  final TokenStorage storage;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await api.post('/api/auth/login', body: {
      'email': email,
      'password': password,
    });

    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException('Login succeeded but no token returned');
    }

    await storage.saveSession(
      token: token,
      id: (data['id'] as num?)?.toInt() ?? 0,
      email: data['email']?.toString() ?? email,
      fullName: data['fullName']?.toString() ?? '',
    );
    api.setToken(token);

    return data;
  }

  Future<Map<String, dynamic>> me() async {
    return api.get('/api/auth/me');
  }

  Future<void> logout() async {
    try {
      await api.post('/api/auth/logout');
    } catch (_) {
      // ignore network errors on logout
    } finally {
      await storage.clear();
      api.setToken(null);
    }
  }

  Future<bool> restoreSession() async {
    final session = await storage.getSession();
    if (session == null) return false;
    final token = session['token'] as String?;
    if (token == null || token.isEmpty) return false;
    api.setToken(token);
    try {
      await me();
      return true;
    } catch (_) {
      await storage.clear();
      api.setToken(null);
      return false;
    }
  }
}
