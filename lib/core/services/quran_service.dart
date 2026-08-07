import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../errors/error_messages.dart';
import '../models/surah_model.dart';
import '../models/surah_detail_model.dart';
import '../models/ayah_model.dart';
import 'api_service.dart';

class QuranService {
  final ApiService _apiService; // v2 API for surah list
  late final ApiService _apiServiceV3; // v3 API for surah detail
  List<SurahModel>? _cachedSurahs;

  QuranService({ApiService? apiService, ApiService? apiServiceV3})
    : _apiService = apiService ?? ApiService() {
    // Initialize v3 API service with alternate base URL from .env
    _apiServiceV3 =
        apiServiceV3 ??
        ApiService(baseUrl: dotenv.env['MYQURAN_API_BASE_URL_ALT']!);
  }

  Future<List<SurahModel>> getAllSurahs({bool forceRefresh = false}) async {
    if (_cachedSurahs != null && !forceRefresh) {
      return _cachedSurahs!;
    }

    try {
      final response = await _apiService.get('/quran/surat/semua');
      final dataList = response['data'] as List<dynamic>;

      final surahs = dataList
          .map((json) => SurahModel.fromJson(json as Map<String, dynamic>))
          .toList();

      _cachedSurahs = surahs;
      return surahs;
    } on ApiException {
      // Already carries a user-friendly message
      rethrow;
    } catch (e) {
      debugPrint('QuranService parse error: $e');
      throw ApiException(ErrorMessages.surahListFailed);
    }
  }

  /// Get detailed surah data from v3 API with pagination support
  /// ponytail: Pagination handles large surahs (100+ ayahs) by fetching pages
  /// Upgrade path: Implement lazy loading on scroll for better performance
  Future<SurahDetailModel> getSurahDetail(
    int surahNumber, {
    int page = 1,
    int limit = 50,
  }) async {
    // Validate surah number
    if (surahNumber < 1 || surahNumber > 114) {
      throw ApiException('Invalid surah number: $surahNumber');
    }

    try {
      // Build endpoint with pagination params
      final endpoint = '/quran/$surahNumber?page=$page&limit=$limit';

      // Call v3 API
      final response = await _apiServiceV3.get(endpoint);

      // Parse and return
      return SurahDetailModel.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('QuranService.getSurahDetail error: $e');
      throw ApiException(ErrorMessages.dataUnavailable);
    }
  }

  /// Load complete surah by handling pagination automatically
  /// ponytail: Simple sequential loading - load all pages one by one
  /// Upgrade path: Parallel loading for multiple pages or lazy loading on scroll
  Future<SurahDetailModel> loadCompleteSurah(int surahNumber) async {
    try {
      // First request to get total count and check if pagination needed
      final firstPage = await getSurahDetail(surahNumber, page: 1, limit: 50);

      // If all ayahs fit in first page, return immediately
      if (firstPage.ayahs.length >= firstPage.numberOfAyahs) {
        return firstPage;
      }

      // Otherwise, load remaining pages
      final allAyahs = List<AyahModel>.from(firstPage.ayahs);
      int currentPage = 2;
      final totalPages = (firstPage.numberOfAyahs / 50).ceil();

      while (currentPage <= totalPages) {
        final nextPage = await getSurahDetail(
          surahNumber,
          page: currentPage,
          limit: 50,
        );
        allAyahs.addAll(nextPage.ayahs);
        currentPage++;
      }

      // Return complete surah with all ayahs
      return SurahDetailModel(
        number: firstPage.number,
        name: firstPage.name,
        nameLatin: firstPage.nameLatin,
        numberOfAyahs: firstPage.numberOfAyahs,
        translation: firstPage.translation,
        revelation: firstPage.revelation,
        description: firstPage.description,
        audioUrl: firstPage.audioUrl,
        ayahs: allAyahs,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('QuranService.loadCompleteSurah error: $e');
      throw ApiException(ErrorMessages.dataUnavailable);
    }
  }

  void dispose() {
    _apiService.dispose();
    _apiServiceV3.dispose();
  }
}
