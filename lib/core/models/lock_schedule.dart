import 'package:flutter/material.dart';

/// Base class for lock schedules
abstract class LockSchedule {
  final String id;
  final String label;
  final bool enabled;

  const LockSchedule({
    required this.id,
    required this.label,
    required this.enabled,
  });

  /// Check if current time is within this schedule's lock window
  bool isActiveNow();

  Map<String, dynamic> toJson();
}

/// Prayer-based lock schedule
class PrayerLockSchedule extends LockSchedule {
  final List<String>
  enabledPrayers; // ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']
  final int startOffsetMinutes; // Lock X minutes before prayer
  final int durationMinutes; // Lock for Y minutes

  // Runtime data (not persisted)
  Map<String, String>? _prayerTimes; // Injected from PrayerProvider

  PrayerLockSchedule({
    required super.id,
    required super.label,
    required super.enabled,
    required this.enabledPrayers,
    required this.startOffsetMinutes,
    required this.durationMinutes,
  });

  /// Inject prayer times from PrayerProvider
  void setPrayerTimes(Map<String, String> prayerTimes) {
    _prayerTimes = prayerTimes;
  }

  /// Get lock start time for a specific prayer
  DateTime? getLockStartTime(String prayerName) {
    if (_prayerTimes == null) return null;
    final timeStr = _prayerTimes![prayerName];
    if (timeStr == null) return null;

    final prayerTime = _parseTime(timeStr);
    if (prayerTime == null) return null;

    return prayerTime.subtract(Duration(minutes: startOffsetMinutes));
  }

  /// Get lock end time for a specific prayer
  DateTime? getLockEndTime(String prayerName) {
    final startTime = getLockStartTime(prayerName);
    if (startTime == null) return null;

    return startTime.add(Duration(minutes: durationMinutes));
  }

  @override
  bool isActiveNow() {
    if (_prayerTimes == null) return false;

    final now = DateTime.now();

    // Check each enabled prayer
    for (final prayerName in enabledPrayers) {
      final startTime = getLockStartTime(prayerName);
      final endTime = getLockEndTime(prayerName);

      if (startTime != null && endTime != null) {
        if (now.isAfter(startTime) && now.isBefore(endTime)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Get currently active prayer name (if any)
  String? getActivePrayerName() {
    if (_prayerTimes == null) return null;

    final now = DateTime.now();

    for (final prayerName in enabledPrayers) {
      final startTime = getLockStartTime(prayerName);
      final endTime = getLockEndTime(prayerName);

      if (startTime != null && endTime != null) {
        if (now.isAfter(startTime) && now.isBefore(endTime)) {
          return prayerName;
        }
      }
    }

    return null;
  }

  /// Parse time string (HH:mm) to DateTime today
  DateTime? _parseTime(String timeStr) {
    try {
      final now = DateTime.now();
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'prayer',
    'id': id,
    'label': label,
    'enabled': enabled,
    'enabledPrayers': enabledPrayers,
    'startOffsetMinutes': startOffsetMinutes,
    'durationMinutes': durationMinutes,
  };

  factory PrayerLockSchedule.fromJson(Map<String, dynamic> json) =>
      PrayerLockSchedule(
        id: json['id'] as String,
        label: json['label'] as String,
        enabled: json['enabled'] as bool,
        enabledPrayers: List<String>.from(json['enabledPrayers'] as List),
        startOffsetMinutes: json['startOffsetMinutes'] as int,
        durationMinutes: json['durationMinutes'] as int,
      );

  PrayerLockSchedule copyWith({
    String? id,
    String? label,
    bool? enabled,
    List<String>? enabledPrayers,
    int? startOffsetMinutes,
    int? durationMinutes,
  }) => PrayerLockSchedule(
    id: id ?? this.id,
    label: label ?? this.label,
    enabled: enabled ?? this.enabled,
    enabledPrayers: enabledPrayers ?? this.enabledPrayers,
    startOffsetMinutes: startOffsetMinutes ?? this.startOffsetMinutes,
    durationMinutes: durationMinutes ?? this.durationMinutes,
  );
}

/// Custom time-based lock schedule
class CustomLockSchedule extends LockSchedule {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const CustomLockSchedule({
    required super.id,
    required super.label,
    required super.enabled,
    required this.startTime,
    required this.endTime,
  });

  @override
  bool isActiveNow() {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (startMinutes < endMinutes) {
      // Same day (e.g., 9:00 - 17:00)
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    } else {
      // Crosses midnight (e.g., 22:00 - 06:00)
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'custom',
    'id': id,
    'label': label,
    'enabled': enabled,
    'startHour': startTime.hour,
    'startMinute': startTime.minute,
    'endHour': endTime.hour,
    'endMinute': endTime.minute,
  };

  factory CustomLockSchedule.fromJson(Map<String, dynamic> json) =>
      CustomLockSchedule(
        id: json['id'] as String,
        label: json['label'] as String,
        enabled: json['enabled'] as bool,
        startTime: TimeOfDay(
          hour: json['startHour'] as int,
          minute: json['startMinute'] as int,
        ),
        endTime: TimeOfDay(
          hour: json['endHour'] as int,
          minute: json['endMinute'] as int,
        ),
      );

  CustomLockSchedule copyWith({
    String? id,
    String? label,
    bool? enabled,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) => CustomLockSchedule(
    id: id ?? this.id,
    label: label ?? this.label,
    enabled: enabled ?? this.enabled,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
  );

  DateTime getAbsoluteStartTime({DateTime? now}) {
    final n = now ?? DateTime.now();
    final startOfDay = DateTime(n.year, n.month, n.day);
    var result = startOfDay.add(
      Duration(hours: startTime.hour, minutes: startTime.minute),
    );
    final startMin = startTime.hour * 60 + startTime.minute;
    final endMin = endTime.hour * 60 + endTime.minute;
    if (startMin > endMin) {
      final nowMin = n.hour * 60 + n.minute;
      if (nowMin < endMin) {
        result = result.subtract(const Duration(days: 1));
      }
    }
    return result;
  }

  DateTime getAbsoluteEndTime({DateTime? now}) {
    final start = getAbsoluteStartTime(now: now);
    final sMin = startTime.hour * 60 + startTime.minute;
    final eMin = endTime.hour * 60 + endTime.minute;
    final diffMin = (sMin <= eMin) ? (eMin - sMin) : (eMin + 24 * 60 - sMin);
    return start.add(Duration(minutes: diffMin));
  }
}

enum LockReason { prayer, customFocus }

class ActiveLockInfo {
  final LockReason reason;
  final String label;
  final DateTime startTime;
  final DateTime endTime;
  final CustomLockSchedule? customSchedule;
  final String? prayerName;

  const ActiveLockInfo({
    required this.reason,
    required this.label,
    required this.startTime,
    required this.endTime,
    this.customSchedule,
    this.prayerName,
  });

  int get remainingSeconds {
    final diff = endTime.difference(DateTime.now()).inSeconds;
    return diff < 0 ? 0 : diff;
  }

  String get formattedRemaining {
    final total = remainingSeconds;
    if (total <= 0) return '0 min';
    if (total < 60) return '$total sec';
    final min = total ~/ 60;
    if (min < 60) return '$min min';
    final h = min ~/ 60;
    final m = min % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}
