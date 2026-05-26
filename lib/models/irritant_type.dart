class IrritantType {
  final String id;
  final String nom;

  IrritantType({required this.id, required this.nom});

  factory IrritantType.fromMap(String id, Map<String, dynamic> map) {
    return IrritantType(
      id: id,
      nom: map['nom'] ?? '',
    );
  }
}