// Modèle qui stocke tous les filtres sélectionnés
class FiltreOptions {
  // Tri par date : 'asc' ou 'desc'
  String triDate;

  // Tri par priorité : null = pas de tri par priorité
  String? triPriorite;

  // Filtres multi-sélection
  List<String> statuts;
  List<String> lieux;
  List<String> types;

  FiltreOptions({
    this.triDate = 'desc',
    this.triPriorite,
    List<String>? statuts,
    List<String>? lieux,
    List<String>? types,
  })  : statuts = statuts ?? [],
        lieux = lieux ?? [],
        types = types ?? [];

  // Retourne true si au moins un filtre est actif
  bool get aDesFiltresActifs =>
      statuts.isNotEmpty ||
      lieux.isNotEmpty ||
      types.isNotEmpty ||
      triPriorite != null ||
      triDate != 'desc';

  // Copie avec modifications
  FiltreOptions copyWith({
    String? triDate,
    String? triPriorite,
    bool clearPriorite = false,
    List<String>? statuts,
    List<String>? lieux,
    List<String>? types,
  }) {
    return FiltreOptions(
      triDate: triDate ?? this.triDate,
      triPriorite: clearPriorite ? null : (triPriorite ?? this.triPriorite),
      statuts: statuts ?? this.statuts,
      lieux: lieux ?? this.lieux,
      types: types ?? this.types,
    );
  }

  // Réinitialise tout
  FiltreOptions reset() => FiltreOptions();
}