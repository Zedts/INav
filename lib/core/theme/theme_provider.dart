import 'package:flutter/material.dart';
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

  /// Load saved theme preference from SharedPreferences
  Future<void> loadThemePreference() async {
    _prefs = await SharedPreferences.getInstance();
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
  }
}
