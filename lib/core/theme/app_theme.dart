import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Theme configuration for the INav app
/// Provides light and dark theme definitions matching HTML reference
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.accent,
        surface: AppColors.surfaceLight,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textMainLight,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.surfaceLight,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textMainLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textMainLight),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardLight,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textMutedLight,
        selectedIconTheme: IconThemeData(size: 22),
        unselectedIconTheme: IconThemeData(size: 22),
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Text Theme with Inter font
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainLight,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainLight,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainLight,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainLight,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainLight,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainLight,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainLight,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMutedLight,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: AppColors.textMainLight, size: 24),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.accent,
        surface: AppColors.surfaceDark,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textMainDark,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.surfaceDark,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textMainDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textMainDark),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textMutedDark,
        selectedIconTheme: IconThemeData(size: 22),
        unselectedIconTheme: IconThemeData(size: 22),
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Text Theme with Inter font
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainDark,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainDark,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainDark,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainDark,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainDark,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMainDark,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMutedDark,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: AppColors.textMainDark, size: 24),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
      ),
    );
  }
}
