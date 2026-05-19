import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream qui écoute l'état de connexion en temps réel
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Récupère l'utilisateur connecté actuellement
  User? get currentUser => _auth.currentUser;

  // Connexion avec email et mot de passe
  Future<AppUser?> connecter(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Récupère les infos supplémentaires depuis Firestore
      return await getAppUser(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      // Retourne un message d'erreur lisible
      throw _getErrorMessage(e.code);
    }
  }

  // Récupère le profil complet de l'utilisateur depuis Firestore
  Future<AppUser?> getAppUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }

  // Déconnexion
  Future<void> deconnecter() async {
    await _auth.signOut();
  }

  // Crée un compte employé (appelé depuis le dashboard admin)
  Future<void> creerCompte({
    required String email,
    required String password,
    required String nom,
    required String role,
  }) async {
    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // Sauvegarde le profil dans Firestore
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'email': email.trim(),
      'nom': nom.trim(),
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Traduit les codes d'erreur Firebase en messages lisibles
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-email':
        return 'Email invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      default:
        return 'Erreur de connexion. Vérifiez vos identifiants.';
    }
  }
}