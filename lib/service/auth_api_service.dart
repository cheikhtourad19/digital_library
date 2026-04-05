import 'package:dio/dio.dart';

import '../../core/api/api_config.dart';
import '../../core/network/dio_client.dart';
import '../../models/user_model.dart';

class AuthApiService {
  final DioClient _dioClient;

  AuthApiService({required DioClient dioClient}) : _dioClient = dioClient;

  ({String token, User user}) _parseAuthResponse(
    dynamic data, {
    required String fallbackAction,
  }) {
    if (data is! Map<String, dynamic>) {
      throw Exception('$fallbackAction failed: invalid server response');
    }

    final dynamic tokenValue = data['token'];
    final dynamic userValue = data['user'];

    if (tokenValue is! String || userValue is! Map<String, dynamic>) {
      throw Exception('$fallbackAction failed: missing token or user data');
    }

    return (token: tokenValue, user: User.fromJson(userValue));
  }

  String _extractErrorMessage(
    dynamic data, {
    required String fallback,
    String? networkMessage,
  }) {
    if (data is Map<String, dynamic>) {
      final dynamic message = data['message'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    if (data is num || data is bool) {
      return data.toString();
    }

    if (data is List && data.isNotEmpty) {
      return data.join(', ');
    }

    if (networkMessage != null && networkMessage.trim().isNotEmpty) {
      return '$fallback: $networkMessage';
    }

    return fallback;
  }

  Future<({String token, User user})> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConfig.signupEndpoint,
        data: {
          'nom': fullName,
          'email': email,
          'motDePasse': password,
          // Compatibility for backends expecting English key names.
          'password': password,
        },
        options: Options(extra: {'requiresAuth': false}),
      );

      if (response.statusCode == 201) {
        return _parseAuthResponse(response.data, fallbackAction: 'Signup');
      }

      throw Exception(
        _extractErrorMessage(response.data, fallback: 'Signup failed'),
      );
    } on DioException catch (e) {
      throw Exception(
        _extractErrorMessage(
          e.response?.data,
          fallback: 'Network error',
          networkMessage: e.message,
        ),
      );
    } catch (e) {
      throw Exception('Signup error: $e');
    }
  }

  Future<({String token, User user})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'motDePasse': password,
          // Compatibility for backends expecting English key names.
          'password': password,
        },
        options: Options(extra: {'requiresAuth': false}),
      );

      if (response.statusCode == 200) {
        return _parseAuthResponse(response.data, fallbackAction: 'Login');
      }

      throw Exception(
        _extractErrorMessage(response.data, fallback: 'Login failed'),
      );
    } on DioException catch (e) {
      throw Exception(
        _extractErrorMessage(
          e.response?.data,
          fallback: 'Network error',
          networkMessage: e.message,
        ),
      );
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
}
