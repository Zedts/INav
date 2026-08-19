import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

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
  /// In-memory fast-path cooldown (same-isolate only). The cross-engine
  /// source of truth is written to SharedPreferences below.
  static DateTime? _lastCloseCooldownUntil;
  static Timer? _debounceTimer;
  static String? _pendingPackage;

  // Cross-engine cooldown "mailbox" keys. Perplexity research confirms that
  // SharedPreferences (with explicit .reload()) is the safest way to exchange
  // small atomic values between separate FlutterEngines/isolates when the
  // engines are spawned by native code (no ReceivePort wiring possible).
  static const String _kCooldownRequestKey = 'inav_lock_cooldown_request';
  static const String _kCooldownAckKey = 'inav_lock_cooldown_ack';

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

  /// Check whether a cooldown is currently active. Uses BOTH:
  ///   1. In-memory static (fast path, same-isolate only), AND
  ///   2. SharedPreferences persisted record (cross-engine source of truth
  ///      via disk; explicitly reload()ed to bypass per-isolate Dart cache).
  ///
  /// Returns the remaining cooldown Duration (0 if none).
  static Future<Duration> _getRemainingCooldown() async {
    // Fast path: same-isolate static flag
    if (_lastCloseCooldownUntil != null) {
      final remaining =
          _lastCloseCooldownUntil!.difference(DateTime.now());
      if (remaining > Duration.zero) {
        return remaining;
      } else {
        _lastCloseCooldownUntil = null;
      }
    }
    // Cross-engine path: read the "mailbox" from disk
    try {
      final prefs = await SharedPreferences.getInstance();
      try {
        await prefs.reload();
      } catch (_) {}
      final raw = prefs.getString(_kCooldownRequestKey);
      if (raw == null || raw.isEmpty) return Duration.zero;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final untilMs = map['until'] as int?;
      if (untilMs == null) return Duration.zero;
      final until = DateTime.fromMillisecondsSinceEpoch(untilMs);
      final remaining = until.difference(DateTime.now());
      return remaining > Duration.zero ? remaining : Duration.zero;
    } catch (_) {
      return Duration.zero;
    }
  }

  static Future<void> showLockOverlay() async {
    final remaining = await _getRemainingCooldown();
    if (remaining > Duration.zero) {
      debugPrint(
        'AccessibilityHelper: Suppressing showLockOverlay '
        '(cooldown active, ${remaining.inSeconds}s remaining)',
      );
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
  ///
  /// The cooldown is persisted to SharedPreferences (cross-engine source of
  /// truth) BEFORE hiding the window. The MAIN ISOLATE's 1s tick timer calls
  /// [checkAndFireCooldownExpiry] which: reads the persisted record, detects
  /// when cooldown has elapsed, re-emits [_lastPackageName] through the main
  /// isolate's app-opened stream, and writes an ack. This 2-isolate mailbox
  /// pattern (Perplexity-recommended best practice) avoids:
  ///   - Calling MethodChannels registered on the main engine's binary
  ///     messenger from the overlay engine → MissingPluginException.
  ///   - Relying on per-isolate static fields → the other isolate never
  ///     sees the cooldown flag → instant re-lock or permanent unlock.
  ///   - Edge-triggered accessibility events → blocked app stays foreground
  ///     with no new event after cooldown expires (native Android behavior).
  static Future<void> hideLockOverlayWithCooldown() async {
    const suppressFor = Duration(seconds: 3);
    _lastCloseCooldownUntil = DateTime.now().add(suppressFor);
    try {
      final prefs = await SharedPreferences.getInstance();
      final untilMs =
          DateTime.now().add(suppressFor).millisecondsSinceEpoch;
      // Unique id so main isolate can distinguish successive requests
      final reqId = 'x_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(
        _kCooldownRequestKey,
        jsonEncode({
          'id': reqId,
          'until': untilMs,
          'pkg': _lastPackageName ?? '',
          'type': 'x',
        }),
      );
    } catch (_) {}
    await hideLockOverlay();
  }

  static Future<void> hideLockOverlayWithSkipCooldown({
    Duration suppressFor = const Duration(seconds: 30),
  }) async {
    _lastCloseCooldownUntil = DateTime.now().add(suppressFor);
    try {
      final prefs = await SharedPreferences.getInstance();
      final untilMs =
          DateTime.now().add(suppressFor).millisecondsSinceEpoch;
      final reqId = 'skip_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(
        _kCooldownRequestKey,
        jsonEncode({
          'id': reqId,
          'until': untilMs,
          'pkg': _lastPackageName ?? '',
          'type': 'skip',
        }),
      );
    } catch (_) {}
    await hideLockOverlay();
  }

  /// Called by the MAIN ISOLATE's 1s FocusLockProvider tick timer to:
  ///   1. Check for an un-acknowledged cooldown request from disk (reload)
  ///   2. If the cooldown has expired → re-emit [_lastPackageName] into the
  ///      main isolate's stream → LockEngine re-evaluates → overlay re-shows
  ///   3. Write an ack so the expiry is processed exactly once.
  ///
  /// The "only from main isolate" invariant is ensured via the
  /// `_appOpenedController.hasListener` guard: ONLY the isolate that
  /// called `LockEngine.start()` → `_subscribeToStreams()` →
  /// `AccessibilityServiceHelper.onAppOpened.listen()` will have a listener.
  /// The overlay isolate runs with `startEngine: false` so it has NO
  /// listener → returns early WITHOUT writing the ack or clearing the
  /// request → the main isolate's next tick handles it correctly (no race).
  static Future<void> checkAndFireCooldownExpiry() async {
    // FAST ELIMINATION: Only the isolate with LockEngine subscribed should
    // process cooldown expiry (main isolate). Overlay has no listener → skip.
    final isDetectorIsolate = _appOpenedController.hasListener;
    if (!isDetectorIsolate) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      try {
        await prefs.reload();
      } catch (_) {}
      final raw = prefs.getString(_kCooldownRequestKey);
      if (raw == null || raw.isEmpty) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final reqId = map['id'] as String? ?? '';
      final untilMs = map['until'] as int?;
      final storedPkg = (map['pkg'] as String?) ?? '';

      if (reqId.isEmpty || untilMs == null) {
        await prefs.remove(_kCooldownRequestKey);
        return;
      }

      final ackId = prefs.getString(_kCooldownAckKey) ?? '';
      if (ackId == reqId) {
        await prefs.remove(_kCooldownRequestKey);
        return;
      }

      final remaining = DateTime.fromMillisecondsSinceEpoch(untilMs)
          .difference(DateTime.now());
      if (remaining > Duration.zero) return; // not yet

      // Cooldown expired. We confirmed we are the detector isolate (has
      // listener → main isolate → valid _lastPackageName from accessibility
      // stream → safe to emit).
      final pkg = storedPkg.isEmpty ? _lastPackageName : storedPkg;
      if (pkg != null && pkg.isNotEmpty) {
        _appOpenedController.add(pkg);
        debugPrint(
          'AccessibilityHelper: Cooldown ($reqId) expired, '
          're-triggering pkg=$pkg',
        );
      }
      await prefs.setString(_kCooldownAckKey, reqId);
      await prefs.remove(_kCooldownRequestKey);
    } catch (e) {
      debugPrint('AccessibilityHelper: Cooldown expiry check error: $e');
    }
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
        // Bug 1 fix: dismiss the overlay window after launching INav.
        // Otherwise the overlay stays on top of the newly-created
        // MainActivity and the user must manually close it with the X.
        await hideLockOverlay();
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
        await hideLockOverlay();
        return;
      }
    } catch (e) {
      debugPrint('Open INav via intent:// failed (fallback to channel): $e');
    }

    try {
      await _channel.invokeMethod('openInavApp');
      debugPrint('Open INav via legacy focus_lock channel succeeded');
      await hideLockOverlay();
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
