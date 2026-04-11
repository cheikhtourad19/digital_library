import 'avis_model.dart';
import 'categorie_model.dart';

class Livre {
  static const Object _unset = Object();

  final String id;
  final String titre;
  final List<String> auteur;
  final String description;
  final Object? categorie;
  final double prix;
  final String couverture;
  final String? couvertureUrl;
  final String? fichierPDF;
  final int nombrePages;
  final String langue;
  final String? isbn;
  final DateTime? datePublication;
  final double noteMoyenne;
  final int nombreAvis;
  final List<Avis> avis;
  final bool actif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Livre({
    required this.id,
    required this.titre,
    required this.auteur,
    required this.description,
    required this.categorie,
    required this.prix,
    required this.couverture,
    this.couvertureUrl,
    this.fichierPDF,
    required this.nombrePages,
    required this.langue,
    this.isbn,
    this.datePublication,
    required this.noteMoyenne,
    required this.nombreAvis,
    required this.avis,
    required this.actif,
    this.createdAt,
    this.updatedAt,
  });

  String? get categorieId {
    final value = categorie;
    if (value == null) {
      return null;
    }
    if (value is Categorie) {
      return value.id;
    }
    return value.toString();
  }

  Categorie? get categorieObj {
    final value = categorie;
    if (value is Categorie) {
      return value;
    }
    return null;
  }

  factory Livre.fromJson(Map<String, dynamic> json) {
    final parsedAvis =
        (json['avis'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(Avis.fromJson)
            .toList() ??
        const <Avis>[];

    return Livre(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      titre: (json['titre'] ?? '').toString(),
      auteur: _parseAuteurs(json['auteur']),
      description: (json['description'] ?? '').toString(),
      categorie: _parseCategorie(json['categorie']),
      prix: _parseDouble(json['prix']),
      couverture: (json['couverture'] ?? '').toString(),
      couvertureUrl: json['couvertureUrl']?.toString(),
      fichierPDF: json['fichierPDF']?.toString(),
      nombrePages: _parseInt(json['nombrePages']),
      langue: (json['langue'] ?? '').toString(),
      isbn: json['isbn']?.toString(),
      datePublication: _parseDate(json['datePublication']),
      noteMoyenne: _parseDouble(json['noteMoyenne']),
      nombreAvis: json['nombreAvis'] == null
          ? parsedAvis.length
          : _parseInt(json['nombreAvis']),
      avis: parsedAvis,
      actif: json['actif'] is bool ? json['actif'] as bool : true,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'titre': titre,
      'auteur': auteur,
      'description': description,
      'categorie': categorie is Categorie
          ? (categorie as Categorie).toJson()
          : categorie?.toString(),
      'prix': prix,
      'couverture': couverture,
      'couvertureUrl': couvertureUrl,
      'fichierPDF': fichierPDF,
      'nombrePages': nombrePages,
      'langue': langue,
      'isbn': isbn,
      'datePublication': datePublication?.toIso8601String(),
      'noteMoyenne': noteMoyenne,
      'nombreAvis': nombreAvis,
      'avis': avis.map((item) => item.toJson()).toList(),
      'actif': actif,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Livre copyWith({
    String? id,
    String? titre,
    List<String>? auteur,
    String? description,
    Object? categorie = _unset,
    double? prix,
    String? couverture,
    Object? couvertureUrl = _unset,
    Object? fichierPDF = _unset,
    int? nombrePages,
    String? langue,
    Object? isbn = _unset,
    Object? datePublication = _unset,
    double? noteMoyenne,
    int? nombreAvis,
    List<Avis>? avis,
    bool? actif,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return Livre(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      auteur: auteur ?? this.auteur,
      description: description ?? this.description,
      categorie: identical(categorie, _unset) ? this.categorie : categorie,
      prix: prix ?? this.prix,
      couverture: couverture ?? this.couverture,
      couvertureUrl: identical(couvertureUrl, _unset)
          ? this.couvertureUrl
          : couvertureUrl as String?,
      fichierPDF: identical(fichierPDF, _unset)
          ? this.fichierPDF
          : fichierPDF as String?,
      nombrePages: nombrePages ?? this.nombrePages,
      langue: langue ?? this.langue,
      isbn: identical(isbn, _unset) ? this.isbn : isbn as String?,
      datePublication: identical(datePublication, _unset)
          ? this.datePublication
          : datePublication as DateTime?,
      noteMoyenne: noteMoyenne ?? this.noteMoyenne,
      nombreAvis: nombreAvis ?? this.nombreAvis,
      avis: avis ?? this.avis,
      actif: actif ?? this.actif,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  static Object? _parseCategorie(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map<String, dynamic>) {
      return Categorie.fromJson(value);
    }
    return value.toString();
  }

  static List<String> _parseAuteurs(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value == null) {
      return const <String>[];
    }
    return <String>[value.toString()];
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
