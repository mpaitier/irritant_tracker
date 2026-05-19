import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/irritant.dart';
import 'photo_service.dart';

class IrritantService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('irritants');

  // PhotoService réutilisable
  final PhotoService _photoService = PhotoService();

  // Ajoute un irritant avec ses photos dans Firebase
  Future<void> ajouterIrritant(Irritant irritant, {List<File>? photos}) async {
    List<String> photosUrls = [];

    // Upload toutes les photos si fournies
    if (photos != null && photos.isNotEmpty) {
      photosUrls = await _photoService.uploadPhotos(photos);
    }

    // Crée l'irritant avec les URLs des photos
    final irritantAvecPhotos = Irritant(
      nom: irritant.nom,
      titre: irritant.titre,
      lieu: irritant.lieu,
      type: irritant.type,
      description: irritant.description,
      priorite: irritant.priorite,
      statut: irritant.statut,
      photosUrls: photosUrls,
    );

    await _collection.add(irritantAvecPhotos.toMap());
  }

  // Récupère tous les irritants en temps réel
  Stream<List<Irritant>> getIrritants() {
    return _collection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Irritant.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ))
            .toList());
  }

  // Met à jour le statut d'un irritant
  Future<void> mettreAJourStatut(String id, String statut) async {
    await _collection.doc(id).update({'statut': statut});
  }

  // Supprime un irritant et ses photos associées
  Future<void> supprimerIrritant(String id, List<String> photosUrls) async {
    // Supprime chaque photo du Storage
    for (final url in photosUrls) {
      await _photoService.supprimerPhoto(url);
    }
    // Supprime le document Firestore
    await _collection.doc(id).delete();
  }
}