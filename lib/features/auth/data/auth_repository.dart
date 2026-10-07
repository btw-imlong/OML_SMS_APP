import 'package:dio/dio.dart';
import 'package:flutter_sms/core/network/dio_client.dart';
import 'package:flutter_sms/features/auth/data/models/login_respone.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    return LoginResponse.fromJson(response.data);
  }
}
