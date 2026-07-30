import 'package:flutter/material.dart';
import '../errors/error_messages.dart';
import '../models/verse_model.dart';
import '../services/verse_service.dart';

/// Provider for managing verse of the day data
class VerseProvider with ChangeNotifier {
  final VerseService _verseService = VerseService();

  // State
  VerseModel? _verse;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  VerseModel? get verse => _verse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load daily verse - checks cache first
  Future<void> loadDailyVerse() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _verse = await _verseService.getDailyVerse();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = friendlyErrorMessage(
        e,
        fallback: ErrorMessages.verseUnavailable,
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force refresh - fetches new verse from API
  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _verse = await _verseService.forceRefresh();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = friendlyErrorMessage(
        e,
        fallback: ErrorMessages.verseUnavailable,
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _verseService.dispose();
    super.dispose();
  }
}
