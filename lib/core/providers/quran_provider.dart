import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/surah_model.dart';
import '../services/quran_service.dart';

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
      _allSurahs = await _quranService.getAllSurahs(
        forceRefresh: forceRefresh,
      );
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = _parseErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleBookmark(String surahNumber) {
    if (_bookmarkedSurahNumbers.contains(surahNumber)) {
      _bookmarkedSurahNumbers.remove(surahNumber);
    } else {
      _bookmarkedSurahNumbers.add(surahNumber);
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

  String _parseErrorMessage(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.contains('Network error') ||
        errorStr.contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    } else if (errorStr.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorStr.contains('Failed to fetch')) {
      return 'Unable to load surahs. Please try again later.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _quranService.dispose();
    super.dispose();
  }
}
