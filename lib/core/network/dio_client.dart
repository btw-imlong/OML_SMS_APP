import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_config.dart';

class DioClient {
  final Dio dio;
  final TokenStorage _tokenStorage;

  DioClient()
    : _tokenStorage = TokenStorage(),
      dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }

  Future<void> testConnection() async {
    try {
      final response = await dio.get('/swagger-ui/index.html');

      print('API connected: ${response.statusCode}');
    } catch (e) {
      print('API connection failed: $e');
    }
  }
}
