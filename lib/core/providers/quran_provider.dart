import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../errors/error_messages.dart';
import '../models/surah_model.dart';
import '../models/surah_detail_model.dart';
import '../services/quran_service.dart';
import '../databases/app_database.dart';
import 'package:sqflite/sqflite.dart';

enum AudioSourceId { banner, tile, sheet }

class QuranProvider with ChangeNotifier {
  final QuranService _quranService = QuranService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<SurahModel> _allSurahs = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  final Set<String> _bookmarkedSurahNumbers = {};
  bool _isSidebarOpen = false;

  String? _currentAudioUrl;
  AudioSourceId? _currentAudioSource;
  String? _currentAudioSourceKey;
  bool _audioLoading = false;
  bool _audioPlaying = false;
  bool _continuousPlaybackMode = false;

  // v3 API state for reading screen
  SurahDetailModel? _currentSurahDetail;
  bool _isLoadingDetail = false;
  String? _errorMessageDetail;
  String? _lastReadSurahKey; // Format: "surahNumber:ayahNumber"
  int? _userId;

  List<SurahModel> get allSurahs => _allSurahs;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<String> get bookmarkedSurahNumbers =>
      Set.unmodifiable(_bookmarkedSurahNumbers);
  bool get isSidebarOpen => _isSidebarOpen;

  String? get currentAudioUrl => _currentAudioUrl;
  AudioSourceId? get currentAudioSource => _currentAudioSource;
  String? get currentAudioSourceKey => _currentAudioSourceKey;
  bool get audioLoading => _audioLoading;
  bool get audioPlaying => _audioPlaying;
  bool get continuousPlaybackMode => _continuousPlaybackMode;

  // v3 API getters for reading screen
  SurahDetailModel? get currentSurahDetail => _currentSurahDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get errorMessageDetail => _errorMessageDetail;
  String? get lastReadSurahKey => _lastReadSurahKey;

  List<SurahModel> get filteredSurahs {
    if (_searchQuery.trim().isEmpty) return _allSurahs;
    final q = _searchQuery.toLowerCase().trim();
    return _allSurahs.where((s) {
      return s.nameEn.toLowerCase().contains(q) ||
          s.nameId.toLowerCase().contains(q) ||
          s.translationEn.toLowerCase().contains(q) ||
          s.translationId.toLowerCase().contains(q);
    }).toList();
  }

  List<SurahModel> get bookmarkedSurahs {
    return _allSurahs
        .where((s) => _bookmarkedSurahNumbers.contains(s.number.toString()))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  QuranProvider() {
    _audioPlayer.playerStateStream.listen((state) async {
      final wasPlaying = _audioPlaying;
      final next = state.playing;
      final completed = state.processingState == ProcessingState.completed;
      if (wasPlaying != next || completed) {
        _audioPlaying = completed ? false : next;
        if (completed) {
          if (_continuousPlaybackMode) {
            await _advanceToNextSurah();
            return;
          }
          _currentAudioUrl = null;
          _currentAudioSource = null;
          _currentAudioSourceKey = null;
        }
        _audioLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _advanceToNextSurah() async {
    final currentNum = int.tryParse(_currentAudioSourceKey ?? '');
    if (currentNum == null) {
      _stopContinuousPlayback();
      return;
    }
    final nextNum = currentNum + 1;
    final nextSurah = _allSurahs.firstWhere(
      (s) => s.number == nextNum,
      orElse: () => SurahModel(
        audioUrl: '',
        nameEn: '',
        nameId: '',
        nameLong: '',
        nameShort: '',
        number: 0,
        numberOfVerses: 0,
        sequence: 0,
        revelation: '',
        revelationEn: '',
        revelationId: '',
        tafsir: '',
        translationEn: '',
        translationId: '',
      ),
    );
    if (nextSurah.number == 0 || nextSurah.audioUrl.isEmpty) {
      _stopContinuousPlayback();
      return;
    }
    _currentAudioUrl = nextSurah.audioUrl;
    _currentAudioSource = AudioSourceId.banner;
    _currentAudioSourceKey = nextSurah.number.toString();
    _audioLoading = true;
    _audioPlaying = false;
    notifyListeners();
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(nextSurah.audioUrl);
      await _audioPlayer.play();
      _audioLoading = false;
      notifyListeners();
    } catch (_) {
      _audioLoading = false;
      _audioPlaying = false;
      notifyListeners();
    }
  }

  void _stopContinuousPlayback() {
    _continuousPlaybackMode = false;
    _currentAudioUrl = null;
    _currentAudioSource = null;
    _currentAudioSourceKey = null;
    _audioLoading = false;
    _audioPlaying = false;
    notifyListeners();
  }

  Future<void> startContinuousPlayback() async {
    if (_allSurahs.isEmpty) return;
    final first = _allSurahs.firstWhere(
      (s) => s.number == 1,
      orElse: () => _allSurahs[0],
    );
    if (first.audioUrl.isEmpty) return;
    _continuousPlaybackMode = true;
    _currentAudioUrl = first.audioUrl;
    _currentAudioSource = AudioSourceId.banner;
    _currentAudioSourceKey = first.number.toString();
    _audioLoading = true;
    _audioPlaying = false;
    notifyListeners();
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(first.audioUrl);
      await _audioPlayer.play();
      _audioLoading = false;
      notifyListeners();
    } catch (_) {
      _audioLoading = false;
      _audioPlaying = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> exitContinuousPlayback() async {
    if (!_continuousPlaybackMode) return;
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    _stopContinuousPlayback();
  }

  Future<void> stopAndClearAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    _continuousPlaybackMode = false;
    _currentAudioUrl = null;
    _currentAudioSource = null;
    _currentAudioSourceKey = null;
    _audioLoading = false;
    _audioPlaying = false;
    notifyListeners();
  }

  bool isPlayingAudioFrom(AudioSourceId source, String sourceKey) {
    return _audioPlaying &&
        _currentAudioSource == source &&
        _currentAudioSourceKey == sourceKey;
  }

  bool isLoadingAudioFrom(AudioSourceId source, String sourceKey) {
    return _audioLoading &&
        _currentAudioSource == source &&
        _currentAudioSourceKey == sourceKey;
  }

  SurahModel? get currentPlayingSurah {
    if (_currentAudioSourceKey == null) return null;
    final number = int.tryParse(_currentAudioSourceKey!);
    if (number == null) return null;
    for (final s in _allSurahs) {
      if (s.number == number) return s;
    }
    return null;
  }

  bool isSurahPlaying(String surahKey) {
    return _audioPlaying && _currentAudioSourceKey == surahKey;
  }

  bool isSurahLoading(String surahKey) {
    return _audioLoading && _currentAudioSourceKey == surahKey;
  }

  bool isSurahActive(String surahKey) {
    return _currentAudioSourceKey == surahKey;
  }

  Future<void> toggleAudio({
    required AudioSourceId source,
    required String sourceKey,
    required String url,
  }) async {
    final sameTrack =
        _currentAudioUrl == url && _currentAudioSourceKey == sourceKey;

    if (sameTrack && _audioPlaying) {
      try {
        await _audioPlayer.pause();
        _audioPlaying = false;
        _audioLoading = false;
        notifyListeners();
      } catch (_) {
        _audioPlaying = false;
        _audioLoading = false;
        notifyListeners();
      }
      return;
    }

    if (sameTrack && !_audioPlaying && _currentAudioUrl != null) {
      try {
        await _audioPlayer.play();
      } catch (_) {
        _audioPlaying = false;
        notifyListeners();
      }
      return;
    }

    if (_continuousPlaybackMode && source != AudioSourceId.banner) {
      _continuousPlaybackMode = false;
    }

    _currentAudioUrl = url;
    _currentAudioSource = source;
    _currentAudioSourceKey = sourceKey;
    _audioLoading = true;
    _audioPlaying = false;
    notifyListeners();

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      _audioLoading = false;
      notifyListeners();
    } catch (_) {
      _audioLoading = false;
      _audioPlaying = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadSurahs({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allSurahs = await _quranService.getAllSurahs(forceRefresh: forceRefresh);
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = friendlyErrorMessage(
        e,
        fallback: ErrorMessages.surahListFailed,
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> setUser(int? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _bookmarkedSurahNumbers.clear();
    _lastReadSurahKey = null;
    if (userId != null) {
      final db = await AppDatabase.database;
      final bookmarks = await db.query(
        'quran_bookmarks',
        columns: ['surah_number'],
        where: 'user_id=?',
        whereArgs: [userId],
      );
      _bookmarkedSurahNumbers.addAll(
        bookmarks.map((row) => row['surah_number'].toString()),
      );
      final lastRead = await db.query(
        'quran_last_read',
        where: 'user_id=?',
        whereArgs: [userId],
      );
      if (lastRead.isNotEmpty)
        _lastReadSurahKey =
            '${lastRead.first['surah_number']}:${lastRead.first['ayah_number']}';
    }
    notifyListeners();
  }

  Future<void> toggleBookmark(String surahNumber) async {
    final userId = _userId;
    if (_bookmarkedSurahNumbers.contains(surahNumber)) {
      _bookmarkedSurahNumbers.remove(surahNumber);
      if (userId != null)
        await (await AppDatabase.database).delete(
          'quran_bookmarks',
          where: 'user_id=? AND surah_number=?',
          whereArgs: [userId, int.parse(surahNumber)],
        );
    } else {
      _bookmarkedSurahNumbers.add(surahNumber);
      if (userId != null)
        await (await AppDatabase.database).insert('quran_bookmarks', {
          'user_id': userId,
          'surah_number': int.parse(surahNumber),
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
    }
    notifyListeners();
  }

  bool isBookmarked(String surahNumber) {
    return _bookmarkedSurahNumbers.contains(surahNumber);
  }

  void openSidebar() {
    _isSidebarOpen = true;
    notifyListeners();
  }

  void closeSidebar() {
    _isSidebarOpen = false;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  /// Load surah detail from v3 API (with pagination support)
  Future<void> loadSurahDetail(int surahNumber) async {
    _isLoadingDetail = true;
    _errorMessageDetail = null;
    notifyListeners();

    try {
      _currentSurahDetail = await _quranService.loadCompleteSurah(surahNumber);
      _isLoadingDetail = false;
      _errorMessageDetail = null;
      notifyListeners();
    } catch (e) {
      _errorMessageDetail = friendlyErrorMessage(
        e,
        fallback: ErrorMessages.dataUnavailable,
      );
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  /// Set last read position (memory-only, resets on app restart)
  Future<void> setLastRead(int surahNumber, int ayahNumber) async {
    _lastReadSurahKey = '$surahNumber:$ayahNumber';
    notifyListeners();
    if (_userId != null)
      await (await AppDatabase.database).insert('quran_last_read', {
        'user_id': _userId,
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get last read position (returns null if no history)
  /// Returns tuple: (surahNumber, ayahNumber)
  (int, int)? getLastRead() {
    if (_lastReadSurahKey == null) return null;
    final parts = _lastReadSurahKey!.split(':');
    if (parts.length != 2) return null;
    final surahNum = int.tryParse(parts[0]);
    final ayahNum = int.tryParse(parts[1]);
    if (surahNum == null || ayahNum == null) return null;
    return (surahNum, ayahNum);
  }

  /// Clear current surah detail (useful when navigating away)
  void clearSurahDetail() {
    _currentSurahDetail = null;
    _errorMessageDetail = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _quranService.dispose();
    super.dispose();
  }
}
