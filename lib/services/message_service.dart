import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Référence à la sous-collection messages d'un irritant
  CollectionReference _messagesRef(String irritantId) {
    return _firestore
        .collection('irritants')
        .doc(irritantId)
        .collection('messages');
  }

  // Écoute les messages en temps réel
  Stream<List<Message>> getMessages(String irritantId) {
    return _messagesRef(irritantId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Message.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Envoie un message
  Future<void> envoyerMessage(String irritantId, Message message) async {
    await _messagesRef(irritantId).add(message.toMap());
  }
}