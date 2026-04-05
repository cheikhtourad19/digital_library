
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
