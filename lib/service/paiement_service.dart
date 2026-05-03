import 'package:digital_library/core/api/api_config.dart';
import 'package:digital_library/core/network/dio_client.dart';
import 'dart:developer' as developer;

class PaiementService {
  final DioClient _dioClient;

  PaiementService({required DioClient dioClient}) : _dioClient = dioClient;

  Future<CreatePaymentIntentResponse> createPaymentIntent({
    required String commandeId,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConfig.createPaymentIntentEndpoint,
      data: {'commandeId': commandeId},
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    return CreatePaymentIntentResponse(
      clientSecret: body['clientSecret'] as String,
      paiementId: body['paiementId'] as String,
    );
  }

  Future<Paiement> confirmPayment({
    required String paiementId,
    String? paymentMethodId,
  }) async {
    developer.log('Calling confirm endpoint with paiementId: $paiementId', name: 'PaiementService');
    
    final response = await _dioClient.dio.post(
      ApiConfig.confirmPaymentEndpoint,
      data: {
        'paiementId': paiementId,
        if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
      },
    );

    developer.log('Confirm response: ${response.data}', name: 'PaiementService');

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    final paiementJson = body['paiement'];
    if (paiementJson is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    return Paiement.fromJson(paiementJson);
  }

  Future<Paiement> getPaiementById(String id) async {
    final response = await _dioClient.dio.get(ApiConfig.paiementByIdEndpoint(id));
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }
    return Paiement.fromJson(body);
  }

  Future<Paiement> getPaiementByCommande(String commandeId) async {
    final response = await _dioClient.dio.get(
      ApiConfig.paiementByCommandeEndpoint(commandeId),
    );
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }
    return Paiement.fromJson(body);
  }
}

class CreatePaymentIntentResponse {
  final String clientSecret;
  final String paiementId;

  CreatePaymentIntentResponse({
    required this.clientSecret,
    required this.paiementId,
  });
}

class Paiement {
  final String id;
  final String commandeId;
  final double montant;
  final String devise;
  final String statut;
  final DateTime? datePaiement;

  Paiement({
    required this.id,
    required this.commandeId,
    required this.montant,
    required this.devise,
    required this.statut,
    this.datePaiement,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['_id'] as String,
      commandeId: json['commande'] is String
          ? json['commande'] as String
          : (json['commande'] as Map<String, dynamic>?)?['_id'] as String? ?? '',
      montant: (json['montant'] as num).toDouble(),
      devise: json['devise'] as String,
      statut: json['statut'] as String,
      datePaiement: json['datePaiement'] != null
          ? DateTime.parse(json['datePaiement'] as String)
          : null,
    );
  }
}