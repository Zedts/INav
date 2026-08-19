import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/app_definition.dart';

/// Wrapper for the richer per-app metadata returned by the upgraded
/// `getInstalledApps` native implementation. [app] holds the
/// persistable/savable AppDefinition; the extra fields are display-only
/// hints used by AppSelectionDialog (filter chips, async icon loading).
class InstalledAppInfo {
  final AppDefinition app;
  final String? activityName;
  final bool hasLauncherActivity;
  final bool isEnabled;
  final bool isSuspended;
  final bool isSystemApp;
  final bool isUpdatedSystemApp;

  const InstalledAppInfo({
    required this.app,
    this.activityName,
    this.hasLauncherActivity = true,
    this.isEnabled = true,
    this.isSuspended = false,
    this.isSystemApp = false,
    this.isUpdatedSystemApp = false,
  });
}

class InstalledAppsService {
  static const MethodChannel _channel = MethodChannel('com.zedt.inav/apps');

  /// Fetch every installed app visible under the current Android profile.
  ///
  /// Equivalent to `adb shell pm list packages` (Android requires the
  /// `QUERY_ALL_PACKAGES` permission to genuinely see ALL packages on
  /// Android 11+). Uses the Perplexity-recommended 2-endpoint pattern:
  /// metadata first (cheap), then icons lazily via [getAppIcon].
  ///
  /// * [includeSystemApps] — if `false`, drop anything with `FLAG_SYSTEM`
  ///   or `FLAG_UPDATED_SYSTEM_APP` (i.e. user-installed only).
  /// * [onlyLaunchable] — if `true`, return only packages that declare an
  ///   `ACTION_MAIN` + `CATEGORY_LAUNCHER` activity (the user's home
  ///   screen / app drawer inventory). Non-launchable headless packages
  ///   (IME, system providers, services, Settings sub-packages) are
  ///   hidden — useful when the user wants the "normal app list" view.
  static Future<List<InstalledAppInfo>> getInstalledApps({
    bool includeSystemApps = true,
    bool onlyLaunchable = false,
  }) async {
    try {
      final result = await _channel.invokeMethod<List>('getInstalledApps', {
        'includeSystemApps': includeSystemApps,
        'onlyLaunchable': onlyLaunchable,
      });

      if (result == null) return [];

      return result.map((raw) {
        final appMap = Map<String, dynamic>.from(raw as Map);
        final packageName = appMap['packageName'] as String;
        final appName = (appMap['appName'] as String?) ?? packageName;
        final activityName = appMap['activityName'] as String?;
        final hasLauncher = (appMap['hasLauncherActivity'] as bool?) ?? false;
        final isEnabled = (appMap['isEnabled'] as bool?) ?? true;
        final isSuspended = (appMap['isSuspended'] as bool?) ?? false;
        final isSystemApp = (appMap['isSystemApp'] as bool?) ?? false;
        final isUpdatedSystemApp =
            (appMap['isUpdatedSystemApp'] as bool?) ?? false;
        return InstalledAppInfo(
          app: AppDefinition(
            packageName: packageName,
            name: appName,
            iconCodePoint: Icons.apps.codePoint,
            iconFontFamily: Icons.apps.fontFamily,
            iconFontPackage: Icons.apps.fontPackage,
            iconMatchTextDirection: Icons.apps.matchTextDirection,
            colorARGB: Colors.grey.toARGB32(),
          ),
          activityName: activityName,
          hasLauncherActivity: hasLauncher,
          isEnabled: isEnabled,
          isSuspended: isSuspended,
          isSystemApp: isSystemApp,
          isUpdatedSystemApp: isUpdatedSystemApp,
        );
      }).toList();
    } catch (e) {
      debugPrint('InstalledAppsService: Error fetching apps - $e');
      return [];
    }
  }

  static Future<List<InstalledAppInfo>> searchApps(String query) async {
    if (query.isEmpty) return [];
    try {
      final allApps = await getInstalledApps();
      final lowerQuery = query.toLowerCase();
      return allApps.where((info) {
        final app = info.app;
        return app.name.toLowerCase().contains(lowerQuery) ||
            app.packageName.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      debugPrint('InstalledAppsService: Error searching apps - $e');
      return [];
    }
  }

  static Future<InstalledAppInfo?> getAppInfo(String packageName) async {
    try {
      final result = await _channel.invokeMethod<Map>('getAppInfo', {
        'packageName': packageName,
      });

      if (result == null) return null;
      final appMap = Map<String, dynamic>.from(result);
      final pkg = appMap['packageName'] as String;
      final name = (appMap['appName'] as String?) ?? pkg;
      return InstalledAppInfo(
        app: AppDefinition(
          packageName: pkg,
          name: name,
          iconCodePoint: Icons.apps.codePoint,
          iconFontFamily: Icons.apps.fontFamily,
          iconFontPackage: Icons.apps.fontPackage,
          iconMatchTextDirection: Icons.apps.matchTextDirection,
          colorARGB: Colors.grey.toARGB32(),
        ),
        hasLauncherActivity:
            (appMap['hasLauncherActivity'] as bool?) ?? false,
        isEnabled: (appMap['isEnabled'] as bool?) ?? true,
        isSuspended: (appMap['isSuspended'] as bool?) ?? false,
        isSystemApp: (appMap['isSystemApp'] as bool?) ?? false,
        isUpdatedSystemApp:
            (appMap['isUpdatedSystemApp'] as bool?) ?? false,
      );
    } catch (e) {
      debugPrint('InstalledAppsService: Error getting app info - $e');
      return null;
    }
  }

  /// Lazily fetch a single app's icon as PNG bytes. Uses the 2-endpoint
  /// pattern: first call [getInstalledApps] to get metadata, then call
  /// this from each visible list row (ListView.builder is on-demand).
  ///
  /// * [packageName] — package to look up (required).
  /// * [activityName] — optional launcher activity from InstalledAppInfo.
  ///   When provided, we render the ACTIVITY's icon (which is the exact
  ///   home-screen launcher icon, including adaptive / themed variants).
  ///   When null, renders `ApplicationInfo.loadIcon()` fallback (generic
  ///   package icon or default Android "app" glyph).
  /// * [sizeDp] — rendered square size in dp (default 48, clamped 16-256).
  static Future<Uint8List?> getAppIcon({
    required String packageName,
    String? activityName,
    int sizeDp = 48,
  }) async {
    try {
      final bytes = await _channel.invokeMethod<Uint8List>('getAppIcon', {
        'packageName': packageName,
        'activityName': activityName,
        'sizeDp': sizeDp,
      });
      return bytes;
    } catch (e) {
      debugPrint(
        'InstalledAppsService: Error loading icon for $packageName - $e',
      );
      return null;
    }
  }
}
