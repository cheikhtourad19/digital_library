import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api/api_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    assert(() {
      final uri = Uri.parse(ApiConfig.baseUrl);
      if (uri.port == 9000) {
        throw FlutterError(
          'ApiConfig.baseUrl points to port 9000 (MinIO). Use backend port 8000.',
        );
      }
      return true;
    }());

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([AuthInterceptor(), ErrorInterceptor()]);

    // Debug network tracing: helpful when backend seems unreachable.
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );
  }

  Dio get dio => _dio;
}
