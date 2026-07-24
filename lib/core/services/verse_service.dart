import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/verse_model.dart';

/// Service for fetching and caching daily verse from MyQuran API
class VerseService {
  final ApiService _apiService;

  // SharedPreferences keys
  static const String _keyArabic = 'verse_arabic';
  static const String _keyTranslation = 'verse_translation';
  static const String _keySurahName = 'verse_surah_name';
  static const String _keyAyahNumber = 'verse_ayah_number';
  static const String _keySurahNumber = 'verse_surah_number';
  static const String _keyCachedDate = 'verse_cached_date';

  VerseService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Get daily verse - checks cache first, then fetches from API if needed
  Future<VerseModel> getDailyVerse() async {
    try {
      // Check if cached verse is still valid
      final cachedVerse = await _getCachedVerse();
      if (cachedVerse != null && await _isCacheValid()) {
        return cachedVerse;
      }

      // Cache expired or missing, fetch from API
      return await _fetchFromApi();
    } catch (e) {
      // If API fails, try to return cached verse even if expired
      final cachedVerse = await _getCachedVerse();
      if (cachedVerse != null) {
        return cachedVerse;
      }
      rethrow;
    }
  }

  /// Fetch verse from API and cache it
  Future<VerseModel> _fetchFromApi() async {
    try {
      final response = await _apiService.get('/quran/ayat/acak');
      final verse = VerseModel.fromJson(response);
      await _cacheVerse(verse);
      return verse;
    } catch (e) {
      throw Exception('Failed to fetch verse: $e');
    }
  }

  /// Get cached verse if available
  Future<VerseModel?> _getCachedVerse() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final arabic = prefs.getString(_keyArabic);
      final translation = prefs.getString(_keyTranslation);
      final surahName = prefs.getString(_keySurahName);
      final ayahNumber = prefs.getString(_keyAyahNumber);
      final surahNumber = prefs.getString(_keySurahNumber);

      if (arabic == null ||
          translation == null ||
          surahName == null ||
          ayahNumber == null ||
          surahNumber == null) {
        return null;
      }

      return VerseModel(
        arabic: arabic,
        translation: translation,
        surahName: surahName,
        ayahNumber: ayahNumber,
        surahNumber: surahNumber,
      );
    } catch (e) {
      return null;
    }
  }

  /// Cache verse data with current date
  Future<void> _cacheVerse(VerseModel verse) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split(
        'T',
      )[0]; // YYYY-MM-DD

      await Future.wait([
        prefs.setString(_keyArabic, verse.arabic),
        prefs.setString(_keyTranslation, verse.translation),
        prefs.setString(_keySurahName, verse.surahName),
        prefs.setString(_keyAyahNumber, verse.ayahNumber),
        prefs.setString(_keySurahNumber, verse.surahNumber),
        prefs.setString(_keyCachedDate, today),
      ]);
    } catch (e) {
      // Cache failure shouldn't prevent verse from being returned
      // Silently fail - user will get new verse on next app launch
    }
  }

  /// Check if cached verse is still valid (same day)
  Future<bool> _isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDate = prefs.getString(_keyCachedDate);

      if (cachedDate == null) return false;

      final today = DateTime.now().toIso8601String().split(
        'T',
      )[0]; // YYYY-MM-DD
      return cachedDate == today;
    } catch (e) {
      return false;
    }
  }

  /// Force refresh - clears cache and fetches new verse
  Future<VerseModel> forceRefresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCachedDate); // Invalidate cache
      return await _fetchFromApi();
    } catch (e) {
      throw Exception('Failed to refresh verse: $e');
    }
  }

  /// Clear all cached verse data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_keyArabic),
        prefs.remove(_keyTranslation),
        prefs.remove(_keySurahName),
        prefs.remove(_keyAyahNumber),
        prefs.remove(_keySurahNumber),
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
