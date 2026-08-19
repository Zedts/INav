import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  LockEngine(this._provider);

  Future<void> start() async {
    if (_isActive) return;

    debugPrint('LockEngine: Starting...');
    _isActive = true;

    final isEnabled =
        await AccessibilityServiceHelper.isAccessibilityServiceEnabled();
    if (!isEnabled) {
      debugPrint(
        'LockEngine: Accessibility service NOT enabled yet. '
        'Subscribing to stream anyway (will activate once user enables it).',
      );
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
    _appOpenedSubscription = AccessibilityServiceHelper.onAppOpened.listen(
      (packageName) => _handleAppOpened(packageName),
    );
    debugPrint('LockEngine: Subscribed to app-opened stream');
  }

  void _startReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!_isActive) return;
      final enabled =
          await AccessibilityServiceHelper.isAccessibilityServiceEnabled();
      if (enabled && !_appOpenedSubscriptionIsListening()) {
        debugPrint(
          'LockEngine: Re-connecting stream (service now enabled)',
        );
        _subscribeToStreams();
      }
    });
  }

  bool _appOpenedSubscriptionIsListening() =>
      _appOpenedSubscription != null;

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

    try {
      _serviceChannel.invokeMethod('stopForegroundService');
    } catch (e) {
      debugPrint('LockEngine: Error stopping foreground service - $e');
    }
  }

  Future<void> _handleAppOpened(String packageName) async {
    debugPrint('LockEngine: App opened - $packageName');

    if (!_provider.shouldBlockApp(packageName)) {
      debugPrint('LockEngine: App not blocked - $packageName');
      return;
    }

    final stillEnabled =
        await AccessibilityServiceHelper.isAccessibilityServiceEnabled();
    if (!stillEnabled) {
      debugPrint('LockEngine: Service disabled since start; skipping overlay');
      return;
    }

    debugPrint('LockEngine: Blocking app - $packageName');

    await AccessibilityServiceHelper.showLockOverlay();
  }

  Future<void> unlock() async {
    await AccessibilityServiceHelper.hideLockOverlay();
  }

  bool get isActive => _isActive;

  void dispose() {
    stop();
  }
}
