import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_user.dart';
import '../screens/add_irritant_screen.dart';
import '../screens/stats_screen.dart';
import '../services/auth_service.dart';

class MainNavigation extends StatefulWidget {
  final AppUser currentUser;

  const MainNavigation({super.key, required this.currentUser});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      AddIrritantScreen(currentUser: widget.currentUser),
      StatsScreen(currentUser: widget.currentUser),
    ];
  }

  void _onTabTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IrritantsTracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().deconnecter();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 28),
            activeIcon: Icon(Icons.add_circle, size: 28),
            label: 'Signaler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined, size: 28),
            activeIcon: Icon(Icons.trending_up, size: 28),
            label: 'Statistiques',
          ),
        ],
      ),
    );
  }
}