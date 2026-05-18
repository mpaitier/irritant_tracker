import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/irritant.dart';

class IrritantService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('irritants');

  // Ajouter un irritant
  Future<void> ajouterIrritant(Irritant irritant) async {
    await _collection.add(irritant.toMap());
  }

  // Récupérer tous les irritants
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

  // Mettre à jour le statut
  Future<void> mettreAJourStatut(String id, String statut) async {
    await _collection.doc(id).update({'statut': statut});
  }

  // Supprimer un irritant
  Future<void> supprimerIrritant(String id) async {
    await _collection.doc(id).delete();
  }
}
