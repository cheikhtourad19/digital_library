import '../core/api/api_config.dart';
import '../core/network/dio_client.dart';
import '../models/stats_model.dart';

class StatsService {
  final DioClient _dioClient;

  StatsService({required DioClient dioClient}) : _dioClient = dioClient;

  Future<StatsOverview> getOverview({int days = 30}) async {
    final response = await _dioClient.dio.get(
      ApiConfig.statsOverviewEndpoint,
      queryParameters: {'days': days},
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected overview response format');
    }

    return StatsOverview.fromJson(body);
  }

  Future<List<TopLivreStat>> getTopLivres({int limit = 10}) async {
    final response = await _dioClient.dio.get(
      ApiConfig.statsTopLivresEndpoint,
      queryParameters: {'limit': limit},
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected top livres response format');
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      return const [];
    }

    final items = data['items'];
    if (items is! List) {
      return const [];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(TopLivreStat.fromJson)
        .toList();
  }

  Future<SalesTrendStats> getSalesTrend({
    int days = 30,
    String groupBy = 'day',
  }) async {
    final response = await _dioClient.dio.get(
      ApiConfig.statsSalesTrendEndpoint,
      queryParameters: {'days': days, 'groupBy': groupBy},
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected sales trend response format');
    }

    return SalesTrendStats.fromJson(body);
  }

  Future<UsersStats> getUsersStats({
    int days = 30,
    String groupBy = 'day',
  }) async {
    final response = await _dioClient.dio.get(
      ApiConfig.statsUsersEndpoint,
      queryParameters: {'days': days, 'groupBy': groupBy},
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected users stats response format');
    }

    return UsersStats.fromJson(body);
  }

  Future<List<CategoryStat>> getCategoriesStats({int limit = 10}) async {
    final response = await _dioClient.dio.get(
      ApiConfig.statsCategoriesEndpoint,
      queryParameters: {'limit': limit},
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected categories stats response format');
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      return const [];
    }

    final items = data['items'];
    if (items is! List) {
      return const [];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(CategoryStat.fromJson)
        .toList();
  }
}
