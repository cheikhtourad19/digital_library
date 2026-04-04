import 'dart:convert';

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

  // ── Session ───────────────────────────────────────────────────

  Future<bool> isSessionValid() async {
    final token = await getSessionToken();
    if (token == null || token.isEmpty) return false;
    return !(await isTokenExpired());
  }

  Future<bool> isTokenExpired() async {
    try {
      final token = await getSessionToken();
      if (token == null) return true;

      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final exp = payload['exp'] as int?;
      if (exp == null) return false;

      return DateTime.now().isAfter(
        DateTime.fromMillisecondsSinceEpoch(exp * 1000),
      );
    } catch (e) {
      return true;
    }
  }

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
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  // ── Auth actions ──────────────────────────────────────────────

  Future<({String token, User user})> login({
    required String email,
    required String password,
  }) async {
    final result = await _apiService.login(email: email, password: password);
    await _saveSession(result.token, result.user);
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
    await _saveSession(result.token, result.user);
    return result;
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }

  // ── Private ───────────────────────────────────────────────────

  Future<void> _saveSession(String token, User user) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    await _secureStorage.write(
      key: 'user_role',
      value: user.isAdmin ? 'admin' : 'client',
    );
    await _secureStorage.write(
      key: 'user_data',
      value: jsonEncode(user.toJson()),
    );
  }
}
