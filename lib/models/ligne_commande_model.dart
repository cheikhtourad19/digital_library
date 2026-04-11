class LigneCommande {
  final String livre;
  final double prixAchat;
  final String titreLivre;

  LigneCommande({
    required this.livre,
    required this.prixAchat,
    required this.titreLivre,
  });

  factory LigneCommande.fromJson(Map<String, dynamic> json) {
    return LigneCommande(
      livre: (json['livre'] ?? '').toString(),
      prixAchat: _parseDouble(json['prixAchat']),
      titreLivre: (json['titreLivre'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'livre': livre, 'prixAchat': prixAchat, 'titreLivre': titreLivre};
  }

  LigneCommande copyWith({
    String? livre,
    double? prixAchat,
    String? titreLivre,
  }) {
    return LigneCommande(
      livre: livre ?? this.livre,
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
