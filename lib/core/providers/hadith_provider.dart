import 'package:flutter/material.dart';
import '../errors/error_messages.dart';
import '../models/hadith_model.dart';
import '../services/hadith_service.dart';

/// Provider for managing the random hadith data (mirrors [VerseProvider])
class HadithProvider with ChangeNotifier {
  final HadithService _hadithService = HadithService();

  // State
  HadithModel? _hadith;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  HadithModel? get hadith => _hadith;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load daily hadith - checks cache first
  Future<void> loadDailyHadith() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hadith = await _hadithService.getDailyHadith();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = friendlyErrorMessage(
        e,
        fallback: ErrorMessages.hadithUnavailable,
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force refresh - fetches a new random hadith from API
  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hadith = await _hadithService.forceRefresh();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = friendlyErrorMessage(
        e,
        fallback: ErrorMessages.hadithUnavailable,
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _hadithService.dispose();
    super.dispose();
  }
}
