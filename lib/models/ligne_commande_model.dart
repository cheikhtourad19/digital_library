class LigneCommande {
  final String livre;
  final String? livreTitre;
  final String? livreCouverture;
  final double prixAchat;
  final String titreLivre;

  LigneCommande({
    required this.livre,
    this.livreTitre,
    this.livreCouverture,
    required this.prixAchat,
    required this.titreLivre,
  });

  factory LigneCommande.fromJson(Map<String, dynamic> json) {
    final livreRaw = json['livre'];
    final livreMap = livreRaw is Map<String, dynamic> ? livreRaw : null;

    return LigneCommande(
      livre: (livreMap?['_id'] ?? livreRaw ?? '').toString(),
      livreTitre: livreMap?['titre']?.toString(),
      livreCouverture: livreMap?['couverture']?.toString(),
      prixAchat: _parseDouble(json['prixAchat']),
      titreLivre: (json['titreLivre'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'livre': livre,
      'prixAchat': prixAchat,
      'titreLivre': titreLivre,
      if (livreTitre != null || livreCouverture != null)
        'livreDetails': {'titre': livreTitre, 'couverture': livreCouverture},
    };
  }

  LigneCommande copyWith({
    String? livre,
    Object? livreTitre = _unset,
    Object? livreCouverture = _unset,
    double? prixAchat,
    String? titreLivre,
  }) {
    return LigneCommande(
      livre: livre ?? this.livre,
      livreTitre: identical(livreTitre, _unset)
          ? this.livreTitre
          : livreTitre as String?,
      livreCouverture: identical(livreCouverture, _unset)
          ? this.livreCouverture
          : livreCouverture as String?,
      prixAchat: prixAchat ?? this.prixAchat,
      titreLivre: titreLivre ?? this.titreLivre,
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
}

const Object _unset = Object();
