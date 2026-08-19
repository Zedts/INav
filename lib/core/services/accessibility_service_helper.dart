import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'dart:async';

class AccessibilityServiceHelper {
  static const MethodChannel _channel = MethodChannel(
    'com.zedt.inav/focus_lock',
  );

  static StreamSubscription<AccessibilityEvent>? _accessStreamSubscription;
  static final StreamController<String> _appOpenedController =
      StreamController<String>.broadcast();
  static bool _isOverlayShowing = false;
  static bool _isInitialized = false;
  static String? _lastPackageName;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _subscribeToAccessStream();
  }

  static void _subscribeToAccessStream() {
    _accessStreamSubscription?.cancel();
    _accessStreamSubscription =
        FlutterAccessibilityService.accessStream.listen((event) {
      final packageName = event.packageName;
      if (packageName == null || packageName.isEmpty) return;

      final eventType = event.eventType;
      if (eventType == null) return;
      const int rawTypeWindowStateChanged = 32; // TYPE_WINDOW_STATE_CHANGED

      bool isWindowStateChange;
      try {
        final dynamic et = eventType;
        final nameMatch = et.toString().split('.').last.toLowerCase() ==
            'typewindowstatechanged';
        final valueMatch = et.value == rawTypeWindowStateChanged ||
            et.rawValue == rawTypeWindowStateChanged ||
            et.hashCode == rawTypeWindowStateChanged;
        isWindowStateChange = nameMatch || valueMatch;
      } catch (_) {
        isWindowStateChange =
            eventType.toString().contains('typeWindowStateChanged');
      }

      if (isWindowStateChange) {
        if (packageName != _lastPackageName) {
          _lastPackageName = packageName;
          _appOpenedController.add(packageName);
        }
      }
    });
  }

  static Stream<String> get onAppOpened {
    if (!_isInitialized) {
      initialize();
    }
    return _appOpenedController.stream;
  }

  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final bool result =
          await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
      return result;
    } catch (e) {
      debugPrint('Error checking accessibility service: $e');
      return false;
    }
  }

  static Future<bool> isServiceRunning() async {
    try {
      return await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
    } catch (e) {
      debugPrint('Error checking if service running: $e');
      return false;
    }
  }

  static Future<void> requestAccessibilityPermission() async {
    try {
      await FlutterAccessibilityService.requestAccessibilityPermission();
    } catch (e) {
      debugPrint('Error requesting accessibility permission: $e');
    }
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      debugPrint('Error opening accessibility settings: $e');
    }
  }

  static Future<bool> hasUsageStatsPermission() async {
    try {
      final bool result = await _channel.invokeMethod(
        'hasUsageStatsPermission',
      );
      return result;
    } catch (e) {
      debugPrint('Error checking usage stats permission: $e');
      return false;
    }
  }

  static Future<void> openUsageAccessSettings() async {
    try {
      await _channel.invokeMethod('openUsageAccessSettings');
    } catch (e) {
      debugPrint('Error opening usage access settings: $e');
    }
  }

  static Future<void> showLockOverlay() async {
    if (_isOverlayShowing) return;

    try {
      await FlutterAccessibilityService.showOverlayWindow();
      _isOverlayShowing = true;
      debugPrint('Lock overlay shown');
    } catch (e) {
      debugPrint('Error showing lock overlay: $e');
    }
  }

  static Future<void> hideLockOverlay() async {
    if (!_isOverlayShowing) return;

    try {
      await FlutterAccessibilityService.hideOverlayWindow();
      _isOverlayShowing = false;
      debugPrint('Lock overlay hidden');
    } catch (e) {
      debugPrint('Error hiding lock overlay: $e');
    }
  }

  static bool get isOverlayShowing => _isOverlayShowing;

  static void dispose() {
    _accessStreamSubscription?.cancel();
    _accessStreamSubscription = null;
    _appOpenedController.close();
    _isInitialized = false;
    _lastPackageName = null;
  }
}
