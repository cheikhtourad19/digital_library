import 'ligne_commande_model.dart';

enum CommandeStatut { en_attente, confirmee, echouee, remboursee }

class CommandeStatutMapper {
  static CommandeStatut fromJson(dynamic value) {
    final raw = value?.toString() ?? '';

    switch (raw) {
      case 'en_attente':
        return CommandeStatut.en_attente;
      case 'confirmée':
      case 'confirmee':
        return CommandeStatut.confirmee;
      case 'échouée':
      case 'echouee':
        return CommandeStatut.echouee;
      case 'remboursée':
      case 'remboursee':
        return CommandeStatut.remboursee;
      default:
        return CommandeStatut.en_attente;
    }
  }

  static String toJson(CommandeStatut statut) {
    switch (statut) {
      case CommandeStatut.en_attente:
        return 'en_attente';
      case CommandeStatut.confirmee:
        return 'confirmée';
      case CommandeStatut.echouee:
        return 'échouée';
      case CommandeStatut.remboursee:
        return 'remboursée';
    }
  }
}

class Commande {
  static const Object _unset = Object();

  final String id;
  final String client;
  final List<LigneCommande> livres;
  final double montantTotal;
  final String modePaiement;
  final String? transactionId;
  final CommandeStatut statut;
  final DateTime? dateCommande;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Commande({
    required this.id,
    required this.client,
    required this.livres,
    required this.montantTotal,
    required this.modePaiement,
    this.transactionId,
    required this.statut,
    this.dateCommande,
    this.createdAt,
    this.updatedAt,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      client: (json['client'] ?? '').toString(),
      livres:
          (json['livres'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(LigneCommande.fromJson)
              .toList() ??
          const <LigneCommande>[],
      montantTotal: _parseDouble(json['montantTotal']),
      modePaiement: (json['modePaiement'] ?? '').toString(),
      transactionId: json['transactionId']?.toString(),
      statut: CommandeStatutMapper.fromJson(json['statut']),
      dateCommande: _parseDate(json['dateCommande']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'client': client,
      'livres': livres.map((item) => item.toJson()).toList(),
      'montantTotal': montantTotal,
      'modePaiement': modePaiement,
      'transactionId': transactionId,
      'statut': CommandeStatutMapper.toJson(statut),
      'dateCommande': dateCommande?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Commande copyWith({
    String? id,
    String? client,
    List<LigneCommande>? livres,
    double? montantTotal,
    String? modePaiement,
    Object? transactionId = _unset,
    CommandeStatut? statut,
    Object? dateCommande = _unset,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return Commande(
      id: id ?? this.id,
      client: client ?? this.client,
      livres: livres ?? this.livres,
      montantTotal: montantTotal ?? this.montantTotal,
      modePaiement: modePaiement ?? this.modePaiement,
      transactionId: identical(transactionId, _unset)
          ? this.transactionId
          : transactionId as String?,
      statut: statut ?? this.statut,
      dateCommande: identical(dateCommande, _unset)
          ? this.dateCommande
          : dateCommande as DateTime?,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
