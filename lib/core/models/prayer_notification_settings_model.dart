/// Model for a single prayer's notification preferences
/// Mirrors the per-prayer settings in the reference design (UI + saved
/// preferences only — no actual notification scheduling)
class PrayerNotificationSetting {
  /// Stable identifier, e.g. 'fajr'
  final String key;

  /// Display name, e.g. 'Fajr'
  final String name;

  final bool enabled;
  final bool playAdhan;

  /// Minutes before prayer time to remind (0–30, steps of 5)
  final int preReminderMinutes;

  final bool vibrate;

  static const int minReminderMinutes = 0;
  static const int maxReminderMinutes = 30;
  static const int reminderStep = 5;

  const PrayerNotificationSetting({
    required this.key,
    required this.name,
    required this.enabled,
    required this.playAdhan,
    required this.preReminderMinutes,
    required this.vibrate,
  });

  /// Copy with updated fields (reminder minutes clamped to valid range)
  PrayerNotificationSetting copyWith({
    bool? enabled,
    bool? playAdhan,
    int? preReminderMinutes,
    bool? vibrate,
  }) {
    return PrayerNotificationSetting(
      key: key,
      name: name,
      enabled: enabled ?? this.enabled,
      playAdhan: playAdhan ?? this.playAdhan,
      preReminderMinutes: (preReminderMinutes ?? this.preReminderMinutes)
          .clamp(minReminderMinutes, maxReminderMinutes),
      vibrate: vibrate ?? this.vibrate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'enabled': enabled,
      'playAdhan': playAdhan,
      'preReminderMinutes': preReminderMinutes,
      'vibrate': vibrate,
    };
  }

  factory PrayerNotificationSetting.fromJson(Map<String, dynamic> json) {
    return PrayerNotificationSetting(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      playAdhan: json['playAdhan'] as bool? ?? true,
      preReminderMinutes: (json['preReminderMinutes'] as int? ?? 0)
          .clamp(minReminderMinutes, maxReminderMinutes),
      vibrate: json['vibrate'] as bool? ?? true,
    );
  }

  /// Default settings for the 5 daily prayers
  static List<PrayerNotificationSetting> defaults() {
    return const [
      PrayerNotificationSetting(
        key: 'fajr',
        name: 'Fajr',
        enabled: true,
        playAdhan: true,
        preReminderMinutes: 10,
        vibrate: true,
      ),
      PrayerNotificationSetting(
        key: 'dhuhr',
        name: 'Dhuhr',
        enabled: true,
        playAdhan: true,
        preReminderMinutes: 5,
        vibrate: true,
      ),
      PrayerNotificationSetting(
        key: 'asr',
        name: 'Asr',
        enabled: true,
        playAdhan: true,
        preReminderMinutes: 5,
        vibrate: false,
      ),
      PrayerNotificationSetting(
        key: 'maghrib',
        name: 'Maghrib',
        enabled: true,
        playAdhan: true,
        preReminderMinutes: 10,
        vibrate: true,
      ),
      PrayerNotificationSetting(
        key: 'isha',
        name: 'Isha',
        enabled: true,
        playAdhan: true,
        preReminderMinutes: 5,
        vibrate: true,
      ),
    ];
  }
}
