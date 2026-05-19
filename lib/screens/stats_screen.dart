import 'package:flutter/material.dart';
import '../models/app_user.dart';

class StatsScreen extends StatelessWidget {
  final AppUser currentUser;

  const StatsScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Statistiques',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'À venir...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}