class Irritant {
  final String? id;
  final String nom;
  final String titre;
  final String lieu;
  final String type;
  final String description;
  final String priorite;
  final String statut;
  final DateTime date;

  Irritant({
    this.id,
    required this.nom,
    required this.titre,
    required this.lieu,
    required this.type,
    required this.description,
    required this.priorite,
    this.statut = 'ouvert',
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'titre': titre,
      'lieu': lieu,
      'type': type,
      'description': description,
      'priorite': priorite,
      'statut': statut,
      'date': date.toIso8601String(),
    };
  }

  factory Irritant.fromMap(String id, Map<String, dynamic> map) {
    return Irritant(
      id: id,
      nom: map['nom'] ?? 'Anonyme',
      titre: map['titre'] ?? '',
      lieu: map['lieu'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      priorite: map['priorite'] ?? 'Normale',
      statut: map['statut'] ?? 'ouvert',
      date: DateTime.parse(map['date']),
    );
  }
}
