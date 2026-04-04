import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => 'Délai de connexion dépassé',
      DioExceptionType.connectionError => 'Pas de connexion réseau',
      DioExceptionType.badResponse => _parseServerError(err.response),
      _ => 'Erreur inattendue',
    };

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        message: message,
      ),
    );
  }

  String _parseServerError(Response? response) {
    if (response == null) return 'Pas de réponse du serveur';

    final data = response.data;
    if (data is Map && data.containsKey('message')) {
      return data['message'].toString();
    }

    return switch (response.statusCode) {
      400 => 'Requête invalide',
      401 => 'Non authentifié',
      403 => 'Accès interdit',
      404 => 'Ressource introuvable',
      422 => 'Données invalides',
      500 => 'Erreur serveur',
      _ => 'Erreur ${response.statusCode}',
    };
  }
}