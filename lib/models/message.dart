class Message {
  final String? id;
  final String texte;
  final String auteur;       // Nom affiché
  final String uidAuteur;    // UID Firebase
  final String role;         // 'employe' ou 'support'
  final DateTime date;

  Message({
    this.id,
    required this.texte,
    required this.auteur,
    required this.uidAuteur,
    required this.role,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'texte': texte,
      'auteur': auteur,
      'uidAuteur': uidAuteur,
      'role': role,
      'date': date.toIso8601String(),
    };
  }

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      texte: map['texte'] ?? '',
      auteur: map['auteur'] ?? '',
      uidAuteur: map['uidAuteur'] ?? '',
      role: map['role'] ?? 'employe',
      date: DateTime.parse(map['date']),
    );
  }
}