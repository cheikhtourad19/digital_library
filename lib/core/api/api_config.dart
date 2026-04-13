import 'dart:io';

class ApiConfig {
  static String get _defaultBaseUrl {
    if (Platform.isAndroid) {
      return 'https://digital-library-backend-production-211f.up.railway.app/api';
    } else {
      return 'http://192.168.1.39:8000/api';
      // return 'https://digital-library-backend-production-211f.up.railway.app/api';
    }
  }

  static final String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static String get _defaultMinioUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:9000';
    }
    return 'http://192.168.1.39:9000';
  }

  static final String minioUrl = String.fromEnvironment(
    'MINIO_URL',
    defaultValue: _defaultMinioUrl,
  );

  // ── Auth ──────────────────────────────────────────────
  static const String authEndpoint = '/auth';
  static const String signupEndpoint = '$authEndpoint/signup';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String editPasswordEndpoint = '$authEndpoint/edit-password';

  // ── Books ─────────────────────────────────────────────
  static const String booksEndpoint = '/books';
  static const String livresEndpoint = '/livres';
  static String livreEndpoint(String id) => '/livres/$id';
  static String livreLireEndpoint(String id) => '/livres/$id/lire';
  static String livreAvisEndpoint(String id) => '/livres/$id/avis';

  // ── Categories ───────────────────────────────────────
  static const String categoriesEndpoint = '/categories';

  // ── Users ─────────────────────────────────────────────
  static const String usersEndpoint = '/users';
  static const String userDetailEndpoint = '$usersEndpoint/me';
  static String userDetailEndpointForAdminById(String id) =>
      '$usersEndpoint/$id';
  static const String editInfoEndpoint = '$usersEndpoint/me';
  static String deleteUserEndpoint(String id) => '$usersEndpoint/$id';

  // ── Stats ─────────────────────────────────────────────
  static const String statsEndpoint = '/stats';
  static const String statsOverviewEndpoint = '$statsEndpoint/overview';
  static const String statsTopLivresEndpoint = '$statsEndpoint/top-livres';
  static const String statsSalesTrendEndpoint = '$statsEndpoint/sales-trend';
  static const String statsUsersEndpoint = '$statsEndpoint/users';
  static const String statsCategoriesEndpoint = '$statsEndpoint/categories';
}
