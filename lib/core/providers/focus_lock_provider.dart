import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

import '../models/app_definition.dart';
import '../models/lock_schedule.dart';
import '../models/unlock_config.dart';
import '../constants/default_apps.dart';
import '../constants/app_constants.dart';
import '../services/lock_engine.dart';
import '../services/device_admin_service.dart';

/// State management for Focus Lock feature
class FocusLockProvider with ChangeNotifier {
  static const String _keyMasterEnabled = 'focus_lock_master_enabled';
  static const String _keyLockedApps = 'focus_lock_locked_apps';
  static const String _keyPrayerSchedule = 'focus_lock_prayer_schedule';
  static const String _keyCustomSchedules = 'focus_lock_custom_schedules';
  static const String _keyUnlockConfig = 'focus_lock_unlock_config';
  static const String _keyAllowEmergency = 'focus_lock_allow_emergency';
  static const String _keyDailySkipAllowance =
      'focus_lock_daily_skip_allowance';
  static const String _keyPreventUninstall = 'focus_lock_prevent_uninstall';
  static const String _keySkipCount = 'focus_lock_skip_count_';
  static const String _keyLastResetDate = 'focus_lock_last_reset_date';

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  LockEngine? _lockEngine;
  Timer? _tickTimer;
  bool _lastIsInLockWindow = false;

  // State
  bool _masterEnabled = true;
  List<AppDefinition> _lockedApps = [];
  PrayerLockSchedule? _prayerSchedule;
  List<CustomLockSchedule> _customSchedules = [];
  UnlockConfig _unlockConfig = const UnlockConfig(
    method: UnlockMethod.markPrayed,
  );
  bool _allowEmergency = true;
  int _dailySkipAllowance = 1;
  bool _preventUninstall = true;
  int _todaySkipCount = 0;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get masterEnabled => _masterEnabled;
  List<AppDefinition> get lockedApps => List.unmodifiable(_lockedApps);
  PrayerLockSchedule? get prayerSchedule => _prayerSchedule;
  List<CustomLockSchedule> get customSchedules =>
      List.unmodifiable(_customSchedules);
  UnlockConfig get unlockConfig => _unlockConfig;
  bool get allowEmergency => _allowEmergency;
  int get dailySkipAllowance => _dailySkipAllowance;
  bool get preventUninstall => _preventUninstall;
  int get todaySkipCount => _todaySkipCount;
  int get remainingSkips =>
      (_dailySkipAllowance - _todaySkipCount).clamp(0, _dailySkipAllowance);
  bool get canSkip => remainingSkips > 0;
  LockEngine? get lockEngine => _lockEngine;

  /// Initialize provider and load saved data
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _loadState();
    await _checkAndResetDailyCount();

    // Initialize lock engine
    _lockEngine = LockEngine(this);

    // Start engine if master is enabled
    if (_masterEnabled) {
      await _lockEngine?.start();
    }

    _startTickTimer();

    _isInitialized = true;
    notifyListeners();
  }

  int _tickCount = 0;

  void _startTickTimer() {
    _tickTimer?.cancel();
    _tickCount = 0;
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tickCount++;
      _checkAndResetDailyCount();
      final nowInWindow = isInLockWindow();
      if (nowInWindow != _lastIsInLockWindow) {
        _lastIsInLockWindow = nowInWindow;
        notifyListeners();
      } else if (_tickCount % 15 == 0) {
        notifyListeners();
      }
    });
  }

  void _stopTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  /// Load state from SharedPreferences
  Future<void> _loadState() async {
    _masterEnabled = _prefs?.getBool(_keyMasterEnabled) ?? true;
    _allowEmergency = _prefs?.getBool(_keyAllowEmergency) ?? true;
    _dailySkipAllowance = _prefs?.getInt(_keyDailySkipAllowance) ?? 1;
    _preventUninstall = _prefs?.getBool(_keyPreventUninstall) ?? true;

    // Load locked apps
    final appsJson = _prefs?.getString(_keyLockedApps);
    if (appsJson != null) {
      final appsList = jsonDecode(appsJson) as List;
      _lockedApps = appsList
          .map((json) => AppDefinition.fromJson(json))
          .toList();
    } else {
      // Default to Instagram, TikTok, YouTube
      _lockedApps = DefaultApps.defaultPackages
          .map((pkg) => DefaultApps.getApp(pkg)!)
          .toList();
    }

    // Load prayer schedule
    final prayerJson = _prefs?.getString(_keyPrayerSchedule);
    if (prayerJson != null) {
      _prayerSchedule = PrayerLockSchedule.fromJson(jsonDecode(prayerJson));
    } else {
      // Default prayer schedule
      _prayerSchedule = PrayerLockSchedule(
        id: 'prayer_default',
        label: 'Lock During Prayer Times',
        enabled: true,
        enabledPrayers: const ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'],
        startOffsetMinutes: 0,
        durationMinutes: 20,
      );
    }

    // Load custom schedules
    final customJson = _prefs?.getString(_keyCustomSchedules);
    if (customJson != null) {
      final customList = jsonDecode(customJson) as List;
      _customSchedules = customList
          .map((json) => CustomLockSchedule.fromJson(json))
          .toList();
    }

    // Load unlock config
    final unlockJson = _prefs?.getString(_keyUnlockConfig);
    if (unlockJson != null) {
      _unlockConfig = UnlockConfig.fromJson(jsonDecode(unlockJson));
    }

    // Load skip count
    final today = DateTime.now().toIso8601String().split('T')[0];
    _todaySkipCount = _prefs?.getInt('$_keySkipCount$today') ?? 0;
  }

  /// Check if daily skip count should be reset
  Future<void> _checkAndResetDailyCount() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastReset = _prefs?.getString(_keyLastResetDate);

    if (lastReset != today) {
      _todaySkipCount = 0;
      await _prefs?.setString(_keyLastResetDate, today);
      await _prefs?.setInt('$_keySkipCount$today', 0);
    }
  }

  /// Set master enable/disable
  Future<void> setMasterEnabled(bool enabled) async {
    _masterEnabled = enabled;
    await _prefs?.setBool(_keyMasterEnabled, enabled);

    // Start/stop lock engine
    if (enabled) {
      await _lockEngine?.start();
    } else {
      _lockEngine?.stop();
    }

    notifyListeners();
  }

  /// Add an app to the locked list
  Future<void> addLockedApp(AppDefinition app) async {
    if (!_lockedApps.contains(app)) {
      _lockedApps.add(app);
      await _saveLockedApps();
      notifyListeners();
    }
  }

  /// Remove an app from the locked list
  Future<void> removeLockedApp(AppDefinition app) async {
    _lockedApps.remove(app);
    await _saveLockedApps();
    notifyListeners();
  }

  /// Toggle an app's locked status
  Future<void> toggleLockedApp(AppDefinition app, bool locked) async {
    if (locked) {
      await addLockedApp(app);
    } else {
      await removeLockedApp(app);
    }
  }

  /// Save locked apps to storage
  Future<void> _saveLockedApps() async {
    final appsJson = jsonEncode(
      _lockedApps.map((app) => app.toJson()).toList(),
    );
    await _prefs?.setString(_keyLockedApps, appsJson);
  }

  /// Update prayer schedule
  Future<void> updatePrayerSchedule(PrayerLockSchedule schedule) async {
    _prayerSchedule = schedule;
    await _prefs?.setString(_keyPrayerSchedule, jsonEncode(schedule.toJson()));
    notifyListeners();
  }

  /// Add a custom schedule
  Future<void> addCustomSchedule(CustomLockSchedule schedule) async {
    _customSchedules.add(schedule);
    await _saveCustomSchedules();
    notifyListeners();
  }

  /// Remove a custom schedule
  Future<void> removeCustomSchedule(String id) async {
    _customSchedules.removeWhere((s) => s.id == id);
    await _saveCustomSchedules();
    notifyListeners();
  }

  /// Update a custom schedule
  Future<void> updateCustomSchedule(CustomLockSchedule schedule) async {
    final index = _customSchedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _customSchedules[index] = schedule;
      await _saveCustomSchedules();
      notifyListeners();
    }
  }

  /// Save custom schedules to storage
  Future<void> _saveCustomSchedules() async {
    final schedulesJson = jsonEncode(
      _customSchedules.map((s) => s.toJson()).toList(),
    );
    await _prefs?.setString(_keyCustomSchedules, schedulesJson);
  }

  /// Update unlock configuration
  Future<void> updateUnlockConfig(UnlockConfig config) async {
    _unlockConfig = config;
    await _prefs?.setString(_keyUnlockConfig, jsonEncode(config.toJson()));
    notifyListeners();
  }

  /// Set allow emergency calls/messages
  Future<void> setAllowEmergency(bool allow) async {
    _allowEmergency = allow;
    await _prefs?.setBool(_keyAllowEmergency, allow);
    notifyListeners();
  }

  /// Set daily skip allowance
  Future<void> setDailySkipAllowance(int allowance) async {
    _dailySkipAllowance = allowance.clamp(0, 5);
    await _prefs?.setInt(_keyDailySkipAllowance, _dailySkipAllowance);
    notifyListeners();
  }

  /// Set prevent uninstall
  Future<void> setPreventUninstall(bool prevent) async {
    _preventUninstall = prevent;
    await _prefs?.setBool(_keyPreventUninstall, prevent);

    // Enable/disable device admin
    if (prevent) {
      await DeviceAdminService.requestDeviceAdmin();
    } else {
      await DeviceAdminService.removeDeviceAdmin();
    }

    notifyListeners();
  }

  /// Check if device admin is enabled
  Future<bool> isDeviceAdminEnabled() async {
    return await DeviceAdminService.isDeviceAdminEnabled();
  }

  /// Use a skip (called when user bypasses lock)
  Future<bool> useSkip() async {
    if (!canSkip) return false;

    _todaySkipCount++;
    final today = DateTime.now().toIso8601String().split('T')[0];
    await _prefs?.setInt('$_keySkipCount$today', _todaySkipCount);
    notifyListeners();
    return true;
  }

  /// Check if an app should be blocked right now
  bool shouldBlockApp(String packageName) {
    if (!_masterEnabled) return false;

    if (AppConstants.kEmergencyNonLockablePackages.contains(packageName)) {
      return false;
    }

    if (_allowEmergency && DefaultApps.isEssentialApp(packageName)) {
      return false;
    }

    final isLocked = _lockedApps.any((app) => app.matchesPackage(packageName));
    if (!isLocked) return false;

    return isInLockWindow();
  }

  /// Check if we're currently in a lock window
  bool isInLockWindow() {
    // Check prayer schedule
    if (_prayerSchedule != null && _prayerSchedule!.enabled) {
      if (_prayerSchedule!.isActiveNow()) return true;
    }

    // Check custom schedules
    for (final schedule in _customSchedules) {
      if (schedule.enabled && schedule.isActiveNow()) return true;
    }

    return false;
  }

  /// Update prayer times from PrayerProvider
  /// Should be called whenever prayer times are updated
  void updatePrayerTimes(Map<String, String> prayerTimes) {
    _prayerSchedule?.setPrayerTimes(prayerTimes);
    notifyListeners();
  }

  /// Get currently active prayer name (if lock is active due to prayer)
  String? getActivePrayerName() {
    if (_prayerSchedule != null && _prayerSchedule!.enabled) {
      return _prayerSchedule!.getActivePrayerName();
    }
    return null;
  }

  /// Reset to default configuration
  Future<void> resetToDefaults() async {
    _masterEnabled = true;
    _allowEmergency = true;
    _dailySkipAllowance = 1;
    _preventUninstall = true;

    _lockedApps = DefaultApps.defaultPackages
        .map((pkg) => DefaultApps.getApp(pkg)!)
        .toList();

    _prayerSchedule = PrayerLockSchedule(
      id: 'prayer_default',
      label: 'Lock During Prayer Times',
      enabled: true,
      enabledPrayers: const ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'],
      startOffsetMinutes: 0,
      durationMinutes: 20,
    );

    _customSchedules.clear();

    _unlockConfig = const UnlockConfig(method: UnlockMethod.markPrayed);

    await _prefs?.setBool(_keyMasterEnabled, _masterEnabled);
    await _prefs?.setBool(_keyAllowEmergency, _allowEmergency);
    await _prefs?.setInt(_keyDailySkipAllowance, _dailySkipAllowance);
    await _prefs?.setBool(_keyPreventUninstall, _preventUninstall);
    await _saveLockedApps();
    await _prefs?.setString(
      _keyPrayerSchedule,
      jsonEncode(_prayerSchedule!.toJson()),
    );
    await _prefs?.setString(_keyCustomSchedules, jsonEncode([]));
    await _prefs?.setString(
      _keyUnlockConfig,
      jsonEncode(_unlockConfig.toJson()),
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _stopTickTimer();
    _lockEngine?.dispose();
    super.dispose();
  }
}
