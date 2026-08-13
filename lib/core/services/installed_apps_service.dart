import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/app_definition.dart';

class InstalledAppsService {
  static const MethodChannel _channel = MethodChannel('com.zedt.inav/apps');

  static Future<List<AppDefinition>> getInstalledApps({
    bool includeSystemApps = false,
  }) async {
    try {
      final result = await _channel.invokeMethod<List>('getInstalledApps', {
        'includeSystemApps': includeSystemApps,
      });

      if (result == null) return [];

      return result.map((app) {
        final appMap = Map<String, dynamic>.from(app);
        return AppDefinition(
          packageName: appMap['packageName'] as String,
          name: appMap['appName'] as String,
          iconCodePoint: Icons.apps.codePoint,
          iconFontFamily: Icons.apps.fontFamily,
          iconFontPackage: Icons.apps.fontPackage,
          iconMatchTextDirection: Icons.apps.matchTextDirection,
          colorARGB: Colors.grey.toARGB32(),
        );
      }).toList();
    } catch (e) {
      debugPrint('InstalledAppsService: Error fetching apps - $e');
      return [];
    }
  }

  static Future<List<AppDefinition>> searchApps(String query) async {
    if (query.isEmpty) return [];

    try {
      final allApps = await getInstalledApps();
      final lowerQuery = query.toLowerCase();

      return allApps
          .where((app) => app.name.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      debugPrint('InstalledAppsService: Error searching apps - $e');
      return [];
    }
  }

  static Future<AppDefinition?> getAppInfo(String packageName) async {
    try {
      final result = await _channel.invokeMethod<Map>('getAppInfo', {
        'packageName': packageName,
      });

      if (result == null) return null;

      return AppDefinition(
        packageName: result['packageName'] as String,
        name: result['appName'] as String,
        iconCodePoint: Icons.apps.codePoint,
        iconFontFamily: Icons.apps.fontFamily,
        iconFontPackage: Icons.apps.fontPackage,
        iconMatchTextDirection: Icons.apps.matchTextDirection,
        colorARGB: Colors.grey.toARGB32(),
      );
    } catch (e) {
      debugPrint('InstalledAppsService: Error getting app info - $e');
      return null;
    }
  }
}
