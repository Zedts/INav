import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/common/app_header.dart';
import '../widgets/navigation/bottom_nav_bar.dart';
import '../widgets/quran/bookmarks_sidebar.dart';
import '../widgets/quran/surah_detail_sheet.dart';
import '../widgets/mosque/favorites_sidebar.dart';
import '../widgets/mosque/mosque_detail_sheet.dart';
import '../core/providers/quran_provider.dart';
import '../core/providers/mosque_provider.dart';
import '../core/models/surah_model.dart';
import '../core/models/mosque_model.dart';
import 'home/home_screen.dart';
import 'quran/quran_screen.dart';
import 'mosque/mosque_screen.dart';
import 'qibla/qibla_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
        HomeScreen(onNavigate: _onTabTapped),
        const QuranScreen(),
        const MosqueScreen(),
        const QiblaScreen(),
        const SettingsScreen(),
      ];

  HeaderMode _getHeaderMode(int index) {
    switch (index) {
      case 1:
        return HeaderMode.quran;
      case 2:
        return HeaderMode.mosque;
      case 3:
        return HeaderMode.qibla;
      case 4:
        return HeaderMode.settings;
      default:
        return HeaderMode.home;
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openSurahDetail(SurahModel surah) {
    SurahDetailSheet.show(context, surah);
  }

  void _openMosqueDetail(MosqueModel mosque) {
    MosqueDetailSheet.show(context, mosque);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeAreaTop = mediaQuery.padding.top;
    final headerHeight = safeAreaTop + 64;
    final headerMode = _getHeaderMode(_currentIndex);
    final quranProvider = context.watch<QuranProvider>();
    final mosqueProvider = context.watch<MosqueProvider>();

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: headerHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppHeader(
              mode: headerMode,
              onToggleBookmarks:
                  headerMode == HeaderMode.quran
                      ? () => quranProvider.toggleSidebar()
                      : null,
              onToggleFavorites:
                  headerMode == HeaderMode.mosque
                      ? () => mosqueProvider.toggleSidebar()
                      : null,
            ),
          ),
          if (_currentIndex == 1)
            Positioned.fill(
              child: BookmarksSidebar(onOpenSurah: _openSurahDetail),
            ),
          if (_currentIndex == 2)
            Positioned.fill(
              child: FavoritesSidebar(onOpenMosque: _openMosqueDetail),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
