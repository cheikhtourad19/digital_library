class Categorie {
  static const Object _unset = Object();

  final String id;
  final String nom;
  final String description;
  final String slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Categorie({
    required this.id,
    required this.nom,
    required this.description,
    required this.slug,
    this.createdAt,
    this.updatedAt,
  });

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      nom: (json['nom'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nom': nom,
      'description': description,
      'slug': slug,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Categorie copyWith({
    String? id,
    String? nom,
    String? description,
    String? slug,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return Categorie(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
