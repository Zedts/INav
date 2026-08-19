import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class AccessibilityServiceHelper {
  static const MethodChannel _channel = MethodChannel(
    'com.zedt.inav/focus_lock',
  );

  static StreamSubscription<AccessibilityEvent>? _accessStreamSubscription;
  static final StreamController<String> _appOpenedController =
      StreamController<String>.broadcast();
  /// NOTE: Do NOT rely on this flag for correctness across-isolate decisions.
  /// The overlay isolate and main isolate each have a DIFFERENT copy of all
  /// static fields on this class (Dart isolates do not share memory). This flag
  /// is a best-effort cache for the SAME isolate that set it.
  static bool _isOverlayShowing = false;
  static bool _isInitialized = false;
  static String? _lastPackageName;
  static Timer? _servicePollTimer;
  static bool _serviceConfirmedConnected = false;
  /// X-cooldown suppresses re-show. Cooldown-timestamp is LOCAL to each isolate
  /// (main isolate uses it for detector → suppressor; overlay isolate writes it on
  /// onCloseViewWithCooldown). Because X-cooldown also reshow on buttons press X.
  static DateTime? _lastCloseCooldownUntil;
  static Timer? _debounceTimer;
  static String? _pendingPackage;
  static Timer? _cooldownExpiryTimer;
  static const MethodChannel _usageStatsChannel = MethodChannel(
    'com.zedt.inav/usage_stats',
  );

  static Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      await _subscribeToAccessStreamWithRetry();
    } catch (e) {
      // Plugin channel may not be ready yet during early init — this is
      // non-fatal. When the user actually enables the accessibility service,
      // the polling timer (LockEngine.startReconnectTimer) will call
      // forceResubscribe(), which will retry again. Never let this throw
      // up into main() and prevent runApp() from executing.
      debugPrint('AccessibilityHelper: init stream subscription delayed (non-fatal): $e');
    }
  }

  static Future<void> forceResubscribe() async {
    _accessStreamSubscription?.cancel();
    _accessStreamSubscription = null;
    _serviceConfirmedConnected = false;
    _lastPackageName = null;
    _pendingPackage = null;
    _debounceTimer?.cancel();
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      await _subscribeToAccessStreamWithRetry();
    } catch (e) {
      debugPrint('AccessibilityHelper: forceResubscribe stream error (non-fatal): $e');
    }
    final connected = await isAccessibilityServiceEnabled();
    if (connected) {
      _serviceConfirmedConnected = true;
      debugPrint('AccessibilityHelper: Force resubscribe succeeded, stream confirmed alive');
    }
  }

  /// Subscribe to the accessibility stream with retry. During early app init
  /// the `x-slayer/accessibility_event` EventChannel's native handler may not
  /// be registered on the BinaryMessenger yet, causing:
  ///   MissingPluginException(No implementation found for method listen on
  ///   channel x-slayer/accessibility_event)
  ///
  /// Without retry, the exception propagates to the root zone uncaught,
  /// preventing main() from reaching runApp() → app stuck on launch logo.
  static Future<void> _subscribeToAccessStreamWithRetry() async {
    const maxAttempts = 5;
    const delay = Duration(milliseconds: 200);
    Object? lastErr;
    for (var i = 0; i < maxAttempts; i++) {
      try {
        _doSubscribe();
        return;
      } catch (e) {
        lastErr = e;
        final isMissing = e is MissingPluginException ||
            (e is PlatformException &&
                (e.code == 'channel-error' ||
                    (e.message ?? '').contains('listen on channel')));
        if (isMissing) {
          await Future.delayed(delay);
          continue;
        }
        rethrow;
      }
    }
    throw lastErr ?? StateError('Accessibility stream unavailable');
  }

  static void _doSubscribe() {
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
        _pendingPackage = packageName;
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 100), () {
          if (_pendingPackage != null && _pendingPackage != _lastPackageName) {
            _lastPackageName = _pendingPackage;
            _appOpenedController.add(_pendingPackage!);
          }
        });
      }
    }, onError: (_) {
      // Swallow stream errors. The polling timer + forceResubscribe will
      // recover. We never want a stream error to reach the root zone.
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

  static void startServicePolling({Duration interval = const Duration(seconds: 2)}) {
    stopServicePolling();
    _servicePollTimer = Timer.periodic(interval, (_) async {
      final enabled = await isAccessibilityServiceEnabled();
      if (enabled && !_serviceConfirmedConnected) {
        debugPrint('AccessibilityHelper: Service detected enabled! Resubscribing...');
        await forceResubscribe();
      } else if (!enabled && _serviceConfirmedConnected) {
        _serviceConfirmedConnected = false;
      }
    });
  }

  static void stopServicePolling() {
    _servicePollTimer?.cancel();
    _servicePollTimer = null;
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
    if (_lastCloseCooldownUntil != null &&
        DateTime.now().isBefore(_lastCloseCooldownUntil!)) {
      debugPrint('AccessibilityHelper: Suppressing showLockOverlay (X cooldown active)');
      return;
    }
    // Always forward to the plugin. The plugin's native side tracks window
    // state; Dart static _isOverlayShowing is isolate-local and unreliable
    // for cross-isolate coordination. Showing an already-shown overlay is
    // harmless (native plugin handles the idempotency).
    try {
      await FlutterAccessibilityService.showOverlayWindow();
      _isOverlayShowing = true;
      debugPrint('Lock overlay shown');
    } catch (e) {
      debugPrint('Error showing lock overlay: $e');
    }
  }

  static Future<void> hideLockOverlay() async {
    // DO NOT early-return based on _isOverlayShowing. Overlay isolate's copy
    // is always `false` (it never called showLockOverlay in its isolate),
    // so the X button was silently no-op'ing the hide call.
    try {
      await FlutterAccessibilityService.hideOverlayWindow();
      _isOverlayShowing = false;
      debugPrint('Lock overlay hidden');
    } catch (e) {
      debugPrint('Error hiding lock overlay: $e');
    }
  }

  /// X button: hide the overlay AND suppress automatic re-show for 3 seconds.
  /// After the 3s cooldown EXPIRES, re-check the CURRENT foreground app via
  /// UsageStats and force a re-lock decision. This handles the edge-triggered
  /// nature of TYPE_WINDOW_STATE_CHANGED: after dismissing the overlay, the
  /// blocked app remains in the foreground so Android emits no new event —
  /// without this explicit re-check, the user would stay unblocked until they
  /// exit and re-open the app.
  static Future<void> hideLockOverlayWithCooldown() async {
    _lastCloseCooldownUntil = DateTime.now().add(const Duration(seconds: 3));
    _cooldownExpiryTimer?.cancel();
    _cooldownExpiryTimer = Timer(const Duration(seconds: 3), () async {
      try {
        final currentPkg = await _usageStatsChannel.invokeMethod('getCurrentApp')
            as String?;
        final pkg = currentPkg ?? _lastPackageName;
        if (pkg != null && pkg.isNotEmpty) {
          _appOpenedController.add(pkg);
          debugPrint(
            'AccessibilityHelper: X-cooldown expired, re-checking pkg=$pkg',
          );
        }
      } catch (e) {
        debugPrint('AccessibilityHelper: Cooldown re-check error: $e');
        if (_lastPackageName != null) {
          _appOpenedController.add(_lastPackageName!);
        }
      }
    });
    await hideLockOverlay();
  }

  static Future<void> hideLockOverlayWithSkipCooldown({
    Duration suppressFor = const Duration(seconds: 30),
  }) async {
    _lastCloseCooldownUntil = DateTime.now().add(suppressFor);
    _cooldownExpiryTimer?.cancel();
    _cooldownExpiryTimer = Timer(suppressFor, () async {
      try {
        final currentPkg = await _usageStatsChannel.invokeMethod('getCurrentApp')
            as String?;
        final pkg = currentPkg ?? _lastPackageName;
        if (pkg != null && pkg.isNotEmpty) {
          _appOpenedController.add(pkg);
          debugPrint(
            'AccessibilityHelper: Skip-cooldown expired, re-checking pkg=$pkg',
          );
        }
      } catch (e) {
        if (_lastPackageName != null) {
          _appOpenedController.add(_lastPackageName!);
        }
      }
    });
    await hideLockOverlay();
  }

  /// Launch INav (the app's own MainActivity).
  ///
  /// PRIMARY: `com.zedt.inav_launcher` MethodChannel — handled by the
  /// inav_launcher local FlutterPlugin (auto-registered on EVERY FlutterEngine
  /// in the process, main + overlay). Uses Application-level Context +
  /// FLAG_ACTIVITY_NEW_TASK so it works from the overlay-isolate engine
  /// (which has NO foreground FlutterActivity — url_launcher_android would
  /// throw PlatformException(NO_ACTIVITY)).
  ///
  /// FALLBACK: url_launcher intent:// scheme (best-effort, works on main
  /// engine).
  ///
  /// FINAL FALLBACK: legacy custom focus_lock MethodChannel (only for the
  /// main isolate, registered in MainActivity.configureFlutterEngine).
  static Future<void> openInavApp() async {
    const launcherChannel = MethodChannel('com.zedt.inav_launcher');
    try {
      final result = await launcherChannel.invokeMethod<bool>('openInavApp');
      if (result == true) {
        debugPrint('Open INav via inav_launcher plugin succeeded');
        return;
      }
    } catch (e) {
      debugPrint('Open INav via inav_launcher failed (fallback chain): $e');
    }

    const package = 'com.zedt.inav';
    try {
      const flags = '0x34000000';
      final intent = Uri.parse(
        'intent://#Intent;'
        'action=android.intent.action.MAIN;'
        'category=android.intent.category.LAUNCHER;'
        'package=$package;'
        'component=$package/.MainActivity;'
        'launchFlags=$flags;'
        'end',
      );
      final ok = await launchUrl(
        intent,
        mode: LaunchMode.externalApplication,
      );
      if (ok) {
        debugPrint('Open INav via intent:// succeeded');
        return;
      }
    } catch (e) {
      debugPrint('Open INav via intent:// failed (fallback to channel): $e');
    }

    try {
      await _channel.invokeMethod('openInavApp');
    } catch (e) {
      debugPrint('Error opening INav app: $e');
    }
  }

  static bool get isOverlayShowing => _isOverlayShowing;
  static bool get isServiceConfirmedConnected => _serviceConfirmedConnected;

  static void dispose() {
    _accessStreamSubscription?.cancel();
    _accessStreamSubscription = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _cooldownExpiryTimer?.cancel();
    _cooldownExpiryTimer = null;
    _appOpenedController.close();
    _servicePollTimer?.cancel();
    _servicePollTimer = null;
    _isInitialized = false;
    _lastPackageName = null;
    _serviceConfirmedConnected = false;
    _lastCloseCooldownUntil = null;
    _pendingPackage = null;
  }
}
