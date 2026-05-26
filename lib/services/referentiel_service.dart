import 'package:cloud_firestore/cloud_firestore.dart';

class ReferentielService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupère tous les lieux depuis la collection "locations"
  Future<List<String>> getLieux() async {
    final snapshot = await _firestore.collection('locations').get();
    final lieux = snapshot.docs
        .map((doc) => doc.data()['Nom'] as String)
        .where((nom) => nom.isNotEmpty)
        .toList();

    // Trie alphabétiquement mais garde "Autre" en dernier
    lieux.sort((a, b) {
      if (a == 'Autre') return 1;
      if (b == 'Autre') return -1;
      return a.compareTo(b);
    });

    return lieux;
  }

  // Récupère tous les types depuis la collection "irritant_type"
  Future<List<String>> getTypes() async {
    final snapshot = await _firestore.collection('irritant_type').get();
    final types = snapshot.docs
        .map((doc) => doc.data()['Nom'] as String)
        .where((nom) => nom.isNotEmpty)
        .toList();

    // Trie alphabétiquement mais garde "Autre" en dernier
    types.sort((a, b) {
      if (a == 'Autre') return 1;
      if (b == 'Autre') return -1;
      return a.compareTo(b);
    });

    return types;
  }
}