class User {
  final String id;
  final String nom;
  final String email;
  final bool isAdmin;
  final List<String>? historiqueRecherche;
  final DateTime? dateCreation;

  User({
    required this.id,
    required this.nom,
    required this.email,
    required this.isAdmin,
    this.historiqueRecherche,
    this.dateCreation,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      historiqueRecherche: List<String>.from(json['historiqueRecherche'] ?? []),
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'isAdmin': isAdmin,
      'historiqueRecherche': historiqueRecherche,
      'dateCreation': dateCreation?.toIso8601String(),
    };
  }
}
