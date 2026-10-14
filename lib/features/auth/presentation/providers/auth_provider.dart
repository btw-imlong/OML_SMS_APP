import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sms/core/network/api_client.dart';
import 'package:flutter_sms/core/services/token_storage.dart';
import 'package:flutter_sms/features/auth/data/auth_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: 'http://localhost:8080');
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(apiClientProvider),
    storage: ref.watch(tokenStorageProvider),
  );
});

/// Current logged-in user (null = logged out).
final authUserProvider =
    AsyncNotifierProvider<AuthNotifier, Map<String, dynamic>?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<Map<String, dynamic>?> build() async {
    // Try to restore session on app start
    final ok = await _repo.restoreSession();
    if (!ok) return null;
    return _repo.me();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final data = await _repo.login(email: email, password: password);
      return data;
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(null);
  }
}
