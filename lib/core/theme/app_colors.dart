import 'package:flutter/material.dart';

/// Color constants extracted from HTML Tailwind config
/// Matches the INav reference design exactly
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  /// Primary color for light theme - Tailwind: primary.DEFAULT (#0D47A1)
  static const Color primaryLight = Color(0xFF0D47A1);
  
  /// Primary color for dark theme - Tailwind: primary.dark (#3B82F6)
  static const Color primaryDark = Color(0xFF3B82F6);

  // Accent Color
  /// Accent color - Tailwind: accent (#1976D2)
  static const Color accent = Color(0xFF1976D2);

  // Surface Colors
  /// Surface/background color for light theme - Tailwind: surface.light (#F8FAFC)
  static const Color surfaceLight = Color(0xFFF8FAFC);
  
  /// Surface/background color for dark theme - Tailwind: surface.dark (#0F172A)
  static const Color surfaceDark = Color(0xFF0F172A);

  // Card Colors
  /// Card background color for light theme - Tailwind: card.light (#FFFFFF)
  static const Color cardLight = Color(0xFFFFFFFF);
  
  /// Card background color for dark theme - Tailwind: card.dark (#1E293B)
  static const Color cardDark = Color(0xFF1E293B);

  // Text Colors - Main
  /// Main text color for light theme - Tailwind: textMain.light (#1E293B)
  static const Color textMainLight = Color(0xFF1E293B);
  
  /// Main text color for dark theme - Tailwind: textMain.dark (#F8FAFC)
  static const Color textMainDark = Color(0xFFF8FAFC);

  // Text Colors - Muted
  /// Muted text color for light theme - Tailwind: textMuted.light (#64748B)
  static const Color textMutedLight = Color(0xFF64748B);
  
  /// Muted text color for dark theme - Tailwind: textMuted.dark (#94A3B8)
  static const Color textMutedDark = Color(0xFF94A3B8);

  // Border Colors
  /// Border color for light theme - Tailwind: border.light (#E2E8F0)
  static const Color borderLight = Color(0xFFE2E8F0);
  
  /// Border color for dark theme - Tailwind: border.dark (#334155)
  static const Color borderDark = Color(0xFF334155);

  // Status Colors
  /// Success color - Tailwind: success (#10B981)
  static const Color success = Color(0xFF10B981);
  
  /// Teal color - Tailwind: teal (#0D9488)
  static const Color teal = Color(0xFF0D9488);
}
