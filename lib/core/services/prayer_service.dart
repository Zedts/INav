import 'package:flutter/foundation.dart';
import '../errors/error_messages.dart';
import '../models/prayer_times_model.dart';
import 'api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for fetching prayer times from MyQuran API
class PrayerService {
  final ApiService _apiService;
  final String _defaultTimezone;

  PrayerService({ApiService? apiService})
    : _apiService = apiService ?? ApiService(),
      _defaultTimezone = dotenv.env['DEFAULT_TIMEZONE']!;

  /// Fetch today's prayer times for a specific city
  ///
  /// [cityId] - City ID from MyQuran API
  /// [timezone] - Optional timezone (defaults to Asia/Jakarta)
  ///
  /// Returns [PrayerTimesModel] with all prayer times
  /// Throws [ApiException] on error
  Future<PrayerTimesModel> getTodayPrayerTimes(
    String cityId, {
    String? timezone,
  }) async {
    try {
      final now = DateTime.now();
      final response = await _apiService.get(
        '/sholat/jadwal/$cityId/${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}',
      );

      return PrayerTimesModel.fromJson(response);
    } on ApiException {
      // Already carries a user-friendly message
      rethrow;
    } catch (e) {
      debugPrint('PrayerService parse error: $e');
      throw ApiException(ErrorMessages.prayerTimesUnreadable);
    }
  }

  /// Fetch prayer times for a specific date
  ///
  /// [cityId] - City ID from MyQuran API
  /// [year] - Year (e.g., 2024)
  /// [month] - Month (1-12)
  /// [day] - Day of month (1-31)
  /// [timezone] - Optional timezone
  ///
  /// Returns [PrayerTimesModel] with prayer times for that date
  Future<PrayerTimesModel> getPrayerTimesByDate(
    String cityId,
    int year,
    int month,
    int day, {
    String? timezone,
  }) async {
    try {
      final tz = timezone ?? _defaultTimezone;
      final encodedTz = Uri.encodeComponent(tz);
      final response = await _apiService.get(
        '/sholat/jadwal/$cityId/$year/$month/$day?tz=$encodedTz',
      );

      return PrayerTimesModel.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('PrayerService parse error (by date): $e');
      throw ApiException(ErrorMessages.prayerTimesUnreadable);
    }
  }

  /// Dispose service
  void dispose() {
    _apiService.dispose();
  }
}
