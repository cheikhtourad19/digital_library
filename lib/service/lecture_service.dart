import '../core/api/api_config.dart';
import '../core/network/dio_client.dart';
import '../models/lecture_model.dart';

class LectureService {
  final DioClient _dioClient;

  LectureService({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<Lecture>> getLatestLectures() async {
    final response = await _dioClient.dio.get(ApiConfig.lecturesLatestEndpoint);
    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final lecturesJson = body['lectures'];
    if (lecturesJson is! List) {
      throw Exception('Unexpected response format');
    }

    return lecturesJson
        .whereType<Map<String, dynamic>>()
        .map(Lecture.fromJson)
        .toList();
  }

  Future<({List<Lecture> lectures, int total, int page, int limite, int pages})>
      getAllLectures({
    int page = 1,
    int limite = 20,
    bool? termine,
  }) async {
    final response = await _dioClient.dio.get(
      ApiConfig.lecturesEndpoint,
      queryParameters: {
        'page': page,
        'limite': limite,
        if (termine != null) 'termine': termine.toString(),
      },
    );

    return _parseLecturesPaginationResponse(response.data);
  }

  Future<Lecture?> getLectureByLivre(String livreId) async {
    final response = await _dioClient.dio.get(
      ApiConfig.lectureByLivreEndpoint(livreId),
    );
    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final lectureJson = body['lecture'];
    if (lectureJson == null) {
      return null;
    }

    if (lectureJson is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    return Lecture.fromJson(lectureJson);
  }

  Future<Lecture> updateLecture({
    required String livreId,
    int? dermierePage,
    int? progression,
    bool? termine,
  }) async {
    final response = await _dioClient.dio.put(
      ApiConfig.lectureByLivreEndpoint(livreId),
      data: {
        if (dermierePage != null) 'dernierePage': dermierePage,
        if (progression != null) 'progression': progression,
        if (termine != null) 'termine': termine,
      },
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final lectureJson = body['lecture'];
    if (lectureJson is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    return Lecture.fromJson(lectureJson);
  }

  ({List<Lecture> lectures, int total, int page, int limite, int pages})
      _parseLecturesPaginationResponse(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final lecturesJson = body['lectures'];
    final paginationJson = body['pagination'];

    if (lecturesJson is! List || paginationJson is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final lectures = lecturesJson
        .whereType<Map<String, dynamic>>()
        .map(Lecture.fromJson)
        .toList();

    return (
      lectures: lectures,
      total: _parseInt(paginationJson['total']),
      page: _parseInt(paginationJson['page']),
      limite: _parseInt(paginationJson['limite']),
      pages: _parseInt(paginationJson['pages']),
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
}