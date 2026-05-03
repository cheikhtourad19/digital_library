import '../core/api/api_config.dart';
import '../core/network/dio_client.dart';
import '../models/recommendation_model.dart';

class RecommendationService {
  final DioClient _dioClient;

  RecommendationService({required DioClient dioClient})
    : _dioClient = dioClient;

  Future<List<RecommendedBook>> getRecommendedByAge() async {
    final response = await _dioClient.dio.get(
      ApiConfig.recommendationsByAgeEndpoint,
    );
    return _extractBooks(response.data);
  }

  Future<List<RecommendedBook>> getTrendingBooks() async {
    final response = await _dioClient.dio.get(
      ApiConfig.recommendationsTrendingEndpoint,
    );
    return _extractBooks(response.data);
  }

  Future<List<RecommendedBook>> getNewBooks({int limit = 10}) async {
    final response = await _dioClient.dio.get(
      ApiConfig.recommendationsNewEndpoint,
      queryParameters: {'limit': limit},
    );
    return _extractBooks(response.data);
  }

  List<RecommendedBook> _extractBooks(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected recommendations response format');
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      return const <RecommendedBook>[];
    }

    final items = data['items'];
    if (items is! List) {
      return const <RecommendedBook>[];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(RecommendedBook.fromJson)
        .toList();
  }
}
