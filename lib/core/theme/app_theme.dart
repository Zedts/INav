import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() {
    final plusJakarta = GoogleFonts.plusJakartaSans();
    final fraunces = GoogleFonts.fraunces();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surfaceLight,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textMainLight,
      ),

      scaffoldBackgroundColor: AppColors.surfaceLight,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textMainLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textMainLight),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMutedLight,
        selectedIconTheme: const IconThemeData(size: 22),
        unselectedIconTheme: const IconThemeData(size: 22),
        selectedLabelStyle: plusJakarta.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: plusJakarta.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      textTheme: TextTheme(
        displayLarge: fraunces.copyWith(
          color: AppColors.textMainLight,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.02,
        ),
        displayMedium: fraunces.copyWith(
          color: AppColors.textMainLight,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.02,
        ),
        displaySmall: fraunces.copyWith(
          color: AppColors.textMainLight,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.02,
        ),
        headlineLarge: fraunces.copyWith(
          color: AppColors.textMainLight,
          fontWeight: FontWeight.w500,
        ),
        headlineMedium: fraunces.copyWith(
          color: AppColors.textMainLight,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: fraunces.copyWith(
          color: AppColors.textMainLight,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: fraunces.copyWith(
          color: AppColors.textMainLight,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: plusJakarta.copyWith(
          color: AppColors.textMainLight,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: plusJakarta.copyWith(
          color: AppColors.textMainLight,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: plusJakarta.copyWith(
          color: AppColors.textMainLight,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: plusJakarta.copyWith(
          color: AppColors.textMainLight,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: plusJakarta.copyWith(
          color: AppColors.textMutedLight,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: plusJakarta.copyWith(
          color: AppColors.textMainLight,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: plusJakarta.copyWith(
          color: AppColors.textMainLight,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: plusJakarta.copyWith(
          color: AppColors.textMutedLight,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.05,
        ),
      ),

      iconTheme: const IconThemeData(color: AppColors.textMainLight, size: 24),

      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.02),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.hairlineLight, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.hairlineLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData darkTheme() {
    final plusJakarta = GoogleFonts.plusJakartaSans();
    final fraunces = GoogleFonts.fraunces();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.primaryLight,
        surface: AppColors.surfaceDark,
        error: Colors.red,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.textMainDark,
      ),

      scaffoldBackgroundColor: AppColors.surfaceDark,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textMainDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textMainDark),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textMutedDark,
        selectedIconTheme: const IconThemeData(size: 22),
        unselectedIconTheme: const IconThemeData(size: 22),
        selectedLabelStyle: plusJakarta.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: plusJakarta.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      textTheme: TextTheme(
        displayLarge: fraunces.copyWith(
          color: AppColors.textMainDark,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.02,
        ),
        displayMedium: fraunces.copyWith(
          color: AppColors.textMainDark,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.02,
        ),
        displaySmall: fraunces.copyWith(
          color: AppColors.textMainDark,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.02,
        ),
        headlineLarge: fraunces.copyWith(
          color: AppColors.textMainDark,
          fontWeight: FontWeight.w500,
        ),
        headlineMedium: fraunces.copyWith(
          color: AppColors.textMainDark,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: fraunces.copyWith(
          color: AppColors.textMainDark,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: fraunces.copyWith(
          color: AppColors.textMainDark,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: plusJakarta.copyWith(
          color: AppColors.textMainDark,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: plusJakarta.copyWith(
          color: AppColors.textMainDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: plusJakarta.copyWith(
          color: AppColors.textMainDark,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: plusJakarta.copyWith(
          color: AppColors.textMainDark,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: plusJakarta.copyWith(
          color: AppColors.textMutedDark,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: plusJakarta.copyWith(
          color: AppColors.textMainDark,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: plusJakarta.copyWith(
          color: AppColors.textMainDark,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: plusJakarta.copyWith(
          color: AppColors.textMutedDark,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.05,
        ),
      ),

      iconTheme: const IconThemeData(color: AppColors.textMainDark, size: 24),

      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.hairlineDark, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.hairlineDark,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
