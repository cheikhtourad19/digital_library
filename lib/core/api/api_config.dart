import 'dart:io';

class ApiConfig {
  static String get _defaultBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://192.168.1.39:8000/api';
    }
  }

  static final String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  // ── Auth ──────────────────────────────────────────────
  static const String authEndpoint = '/auth';
  static const String signupEndpoint = '$authEndpoint/signup';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String editPasswordEndpoint = '$authEndpoint/edit-password';

  // ── Books ─────────────────────────────────────────────
  static const String booksEndpoint = '/books';

  // ── Users ─────────────────────────────────────────────
  static const String usersEndpoint = '/users';
  static const String userDetailEndpoint = '$usersEndpoint/me';
  static String userDetailEndpointForAdminById(String id) =>
      '$usersEndpoint/$id';
  static const String editInfoEndpoint = '$usersEndpoint/me';
}
