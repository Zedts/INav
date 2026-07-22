import 'package:flutter/material.dart';
import '../widgets/common/app_header.dart';
import '../widgets/navigation/bottom_nav_bar.dart';
import 'home/home_screen.dart';
import 'quran/quran_screen.dart';
import 'mosque/mosque_screen.dart';
import 'qibla/qibla_screen.dart';
import 'settings/settings_screen.dart';

/// Main screen that combines header, content area, and bottom navigation
/// Uses IndexedStack to preserve state across tab switches
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of all screens
  final List<Widget> _screens = const [
    HomeScreen(),
    QuranScreen(),
    MosqueScreen(),
    QiblaScreen(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeAreaTop = mediaQuery.padding.top;
    final headerHeight =
        safeAreaTop + 64;

    return Scaffold(
      body: Stack(
        children: [
          // Content Area with IndexedStack (preserves state)
          // Add top padding to account for fixed header
          Positioned(
            top: headerHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),

          // Fixed Header - positioned on top as overlay
          Positioned(top: 0, left: 0, right: 0, child: const AppHeader()),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
