class Avis {
  static const Object _unset = Object();

  final String id;
  final String clientId;
  final String? clientNom;
  final int note;
  final String commentaire;
  final DateTime? createdAt;

  Avis({
    required this.id,
    required this.clientId,
    this.clientNom,
    required this.note,
    required this.commentaire,
    this.createdAt,
  });

  factory Avis.fromJson(Map<String, dynamic> json) {
    final rawClient = json['client'];
    String parsedClientId = '';
    String? parsedClientNom;

    if (rawClient is Map<String, dynamic>) {
      parsedClientId = (rawClient['_id'] ?? rawClient['id'] ?? '').toString();
      parsedClientNom = rawClient['nom']?.toString();
    } else if (rawClient != null) {
      parsedClientId = rawClient.toString();
    }

    return Avis(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      clientId: parsedClientId,
      clientNom: parsedClientNom,
      note: _parseInt(json['note']),
      commentaire: (json['commentaire'] ?? '').toString(),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'client': clientNom != null
          ? {'_id': clientId, 'nom': clientNom}
          : clientId,
      'note': note,
      'commentaire': commentaire,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Avis copyWith({
    String? id,
    String? clientId,
    Object? clientNom = _unset,
    int? note,
    String? commentaire,
    Object? createdAt = _unset,
  }) {
    return Avis(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientNom: identical(clientNom, _unset)
          ? this.clientNom
          : clientNom as String?,
      note: note ?? this.note,
      commentaire: commentaire ?? this.commentaire,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
