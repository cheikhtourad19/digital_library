import '../core/api/api_config.dart';
import '../core/network/dio_client.dart';
import '../models/commande_model.dart';
import '../models/livre_model.dart';

class DuplicatePurchaseException implements Exception {
  final String message;
  final List<({String id, String titre})> livresDejaPossedes;

  DuplicatePurchaseException({
    required this.message,
    required this.livresDejaPossedes,
  });
}

class CommandeService {
  final DioClient _dioClient;

  CommandeService({required DioClient dioClient}) : _dioClient = dioClient;

  Future<Commande> createCommande({
    required List<String> livreIds,
    required String modePaiement,
    String? transactionId,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConfig.commandesEndpoint,
        data: {
          'livreIds': livreIds,
          'modePaiement': modePaiement,
          if (transactionId != null && transactionId.isNotEmpty)
            'transactionId': transactionId,
        },
      );

      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw Exception('Unexpected response format');
      }

      final commandeJson = body['commande'];
      if (commandeJson is! Map<String, dynamic>) {
        throw Exception('Unexpected response format');
      }

      return Commande.fromJson(commandeJson);
    } on Exception catch (e) {
      if (_isDuplicateError(e)) {
        throw DuplicatePurchaseException(
          message: _extractErrorMessage(e) ?? 'Duplicate purchase',
          livresDejaPossedes: _extractOwnedBooks(e),
        );
      }
      rethrow;
    }
  }

  Future<({List<Commande> commandes, int total, int page, int limite, int pages})>
  getMyCommandes({
    int page = 1,
    int limite = 10,
    String? statut,
  }) async {
    final response = await _dioClient.dio.get(
      ApiConfig.myCommandesEndpoint,
      queryParameters: {
        'page': page,
        'limite': limite,
        if (statut != null && statut.isNotEmpty) 'statut': statut,
      },
    );

    return _parseCommandesPaginationResponse(response.data);
  }

  Future<({List<Livre> livres, int total})> getMyBooks() async {
    final response = await _dioClient.dio.get(ApiConfig.myBooksEndpoint);
    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final livresJson = body['livres'];
    if (livresJson is! List) {
      throw Exception('Unexpected response format');
    }

    final livres = livresJson
        .whereType<Map<String, dynamic>>()
        .map(Livre.fromJson)
        .toList();

    return (livres: livres, total: _parseInt(body['total']));
  }

  Future<({List<Commande> commandes, int total, int page, int limite, int pages})>
  getAllCommandes({
    int page = 1,
    int limite = 20,
    String? statut,
    String? clientId,
  }) async {
    final response = await _dioClient.dio.get(
      ApiConfig.commandesEndpoint,
      queryParameters: {
        'page': page,
        'limite': limite,
        if (statut != null && statut.isNotEmpty) 'statut': statut,
        if (clientId != null && clientId.isNotEmpty) 'clientId': clientId,
      },
    );

    return _parseCommandesPaginationResponse(response.data);
  }

  Future<Commande> getCommandeById(String id) async {
    final response = await _dioClient.dio.get(ApiConfig.commandeByIdEndpoint(id));
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }
    return Commande.fromJson(body);
  }

  Future<({List<Commande> commandes, int total, int page, int limite, int pages})>
  getCommandesByClient({
    required String clientId,
    int page = 1,
    int limite = 10,
  }) async {
    final response = await _dioClient.dio.get(
      ApiConfig.commandesByClientEndpoint(clientId),
      queryParameters: {'page': page, 'limite': limite},
    );

    return _parseCommandesPaginationResponse(response.data);
  }

  Future<Commande> updateCommandeStatus({
    required String id,
    required String statut,
  }) async {
    final response = await _dioClient.dio.patch(
      ApiConfig.commandeStatusEndpoint(id),
      data: {'statut': statut},
    );
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final commandeJson = body['commande'];
    if (commandeJson is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    return Commande.fromJson(commandeJson);
  }

  Future<void> deleteCommande(String id) async {
    await _dioClient.dio.delete(ApiConfig.commandeByIdEndpoint(id));
  }

  ({List<Commande> commandes, int total, int page, int limite, int pages})
  _parseCommandesPaginationResponse(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final commandesJson = body['commandes'];
    final paginationJson = body['pagination'];

    if (commandesJson is! List || paginationJson is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final commandes = commandesJson
        .whereType<Map<String, dynamic>>()
        .map(Commande.fromJson)
        .toList();

    return (
      commandes: commandes,
      total: _parseInt(paginationJson['total']),
      page: _parseInt(paginationJson['page']),
      limite: _parseInt(paginationJson['limite']),
      pages: _parseInt(paginationJson['pages']),
    );
  }

  bool _isDuplicateError(Exception e) {
    final message = _extractErrorMessage(e);
    return message != null &&
        message.toLowerCase().contains('déjà') &&
        message.toLowerCase().contains('livres');
  }

  String? _extractErrorMessage(Exception e) {
    try {
      final dynamic data = (e as dynamic).response?.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  List<({String id, String titre})> _extractOwnedBooks(Exception e) {
    try {
      final dynamic data = (e as dynamic).response?.data;
      if (data is! Map<String, dynamic>) {
        return const <({String id, String titre})>[];
      }
      final books = data['livresDejaPossedes'];
      if (books is! List) {
        return const <({String id, String titre})>[];
      }

      return books.whereType<Map<String, dynamic>>().map((book) {
        return (
          id: (book['id'] ?? '').toString(),
          titre: (book['titre'] ?? '').toString(),
        );
      }).toList();
    } catch (_) {
      return const <({String id, String titre})>[];
    }
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
