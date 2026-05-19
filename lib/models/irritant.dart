class Irritant {
  final String? id;
  final String nom;           // "Anonyme" ou nom affiché
  final String nomReel;       // Toujours le vrai nom (visible admin seulement)
  final String uidAuteur;     // UID Firebase de l'auteur
  final String titre;
  final String lieu;
  final String type;
  final String description;
  final String priorite;
  final String statut;
  final DateTime date;
  final List<String> photosUrls;

  Irritant({
    this.id,
    required this.nom,
    required this.nomReel,
    required this.uidAuteur,
    required this.titre,
    required this.lieu,
    required this.type,
    required this.description,
    required this.priorite,
    this.statut = 'Ouvert',
    DateTime? date,
    List<String>? photosUrls,
  })  : date = date ?? DateTime.now(),
        photosUrls = photosUrls ?? [];

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'nomReel': nomReel,
      'uidAuteur': uidAuteur,
      'titre': titre,
      'lieu': lieu,
      'type': type,
      'description': description,
      'priorite': priorite,
      'statut': statut,
      'date': date.toIso8601String(),
      'photosUrls': photosUrls,
    };
  }

  factory Irritant.fromMap(String id, Map<String, dynamic> map) {
    return Irritant(
      id: id,
      nom: map['nom'] ?? 'Anonyme',
      nomReel: map['nomReel'] ?? '',
      uidAuteur: map['uidAuteur'] ?? '',
      titre: map['titre'] ?? '',
      lieu: map['lieu'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      priorite: map['priorite'] ?? 'Normale',
      statut: map['statut'] ?? 'Ouvert',
      date: DateTime.parse(map['date']),
      photosUrls: List<String>.from(map['photosUrls'] ?? []),
    );
  }
}