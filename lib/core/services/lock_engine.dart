import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../providers/focus_lock_provider.dart';
import 'accessibility_service_helper.dart';

class LockEngine {
  static const MethodChannel _serviceChannel = MethodChannel(
    'com.zedt.inav/foreground_service',
  );

  final FocusLockProvider _provider;
  StreamSubscription? _appOpenedSubscription;
  StreamSubscription? _serviceStatusSubscription;
  bool _isActive = false;
  Timer? _reconnectTimer;
  bool _lastKnownServiceState = false;
  String? _currentlyBlockingPkg;
  int _lastEventCount = 0;
  int _lastPollEventCount = 0;
  DateTime? _lastServiceOnAt;

  LockEngine(this._provider);

  Future<void> start() async {
    if (_isActive) return;

    debugPrint('LockEngine: Starting...');
    _isActive = true;

    final isEnabled =
        await AccessibilityServiceHelper.isAccessibilityServiceEnabled();
    _lastKnownServiceState = isEnabled;
    if (!isEnabled) {
      debugPrint(
        'LockEngine: Accessibility service NOT enabled yet. '
        'Subscribing to stream anyway (will activate once user enables it).',
      );
    } else {
      _lastServiceOnAt = DateTime.now();
    }

    try {
      await _serviceChannel.invokeMethod('startForegroundService');
    } catch (e) {
      debugPrint('LockEngine: Error starting foreground service - $e');
    }

    _subscribeToStreams();
    _startReconnectTimer();
  }

  void _subscribeToStreams() {
    _appOpenedSubscription?.cancel();
    _lastEventCount = 0;
    _appOpenedSubscription = AccessibilityServiceHelper.onAppOpened.listen(
      (packageName) {
        _lastEventCount++;
        _handleAppOpened(packageName);
      },
      onError: (Object e) {
        debugPrint('LockEngine: onAppOpened stream error: $e');
      },
      onDone: () {
        debugPrint('LockEngine: onAppOpened stream closed — will re-subscribe on next poll');
        _appOpenedSubscription = null;
      },
    );
    debugPrint('LockEngine: Subscribed to app-opened stream');
  }

  void _startReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!_isActive) return;
      final enabled =
          await AccessibilityServiceHelper.isAccessibilityServiceEnabled();

      if (enabled != _lastKnownServiceState) {
        debugPrint(
          'LockEngine: Service state transition $_lastKnownServiceState -> $enabled',
        );
        _lastKnownServiceState = enabled;
        if (enabled) {
          _lastServiceOnAt = DateTime.now();
          debugPrint('LockEngine: Service turned ON — tearing down and rebuilding stream');
          _appOpenedSubscription?.cancel();
          _appOpenedSubscription = null;
          await AccessibilityServiceHelper.forceResubscribeStream();
          _subscribeToStreams();
          await Future<void>.delayed(const Duration(milliseconds: 300));
          _subscribeToStreams();
        } else {
          _lastServiceOnAt = null;
        }
      } else if (enabled) {
        _lastServiceOnAt ??= DateTime.now();
        final hasSub = _appOpenedSubscription != null;
        if (!hasSub) {
          debugPrint('LockEngine: Service ON but no subscription — re-subscribing');
          await AccessibilityServiceHelper.forceResubscribeStream();
          _subscribeToStreams();
        } else {
          if (_lastEventCount == _lastPollEventCount) {
            final age = DateTime.now().difference(_lastServiceOnAt!).inSeconds;
            if (age > 8) {
              debugPrint(
                'LockEngine: Stream silent for >${age}s (eventCount=$_lastEventCount) — forcing re-subscribe',
              );
              _appOpenedSubscription?.cancel();
              _appOpenedSubscription = null;
              await AccessibilityServiceHelper.forceResubscribeStream();
              _subscribeToStreams();
            }
          } else {
            _lastPollEventCount = _lastEventCount;
          }
        }
      }
    });
  }

  void stop() {
    if (!_isActive) return;

    debugPrint('LockEngine: Stopping...');
    _appOpenedSubscription?.cancel();
    _appOpenedSubscription = null;
    _serviceStatusSubscription?.cancel();
    _serviceStatusSubscription = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isActive = false;
    _currentlyBlockingPkg = null;
    _lastEventCount = 0;
    _lastPollEventCount = 0;
    _lastServiceOnAt = null;

    try {
      _serviceChannel.invokeMethod('stopForegroundService');
    } catch (e) {
      debugPrint('LockEngine: Error stopping foreground service - $e');
    }
  }

  Future<void> _handleAppOpened(String packageName) async {
    if (AppConstants.kEmergencyNonLockablePackages.contains(packageName)) {
      if (_currentlyBlockingPkg != null) {
        debugPrint('LockEngine: Emergency package $packageName visible — hiding overlay');
        _currentlyBlockingPkg = null;
        await AccessibilityServiceHelper.hideLockOverlay();
      } else {
        debugPrint('LockEngine: App in emergency allowlist - $packageName');
      }
      return;
    }

    final shouldBlock = _provider.shouldBlockApp(packageName);

    if (!shouldBlock) {
      if (_currentlyBlockingPkg != null) {
        debugPrint(
          'LockEngine: User navigated from $_currentlyBlockingPkg to $packageName (not blocked) — hiding overlay',
        );
        _currentlyBlockingPkg = null;
        await AccessibilityServiceHelper.hideLockOverlay();
      }
      return;
    }

    final stillEnabled =
        await AccessibilityServiceHelper.isAccessibilityServiceEnabled();
    if (!stillEnabled) {
      debugPrint('LockEngine: Service disabled since start; skipping overlay');
      return;
    }

    if (_currentlyBlockingPkg == packageName &&
        AccessibilityServiceHelper.isOverlayShowing) {
      debugPrint(
        'LockEngine: Still in $packageName (overlay already up) — no action',
      );
      return;
    }

    final appName = _provider.getAppName(packageName);
    debugPrint('LockEngine: Blocking app - $packageName ($appName)');
    _currentlyBlockingPkg = packageName;

    await AccessibilityServiceHelper.showLockOverlay(
      forPackage: packageName,
      appName: appName,
    );
  }

  Future<void> unlock() async {
    _currentlyBlockingPkg = null;
    await AccessibilityServiceHelper.hideLockOverlay();
  }

  bool get isActive => _isActive;

  String? get currentlyBlockingPkg => _currentlyBlockingPkg;

  void dispose() {
    stop();
  }
}
