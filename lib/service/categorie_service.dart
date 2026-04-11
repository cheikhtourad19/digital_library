import '../core/api/api_config.dart';
import '../core/network/dio_client.dart';
import '../models/categorie_model.dart';

class CategorieService {
  final DioClient _dioClient;

  CategorieService({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<Categorie>> fetchCategories() async {
    final response = await _dioClient.dio.get(ApiConfig.categoriesEndpoint);
    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final data = body['data'];
    if (data is! List) {
      throw Exception('Unexpected response format');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(Categorie.fromJson)
        .toList();
  }

  Future<Categorie> createCategorie({
    required String nom,
    String? description,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConfig.categoriesEndpoint,
      data: {
        'nom': nom,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    return Categorie.fromJson(data);
  }
}
