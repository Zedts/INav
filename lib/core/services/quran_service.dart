import 'package:flutter/foundation.dart';
import '../models/surah_model.dart';
import 'api_service.dart';

class QuranService {
  final ApiService _apiService;
  List<SurahModel>? _cachedSurahs;

  QuranService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

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
      throw ApiException(
        'Unable to read the surah list. Please try again later.',
      );
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}
