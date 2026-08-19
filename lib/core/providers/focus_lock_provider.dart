import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

import '../models/app_definition.dart';
import '../models/lock_schedule.dart';
import '../models/unlock_config.dart';
import '../constants/default_apps.dart';
import '../constants/app_constants.dart';
import '../services/lock_engine.dart';
import '../services/accessibility_service_helper.dart';
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
  static const String _keyActiveLockSnapshot = 'focus_lock_active_snapshot';
  static const String _keyPrayerTimesSnapshot = 'focus_lock_prayer_times';

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

  /// Retry helper for SharedPreferences.getInstance(). On some devices the
  /// pigeon channel is NOT ready synchronously after ensureInitialized(),
  /// throwing PlatformException(channel-error). If that propagates up
  /// uncaught during main() init, runApp() is never called and the app
  /// is PERMANENTLY stuck on the splash logo screen.
  static Future<SharedPreferences> _getPrefsWithRetry() async {
    const maxAttempts = 5;
    const delay = Duration(milliseconds: 100);
    Object? lastErr;
    for (var i = 0; i < maxAttempts; i++) {
      try {
        final prefs = await SharedPreferences.getInstance();
        try {
          await prefs.reload();
        } catch (_) {}
        return prefs;
      } catch (e) {
        lastErr = e;
        if (e is PlatformException && e.code == 'channel-error') {
          await Future.delayed(delay);
          continue;
        }
        rethrow;
      }
    }
    throw lastErr ?? StateError('SharedPreferences unavailable');
  }

  /// Initialize provider and load saved data
  Future<void> initialize({
    LockEngineMode mode = LockEngineMode.mainApp,
    bool startEngine = true,
  }) async {
    if (_isInitialized) return;

    try {
      _prefs = await _getPrefsWithRetry();
      await _loadState();
      await _checkAndResetDailyCount();

      // Initialize lock engine
      _lockEngine = LockEngine(this, mode: mode);

      // Start engine if master is enabled AND caller requested it
      // (overlay isolate is UI-only, never starts the detector engine)
      if (_masterEnabled && startEngine) {
        try {
          await _lockEngine?.start();
        } catch (e) {
          debugPrint('FocusLockProvider: LockEngine start failed (non-fatal): $e');
        }
      }

      _startTickTimer();
    } catch (e) {
      // NEVER propagate up. If we can't load state, fall back to sane
      // defaults + no engine, so at least the rest of the app boots.
      debugPrint('FocusLockProvider: init failed (non-fatal, defaults used): $e');
      _prefs = null;
      _masterEnabled = true;
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
      _customSchedules = [];
      _unlockConfig = const UnlockConfig(method: UnlockMethod.markPrayed);
      _allowEmergency = true;
      _dailySkipAllowance = 1;
      _preventUninstall = true;
      _todaySkipCount = 0;
      try {
        _startTickTimer();
      } catch (_) {}
    }

    _isInitialized = true;
    _lastIsInLockWindow = isInLockWindow();
    // Bug 3 fix (timer empty): save a snapshot of currently-active lock
    // immediately on boot so overlay can display the countdown even if it
    // opens during the first 5 seconds of app life (before the periodic
    // every-5-tick save fires). Prayer-schedule snapshots can be 0/0 if
    // prayer times not yet injected; PrayerProvider.updatePrayerTimes()
    // writes a fresh snapshot below. Custom schedules resolve immediately
    // from pure Dart so this call gets a concrete endsAt for them.
    if (_lastIsInLockWindow) {
      await _saveActiveLockSnapshot();
    }
    notifyListeners();
  }

  int _tickCount = 0;

  void _startTickTimer() {
    _tickTimer?.cancel();
    _tickCount = 0;
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _tickCount++;
      _checkAndResetDailyCount();
      // Refresh SharedPreferences cache so the overlay-isolate copy of this
      // provider always reads the newest skip count / cooldown / snapshot
      // values written by the main isolate (they share the disk file, not
      // the in-memory Dart cache).
      try {
        _prefs?.reload();
      } catch (_) {}
      // Cross-engine cooldown expiry re-check. Called from BOTH isolates but
      // AccessibilityServiceHelper internally short-circuits: only the
      // detector isolate (main, has onAppOpened listener) processes requests.
      await AccessibilityServiceHelper.checkAndFireCooldownExpiry();
      final nowInWindow = isInLockWindow();
      // Persist an ActiveLockSnapshot every 5s. This snapshot is the overlay
      // isolate's fall-back source of truth when:
      //   (a) the main isolate wrote the snapshot, but
      //   (b) the overlay isolate failed to hydrate _prayerSchedule._prayerTimes
      //       AND its own native getActiveLockInfo() returned null.
      // Storing absolute `endsAt` millis lets the overlay recompute remaining
      // seconds from realtime clock even if it started mid-window.
      if (_tickCount % 5 == 0) {
        await _saveActiveLockSnapshot();
      }
      if (nowInWindow != _lastIsInLockWindow) {
        _lastIsInLockWindow = nowInWindow;
        notifyListeners();
      } else if (_tickCount % 5 == 0) {
        // Refresh every 5s when idling OUT of lock window. BUT when user is
        // actively in a lock window, always notify EVERY SECOND so the
        // overlay header countdown + progress bar + wait-it-out timer
        // display stay 100% live in both main & overlay isolates.
        notifyListeners();
      } else if (_lastIsInLockWindow) {
        notifyListeners();
      }
    });
  }

  /// Public wrapper so LockEngine can save a snapshot immediately when it
  /// decides to block an app (before overlay opens). This removes the race
  /// where overlay loads before the first every-5s periodic save fires
  /// and gets null ActiveLockInfo → "—" displayed instead of countdown.
  Future<void> saveActiveLockSnapshotNow() => _saveActiveLockSnapshot();

  /// Serialize the CURRENT ActiveLockInfo to SharedPreferences with absolute
  /// timestamps. The overlay isolate reads this back in getActiveLockInfo()
  /// when its own runtime schedule objects can't resolve (prayer times not
  /// injected, schedule objects freshly loaded without runtime data).
  Future<void> _saveActiveLockSnapshot() async {
    try {
      final info = _nativeActiveLockInfo();
      if (info == null) {
        await _prefs?.remove(_keyActiveLockSnapshot);
        return;
      }
      await _prefs?.setString(
        _keyActiveLockSnapshot,
        jsonEncode({
          'reason': info.reason == LockReason.prayer ? 'prayer' : 'custom',
          'label': info.label,
          'startTime': info.startTime.millisecondsSinceEpoch,
          'endTime': info.endTime.millisecondsSinceEpoch,
          'prayerName': info.prayerName,
        }),
      );
    } catch (_) {}
  }

  /// The "native" (schedule-object-based) active-lock calculation. Renamed
  /// from the old getActiveLockInfo(); the public getter wraps this with
  /// SharedPreferences snapshot fallback for the overlay isolate.
  ActiveLockInfo? _nativeActiveLockInfo() {
    final now = DateTime.now();

    // 1. Check custom schedules FIRST (custom wins overlap — user answer Q2)
    for (final s in _customSchedules) {
      if (s.enabled && s.isActiveNow()) {
        return ActiveLockInfo(
          reason: LockReason.customFocus,
          label: s.label,
          startTime: s.getAbsoluteStartTime(now: now),
          endTime: s.getAbsoluteEndTime(now: now),
          customSchedule: s,
        );
      }
    }

    // 2. Prayer schedule SECOND
    if (_prayerSchedule != null && _prayerSchedule!.enabled) {
      final activePrayerName = _prayerSchedule!.getActivePrayerName();
      if (activePrayerName != null) {
        final start = _prayerSchedule!.getLockStartTime(activePrayerName) ?? now;
        final end = _prayerSchedule!.getLockEndTime(activePrayerName) ?? now;
        return ActiveLockInfo(
          reason: LockReason.prayer,
          label: activePrayerName.capitalizeFirst(),
          startTime: start,
          endTime: end,
          prayerName: activePrayerName,
        );
      }
    }

    return null;
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

    // Load persisted prayer times. PrayerLockSchedule._prayerTimes is RUNTIME-
    // ONLY (not serialized in toJson). Without this, the overlay isolate can
    // never resolve isActiveNow()/getActivePrayerName() and getActiveLockInfo()
    // returns null → the countdown timer would permanently show "—".
    final prayerTimesRaw = _prefs?.getString(_keyPrayerTimesSnapshot);
    if (prayerTimesRaw != null && _prayerSchedule != null) {
      try {
        final map = Map<String, String>.from(
          jsonDecode(prayerTimesRaw) as Map<String, dynamic>,
        );
        _prayerSchedule!.setPrayerTimes(map);
      } catch (_) {
        /* best effort; snapshot fallback below handles unknowns */
      }
    }
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
  /// Should be called whenever prayer times are updated.
  ///
  /// Also PERSISTS the prayer times to SharedPreferences so the OVERLAY
  /// isolate (which never creates PrayerProvider / never hits the network)
  /// can still resolve prayer-based isActiveNow() and getActivePrayerName().
  /// Without this the overlay's countdown renders as "—".
  Future<void> updatePrayerTimes(Map<String, String> prayerTimes) async {
    _prayerSchedule?.setPrayerTimes(prayerTimes);
    try {
      await _prefs?.setString(
        _keyPrayerTimesSnapshot,
        jsonEncode(prayerTimes),
      );
    } catch (_) {
      /* persist is best-effort */
    }
    // Bug 3 fix (timer empty): whenever prayer times are (re)injected from
    // PrayerProvider, immediately persist an ActiveLockInfo snapshot if
    // we are inside a lock window. This removes the ~5s window where the
    // overlay would show "—" for prayer-based locks before the periodic
    // tick save fires.
    if (isInLockWindow()) {
      await _saveActiveLockSnapshot();
    }
    notifyListeners();
  }

  /// Get currently active prayer name (if lock is active due to prayer)
  String? getActivePrayerName() {
    if (_prayerSchedule != null && _prayerSchedule!.enabled) {
      return _prayerSchedule!.getActivePrayerName();
    }
    return null;
  }

  /// Get currently active lock window info (custom wins over prayer per user
  /// request).
  ///
  /// TWO-LAYER resolve:
  ///   1. Fast path — `_nativeActiveLockInfo()` using in-memory schedule
  ///      objects and (if present) runtime-injected prayer times. Works in
  ///      the main isolate and works in the overlay IF prayer times were
  ///      successfully loaded from the SharedPreferences snapshot.
  ///   2. Fallback path — if native resolve returned null AND a persisted
  ///      ActiveLockSnapshot exists in SharedPreferences (written by the
  ///      main isolate every 5 ticks + still within its endTime window),
  ///      hydrate an ActiveLockInfo from that snapshot. This is the "belt
  ///      and suspenders" fix for the overlay isolate which has no network
  ///      access and can end up with null _prayerSchedule._prayerTimes even
  ///      after successful loadState().
  ActiveLockInfo? getActiveLockInfo() {
    final native = _nativeActiveLockInfo();
    if (native != null) return native;

    try {
      final raw = _prefs?.getString(_keyActiveLockSnapshot);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final endMillis = map['endTime'] as int?;
      final startMillis = map['startTime'] as int?;
      if (endMillis == null || startMillis == null) return null;

      final now = DateTime.now();
      final endTime = DateTime.fromMillisecondsSinceEpoch(endMillis);
      if (endTime.isBefore(now)) return null; // snapshot expired

      final reasonStr = map['reason'] as String? ?? 'prayer';
      return ActiveLockInfo(
        reason: reasonStr == 'prayer' ? LockReason.prayer : LockReason.customFocus,
        label: (map['label'] as String?) ?? 'Focus Time',
        startTime: DateTime.fromMillisecondsSinceEpoch(startMillis),
        endTime: endTime,
        prayerName: map['prayerName'] as String?,
      );
    } catch (_) {
      return null;
    }
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

extension _StringCapitalize on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
