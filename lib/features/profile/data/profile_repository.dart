import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_sms/core/network/dio_client.dart';
import 'package:flutter_sms/core/storage/token_storage.dart';
import 'package:flutter_sms/features/profile/data/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final DioClient _client;

  Future<Options> _auth() async {
    final token = await TokenStorage().getToken();
    return Options(
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
  }

  /// GET /api/auth/me
  Future<UserProfile> me() async {
    final res = await _client.dio.get('/api/auth/me', options: await _auth());
    final data = res.data is String ? jsonDecode(res.data as String) : res.data;
    return UserProfile.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// POST /api/auth/logout
  Future<void> logout() async {
    await _client.dio.post('/api/auth/logout', options: await _auth());
  }
}
