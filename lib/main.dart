import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/providers/prayer_provider.dart';
import 'core/providers/verse_provider.dart';
import 'core/providers/hadith_provider.dart';
import 'core/providers/streak_provider.dart';
import 'core/providers/prayer_settings_provider.dart';
import 'core/providers/quran_provider.dart';
import 'core/providers/mosque_provider.dart';
import 'core/providers/qibla_provider.dart';
import 'core/providers/focus_lock_provider.dart';
import 'core/services/lock_engine.dart';
import 'core/services/accessibility_service_helper.dart';
import 'screens/main_screen.dart';
import 'screens/lock_overlay_screen.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    ThemeProvider? themeProvider;
    FocusLockProvider? focusLockProvider;
    try {
      // Load environment variables (services have safe fallbacks if missing)
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        debugPrint('Could not load .env file, using default configuration: $e');
        dotenv.loadFromString(envString: '');
      }

      // Initialize accessibility service helper (best effort, swallow errors)
      try {
        await AccessibilityServiceHelper.initialize();
      } catch (e) {
        debugPrint('AccessibilityServiceHelper init delayed (non-fatal): $e');
      }

      // Create theme provider and load saved preference
      themeProvider = ThemeProvider();
      try {
        await themeProvider.loadThemePreference();
      } catch (e) {
        debugPrint('ThemeProvider init fallback (non-fatal): $e');
      }

      // Create focus lock provider and initialize
      focusLockProvider = FocusLockProvider();
      try {
        await focusLockProvider.initialize();
      } catch (e) {
        debugPrint('FocusLockProvider init fallback (non-fatal): $e');
        // Manually set defaults so the app still boots
        focusLockProvider = FocusLockProvider();
      }
    } catch (e, st) {
      debugPrint('main() init caught (fallback used): $e\n$st');
    } finally {
      // GUARANTEE: runApp always executes. If either provider failed, create
      // safe defaults. This is the final backstop against "stuck on logo".
      themeProvider ??= ThemeProvider();
      focusLockProvider ??= FocusLockProvider();
      // Lock in defaults for both providers without awaiting (would re-trigger
      // the same startup races that just failed).
      runApp(
        MyApp(
          themeProvider: themeProvider,
          focusLockProvider: focusLockProvider,
        ),
      );
    }
  }, (error, stackTrace) {
    debugPrint('ROOT ZONE ERROR (uncaught): $error\n$stackTrace');
    // Never let a root-zone error crash the app on startup.
  });
}

/// Entry point for lock overlay (called by flutter_accessibility_service)
@pragma('vm:entry-point')
void accessibilityOverlay() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize dotenv FIRST — VerseService/HadithService -> ApiService static
    // fields read dotenv.env at class-load time. Without this, overlay isolate
    // would throw NotInitializedError and crash (blank overlay, no UI).
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      dotenv.loadFromString(envString: '');
    }

    // Focus lock — overlay isolate is UI-ONLY. NEVER start LockEngine/detector
    // here (mainApp isolate already runs detector, prevents duplicate logs).
    final focusLockProvider = FocusLockProvider();
    try {
      await focusLockProvider.initialize(
        mode: LockEngineMode.overlayIsolate,
        startEngine: false,
      );
    } catch (_) {
      /* initialize best-effort; overlay still shows lock screen */
    }

    // Verse + Hadith (mindful pause 50/50 coin flip source)
    final verseProvider = VerseProvider();
    final hadithProvider = HadithProvider();
    try {
      await verseProvider.loadDailyVerse();
    } catch (_) {
      /* fallback: overlay shows hardcoded verse instead */
    }
    try {
      await hadithProvider.loadDailyHadith();
    } catch (_) {
      /* fallback: overlay shows hardcoded hadith instead */
    }

    final streakProvider = StreakProvider();

    runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: focusLockProvider),
        ChangeNotifierProvider.value(value: verseProvider),
        ChangeNotifierProvider.value(value: hadithProvider),
        ChangeNotifierProvider.value(value: streakProvider),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.dark,
        home: LockOverlayScreen(
          activeLockInfo: focusLockProvider.getActiveLockInfo(),
          dailySkipAllowance: focusLockProvider.dailySkipAllowance,
          remainingSkips: focusLockProvider.remainingSkips,
          canSkip: focusLockProvider.canSkip,
          onSkip: () async {
            final ok = await focusLockProvider.useSkip();
            if (ok) {
              // Skip = truly skip the window for the rest of the current
              // lock window (30s cooldown suppresses re-show). Also hide
              // the overlay window NOW so the user gets the expected
              // visual feedback that "skip worked".
              await AccessibilityServiceHelper.hideLockOverlayWithSkipCooldown(
                suppressFor: const Duration(seconds: 30),
              );
            }
            return ok;
          },
          onCloseViewWithCooldown: () async {
            await AccessibilityServiceHelper.hideLockOverlayWithCooldown();
          },
          onOpenInav: () async {
            await AccessibilityServiceHelper.openInavApp();
          },
          unlockConfig: focusLockProvider.unlockConfig,
          currentPrayerName: focusLockProvider.getActivePrayerName(),
          onUnlock: () async {
            await AccessibilityServiceHelper.hideLockOverlay();
          },
        ),
      ),
    ),
    );
  }, (error, stackTrace) {
    debugPrint('OVERLAY ROOT ZONE ERROR (uncaught): $error\n$stackTrace');
  });
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final FocusLockProvider focusLockProvider;

  const MyApp({
    super.key,
    required this.themeProvider,
    required this.focusLockProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: focusLockProvider),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => VerseProvider()),
        ChangeNotifierProvider(create: (_) => HadithProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider()),
        ChangeNotifierProvider(create: (_) => PrayerSettingsProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => MosqueProvider()),
        ChangeNotifierProvider(create: (_) => QiblaProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'INav',
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.themeMode,

            // Home screen
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
