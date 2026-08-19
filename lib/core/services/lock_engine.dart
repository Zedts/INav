import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../providers/focus_lock_provider.dart';
import 'accessibility_service_helper.dart';

enum LockEngineMode { mainApp, overlayIsolate }

class LockEngine {
  static const MethodChannel _serviceChannel = MethodChannel(
    'com.zedt.inav/foreground_service',
  );

  final FocusLockProvider _provider;
  final LockEngineMode mode;
  StreamSubscription? _appOpenedSubscription;
  bool _isActive = false;

  LockEngine(this._provider, {this.mode = LockEngineMode.mainApp});

  Future<void> start() async {
    if (_isActive) return;

    debugPrint('LockEngine[$mode]: Starting...');
    _isActive = true;

    final isEnabled =
        await AccessibilityServiceHelper.isAccessibilityServiceEnabled();
    if (!isEnabled) {
      debugPrint(
        'LockEngine[$mode]: Accessibility service NOT enabled yet. '
        'Subscribing to stream anyway (will activate once user enables it).',
      );
    }

    if (mode == LockEngineMode.mainApp) {
      try {
        await _serviceChannel.invokeMethod('startForegroundService');
      } catch (e) {
        debugPrint('LockEngine[$mode]: Error starting foreground service - $e');
      }
    }

    _subscribeToStreams();
    _startReconnectTimer();
  }

  void _subscribeToStreams() {
    _appOpenedSubscription?.cancel();
    _appOpenedSubscription = AccessibilityServiceHelper.onAppOpened.listen(
      (packageName) => _handleAppOpened(packageName),
    );
    debugPrint('LockEngine[$mode]: Subscribed to app-opened stream');
  }

  void _startReconnectTimer() {
    AccessibilityServiceHelper.startServicePolling(
      interval: const Duration(seconds: 2),
    );
  }

  void stop() {
    if (!_isActive) return;

    debugPrint('LockEngine[$mode]: Stopping...');
    _appOpenedSubscription?.cancel();
    _appOpenedSubscription = null;
    AccessibilityServiceHelper.stopServicePolling();
    _isActive = false;

    if (mode == LockEngineMode.mainApp) {
      try {
        _serviceChannel.invokeMethod('stopForegroundService');
      } catch (e) {
        debugPrint('LockEngine[$mode]: Error stopping foreground service - $e');
      }
    }
  }

  Future<void> _handleAppOpened(String packageName) async {
    debugPrint('LockEngine[$mode]: App opened - $packageName');

    if (!_provider.shouldBlockApp(packageName)) {
      debugPrint('LockEngine[$mode]: App not blocked - $packageName');
      return;
    }

    final stillEnabled =
        await AccessibilityServiceHelper.isAccessibilityServiceEnabled();
    if (!stillEnabled) {
      debugPrint('LockEngine[$mode]: Service disabled since start; skipping overlay');
      return;
    }

    debugPrint('LockEngine[$mode]: Blocking app - $packageName');

    // Bug 3 fix (timer empty): persist ActiveLockInfo snapshot synchronously
    // RIGHT BEFORE showing the overlay. The overlay reads SharedPreferences
    // during its FocusLockProvider._loadState, so writing here ensures the
    // overlay sees a valid snapshot even if it starts mid-lock before the
    // every-5s periodic save fires. This also means prayer-based locks get
    // an up-to-date snapshot whenever a new app triggers re-block.
    try {
      await _provider.saveActiveLockSnapshotNow();
    } catch (_) {}

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
