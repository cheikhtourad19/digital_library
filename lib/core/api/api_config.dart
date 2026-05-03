import 'dart:io';

class ApiConfig {
  static String get _defaultBaseUrl {
    if (Platform.isAndroid) {
      return 'https://digital-library-backend-production-211f.up.railway.app/api';
    } else {
      return 'http://localhost:8000/api';
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
    return 'http://localhost:9000';
  }

  static final String minioUrl = String.fromEnvironment(
    'MINIO_URL',
    defaultValue: _defaultMinioUrl,
  );

  static final String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51TT5ivF8NFSibLhGgvDTp4X1HXETZmUFCdLJp8ZaRbMh1SUJ7EwKhRBy16Fn4fOCqgUoDIjLqScZzeM8irJcqBOx00h5i2aatx',
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
  static const String statsTopCategoriesByAgeEndpoint =
      '$statsEndpoint/top-categories-by-age';

  // ── Recommendations ─────────────────────────────────
  static const String recommendationsEndpoint = '/recommendations';
  static const String recommendationsByAgeEndpoint =
      '$recommendationsEndpoint/age';
  static const String recommendationsTrendingEndpoint =
      '$recommendationsEndpoint/trending';
  static const String recommendationsNewEndpoint =
      '$recommendationsEndpoint/new';

  // ── Commandes (Orders) ────────────────────────────────
  static const String commandesEndpoint = '/commandes';
  static const String myCommandesEndpoint = '$commandesEndpoint/my-commandes';
  static const String myBooksEndpoint = '$commandesEndpoint/my-books';
  static String commandeByIdEndpoint(String id) => '$commandesEndpoint/$id';
  static String commandesByClientEndpoint(String clientId) =>
      '$commandesEndpoint/client/$clientId';
  static String commandeStatusEndpoint(String id) =>
      '$commandesEndpoint/$id/status';

  // ── Avis (Reviews) ───────────────────────────────────
  static const String avisEndpoint = '/avis';
  static String avisByLivreEndpoint(String livreId) => '$avisEndpoint/$livreId';
  static String avisRateEndpoint(String livreId) => '$avisEndpoint/$livreId/rate';
  static String avisCommentEndpoint(String livreId) =>
      '$avisEndpoint/$livreId/comment';
  static String avisMyReviewEndpoint(String livreId) =>
      '$avisEndpoint/$livreId/my-review';

  // ── Paiements (Payments) ─────────────────────────────
  static const String paiementsEndpoint = '/paiements';
  static String paiementByIdEndpoint(String id) => '$paiementsEndpoint/$id';
  static String paiementByCommandeEndpoint(String commandeId) =>
      '$paiementsEndpoint/commande/$commandeId';
  static String paiementRefundEndpoint(String id) => '$paiementsEndpoint/$id/refund';
  static const String createPaymentIntentEndpoint =
      '$paiementsEndpoint/create-payment-intent';
  static const String confirmPaymentEndpoint = '$paiementsEndpoint/confirm';

  // ── Lectures (Reading) ─────────────────────────────────
  static const String lecturesEndpoint = '/lectures';
  static const String lecturesLatestEndpoint = '$lecturesEndpoint/latest';
  static String lectureByLivreEndpoint(String livreId) =>
      '$lecturesEndpoint/$livreId';
}
