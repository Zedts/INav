import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
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
import 'core/services/accessibility_service_helper.dart';
import 'screens/main_screen.dart';
import 'screens/lock_overlay_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (services have safe fallbacks if missing)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Could not load .env file, using default configuration: $e');
    // Initialize dotenv with empty content so dotenv.env access is safe
    dotenv.loadFromString(envString: '');
  }

  // Initialize accessibility service helper
  await AccessibilityServiceHelper.initialize();

  // Create theme provider and load saved preference
  final themeProvider = ThemeProvider();
  await themeProvider.loadThemePreference();

  // Create focus lock provider and initialize
  final focusLockProvider = FocusLockProvider();
  await focusLockProvider.initialize();

  runApp(
    MyApp(themeProvider: themeProvider, focusLockProvider: focusLockProvider),
  );
}

/// Entry point for lock overlay (called by flutter_accessibility_service)
@pragma('vm:entry-point')
void accessibilityOverlay() async {
  WidgetsFlutterBinding.ensureInitialized();

  final focusLockProvider = FocusLockProvider();
  await focusLockProvider.initialize();

  final streakProvider = StreakProvider();

  final themeProvider = ThemeProvider();
  await themeProvider.loadThemePreference();

  final savedBlockedPkg =
      await AccessibilityServiceHelper.getLastBlockedPackage();
  final savedBlockedName =
      await AccessibilityServiceHelper.getLastBlockedAppName();

  final displayAppName =
      savedBlockedName ??
      (savedBlockedPkg != null
          ? focusLockProvider.getAppName(savedBlockedPkg)
          : null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: focusLockProvider),
        ChangeNotifierProvider.value(value: streakProvider),
      ],
      child: LockOverlayScreen(
        blockedAppName: displayAppName,
        blockedPackageName: savedBlockedPkg,
        unlockConfig: focusLockProvider.unlockConfig,
        currentPrayerName: focusLockProvider.getActivePrayerName(),
        isDarkMode: themeProvider.themeMode == ThemeMode.dark ||
            (themeProvider.themeMode == ThemeMode.system &&
                WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                    Brightness.dark),
        onUnlock: () async {
          await AccessibilityServiceHelper.hideLockOverlay();
        },
        onUseSkip: () async {
          final ok = await focusLockProvider.useSkip();
          if (ok) {
            await AccessibilityServiceHelper.hideOverlayAndSuppress(
                suppressMs: 5000);
          }
          return ok;
        },
        onOpenInav: () async {
          await AccessibilityServiceHelper.launchInavApp();
          await AccessibilityServiceHelper.hideOverlayAndSuppress(
              suppressMs: 4000);
        },
        onHome: () async {
          await AccessibilityServiceHelper.goToHome();
        },
      ),
    ),
  );
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
