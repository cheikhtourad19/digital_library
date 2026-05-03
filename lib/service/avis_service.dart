import '../core/api/api_config.dart';
import '../core/network/dio_client.dart';
import '../models/avis_model.dart';

class AvisService {
  final DioClient _dioClient;

  AvisService({required DioClient dioClient}) : _dioClient = dioClient;

  Future<
    ({
      String livreId,
      String titre,
      double noteMoyenne,
      int totalAvis,
      Map<int, int> distribution,
      List<Avis> avis,
      int total,
      int page,
      int limite,
      int pages,
    })
  > getBookReviews({
    required String livreId,
    int page = 1,
    int limite = 10,
  }) async {
    final response = await _dioClient.dio.get(
      ApiConfig.avisByLivreEndpoint(livreId),
      queryParameters: {'page': page, 'limite': limite},
    );
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final avisData = body['avis'];
    final ratingData = body['rating'];
    final paginationData = body['pagination'];
    if (avisData is! List ||
        ratingData is! Map<String, dynamic> ||
        paginationData is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    return (
      livreId: (body['livreId'] ?? '').toString(),
      titre: (body['titre'] ?? '').toString(),
      noteMoyenne: _parseDouble(ratingData['noteMoyenne']),
      totalAvis: _parseInt(ratingData['totalAvis']),
      distribution: _parseDistribution(ratingData['distribution']),
      avis: avisData
          .whereType<Map<String, dynamic>>()
          .map(Avis.fromJson)
          .toList(),
      total: _parseInt(paginationData['total']),
      page: _parseInt(paginationData['page']),
      limite: _parseInt(paginationData['limite']),
      pages: _parseInt(paginationData['pages']),
    );
  }

  Future<Avis?> getMyReview(String livreId) async {
    final response = await _dioClient.dio.get(
      ApiConfig.avisMyReviewEndpoint(livreId),
    );
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }
    final avisJson = body['avis'];
    if (avisJson == null) {
      return null;
    }
    if (avisJson is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }
    return Avis.fromJson(avisJson);
  }

  Future<({String message, int note, double noteMoyenne, int nombreAvis})>
  rateBook({
    required String livreId,
    required int note,
  }) async {
    final response = await _dioClient.dio.put(
      ApiConfig.avisRateEndpoint(livreId),
      data: {'note': note},
    );
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }
    return (
      message: (body['message'] ?? '').toString(),
      note: _parseInt(body['note']),
      noteMoyenne: _parseDouble(body['noteMoyenne']),
      nombreAvis: _parseInt(body['nombreAvis']),
    );
  }

  Future<({String message, double noteMoyenne, int nombreAvis})> commentBook({
    required String livreId,
    required String commentaire,
    int? note,
  }) async {
    final response = await _dioClient.dio.put(
      ApiConfig.avisCommentEndpoint(livreId),
      data: {
        'commentaire': commentaire,
        if (note != null) 'note': note,
      },
    );
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }
    return (
      message: (body['message'] ?? '').toString(),
      noteMoyenne: _parseDouble(body['noteMoyenne']),
      nombreAvis: _parseInt(body['nombreAvis']),
    );
  }

  Future<({String message, double noteMoyenne, int nombreAvis})> deleteMyReview(
    String livreId,
  ) async {
    final response = await _dioClient.dio.delete(ApiConfig.avisByLivreEndpoint(livreId));
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }
    return (
      message: (body['message'] ?? '').toString(),
      noteMoyenne: _parseDouble(body['noteMoyenne']),
      nombreAvis: _parseInt(body['nombreAvis']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Map<int, int> _parseDistribution(dynamic value) {
    if (value is! Map) {
      return const <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    }

    final parsed = <int, int>{};
    for (var i = 1; i <= 5; i++) {
      final raw = value[i.toString()] ?? value[i];
      parsed[i] = _parseInt(raw);
    }
    return parsed;
  }
}
