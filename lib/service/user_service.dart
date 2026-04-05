import '../../../core/api/api_config.dart';
import '../../../core/network/dio_client.dart';
import '../../../models/user_model.dart';

class UserService {
  final DioClient _dioClient;

  UserService({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<User>> fetchAllUsers() async {
    final response = await _dioClient.dio.get(ApiConfig.usersEndpoint);

    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final usersData = body['data'];

    if (usersData is! List) {
      throw Exception('Expected data to be a list');
    }

    return usersData
        .whereType<Map<String, dynamic>>()
        .map((json) => User.fromJson(json))
        .toList();
  }

  Future<({String message, Map<String, dynamic>? user})>
  fetchCurrentUser() async {
    final response = await _dioClient.dio.get(ApiConfig.editInfoEndpoint);
    final data = response.data as Map<String, dynamic>;

    if (response.statusCode == 200 && data['success'] == true) {
      return (
        message: data['msg'] as String,
        user: data['data'] as Map<String, dynamic>?,
      );
    }
    throw Exception(data['msg'] ?? 'Failed to fetch user info');
  }

  Future<({String message, Map<String, dynamic>? user})> editInfo({
    String? nom,
    String? email,
  }) async {
    final response = await _dioClient.dio.put(
      ApiConfig.editInfoEndpoint,
      data: {if (nom != null) 'nom': nom, if (email != null) 'email': email},
    );

    final data = response.data as Map<String, dynamic>;

    if (response.statusCode == 200 && data['success'] == true) {
      return (
        message: data['msg'] as String,
        user: data['data'] as Map<String, dynamic>?,
      );
    }

    throw Exception(data['msg'] ?? 'Edit info failed');
  }

  Future<User> fetchUserById(int id) async {
    final response = await _dioClient.dio.get('${ApiConfig.usersEndpoint}/$id');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> updateUser(int id, Map<String, dynamic> payload) async {
    final response = await _dioClient.dio.put(
      '${ApiConfig.usersEndpoint}/$id',
      data: payload,
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteUser(int id) async {
    await _dioClient.dio.delete('${ApiConfig.usersEndpoint}/$id');
  }
}
