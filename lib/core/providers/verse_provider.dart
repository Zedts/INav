import 'package:flutter/material.dart';
import '../models/verse_model.dart';
import '../services/api_service.dart';
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
      _errorMessage = _parseErrorMessage(e);
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
      _errorMessage = _parseErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Parse error message for user-friendly display
  String _parseErrorMessage(dynamic error) {
    // ApiException already carries a user-friendly message
    if (error is ApiException) return error.message;

    final errorStr = error.toString();
    if (errorStr.contains('SocketException') ||
        errorStr.contains('Failed host lookup') ||
        errorStr.contains('Network')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'The request timed out. Please try again.';
    } else {
      return 'Unable to load the verse of the day. Please try again later.';
    }
  }

  @override
  void dispose() {
    _verseService.dispose();
    super.dispose();
  }
}
