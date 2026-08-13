import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AccessibilityServiceHelper {
  static const MethodChannel _channel = MethodChannel(
    'com.zedt.inav/focus_lock',
  );

  static const String _keyPendingUnlock = 'focus_lock_pending_unlock';
  static const String _keyLastBlockedPkg = 'focus_lock_last_blocked_pkg';
  static const String _keyLastBlockedName = 'focus_lock_last_blocked_name';

  static StreamSubscription<AccessibilityEvent>? _accessStreamSubscription;
  static final StreamController<String> _appOpenedController =
      StreamController<String>.broadcast();
  static bool _isOverlayShowing = false;
  static bool _isInitialized = false;
  static String? _lastPackageName;
  static int? _lastEventMillis;
  static const int _dedupWindowMs = 1800;
  static String? _currentlyBlockingPackage;
  static int? _suppressUntilMillis;
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    _currentlyBlockingPackage = null;
    _suppressUntilMillis = null;
    _subscribeToAccessStream();
  }

  static Future<void> forceResubscribeStream() async {
    debugPrint('AccessibilityHelper: Force re-subscribing access stream');
    _subscribeToAccessStream();
  }

  static void _subscribeToAccessStream() {
    _accessStreamSubscription?.cancel();
    _accessStreamSubscription =
        FlutterAccessibilityService.accessStream.listen((event) {
      final packageName = event.packageName;
      if (packageName == null || packageName.isEmpty) return;

      const int tWindowStateChanged = 32;

      bool isWindowStateChanged = false;
      try {
        isWindowStateChanged = event.eventType == EventType.typeWindowStateChanged;
      } catch (_) {
        isWindowStateChanged =
            event.eventType?.hashCode == tWindowStateChanged ||
            event.eventType?.toString().contains('typeWindowStateChanged') == true;
      }

      if (!isWindowStateChanged) {
        return;
      }

      final nowMs = DateTime.now().millisecondsSinceEpoch;

      if (_suppressUntilMillis != null && nowMs < _suppressUntilMillis!) {
        return;
      }

      if (_lastPackageName == packageName &&
          _lastEventMillis != null &&
          (nowMs - _lastEventMillis!) < _dedupWindowMs) {
        return;
      }

      _lastPackageName = packageName;
      _lastEventMillis = nowMs;
      _appOpenedController.add(packageName);
    }, onError: (Object e, StackTrace st) {
      debugPrint('AccessibilityHelper: accessStream error: $e');
    }, onDone: () {
      debugPrint('AccessibilityHelper: accessStream closed — will reconnect on next poll');
      _accessStreamSubscription = null;
    });
    debugPrint('AccessibilityHelper: Stream subscribed (typeWindowStateChanged only, dedup=${_dedupWindowMs}ms)');
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

  static String? get currentlyBlockingPackage => _currentlyBlockingPackage;

  static Future<void> showLockOverlay({String? forPackage, String? appName}) async {
    if (_isOverlayShowing) {
      if (forPackage != null && forPackage != _currentlyBlockingPackage) {
        debugPrint('LockEngine: Already showing overlay for $_currentlyBlockingPackage — switching to $forPackage');
      } else {
        return;
      }
    }

    try {
      _currentlyBlockingPackage = forPackage;
      await _prefs?.setString(_keyLastBlockedPkg, forPackage ?? '');
      await _prefs?.setString(_keyLastBlockedName, appName ?? '');
      await FlutterAccessibilityService.showOverlayWindow();
      _isOverlayShowing = true;
      debugPrint('Lock overlay shown${forPackage != null ? ' for $forPackage' : ''}');
    } catch (e) {
      debugPrint('Error showing lock overlay: $e');
    }
  }

  static Future<void> hideLockOverlay() async {
    if (!_isOverlayShowing) return;

    try {
      await FlutterAccessibilityService.hideOverlayWindow();
      _isOverlayShowing = false;
      _currentlyBlockingPackage = null;
      debugPrint('Lock overlay hidden');
    } catch (e) {
      debugPrint('Error hiding lock overlay: $e');
    }
  }

  static Future<void> hideOverlayAndSuppress({int suppressMs = 3000}) async {
    await hideLockOverlay();
    _suppressUntilMillis =
        DateTime.now().millisecondsSinceEpoch + suppressMs;
    debugPrint('Lock overlay suppressed for ${suppressMs}ms');
  }

  static bool get isOverlayShowing => _isOverlayShowing;

  static Future<void> goToHome() async {
    try {
      await FlutterAccessibilityService.performGlobalAction(
        GlobalAction.globalActionHome,
      );
      await hideOverlayAndSuppress(suppressMs: 3000);
    } catch (e) {
      debugPrint('Error performing home action: $e');
      try {
        await hideOverlayAndSuppress(suppressMs: 3000);
      } catch (_) {}
    }
  }

  static Future<void> goBack() async {
    try {
      await FlutterAccessibilityService.performGlobalAction(
        GlobalAction.globalActionBack,
      );
    } catch (e) {
      debugPrint('Error performing back action: $e');
    }
  }

  static Future<bool> launchInavApp() async {
    try {
      final dynamic ok = await _channel.invokeMethod('launchMainActivity');
      await setPendingUnlockRequest(true);
      return ok == true || ok == null;
    } catch (e) {
      debugPrint('Error launching INav: $e');
      return false;
    }
  }

  static Future<void> setPendingUnlockRequest(bool pending) async {
    try {
      if (pending) {
        await _prefs?.setBool(_keyPendingUnlock, true);
      } else {
        await _prefs?.remove(_keyPendingUnlock);
      }
    } catch (e) {
      debugPrint('Error setting pending unlock: $e');
    }
  }

  static Future<bool> consumePendingUnlockRequest() async {
    try {
      final val = _prefs?.getBool(_keyPendingUnlock) ?? false;
      if (val) {
        await _prefs?.remove(_keyPendingUnlock);
      }
      return val;
    } catch (e) {
      debugPrint('Error consuming pending unlock: $e');
      return false;
    }
  }

  static Future<String?> getLastBlockedPackage() async {
    try {
      final v = _prefs?.getString(_keyLastBlockedPkg);
      if (v != null && v.isEmpty) return null;
      return v;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getLastBlockedAppName() async {
    try {
      final v = _prefs?.getString(_keyLastBlockedName);
      if (v != null && v.isEmpty) return null;
      return v;
    } catch (e) {
      return null;
    }
  }

  static void dispose() {
    _accessStreamSubscription?.cancel();
    _accessStreamSubscription = null;
    _appOpenedController.close();
    _isInitialized = false;
    _lastPackageName = null;
    _lastEventMillis = null;
    _currentlyBlockingPackage = null;
    _suppressUntilMillis = null;
  }
}
