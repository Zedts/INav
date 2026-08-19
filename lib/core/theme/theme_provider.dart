import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme provider for managing light/dark mode with persistence
/// Uses ChangeNotifier for reactive state updates
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _prefs;

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Check if dark mode is currently active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Load SharedPreferences with retry. On some devices, the pigeon channel
  /// is not immediately available right after WidgetsFlutterBinding.ensureInitialized().
  /// Without retry, `PlatformException(channel-error, Unable to establish connection
  /// on channel: "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesApi.getAll")`
  /// is thrown — and if uncaught, it propagates up and prevents runApp() from
  /// being called (app stuck on launch logo forever).
  static Future<SharedPreferences> _getPrefsWithRetry() async {
    const maxAttempts = 5;
    const delay = Duration(milliseconds: 100);
    Object? lastErr;
    for (var i = 0; i < maxAttempts; i++) {
      try {
        final prefs = await SharedPreferences.getInstance();
        try {
          await prefs.reload();
        } catch (_) {}
        return prefs;
      } catch (e) {
        lastErr = e;
        if (e is PlatformException && e.code == 'channel-error') {
          await Future.delayed(delay);
          continue;
        }
        rethrow;
      }
    }
    throw lastErr ?? StateError('SharedPreferences unavailable');
  }

  /// Load saved theme preference from SharedPreferences.
  ///
  /// NOTE: Always call [SharedPreferences.reload()] before reading.
  /// The overlay isolate and main isolate run in separate Dart isolates and
  /// EACH has its OWN in-memory cache of SharedPreferences. Without explicit
  /// reload(), the overlay would read stale cached theme values even after the
  /// main isolate wrote a new theme to disk.
  Future<void> loadThemePreference() async {
    try {
      _prefs = await _getPrefsWithRetry();
      final String? savedTheme = _prefs?.getString(_themeKey);

      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
            _themeMode = ThemeMode.system;
            break;
          default:
            _themeMode = ThemeMode.system;
        }
        notifyListeners();
      }
    } catch (e) {
      // Fall back to system theme — never block app startup on storage errors
      debugPrint('ThemeProvider load error (non-fatal): $e');
      _themeMode = ThemeMode.system;
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    // Toggle between light and dark (skip system mode during toggle)
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    
    // Save to SharedPreferences
    await _saveThemePreference();
    
    // Notify listeners to rebuild UI
    notifyListeners();
  }

  /// Set theme mode explicitly
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    await _saveThemePreference();
    notifyListeners();
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveThemePreference() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();

      String themeString;
      switch (_themeMode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }

      await _prefs?.setString(_themeKey, themeString);
    } catch (e) {
      // Persisting is best-effort — the in-memory theme still applies
      debugPrint('ThemeProvider save error (non-fatal): $e');
    }
  }
}
