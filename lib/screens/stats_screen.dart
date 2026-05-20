import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/filtre_options.dart';
import '../models/irritant.dart';
import '../services/irritant_service.dart';
import '../widgets/filtre_bottom_sheet.dart';
import 'irritant_detail_screen.dart';

class StatsScreen extends StatefulWidget {
  final AppUser currentUser;

  const StatsScreen({super.key, required this.currentUser});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  FiltreOptions _filtres = FiltreOptions();

  final List<String> _tousLieux = [
    'Petite salle de réunion', 'Grande salle de réunion', 'Zone A',
    'Zone B', 'Zone C', 'Toilettes', 'Couloir', 'Entrée', 'Autre',
  ];
  final List<String> _tousTypes = [
    'Équipement', 'Climatisation', 'Bruit', 'Éclairage', 'Propreté', 'Autre',
  ];
  final List<String> _tousStatuts = [
    'Ouvert', 'En attente', 'En cours', 'Fini', 'Annulé',
  ];

  // Applique les filtres et tris à la liste d'irritants
  List<Irritant> _appliquerFiltres(List<Irritant> irritants) {
    List<Irritant> resultat = List.from(irritants);

    // Filtre par statut
    if (_filtres.statuts.isNotEmpty) {
      resultat = resultat
          .where((i) => _filtres.statuts.contains(i.statut))
          .toList();
    }

    // Filtre par lieu
    if (_filtres.lieux.isNotEmpty) {
      resultat = resultat
          .where((i) => _filtres.lieux.contains(i.lieu))
          .toList();
    }

    // Filtre par type
    if (_filtres.types.isNotEmpty) {
      resultat = resultat
          .where((i) => _filtres.types.contains(i.type))
          .toList();
    }

    // Tri par priorité (prioritaire sur le tri par date)
    if (_filtres.triPriorite != null) {
      resultat.sort((a, b) {
        final int pa = int.tryParse(a.priorite) ?? 5;
        final int pb = int.tryParse(b.priorite) ?? 5;
        return _filtres.triPriorite == 'asc' ? pa.compareTo(pb) : pb.compareTo(pa);
      });
    } else {
      // Tri par date
      resultat.sort((a, b) => _filtres.triDate == 'asc'
          ? a.date.compareTo(b.date)
          : b.date.compareTo(a.date));
    }

    return resultat;
  }

  // Ouvre la bottom sheet et récupère les filtres choisis
  void _ouvrirFiltres() async {
    final FiltreOptions? nouveauxFiltres = await showModalBottomSheet<FiltreOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FiltreBottomSheet(
          filtreInitial: _filtres,
          lieux: _tousLieux,
          types: _tousTypes,
          statuts: _tousStatuts,
        ),
      ),
    );

    // Met à jour les filtres si l'utilisateur a appuyé sur Appliquer
    if (nouveauxFiltres != null) {
      setState(() => _filtres = nouveauxFiltres);
    }
  }

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'Ouvert':
        return const Color(0xFF9E9E9E);
      case 'En attente':
        return const Color(0xFF42A5F5);
      case 'En cours':
        return const Color(0xFFFFA726);
      case 'Fini':
        return const Color(0xFF66BB6A);
      case 'Annulé':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color _couleurPriorite(String priorite) {
    final int p = int.tryParse(priorite) ?? 5;
    if (p <= 3) return const Color(0xFF66BB6A);
    if (p <= 6) return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Irritant>>(
        stream: IrritantService().irritantsParUtilisateur(widget.currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }

          final irritants = _appliquerFiltres(snapshot.data ?? []);

          if (irritants.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun signalement',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: irritants.length,
            itemBuilder: (context, index) {
              final irritant = irritants[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IrritantDetailScreen(
                      irritant: irritant,
                      currentUser: widget.currentUser,
                    ),
                  ),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                irritant.titre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 13),
                                  const SizedBox(width: 4),
                                  Text(
                                    irritant.lieu,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.menu, size: 13),
                                  const SizedBox(width: 4),
                                  Text(
                                    irritant.type,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.flag,
                                    size: 13,
                                    color: _couleurPriorite(irritant.priorite),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Priorité : ${irritant.priorite}/10',
                                    style: TextStyle(
                                      color: _couleurPriorite(irritant.priorite),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _couleurStatut(irritant.statut),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  irritant.statut,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: irritant.photosUrls.isNotEmpty
                              ? Image.network(
                                  irritant.photosUrls.first,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey.shade100,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, _, _) =>
                                      _placeholderPhoto(),
                                )
                              : _placeholderPhoto(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      // Bouton filtre flottant en bas à droite
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ouvrirFiltres,
        backgroundColor: _filtres.aDesFiltresActifs
            ? Colors.deepPurple          // Violet si filtres actifs
            : Colors.white,
        foregroundColor: _filtres.aDesFiltresActifs
            ? Colors.white
            : Colors.deepPurple,
        elevation: 2,
        icon: const Icon(Icons.tune),
        label: Text(_filtres.aDesFiltresActifs ? 'Filtres actifs' : 'Filtrer'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _placeholderPhoto() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Icon(Icons.image_outlined, color: Colors.grey, size: 32),
    );
  }
}