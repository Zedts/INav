class AppConstants {
  AppConstants._();
  static const String appName = "INav";
  static const String version = "1.0.0";
  static const String legalLastUpdated = "August 31, 2026";
  static const String legalLastUpdatedShort = "Aug 2026";
  static const String legalese = "© 2026 INav. All rights reserved.";

  static const Set<String> kEmergencyNonLockablePackages = {
    'com.android.launcher',
    'com.android.launcher3',
    'com.google.android.apps.nexuslauncher',
    'com.sec.android.app.launcher',
    'com.miui.home',
    'com.oneplus.launcher',
    'com.android.settings',
    'com.android.systemui',
    'com.android.packageinstaller',
    'com.google.android.packageinstaller',
    'com.android.dialer',
    'com.google.android.dialer',
    'com.samsung.android.dialer',
    'com.android.incallui',
    'com.android.server.telecom',
    'com.android.emergency',
    'com.android.phone',
    'com.android.providers.settings',
  };
}