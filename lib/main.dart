import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/add_irritant_screen.dart';
import 'services/auth_service.dart';
import 'models/app_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IrritantTracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // StreamBuilder écoute l'état de connexion en temps réel
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          // En attente de la réponse Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Pas connecté → écran de login
          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // Connecté → récupère le profil et redirige
          return FutureBuilder<AppUser?>(
            future: AuthService().getAppUser(snapshot.data!.uid),
            builder: (context, userSnapshot) {

              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final appUser = userSnapshot.data;

              // Redirige selon le rôle
              if (appUser != null) {
                // Pour l'instant les deux roles voient le formulaire
                // L'admin aura son dashboard web plus tard
                return AddIrritantScreen(currentUser: appUser);
              }

              // Profil introuvable → retour au login
              return const LoginScreen();
            },
          );
        },
      ),
    );
  }
}