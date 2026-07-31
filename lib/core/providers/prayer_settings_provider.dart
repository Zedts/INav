import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_notification_settings_model.dart';

/// Provider for managing prayer notification preferences
/// UI + saved preferences only — no actual notification scheduling
class PrayerSettingsProvider with ChangeNotifier {
  static const String _keySettings = 'prayer_notification_settings';

  // State
  List<PrayerNotificationSetting> _settings =
      PrayerNotificationSetting.defaults();
  int _adhanVolume = 80;
  bool _playOnSilent = false;
  bool _vibrateOnSilent = true;
  bool _isInitialized = false;

  // Getters
  List<PrayerNotificationSetting> get settings =>
      List.unmodifiable(_settings);
  int get adhanVolume => _adhanVolume;
  bool get playOnSilent => _playOnSilent;
  bool get vibrateOnSilent => _vibrateOnSilent;
  bool get isInitialized => _isInitialized;

  /// Master toggle is on when at least one prayer is enabled
  bool get masterEnabled => _settings.any((s) => s.enabled);

  /// Load persisted settings (safe to call multiple times)
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadState();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load state from shared preferences
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_keySettings);
      if (stored == null) return;

      final data = json.decode(stored) as Map<String, dynamic>;
      final list = data['prayers'] as List<dynamic>? ?? [];
      final loaded = list
          .map((e) =>
              PrayerNotificationSetting.fromJson(e as Map<String, dynamic>))
          .toList();
      if (loaded.length == 5) {
        _settings = loaded;
      }
      _adhanVolume = (data['adhanVolume'] as int? ?? 80).clamp(0, 100);
      _playOnSilent = data['playOnSilent'] as bool? ?? false;
      _vibrateOnSilent = data['vibrateOnSilent'] as bool? ?? true;
    } catch (e) {
      // Corrupted or unreadable stored data — keep defaults instead of crashing
      debugPrint('PrayerSettingsProvider load error (non-fatal): $e');
      _settings = PrayerNotificationSetting.defaults();
    }
  }

  /// Save state to shared preferences (best-effort)
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _keySettings,
        json.encode({
          'prayers': _settings.map((s) => s.toJson()).toList(),
          'adhanVolume': _adhanVolume,
          'playOnSilent': _playOnSilent,
          'vibrateOnSilent': _vibrateOnSilent,
        }),
      );
    } catch (e) {
      // Persisting is best-effort — in-memory state stays valid for this session
      debugPrint('PrayerSettingsProvider save error (non-fatal): $e');
    }
  }

  PrayerNotificationSetting? settingFor(String key) {
    for (final s in _settings) {
      if (s.key == key) return s;
    }
    return null;
  }

  void _updateSetting(
    String key,
    PrayerNotificationSetting Function(PrayerNotificationSetting) update,
  ) {
    _settings = _settings.map((s) => s.key == key ? update(s) : s).toList();
    _saveState();
    notifyListeners();
  }

  /// Master switch — enables/disables notifications for all prayers
  void setMasterEnabled(bool enabled) {
    _settings = _settings.map((s) => s.copyWith(enabled: enabled)).toList();
    _saveState();
    notifyListeners();
  }

  void setPrayerEnabled(String key, bool enabled) {
    _updateSetting(key, (s) => s.copyWith(enabled: enabled));
  }

  void setPlayAdhan(String key, bool playAdhan) {
    _updateSetting(key, (s) => s.copyWith(playAdhan: playAdhan));
  }

  void setVibrate(String key, bool vibrate) {
    _updateSetting(key, (s) => s.copyWith(vibrate: vibrate));
  }

  /// Adjust the pre-prayer reminder by [delta] minutes (clamped in copyWith)
  void adjustPreReminder(String key, int delta) {
    _updateSetting(
      key,
      (s) => s.copyWith(preReminderMinutes: s.preReminderMinutes + delta),
    );
  }

  void setAdhanVolume(int volume) {
    _adhanVolume = volume.clamp(0, 100);
    _saveState();
    notifyListeners();
  }

  void setPlayOnSilent(bool value) {
    _playOnSilent = value;
    _saveState();
    notifyListeners();
  }

  void setVibrateOnSilent(bool value) {
    _vibrateOnSilent = value;
    _saveState();
    notifyListeners();
  }

  /// Restore all settings to their defaults
  void resetToDefaults() {
    _settings = PrayerNotificationSetting.defaults();
    _adhanVolume = 80;
    _playOnSilent = false;
    _vibrateOnSilent = true;
    _saveState();
    notifyListeners();
  }
}
