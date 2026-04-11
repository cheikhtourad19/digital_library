import 'package:dio/dio.dart';

import '../core/api/api_config.dart';
import '../core/network/dio_client.dart';
import '../models/livre_model.dart';

class LivreService {
  final DioClient _dioClient;

  LivreService({required DioClient dioClient}) : _dioClient = dioClient;

  Future<({List<Livre> livres, int total, int page, int limite, int pages})>
  fetchLivres({
    String? categorie,
    double? minPrix,
    double? maxPrix,
    String? langue,
    String? search,
    int page = 1,
    int limite = 12,
  }) async {
    final queryParameters = <String, dynamic>{
      if (categorie != null && categorie.isNotEmpty) 'categorie': categorie,
      if (minPrix != null) 'minPrix': minPrix,
      if (maxPrix != null) 'maxPrix': maxPrix,
      if (langue != null && langue.isNotEmpty) 'langue': langue,
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page,
      'limite': limite,
    };

    final response = await _dioClient.dio.get(
      ApiConfig.livresEndpoint,
      queryParameters: queryParameters,
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final livresData = body['livres'];
    final paginationData = body['pagination'];

    if (livresData is! List || paginationData is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final livres = livresData
        .whereType<Map<String, dynamic>>()
        .map(Livre.fromJson)
        .toList();

    return (
      livres: livres,
      total: _parseInt(paginationData['total']),
      page: _parseInt(paginationData['page']),
      limite: _parseInt(paginationData['limite']),
      pages: _parseInt(paginationData['pages']),
    );
  }

  Future<Livre> fetchLivreById(String id) async {
    final response = await _dioClient.dio.get(ApiConfig.livreEndpoint(id));
    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    if (body['livre'] is Map<String, dynamic>) {
      return Livre.fromJson(body['livre'] as Map<String, dynamic>);
    }

    if (body['data'] is Map<String, dynamic>) {
      return Livre.fromJson(body['data'] as Map<String, dynamic>);
    }

    if (body.containsKey('_id') || body.containsKey('id')) {
      return Livre.fromJson(body);
    }

    throw Exception('Unexpected response format');
  }

  Future<({String url, String titre})> getLivrePdfUrl(String id) async {
    final response = await _dioClient.dio.get(ApiConfig.livreLireEndpoint(id));
    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final url = body['url']?.toString();
    final titre = body['titre']?.toString();

    if (url == null || titre == null) {
      throw Exception('Unexpected response format');
    }

    final normalizedUrl = _normalizeMinioUrl(url);
    return (url: normalizedUrl, titre: titre);
  }

  String _normalizeMinioUrl(String url) {
    const localhostMinio = 'http://localhost:9000';
    if (url.startsWith(localhostMinio)) {
      return url.replaceFirst(localhostMinio, ApiConfig.minioUrl);
    }
    return url;
  }

  Future<({double noteMoyenne})> ajouterAvis({
    required String livreId,
    required int note,
    String? commentaire,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConfig.livreAvisEndpoint(livreId),
      data: {'note': note, if (commentaire != null) 'commentaire': commentaire},
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    return (noteMoyenne: _parseDouble(body['noteMoyenne']));
  }

  Future<void> supprimerAvis(String livreId) async {
    await _dioClient.dio.delete(ApiConfig.livreAvisEndpoint(livreId));
  }

  Future<Livre> creerLivre({
    required String titre,
    required List<String> auteur,
    required String description,
    required String categorie,
    required double prix,
    int? nombrePages,
    required String langue,
    String? isbn,
    DateTime? datePublication,
    required List<int> pdfBytes,
    required String pdfFileName,
    required List<int> couvertureBytes,
    required String couvertureFileName,
  }) async {
    final formData = FormData();

    formData.fields.add(MapEntry('titre', titre));
    for (final auteurItem in auteur) {
      formData.fields.add(MapEntry('auteur', auteurItem));
    }
    formData.fields.add(MapEntry('description', description));
    formData.fields.add(MapEntry('categorie', categorie));
    formData.fields.add(MapEntry('prix', prix.toString()));
    if (nombrePages != null) {
      formData.fields.add(MapEntry('nombrePages', nombrePages.toString()));
    }
    formData.fields.add(MapEntry('langue', langue));

    if (isbn != null) {
      formData.fields.add(MapEntry('isbn', isbn));
    }
    if (datePublication != null) {
      formData.fields.add(
        MapEntry('datePublication', datePublication.toIso8601String()),
      );
    }

    formData.files.add(
      MapEntry('pdf', MultipartFile.fromBytes(pdfBytes, filename: pdfFileName)),
    );
    formData.files.add(
      MapEntry(
        'couverture',
        MultipartFile.fromBytes(couvertureBytes, filename: couvertureFileName),
      ),
    );

    final response = await _dioClient.dio.post(
      ApiConfig.livresEndpoint,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return _extractLivreFromResponse(response.data);
  }

  Future<Livre> modifierLivre({
    required String id,
    String? titre,
    List<String>? auteur,
    String? description,
    String? categorie,
    double? prix,
    int? nombrePages,
    String? langue,
    Object? isbn = _unset,
    Object? datePublication = _unset,
    List<int>? pdfBytes,
    String? pdfFileName,
    List<int>? couvertureBytes,
    String? couvertureFileName,
  }) async {
    final formData = FormData();

    if (titre != null) {
      formData.fields.add(MapEntry('titre', titre));
    }
    if (auteur != null) {
      for (final auteurItem in auteur) {
        formData.fields.add(MapEntry('auteur', auteurItem));
      }
    }
    if (description != null) {
      formData.fields.add(MapEntry('description', description));
    }
    if (categorie != null) {
      formData.fields.add(MapEntry('categorie', categorie));
    }
    if (prix != null) {
      formData.fields.add(MapEntry('prix', prix.toString()));
    }
    if (nombrePages != null) {
      formData.fields.add(MapEntry('nombrePages', nombrePages.toString()));
    }
    if (langue != null) {
      formData.fields.add(MapEntry('langue', langue));
    }

    if (!identical(isbn, _unset)) {
      if (isbn == null) {
        formData.fields.add(const MapEntry('isbn', ''));
      } else {
        formData.fields.add(MapEntry('isbn', isbn.toString()));
      }
    }

    if (!identical(datePublication, _unset)) {
      if (datePublication == null) {
        formData.fields.add(const MapEntry('datePublication', ''));
      } else if (datePublication is DateTime) {
        formData.fields.add(
          MapEntry('datePublication', datePublication.toIso8601String()),
        );
      }
    }

    if (pdfBytes != null && pdfFileName != null && pdfFileName.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'pdf',
          MultipartFile.fromBytes(pdfBytes, filename: pdfFileName),
        ),
      );
    }

    if (couvertureBytes != null &&
        couvertureFileName != null &&
        couvertureFileName.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'couverture',
          MultipartFile.fromBytes(
            couvertureBytes,
            filename: couvertureFileName,
          ),
        ),
      );
    }

    final response = await _dioClient.dio.put(
      ApiConfig.livreEndpoint(id),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return _extractLivreFromResponse(response.data);
  }

  Future<void> supprimerLivre(String id) async {
    await _dioClient.dio.delete(ApiConfig.livreEndpoint(id));
  }

  Livre _extractLivreFromResponse(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    if (body['livre'] is Map<String, dynamic>) {
      return Livre.fromJson(body['livre'] as Map<String, dynamic>);
    }

    if (body['data'] is Map<String, dynamic>) {
      return Livre.fromJson(body['data'] as Map<String, dynamic>);
    }

    if (body.containsKey('_id') || body.containsKey('id')) {
      return Livre.fromJson(body);
    }

    throw Exception('Unexpected response format');
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
}

const Object _unset = Object();
