import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';
import 'auth_api_service.dart';

enum UserRole { client, admin }

class AuthService {
  final AuthApiService _apiService;
  final FlutterSecureStorage _secureStorage;

  AuthService({AuthApiService? apiService, FlutterSecureStorage? secureStorage})
    : _apiService = apiService ?? AuthApiService(),
      _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<String?> getSessionToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      return null;
    }
  }

  Future<UserRole?> getUserRole() async {
    try {
      final roleStr = await _secureStorage.read(key: 'user_role');
      if (roleStr == null) return null;
      return roleStr == 'admin' ? UserRole.admin : UserRole.client;
    } catch (e) {
      return null;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final userJson = await _secureStorage.read(key: 'user_data');
      if (userJson == null) return null;
      // In production, parse JSON properly
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<({String token, User user})> login({
    required String email,
    required String password,
  }) async {
    final result = await _apiService.login(email: email, password: password);

    // Store token and role securely
    await _secureStorage.write(key: 'auth_token', value: result.token);
    await _secureStorage.write(
      key: 'user_role',
      value: result.user.isAdmin ? 'admin' : 'client',
    );

    return result;
  }

  Future<({String token, User user})> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final result = await _apiService.signup(
      fullName: fullName,
      email: email,
      password: password,
    );

    // Store token and role securely
    await _secureStorage.write(key: 'auth_token', value: result.token);
    await _secureStorage.write(
      key: 'user_role',
      value: result.user.isAdmin ? 'admin' : 'client',
    );

    return result;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'user_role');
    await _secureStorage.delete(key: 'user_data');
  }
}
