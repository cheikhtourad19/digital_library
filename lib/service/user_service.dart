import 'package:dio/dio.dart';

import '../../core/api/api_config.dart';
import '../../core/network/dio_client.dart';
import '../../models/user_model.dart';

class UserService {
  final DioClient _dioClient;

  UserService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  Future<List<User>> fetchAllUsers() async {
    try {
      final response = await _dioClient.dio.get(ApiConfig.usersEndpoint);

      if (response.statusCode == 200) {
        final body = response.data;

        if (body is Map<String, dynamic>) {
          final usersData = body['data'];

          if (usersData is List) {
            return usersData
                .whereType<Map<String, dynamic>>()
                .map((json) => User.fromJson(json))
                .toList();
          } else {
            throw Exception('Expected data to be a list');
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }
}
