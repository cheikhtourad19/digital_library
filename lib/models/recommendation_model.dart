class RecommendedBook {
  final String id;
  final String titre;
  final List<String> auteur;
  final String categorieNom;
  final double prix;
  final double noteMoyenne;
  final String couverture;
  final DateTime? createdAt;

  const RecommendedBook({
    required this.id,
    required this.titre,
    required this.auteur,
    required this.categorieNom,
    required this.prix,
    required this.noteMoyenne,
    required this.couverture,
    required this.createdAt,
  });

  factory RecommendedBook.fromJson(Map<String, dynamic> json) {
    final categorieRaw = json['categorie'];
    final categorieNom = categorieRaw is Map<String, dynamic>
        ? (categorieRaw['nom'] ?? '').toString()
        : categorieRaw?.toString() ?? '';

    return RecommendedBook(
      id: (json['livreId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      titre: (json['titre'] ?? '').toString(),
      auteur: _parseAuteur(json['auteur']),
      categorieNom: categorieNom,
      prix: _parseDouble(json['prix']),
      noteMoyenne: _parseDouble(json['noteMoyenne']),
      couverture: (json['couvertureUrl'] ?? json['couverture'] ?? '')
          .toString(),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static List<String> _parseAuteur(dynamic raw) {
    if (raw is List) {
      return raw.map((item) => item.toString()).toList();
    }
    if (raw == null) {
      return const <String>[];
    }
    return <String>[raw.toString()];
  }

  static double _parseDouble(dynamic value) {
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
