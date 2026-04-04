import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra['requiresAuth'] != false;
    if (!requiresAuth) {
      options.headers.remove('Authorization');
      return handler.next(options);
    }

    final publicPaths = ['/auth/login', '/auth/signup', '/books/preview'];
    if (publicPaths.any((p) => options.path.contains(p))) {
      options.headers.remove('Authorization');
      return handler.next(options);
    }

    final token =
        await _storage.read(key: 'auth_token') ??
        await _storage.read(key: 'access_token');

    if (token != null && !JwtDecoder.isExpired(token)) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers.remove('Authorization');
    }

    handler.next(options);
  }
}
