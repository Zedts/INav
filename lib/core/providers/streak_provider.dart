import 'dart:convert';
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
  Future<void> initialize({
    required DateTime currentDate,
    required String currentPrayer,
  }) async {
    await _loadState();
    await _checkAndResetDate(currentDate, currentPrayer);
    await _checkPrayerWindow(currentPrayer);
    _isInitialized = true;
    notifyListeners();
  }

  /// Load state from shared preferences
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyDate);
    final completedStr = prefs.getString(_keyCompletedPrayers);
    final currentPrayerStr = prefs.getString(_keyCurrentPrayer);
    final streakDaysStr = prefs.getInt(_keyStreakDays);

    if (dateStr != null) {
      _trackedDate = DateTime.parse(dateStr);
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
  }

  /// Save state to shared preferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_trackedDate != null) {
      await prefs.setString(_keyDate, _trackedDate!.toIso8601String());
    }
    await prefs.setString(_keyCompletedPrayers, json.encode(_completedPrayers));
    if (_currentPrayerWindow != null) {
      await prefs.setString(_keyCurrentPrayer, _currentPrayerWindow!);
    }
    await prefs.setInt(_keyStreakDays, _streakDays);
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
