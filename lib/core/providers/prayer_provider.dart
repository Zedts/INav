import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../errors/error_messages.dart';
import '../models/prayer_times_model.dart';
import '../models/qibla_model.dart';
import '../models/calendar_model.dart';
import '../services/prayer_service.dart';
import '../services/qibla_service.dart';
import '../services/calendar_service.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

/// Provider for managing prayer times, qibla, and calendar data
/// Handles data fetching, caching, countdown timer, and state management
class PrayerProvider with ChangeNotifier {
  // Services
  final PrayerService _prayerService = PrayerService();
  final QiblaService _qiblaService = QiblaService();
  final CalendarService _calendarService = CalendarService();
  final LocationService _locationService = LocationService();

  // State
  PrayerTimesModel? _prayerTimes;
  QiblaModel? _qiblaData;
  CalendarModel? _calendar;
  Position? _currentPosition;
  String _locationName = 'Loading...';

  bool _isLoading = false;
  String? _errorMessage;

  // Countdown timer
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;
  String _nextPrayer = 'Fajr';
  String _currentPrayer = 'Fajr'; // Current/last passed prayer

  // Getters
  PrayerTimesModel? get prayerTimes => _prayerTimes;
  QiblaModel? get qiblaData => _qiblaData;
  CalendarModel? get calendar => _calendar;
  Position? get currentPosition => _currentPosition;
  String get locationName => _locationName;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Duration get timeRemaining => _timeRemaining;
  String get nextPrayer => _nextPrayer;
  String get currentPrayer => _currentPrayer; // Getter for current prayer

  /// Initialize prayer data - fetch location, prayer times, qibla, and calendar
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current location
      await _fetchLocation();

      // Fetch all data in parallel. Prayer times are essential; qibla and
      // calendar failures are non-fatal (both have local fallbacks).
      await Future.wait([
        _fetchPrayerTimes(),
        _fetchQiblaDirection(),
        _fetchCalendar(),
      ]);

      // Start countdown timer
      _startCountdownTimer();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = friendlyErrorMessage(
        e,
        fallback: ErrorMessages.prayerDataFailed,
      );
      _isLoading = false;
      debugPrint('PrayerProvider initialize error: $e');
      notifyListeners();
    }
  }

  /// Fetch current location
  Future<void> _fetchLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentPosition();

      if (_currentPosition != null) {
        _locationName = await _locationService.getCityFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }
    } catch (e) {
      _locationName = 'Location unavailable';
      debugPrint('PrayerProvider location error: $e');
      // Use default location (Jakarta)
      _currentPosition = Position(
        latitude: -6.2088,
        longitude: 106.8456,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
  }

  /// Fetch prayer times from API (essential — errors propagate to the UI)
  Future<void> _fetchPrayerTimes() async {
    if (_currentPosition == null) return;

    // Use default city ID from .env
    final cityId = dotenv.env['DEFAULT_CITY_ID']!;
    // ApiException already carries a user-friendly message; let it propagate
    _prayerTimes = await _prayerService.getTodayPrayerTimes(cityId);
  }

  /// Fetch Qibla direction (non-fatal — the service falls back to a local
  /// calculation, so a failure here should not block the home screen)
  Future<void> _fetchQiblaDirection() async {
    if (_currentPosition == null) return;

    try {
      _qiblaData = await _qiblaService.getQiblaDirection(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    } catch (e) {
      debugPrint('PrayerProvider qibla error (non-fatal): $e');
    }
  }

  /// Fetch Islamic calendar (non-fatal — computed locally)
  Future<void> _fetchCalendar() async {
    try {
      _calendar = await _calendarService.getTodayCalendar();
    } catch (e) {
      debugPrint('PrayerProvider calendar error (non-fatal): $e');
    }
  }

  /// Start countdown timer to next prayer
  void _startCountdownTimer() {
    _countdownTimer?.cancel();

    if (_prayerTimes == null) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeRemaining();
    });
  }

  /// Update time remaining to next prayer
  void _updateTimeRemaining() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    final times = _prayerTimes!.getAllPrayerTimes();

    // Find next prayer and current/last passed prayer
    DateTime? nextPrayerTime;
    String? nextPrayerName;
    String? lastPassedPrayer;

    for (final entry in times.entries) {
      final prayerTime = _parseTime(entry.value);
      if (prayerTime != null) {
        if (prayerTime.isAfter(now)) {
          // This is the next upcoming prayer
          if (nextPrayerTime == null) {
            nextPrayerTime = prayerTime;
            nextPrayerName = entry.key;
          }
        } else {
          // This prayer has passed, keep track of the last one
          lastPassedPrayer = entry.key;
        }
      }
    }

    // Set current prayer to the last passed prayer
    // If no prayer has passed today, default to Isha (from yesterday)
    if (lastPassedPrayer != null) {
      _currentPrayer = lastPassedPrayer;
    } else {
      _currentPrayer = 'Isha'; // Before Fajr, show Isha from previous day
    }

    // If no prayer found today, next prayer is Fajr tomorrow
    if (nextPrayerTime == null) {
      nextPrayerName = 'Fajr';
      final fajrTime = _parseTime(_prayerTimes!.fajr);
      if (fajrTime != null) {
        nextPrayerTime = DateTime(
          now.year,
          now.month,
          now.day + 1,
          fajrTime.hour,
          fajrTime.minute,
        );
      }
    }

    if (nextPrayerTime != null && nextPrayerName != null) {
      _nextPrayer = nextPrayerName;
      _timeRemaining = nextPrayerTime.difference(now);

      // If time remaining is negative, recalculate
      if (_timeRemaining.isNegative) {
        _timeRemaining = Duration.zero;
      }

      notifyListeners();
    }
  }

  /// Parse time string (HH:mm) to DateTime
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

  /// Get formatted countdown string (HH:MM:SS)
  String getFormattedCountdown() {
    final hours = _timeRemaining.inHours.toString().padLeft(2, '0');
    final minutes = (_timeRemaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_timeRemaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Get prayer icon based on prayer name
  IconData getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.wb_sunny_outlined;
      case 'maghrib':
        return Icons.wb_cloudy;
      case 'isha':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  /// Check if prayer time has passed
  bool isPrayerPassed(String prayerTime) {
    final now = DateTime.now();
    final prayer = _parseTime(prayerTime);
    return prayer != null && prayer.isBefore(now);
  }

  /// Refresh all data
  Future<void> refresh() async {
    await initialize();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _prayerService.dispose();
    _qiblaService.dispose();
    _calendarService.dispose();
    super.dispose();
  }
}
