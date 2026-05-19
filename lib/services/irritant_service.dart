import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/irritant.dart';
import 'photo_service.dart';

class IrritantService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('irritants');

  final PhotoService _photoService = PhotoService();

  // Ajoute un irritant avec ses photos dans Firebase
  Future<void> ajouterIrritant(Irritant irritant, {List<File>? photos}) async {
    List<String> photosUrls = [];

    if (photos != null && photos.isNotEmpty) {
      photosUrls = await _photoService.uploadPhotos(photos);
    }

    final irritantAvecPhotos = Irritant(
      nom: irritant.nom,
      nomReel: irritant.nomReel,
      uidAuteur: irritant.uidAuteur,
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
    for (final url in photosUrls) {
      await _photoService.supprimerPhoto(url);
    }
    await _collection.doc(id).delete();
  }

  Stream<List<Irritant>> irritantsParUtilisateur(String uid) {
    return FirebaseFirestore.instance
        .collection('irritants')
        .where('uidAuteur', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Irritant.fromMap(
                  doc.id,                              // ← String en premier
                  doc.data(),  // ← Map en second
                ))
            .toList());
  }
}