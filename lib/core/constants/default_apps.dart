import 'package:flutter/material.dart';
import '../models/app_definition.dart';

class DefaultApps {
  static final Map<String, AppDefinition> apps = {
    'com.instagram.android': AppDefinition(
      packageName: 'com.instagram.android',
      name: 'Instagram',
      iconCodePoint: Icons.photo_camera.codePoint,
      iconFontFamily: Icons.photo_camera.fontFamily,
      iconFontPackage: Icons.photo_camera.fontPackage,
      iconMatchTextDirection: Icons.photo_camera.matchTextDirection,
      colorARGB: 0xFFD946EF,
      isDefault: true,
    ),
    'com.ss.android.ugc.trill': AppDefinition(
      packageName: 'com.ss.android.ugc.trill',
      packageAliases: const ['com.zhiliaoapp.musically'],
      name: 'TikTok',
      iconCodePoint: Icons.music_note.codePoint,
      iconFontFamily: Icons.music_note.fontFamily,
      iconFontPackage: Icons.music_note.fontPackage,
      iconMatchTextDirection: Icons.music_note.matchTextDirection,
      colorARGB: 0xFF475569,
      isDefault: true,
    ),
    'com.google.android.youtube': AppDefinition(
      packageName: 'com.google.android.youtube',
      name: 'YouTube',
      iconCodePoint: Icons.play_circle_filled.codePoint,
      iconFontFamily: Icons.play_circle_filled.fontFamily,
      iconFontPackage: Icons.play_circle_filled.fontPackage,
      iconMatchTextDirection: Icons.play_circle_filled.matchTextDirection,
      colorARGB: 0xFFEF4444,
      isDefault: true,
    ),
  };

  static AppDefinition? getApp(String packageName) {
    final direct = apps[packageName];
    if (direct != null) return direct;
    for (final app in apps.values) {
      if (app.matchesPackage(packageName)) return app;
    }
    return null;
  }

  static bool isDefaultApp(String packageName) {
    return getApp(packageName)?.isDefault ?? false;
  }

  static List<String> get defaultPackages => apps.keys.toList();

  static AppDefinition createGenericApp(String packageName, String appName) =>
      AppDefinition(
        packageName: packageName,
        name: appName,
        iconCodePoint: Icons.apps.codePoint,
        iconFontFamily: Icons.apps.fontFamily,
        iconFontPackage: Icons.apps.fontPackage,
        iconMatchTextDirection: Icons.apps.matchTextDirection,
        colorARGB: 0xFF64748B,
        isDefault: false,
      );

  static const List<String> essentialAppsWhitelist = [
    'com.android.dialer',
    'com.android.phone',
    'com.google.android.dialer',
    'com.android.messaging',
    'com.google.android.apps.messaging',
    'com.samsung.android.messaging',
  ];

  static bool isEssentialApp(String packageName) =>
      essentialAppsWhitelist.contains(packageName);
}
