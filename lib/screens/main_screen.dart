import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../widgets/common/app_header.dart';
import '../widgets/navigation/bottom_nav_bar.dart';
import '../widgets/quran/bookmarks_sidebar.dart';
import '../widgets/quran/surah_detail_sheet.dart';
import '../widgets/mosque/favorites_sidebar.dart';
import '../widgets/mosque/mosque_detail_sheet.dart';
import '../core/providers/quran_provider.dart';
import '../core/providers/mosque_provider.dart';
import '../core/providers/focus_lock_provider.dart';
import '../core/providers/streak_provider.dart';
import '../core/models/surah_model.dart';
import '../core/models/mosque_model.dart';
import '../core/models/unlock_config.dart';
import '../core/services/accessibility_service_helper.dart';
import '../core/theme/app_colors.dart';
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

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _pendingUnlockDialogShown = false;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingUnlock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingUnlock();
    }
  }

  Future<void> _checkPendingUnlock() async {
    if (_pendingUnlockDialogShown || !mounted) return;
    final pending = await AccessibilityServiceHelper.consumePendingUnlockRequest();
    if (pending && mounted) {
      _pendingUnlockDialogShown = true;
      await _showPendingUnlockDialog();
      _pendingUnlockDialogShown = false;
    }
  }

  Future<void> _showPendingUnlockDialog() async {
    final flp = context.read<FocusLockProvider>();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PendingUnlockDialog(unlockConfig: flp.unlockConfig),
    );
    if (result == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final eng = context.read<FocusLockProvider>().lockEngine;
      await eng?.unlock();
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('App unlocked. You can return to your app now.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    }
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

class _PendingUnlockDialog extends StatefulWidget {
  final UnlockConfig unlockConfig;
  const _PendingUnlockDialog({required this.unlockConfig});

  @override
  State<_PendingUnlockDialog> createState() => _PendingUnlockDialogState();
}

class _PendingUnlockDialogState extends State<_PendingUnlockDialog> {
  int _remainingWaitSecs = 0;
  Timer? _waitTimer;
  int _breathingCycles = 0;
  String _breathingPhase = 'Breathe In';
  bool _prayerMarked = false;
  final _phraseCtrl = TextEditingController();
  bool _phraseError = false;

  @override
  void initState() {
    super.initState();
    if (widget.unlockConfig.method == UnlockMethod.waitItOut) {
      _remainingWaitSecs = widget.unlockConfig.waitDurationSeconds;
      _waitTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remainingWaitSecs > 0) {
          setState(() => _remainingWaitSecs--);
        } else {
          _waitTimer?.cancel();
          _finishSuccess();
        }
      });
    }
    if (widget.unlockConfig.method == UnlockMethod.mindfulPause) {
      Timer.periodic(const Duration(seconds: 4), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          if (_breathingPhase == 'Breathe In') {
            _breathingPhase = 'Breathe Out';
          } else {
            _breathingPhase = 'Breathe In';
            _breathingCycles++;
          }
        });
        if (_breathingCycles >= 3) timer.cancel();
      });
    }
    if (widget.unlockConfig.method == UnlockMethod.markPrayed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final streak = context.read<StreakProvider>();
        if (streak.isCurrentPrayerCompleted) {
          _finishSuccess();
        } else {
          Timer.periodic(const Duration(seconds: 2), (timer) {
            if (!mounted) {
              timer.cancel();
              return;
            }
            final streak2 = context.read<StreakProvider>();
            if (streak2.isCurrentPrayerCompleted && !_prayerMarked) {
              _prayerMarked = true;
              timer.cancel();
              _finishSuccess();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _waitTimer?.cancel();
    _phraseCtrl.dispose();
    super.dispose();
  }

  void _finishSuccess() {
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _validatePhrase() {
    final inp = _phraseCtrl.text.trim();
    final tgt = widget.unlockConfig.unlockPhrase.trim();
    if (inp.toLowerCase() == tgt.toLowerCase()) {
      _finishSuccess();
    } else {
      HapticFeedback.vibrate();
      setState(() => _phraseError = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _phraseError = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primary;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final hairline = isDark ? AppColors.hairlineDark : AppColors.hairlineLight;

    Widget content;
    switch (widget.unlockConfig.method) {
      case UnlockMethod.waitItOut:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TIME REMAINING',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _fmt(_remainingWaitSecs),
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: primary,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
          ],
        );
        break;
      case UnlockMethod.markPrayed:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mosque, size: 56, color: primary),
            const SizedBox(height: 12),
            Text(
              _prayerMarked ? 'Prayer Completed!' : 'Mark Prayer as Prayed',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _prayerMarked
                  ? 'Unlocking app...'
                  : 'Mark your current prayer as completed in INav',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 12,
                color: textMuted,
                height: 1.4,
              ),
            ),
            if (!_prayerMarked) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ],
        );
        break;
      case UnlockMethod.mindfulPause:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.air, size: 56, color: primary),
            const SizedBox(height: 12),
            Text(
              _breathingPhase,
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Breathing cycles: $_breathingCycles / 3',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 13,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _breathingCycles >= 3 ? _finishSuccess : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _breathingCycles >= 3 ? 'Continue' : 'Complete breathing cycles',
                style: GoogleFonts.plusJakartaSans().copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
        break;
      case UnlockMethod.typePhrase:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _phraseError ? Colors.red : hairline),
              ),
              child: Text(
                '"${widget.unlockConfig.unlockPhrase}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans().copyWith(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phraseCtrl,
              autofocus: true,
              style: GoogleFonts.plusJakartaSans().copyWith(color: textMain),
              decoration: InputDecoration(
                hintText: 'Type the phrase...',
                hintStyle: TextStyle(color: textMuted),
                filled: true,
                fillColor: card,
                errorText: _phraseError ? 'Incorrect phrase' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: hairline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: hairline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primary, width: 2),
                ),
              ),
              onSubmitted: (_) => _validatePhrase(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _validatePhrase,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Unlock',
                style: GoogleFonts.plusJakartaSans().copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
        break;
    }

    return AlertDialog(
      backgroundColor: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Column(
        children: [
          const Icon(Icons.lock_rounded, size: 36, color: AppColors.roseAccent),
          const SizedBox(height: 8),
          Text(
            'Unlock Your App',
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete the challenge below to unlock',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 12,
              color: textMuted,
            ),
          ),
        ],
      ),
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
