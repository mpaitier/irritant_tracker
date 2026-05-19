import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/irritant.dart';
import '../services/irritant_service.dart';

class StatsScreen extends StatelessWidget {
  final AppUser currentUser;

  const StatsScreen({super.key, required this.currentUser});

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
    if (p <= 3) return const Color(0xFF66BB6A);      // Vert
    if (p <= 6) return const Color(0xFFFFA726);      // Orange
    return const Color(0xFFEF5350);                  // Rouge
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Irritant>>(
      stream: IrritantService().irritantsParUtilisateur(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erreur de chargement'));
        }

        final irritants = snapshot.data ?? [];

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
          padding: const EdgeInsets.all(16),
          itemCount: irritants.length,
          itemBuilder: (context, index) {
            final irritant = irritants[index];
            return Card(
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
                    // Infos à gauche
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                irritant.titre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ]
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 13,
                              ),
                              Text(
                                irritant.lieu,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ]
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.menu,
                                size: 13,
                              ),
                              Text(
                                irritant.type,
                                style: const TextStyle(color: Colors.grey, fontSize: 13)
                              ),
                            ]
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.flag,
                                size: 13,
                                color: _couleurPriorite(irritant.priorite),  // ← icône colorée
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Priorité : ${irritant.priorite}/10',
                                style: TextStyle(
                                  color: _couleurPriorite(irritant.priorite), // ← texte coloré
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Badge statut
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
                    // Photo à droite (ou placeholder)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: irritant.photosUrls.isNotEmpty
                          ? Image.network(
                            irritant.photosUrls.first,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (_, error, __) {
                              print('Erreur image: $error'); // ← pour voir l'erreur exacte dans les logs
                              return _placeholderPhoto();
                            },
                          )
                          : _placeholderPhoto(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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