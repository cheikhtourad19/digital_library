import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor({required FlutterSecureStorage secureStorage})
    : _storage = secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublic = options.extra['requiresAuth'] == false;
    if (isPublic) {
      options.headers.remove('Authorization');
      return handler.next(options);
    }

    final token = await _storage.read(key: 'access_token');

    if (token != null && !JwtDecoder.isExpired(token)) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers.remove('Authorization');
    }

    handler.next(options);
  }
}
