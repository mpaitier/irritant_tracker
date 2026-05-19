// Modèle représentant un utilisateur de l'app
class AppUser {
  final String uid;           // ID Firebase Auth
  final String email;
  final String nom;           // Prénom + Nom
  final String role;          // 'employe' ou 'admin'

  AppUser({
    required this.uid,
    required this.email,
    required this.nom,
    required this.role,
  });

  // Depuis un document Firestore
  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      nom: map['nom'] ?? '',
      role: map['role'] ?? 'employe',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nom': nom,
      'role': role,
    };
  }

  // Raccourci pour vérifier si admin
  bool get isAdmin => role == 'admin';
}