import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../errors/error_messages.dart';
import 'api_service.dart';
import '../models/hadith_model.dart';

/// Service for fetching and caching a daily random hadith from MyQuran API
/// Mirrors [VerseService]'s cache-per-day approach.
class HadithService {
  final ApiService _apiService;

  // SharedPreferences keys
  static const String _keyArabic = 'hadith_arabic';
  static const String _keyTranslation = 'hadith_translation';
  static const String _keyNarrator = 'hadith_narrator';
  static const String _keyNumber = 'hadith_number';
  static const String _keyCachedDate = 'hadith_cached_date';

  HadithService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Get daily hadith - checks cache first, then fetches from API if needed
  Future<HadithModel> getDailyHadith() async {
    try {
      final cachedHadith = await _getCachedHadith();
      if (cachedHadith != null && await _isCacheValid()) {
        return cachedHadith;
      }
      return await _fetchFromApi();
    } catch (e) {
      // If API fails, try to return cached hadith even if expired
      final cachedHadith = await _getCachedHadith();
      if (cachedHadith != null) {
        return cachedHadith;
      }
      rethrow;
    }
  }

  /// Fetch hadith from API and cache it
  Future<HadithModel> _fetchFromApi() async {
    try {
      final response = await _apiService.get('/hadits/perawi/acak');
      final hadith = HadithModel.fromJson(response);
      await _cacheHadith(hadith);
      return hadith;
    } on ApiException {
      // Already carries a user-friendly message
      rethrow;
    } catch (e) {
      debugPrint('HadithService parse error: $e');
      throw ApiException(ErrorMessages.hadithUnavailable);
    }
  }

  /// Get cached hadith if available
  Future<HadithModel?> _getCachedHadith() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final arabic = prefs.getString(_keyArabic);
      final translation = prefs.getString(_keyTranslation);
      final narrator = prefs.getString(_keyNarrator);
      final number = prefs.getString(_keyNumber);

      if (arabic == null || translation == null) {
        return null;
      }

      return HadithModel(
        arabic: arabic,
        translation: translation,
        narrator: narrator ?? '',
        number: number ?? '',
      );
    } catch (e) {
      return null;
    }
  }

  /// Cache hadith data with current date
  Future<void> _cacheHadith(HadithModel hadith) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

      await Future.wait([
        prefs.setString(_keyArabic, hadith.arabic),
        prefs.setString(_keyTranslation, hadith.translation),
        prefs.setString(_keyNarrator, hadith.narrator),
        prefs.setString(_keyNumber, hadith.number),
        prefs.setString(_keyCachedDate, today),
      ]);
    } catch (e) {
      // Cache failure shouldn't prevent hadith from being returned
    }
  }

  /// Check if cached hadith is still valid (same day)
  Future<bool> _isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDate = prefs.getString(_keyCachedDate);

      if (cachedDate == null) return false;

      final today = DateTime.now().toIso8601String().split('T')[0];
      return cachedDate == today;
    } catch (e) {
      return false;
    }
  }

  /// Force refresh - clears cache and fetches a new random hadith
  Future<HadithModel> forceRefresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCachedDate); // Invalidate cache
      return await _fetchFromApi();
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('HadithService refresh error: $e');
      throw ApiException(ErrorMessages.hadithUnavailable);
    }
  }

  /// Clear all cached hadith data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_keyArabic),
        prefs.remove(_keyTranslation),
        prefs.remove(_keyNarrator),
        prefs.remove(_keyNumber),
        prefs.remove(_keyCachedDate),
      ]);
    } catch (e) {
      // Silently fail - not critical
    }
  }

  /// Dispose resources
  void dispose() {
    _apiService.dispose();
  }
}
