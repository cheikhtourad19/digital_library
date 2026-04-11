class Lecture {
  static const Object _unset = Object();

  final String id;
  final String client;
  final String livre;
  final DateTime? dateDebut;
  final DateTime? dateDerniereLecture;
  final int dernierePage;
  final double progression;
  final bool termine;
  final DateTime? dateFin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Lecture({
    required this.id,
    required this.client,
    required this.livre,
    this.dateDebut,
    this.dateDerniereLecture,
    required this.dernierePage,
    required this.progression,
    required this.termine,
    this.dateFin,
    this.createdAt,
    this.updatedAt,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      client: (json['client'] ?? '').toString(),
      livre: (json['livre'] ?? '').toString(),
      dateDebut: _parseDate(json['dateDebut']),
      dateDerniereLecture: _parseDate(json['dateDerniereLecture']),
      dernierePage: _parseInt(json['dernierePage']),
      progression: _parseDouble(json['progression']),
      termine: json['termine'] is bool ? json['termine'] as bool : false,
      dateFin: _parseDate(json['dateFin']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'client': client,
      'livre': livre,
      'dateDebut': dateDebut?.toIso8601String(),
      'dateDerniereLecture': dateDerniereLecture?.toIso8601String(),
      'dernierePage': dernierePage,
      'progression': progression,
      'termine': termine,
      'dateFin': dateFin?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Lecture copyWith({
    String? id,
    String? client,
    String? livre,
    Object? dateDebut = _unset,
    Object? dateDerniereLecture = _unset,
    int? dernierePage,
    double? progression,
    bool? termine,
    Object? dateFin = _unset,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return Lecture(
      id: id ?? this.id,
      client: client ?? this.client,
      livre: livre ?? this.livre,
      dateDebut: identical(dateDebut, _unset)
          ? this.dateDebut
          : dateDebut as DateTime?,
      dateDerniereLecture: identical(dateDerniereLecture, _unset)
          ? this.dateDerniereLecture
          : dateDerniereLecture as DateTime?,
      dernierePage: dernierePage ?? this.dernierePage,
      progression: progression ?? this.progression,
      termine: termine ?? this.termine,
      dateFin: identical(dateFin, _unset) ? this.dateFin : dateFin as DateTime?,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
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
