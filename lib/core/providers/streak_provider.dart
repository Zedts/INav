import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing prayer streak/completion state
class StreakProvider with ChangeNotifier {
  static const String _keyDate = 'streak_date';
  static const String _keyCompletedPrayers = 'streak_completed';
  static const String _keyCurrentPrayer = 'streak_current_prayer';
  static const String _keyStreakDays = 'streak_days';

  // State
  DateTime? _trackedDate;
  List<String> _completedPrayers = [];
  String? _currentPrayerWindow;
  int _streakDays = 0;
  bool _isInitialized = false;

  // Getters
  List<String> get completedPrayers => _completedPrayers;
  int get completedCount => _completedPrayers.length;
  bool get isCurrentPrayerCompleted =>
      _currentPrayerWindow != null && _completedPrayers.contains(_currentPrayerWindow!);
  int get streakDays => _streakDays;
  bool get isInitialized => _isInitialized;

  /// Initialize the provider
  ///
  /// [fajrTime] is today's Fajr time as "HH:mm". The streak "day" boundary is
  /// Fajr, not midnight: before Fajr we still belong to the previous prayer
  /// day, so progress is only reset once Subuh (Fajr) time hits.
  Future<void> initialize({
    required DateTime currentDate,
    required String currentPrayer,
    String? fajrTime,
  }) async {
    try {
      await _loadState();
      final effectiveDate = _effectivePrayerDate(currentDate, fajrTime);
      await _checkAndResetDate(effectiveDate, currentPrayer);
      await _checkPrayerWindow(currentPrayer);
    } catch (e) {
      // Streak tracking is non-essential — never let a storage failure
      // bubble up and break the home screen
      debugPrint('StreakProvider initialize error (non-fatal): $e');
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Resolve the "prayer day" a moment belongs to. If [now] is before today's
  /// Fajr time, it still belongs to the previous calendar day; otherwise it is
  /// the current day. Falls back to the raw date when Fajr can't be parsed.
  DateTime _effectivePrayerDate(DateTime now, String? fajrTime) {
    final today = DateTime(now.year, now.month, now.day);
    if (fajrTime == null) return today;

    final parts = fajrTime.split(':');
    if (parts.length != 2) return today;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return today;

    final fajrToday = DateTime(now.year, now.month, now.day, hour, minute);
    if (now.isBefore(fajrToday)) {
      // Still the previous prayer day (between midnight and Subuh)
      return today.subtract(const Duration(days: 1));
    }
    return today;
  }

  /// Load state from shared preferences
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateStr = prefs.getString(_keyDate);
      final completedStr = prefs.getString(_keyCompletedPrayers);
      final currentPrayerStr = prefs.getString(_keyCurrentPrayer);
      final streakDaysStr = prefs.getInt(_keyStreakDays);

      if (dateStr != null) {
        _trackedDate = DateTime.tryParse(dateStr);
      }
      if (completedStr != null) {
        _completedPrayers = List<String>.from(json.decode(completedStr));
      }
      if (currentPrayerStr != null) {
        _currentPrayerWindow = currentPrayerStr;
      }
      if (streakDaysStr != null) {
        _streakDays = streakDaysStr;
      }
    } catch (e) {
      // Corrupted or unreadable stored data — start fresh instead of crashing
      debugPrint('StreakProvider load error (non-fatal): $e');
      _trackedDate = null;
      _completedPrayers = [];
      _currentPrayerWindow = null;
      _streakDays = 0;
    }
  }

  /// Save state to shared preferences
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_trackedDate != null) {
        await prefs.setString(_keyDate, _trackedDate!.toIso8601String());
      }
      await prefs.setString(
        _keyCompletedPrayers,
        json.encode(_completedPrayers),
      );
      if (_currentPrayerWindow != null) {
        await prefs.setString(_keyCurrentPrayer, _currentPrayerWindow!);
      }
      await prefs.setInt(_keyStreakDays, _streakDays);
    } catch (e) {
      // Persisting is best-effort — in-memory state stays valid for this session
      debugPrint('StreakProvider save error (non-fatal): $e');
    }
  }

  /// Check if we need to reset for a new day
  Future<void> _checkAndResetDate(DateTime currentDate, String currentPrayer) async {
    if (_trackedDate == null ||
        _trackedDate!.year != currentDate.year ||
        _trackedDate!.month != currentDate.month ||
        _trackedDate!.day != currentDate.day) {
      // New day! Reset completed prayers, update streak if applicable
      if (_trackedDate != null) {
        final yesterday = currentDate.subtract(const Duration(days: 1));
        if (_trackedDate!.year == yesterday.year &&
            _trackedDate!.month == yesterday.month &&
            _trackedDate!.day == yesterday.day) {
          // If yesterday all 5 prayers were completed, increment streak
          if (_completedPrayers.length == 5) {
            _streakDays++;
          }
        } else {
          // Streak broken
          _streakDays = 0;
        }
      }
      _trackedDate = currentDate;
      _completedPrayers = [];
      _currentPrayerWindow = currentPrayer;
      await _saveState();
    }
  }

  /// Check if the prayer window has changed
  Future<void> _checkPrayerWindow(String newPrayer) async {
    if (_currentPrayerWindow != newPrayer) {
      _currentPrayerWindow = newPrayer;
      await _saveState();
    }
  }

  /// Mark current prayer as completed (cannot uncomplete)
  Future<void> markCurrentPrayerCompleted() async {
    if (_currentPrayerWindow == null) return;

    if (!_completedPrayers.contains(_currentPrayerWindow!)) {
      _completedPrayers.add(_currentPrayerWindow!);
      await _saveState();
      notifyListeners();
    }
  }

  /// Update prayer window (called when current prayer changes)
  Future<void> updatePrayerWindow(String newPrayer) async {
    await _checkPrayerWindow(newPrayer);
    notifyListeners();
  }
}
