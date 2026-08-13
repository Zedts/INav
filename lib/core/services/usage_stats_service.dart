import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class UsageStatsService {
  static const MethodChannel _channel = MethodChannel('com.zedt.inav/usage_stats');

  static Future<bool> hasPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasUsageStatsPermission');
      return result ?? false;
    } catch (e) {
      debugPrint('UsageStatsService: Error checking permission - $e');
      return false;
    }
  }

  static Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod('openUsageAccessSettings');
    } catch (e) {
      debugPrint('UsageStatsService: Error requesting permission - $e');
    }
  }

  static Future<String?> getCurrentApp() async {
    try {
      final result = await _channel.invokeMethod<String>('getCurrentApp');
      return result;
    } catch (e) {
      debugPrint('UsageStatsService: Error getting current app - $e');
      return null;
    }
  }

  static Future<int> getAppUsageTime(String packageName) async {
    try {
      final result = await _channel.invokeMethod<int>('getAppUsageTime', {
        'packageName': packageName,
      });
      return result ?? 0;
    } catch (e) {
      debugPrint('UsageStatsService: Error getting usage time - $e');
      return 0;
    }
  }
}
