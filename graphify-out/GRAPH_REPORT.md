# Graph Report - inav  (2026-07-31)

## Corpus Check
- 101 files · ~53,071 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1307 nodes · 1795 edges · 107 communities (75 shown, 32 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `57c6e358`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Windows Flutter Platform
- GeneratedPluginRegistrant.swift
- prayer_provider.dart
- quran_provider.dart
- location_service.dart
- calendar_model.dart
- my_application.cc
- streak_provider.dart
- glass_pill_badge.dart
- surah_model.dart
- quran_banner.dart
- app_colors.dart
- mosque_provider.dart
- prayer_times_model.dart
- verse_service.dart
- app_header.dart
- prayer_settings_provider.dart
- mosque_service.dart
- main_screen.dart
- MosqueProvider
- quran_screen.dart
- verse_provider.dart
- main.dart
- mosque_detail_sheet.dart
- theme_provider.dart
- qibla_provider.dart
- glass_banner.dart
- QuranProvider
- qibla_service.dart
- search_bar.dart
- wWinMain
- favorites_sidebar.dart
- random_content_card.dart
- manifest.json
- package:flutter/foundation.dart
- inav
- error_messages.dart
- ../errors/error_messages.dart
- services_tools_grid.dart
- compass_dial.dart
- package:flutter/material.dart
- widget_test.dart
- MainActivity
- Linux Project CMakeLists
- Web Index HTML
- Windows Project CMakeLists
- iOS Launch Image
- iOS App Icon (20x20@1x)
- iOS App Icon (20x20@2x)
- iOS App Icon (20x20@3x)
- iOS App Icon (29x29@1x)
- iOS App Icon (29x29@2x)
- iOS App Icon (29x29@3x)
- iOS App Icon (40x40@1x)
- iOS App Icon (40x40@2x)
- iOS App Icon (40x40@3x)
- iOS App Icon (60x60@2x)
- iOS App Icon (60x60@3x)
- iOS App Icon (76x76@1x)
- iOS App Icon 76x76@2x
- iOS App Icon 83.5x83.5@2x
- iOS Launch Image @2x
- iOS Launch Image @3x
- macOS App Icon 1024
- macOS App Icon 128
- macOS App Icon 16
- macOS App Icon 256
- macOS App Icon 32
- macOS App Icon 512
- macOS App Icon 64
- String?
- Web Icon 512
- Web Maskable Icon 192
- Web Maskable Icon 512
- AGENTS.md
- map_view_section.dart
- mosque_model.dart
- horizontal_prayer_stepper.dart
- prayer_notification_settings_screen.dart
- surah_detail_sheet.dart
- section_skeleton.dart
- home_screen.dart
- streak_card.dart
- refreshNearbyMosques
- bool?
- qibla_model.dart
- nearest_mosque_banner.dart
- verse_model.dart
- nearby_mosque_list_tile.dart
- qibla_screen.dart
- qibla_info_grid.dart
- app_exceptions.dart
- StatelessWidget
- State
- prayer_notification_settings_model.dart
- hadith_service.dart
- error_state_view.dart
- hadith_provider.dart
- hadith_model.dart
- calendar_service.dart
- Home Screen Enhancements Plan
- bookmarks_sidebar.dart
- Home Screen Enhancements — Task Plan

## God Nodes (most connected - your core abstractions)
1. `MosqueProvider` - 32 edges
2. `QuranProvider` - 28 edges
3. `Win32Window` - 22 edges
4. `PrayerProvider` - 18 edges
5. `ThemeProvider` - 12 edges
6. `MessageHandler` - 12 edges
7. `QiblaProvider` - 10 edges
8. `StreakProvider` - 10 edges
9. `FlutterWindow` - 10 edges
10. `Create` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Android Launcher Icon (hdpi)` --references--> `inav`  [INFERRED]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → pubspec.yaml
- `iOS App Icon (1024x1024)` --references--> `inav`  [INFERRED]
  ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png → pubspec.yaml
- `Dark Theme Logo` --references--> `inav`  [EXTRACTED]
  assets/images/Dark_Theme.png → pubspec.yaml
- `White Theme Logo` --references--> `inav`  [EXTRACTED]
  assets/images/White_Theme.png → pubspec.yaml
- `Launch Screen Assets README` --references--> `iOS Launch Image`  [INFERRED]
  ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Application Branding Assets** — assets_images_dark_theme, assets_images_white_theme, ios_appicon_1024 [EXTRACTED 0.90]
- **Flutter Platform Build System** — linux_cmakelists, windows_cmakelists, linux_flutter_cmakelists, windows_flutter_cmakelists [EXTRACTED 1.00]

## Communities (107 total, 32 thin omitted)

### Community 0 - "Windows Flutter Platform"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (34): Any, audio_session, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS (+26 more)

### Community 2 - "prayer_provider.dart"
Cohesion: 0.05
Nodes (36): CalendarModel? get, Duration get, _calendar, _calendarService, _countdownTimer, _currentPosition, _currentPrayer, dispose (+28 more)

### Community 3 - "quran_provider.dart"
Cohesion: 0.05
Nodes (39): AudioPlayer, AudioSourceId? get, _advanceToNextSurah, _allSurahs, _audioLoading, _audioPlayer, _audioPlaying, AudioSourceId (+31 more)

### Community 4 - "location_service.dart"
Cohesion: 0.09
Nodes (21): Geocoding, checkPermission, city, country, countryCode, _formatAddress, formattedAddress, _geocoding (+13 more)

### Community 5 - "calendar_model.dart"
Cohesion: 0.12
Nodes (15): CalendarModel, date, day, dayOfMonth, formattedDate, fromJson, gregorian, GregorianDate (+7 more)

### Community 6 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 7 - "streak_provider.dart"
Cohesion: 0.09
Nodes (21): DateTime?, int get, _checkAndResetDate, _checkPrayerWindow, completedCount, _completedPrayers, _currentPrayerWindow, _effectivePrayerDate (+13 more)

### Community 8 - "glass_pill_badge.dart"
Cohesion: 0.13
Nodes (14): Color, _animation, build, color, _controller, createState, dispose, GlassPillBadge (+6 more)

### Community 9 - "surah_model.dart"
Cohesion: 0.11
Nodes (18): audioUrl, fromJson, isMeccan, nameEn, nameId, nameLong, nameShort, number (+10 more)

### Community 10 - "quran_banner.dart"
Cohesion: 0.14
Nodes (14): _buildAudioButton, _buildContinuousBadge, _buildDefaultContent, _buildExitButton, _buildNowPlayingBadge, _buildNowPlayingContent, createState, _defaultAudioUrl (+6 more)

### Community 11 - "app_colors.dart"
Cohesion: 0.11
Nodes (17): accent, AppColors, borderDark, borderLight, cardDark, cardLight, primaryDark, primaryLight (+9 more)

### Community 12 - "mosque_provider.dart"
Cohesion: 0.05
Nodes (38): _cityName, clearSelection, closeSidebar, dispose, _errorMessage, _favoriteMosqueIds, _featuredMosqueId, initialize (+30 more)

### Community 13 - "prayer_times_model.dart"
Cohesion: 0.12
Nodes (15): asr, cityName, date, dhuhr, fajr, fromJson, getAllPrayerTimes, getPrayerTime (+7 more)

### Community 14 - "verse_service.dart"
Cohesion: 0.12
Nodes (15): _apiService, _cacheVerse, clearCache, dispose, _fetchFromApi, forceRefresh, _getCachedVerse, getDailyVerse (+7 more)

### Community 15 - "app_header.dart"
Cohesion: 0.11
Nodes (22): ../../core/theme/app_colors.dart, ../../core/theme/theme_provider.dart, ThemeProvider, build, _buildActions, _buildLikeButton, _buildMosqueLeading, _buildNotificationButton (+14 more)

### Community 16 - "prayer_settings_provider.dart"
Cohesion: 0.09
Nodes (22): _adhanVolume, adjustPreReminder, initialize, _isInitialized, _keySettings, _loadState, masterEnabled, _playOnSilent (+14 more)

### Community 17 - "mosque_service.dart"
Cohesion: 0.06
Nodes (38): @visibleForTesting, Client, dart:async, dart:convert, dart:io, Duration, ../errors/app_exceptions.dart, _baseUrl (+30 more)

### Community 18 - "main_screen.dart"
Cohesion: 0.11
Nodes (18): home/home_screen.dart, createState, _currentIndex, _getHeaderMode, MainScreen, _MainScreenState, _onTabTapped, _openMosqueDetail (+10 more)

### Community 19 - "MosqueProvider"
Cohesion: 0.14
Nodes (20): MosqueProvider, build, build, _buildContent, _buildLoadingView, createState, initState, MosqueScreen (+12 more)

### Community 20 - "quran_screen.dart"
Cohesion: 0.17
Nodes (12): build, _buildAllSurahHeader, _buildLoadingState, _buildNoResultsState, createState, _openSurahDetail, QuranScreen, _QuranScreenState (+4 more)

### Community 21 - "verse_provider.dart"
Cohesion: 0.17
Nodes (11): dispose, _errorMessage, _isLoading, loadDailyVerse, refresh, _verse, _verseService, VerseService (+3 more)

### Community 22 - "main.dart"
Cohesion: 0.17
Nodes (11): ../../core/providers/prayer_settings_provider.dart, ../../core/providers/qibla_provider.dart, ../../core/providers/streak_provider.dart, ../../core/providers/verse_provider.dart, core/theme/app_theme.dart, build, loadThemePreference, main (+3 more)

### Community 23 - "mosque_detail_sheet.dart"
Cohesion: 0.15
Nodes (12): build, _buildBadge, _buildBadgesRow, _buildBottomActions, _buildDetailsSection, _buildDragHandle, _buildHeader, mosque (+4 more)

### Community 24 - "theme_provider.dart"
Cohesion: 0.14
Nodes (13): isDarkMode, loadThemePreference, _prefs, _saveThemePreference, setThemeMode, _themeKey, _themeMode, toggleTheme (+5 more)

### Community 25 - "qibla_provider.dart"
Cohesion: 0.06
Nodes (35): CompassStatus get, double get, _alignedThresholdDeg, _calibratedAccuracyDeg, _cityName, _currentPosition, dispose, _errorMessage (+27 more)

### Community 26 - "glass_banner.dart"
Cohesion: 0.17
Nodes (12): ../common/glass_pill_badge.dart, ../../core/providers/prayer_provider.dart, _buildGlassCard, _buildPrayerSlide, _buildQuranSlide, createState, dispose, GlassBanner (+4 more)

### Community 27 - "QuranProvider"
Cohesion: 0.18
Nodes (13): ../../core/models/surah_model.dart, QuranProvider, initState, build, _exitActivePlayback, _buildBottomActions, _toggleAudio, build (+5 more)

### Community 28 - "qibla_service.dart"
Cohesion: 0.13
Nodes (14): dart:math, _apiService, _calculateDistanceKm, _calculateQiblaDirection, _degreesToRadians, dispose, getQiblaDirection, _kaabaLatitude (+6 more)

### Community 29 - "search_bar.dart"
Cohesion: 0.18
Nodes (11): FocusNode, build, _controller, createState, dispose, _focusNode, initState, _isFocused (+3 more)

### Community 30 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 31 - "favorites_sidebar.dart"
Cohesion: 0.25
Nodes (7): ../../core/providers/mosque_provider.dart, build, _buildEmptyState, _buildFavoritesList, _buildFooter, _buildHeader, FavoritesSidebar

### Community 32 - "random_content_card.dart"
Cohesion: 0.08
Nodes (24): accent, arabic, build, child, createState, dispose, headerIcon, headerLabel (+16 more)

### Community 33 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 34 - "package:flutter/foundation.dart"
Cohesion: 0.22
Nodes (8): api_service.dart, _apiService, _cachedSurahs, dispose, getAllSurahs, QuranService, ../models/surah_model.dart, package:flutter/foundation.dart

### Community 35 - "inav"
Cohesion: 0.22
Nodes (6): Android Launcher Icon (hdpi), Dark Theme Logo, White Theme Logo, Flutter Lints, inav, iOS App Icon (1024x1024)

### Community 36 - "error_messages.dart"
Cohesion: 0.05
Nodes (39): app_exceptions.dart, audioPlaybackFailed, audioStopFailed, audioUnavailableForSurah, calendarUnavailable, categorizeErrorMessage, cityLookupFailed, dataUnavailable (+31 more)

### Community 37 - "../errors/error_messages.dart"
Cohesion: 0.22
Nodes (8): ../errors/error_messages.dart, _apiService, _defaultTimezone, dispose, getPrayerTimesByDate, getTodayPrayerTimes, PrayerService, ../models/prayer_times_model.dart

### Community 38 - "services_tools_grid.dart"
Cohesion: 0.14
Nodes (13): IconData, build, color, icon, isActive, isDark, label, onTap (+5 more)

### Community 39 - "compass_dial.dart"
Cohesion: 0.08
Nodes (25): CustomPainter, CompassStatus, _DoughnutPainter, _PinTailPainter, bearing, build, _buildAccuracyBadge, _buildCardinalLabels (+17 more)

### Community 40 - "package:flutter/material.dart"
Cohesion: 0.22
Nodes (7): app_colors.dart, AppTheme, darkTheme, lightTheme, build, SettingsScreen, package:flutter/material.dart

### Community 41 - "widget_test.dart"
Cohesion: 0.40
Nodes (4): package:flutter_test/flutter_test.dart, package:inav/core/theme/theme_provider.dart, package:inav/main.dart, main

### Community 43 - "Linux Project CMakeLists"
Cohesion: 1.00
Nodes (3): Linux Project CMakeLists, Linux Flutter CMakeLists, Linux Runner CMakeLists

### Community 44 - "Web Index HTML"
Cohesion: 0.67
Nodes (3): Web Favicon, Web Icon 192, Web Index HTML

### Community 45 - "Windows Project CMakeLists"
Cohesion: 1.00
Nodes (3): Windows Project CMakeLists, Windows Flutter CMakeLists, Windows Runner CMakeLists

### Community 79 - "map_view_section.dart"
Cohesion: 0.06
Nodes (33): LatLng?, build, _buildAttributionBadge, _buildExpandedInfoCard, _buildMarkers, color, compactHeight, controller (+25 more)

### Community 80 - "mosque_model.dart"
Cohesion: 0.10
Nodes (19): LatLng? get, address, copyWith, distanceKm, fromJson, iconTag, id, latitude (+11 more)

### Community 81 - "horizontal_prayer_stepper.dart"
Cohesion: 0.13
Nodes (14): Animation, build, _buildPrayerStep, _calculateProgress, color, _controller, createState, dispose (+6 more)

### Community 82 - "prayer_notification_settings_screen.dart"
Cohesion: 0.11
Nodes (18): class, ../../core/models/prayer_notification_settings_model.dart, _buildAdhanPlaybackCard, _buildHeader, _buildMasterToggleCard, _buildOptionSwitchRow, _buildPlaybackToggleRow, _buildPrayerCard (+10 more)

### Community 83 - "surah_detail_sheet.dart"
Cohesion: 0.14
Nodes (14): build, _buildActionButton, _buildBadge, _buildBadgesRow, _buildDragHandle, _buildHeader, _buildTafsirSection, _buildTranslationRow (+6 more)

### Community 84 - "section_skeleton.dart"
Cohesion: 0.15
Nodes (12): double?, borderRadius, build, children, CircleSkeleton, height, ScreenSkeleton, SectionSkeleton (+4 more)

### Community 85 - "home_screen.dart"
Cohesion: 0.17
Nodes (21): ChangeNotifier, ../../core/providers/hadith_provider.dart, HadithProvider, PrayerProvider, PrayerSettingsProvider, StreakProvider, VerseProvider, build (+13 more)

### Community 86 - "streak_card.dart"
Cohesion: 0.12
Nodes (16): _animationController, build, createState, _currentProgress, didChangeDependencies, didUpdateWidget, dispose, _FireButton (+8 more)

### Community 89 - "qibla_model.dart"
Cohesion: 0.18
Nodes (10): direction, distanceKm, formattedDistance, fromJson, latitude, longitude, toJson, toString (+2 more)

### Community 90 - "nearest_mosque_banner.dart"
Cohesion: 0.15
Nodes (12): ../common/error_state_view.dart, build, _buildContent, _buildEmptyContent, isOverridden, mosque, _navigate, NearestMosqueBanner (+4 more)

### Community 91 - "verse_model.dart"
Cohesion: 0.18
Nodes (10): arabic, ayahNumber, formattedReference, fromCachedJson, fromJson, surahName, surahNumber, toJson (+2 more)

### Community 92 - "nearby_mosque_list_tile.dart"
Cohesion: 0.18
Nodes (10): ../../core/models/mosque_model.dart, MosqueModel, build, _buildIcon, _buildTrailing, isSelected, mosque, NearbyMosqueListTile (+2 more)

### Community 93 - "qibla_screen.dart"
Cohesion: 0.13
Nodes (19): QiblaProvider, build, _buildContent, _buildLoadingView, createState, _handleAlignmentFeedback, initState, _onRefresh (+11 more)

### Community 94 - "qibla_info_grid.dart"
Cohesion: 0.11
Nodes (18): ../../core/models/qibla_model.dart, QiblaModel, build, _buildBadge, cityName, isAligned, qiblaData, QiblaHeroBanner (+10 more)

### Community 95 - "app_exceptions.dart"
Cohesion: 0.24
Nodes (9): Exception, int?, ApiException, isNetworkError, LocationException, message, MosqueServiceException, statusCode (+1 more)

### Community 96 - "StatelessWidget"
Cohesion: 0.10
Nodes (21): _ContentBody, _ContentPageScaffold, _EmptyState, _ErrorState, _LoadingState, _RandomHadithPage, _RandomVersePage, _MosquePinMarker (+13 more)

### Community 97 - "State"
Cohesion: 0.15
Nodes (18): AnimationController, HomeScreen, _PulsingDot, _PulsingDotState, _PulsingRing, _PulsingRingState, StreakCard, _StreakCardState (+10 more)

### Community 98 - "prayer_notification_settings_model.dart"
Cohesion: 0.12
Nodes (15): copyWith, defaults, enabled, fromJson, key, maxReminderMinutes, minReminderMinutes, name (+7 more)

### Community 99 - "hadith_service.dart"
Cohesion: 0.13
Nodes (14): _apiService, _cacheHadith, clearCache, dispose, _fetchFromApi, forceRefresh, _getCachedHadith, getDailyHadith (+6 more)

### Community 100 - "error_state_view.dart"
Cohesion: 0.25
Nodes (7): ../../core/errors/error_messages.dart, build, ErrorStateView, message, onOpenSettings, onRetry, showErrorSnackBar

### Community 101 - "hadith_provider.dart"
Cohesion: 0.15
Nodes (12): bool get, HadithModel? get, dispose, _errorMessage, _hadith, _hadithService, _isLoading, loadDailyHadith (+4 more)

### Community 102 - "hadith_model.dart"
Cohesion: 0.22
Nodes (8): arabic, fromCachedJson, fromJson, HadithModel, narrator, number, toJson, translation

### Community 103 - "calendar_service.dart"
Cohesion: 0.22
Nodes (8): ApiService, _apiService, CalendarService, _convertToHijri, dispose, getCalendarByDate, getTodayCalendar, ../models/calendar_model.dart

### Community 104 - "Home Screen Enhancements Plan"
Cohesion: 0.22
Nodes (8): 1. Stepper card -> Prayer Notification Settings (Navigator.push), 2. Services & Tools — single horizontal scrolling row, 3. "Random Verse" + swipeable "Random Hadist" card, 4. Streak reset at Subuh instead of midnight, Assumptions, Home Screen Enhancements Plan, Summary, Test Plan

### Community 105 - "bookmarks_sidebar.dart"
Cohesion: 0.25
Nodes (7): ../../core/providers/quran_provider.dart, BookmarksSidebar, build, _buildBookmarksList, _buildEmptyState, _buildFooter, _buildHeader

### Community 106 - "Home Screen Enhancements — Task Plan"
Cohesion: 0.29
Nodes (6): 1. Stepper card -> Prayer Notification Settings (Navigator.push), 2. Services & Tools — single horizontal row, 3. Random Verse + Random Hadist swipeable card, 4. Streak resets at Subuh, not midnight, Home Screen Enhancements — Task Plan, Verification

## Knowledge Gaps
- **774 isolated node(s):** `message`, `statusCode`, `isNetworkError`, `toString`, `ErrorMessages` (+769 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **32 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `MosqueProvider` connect `MosqueProvider` to `mosque_provider.dart`, `app_header.dart`, `main_screen.dart`, `home_screen.dart`, `mosque_detail_sheet.dart`, `nearest_mosque_banner.dart`, `qibla_screen.dart`, `favorites_sidebar.dart`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **Why does `PrayerTimesModel` connect `prayer_times_model.dart` to `prayer_provider.dart`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **Why does `MosqueModel` connect `nearby_mosque_list_tile.dart` to `mosque_provider.dart`, `map_view_section.dart`, `mosque_model.dart`, `mosque_detail_sheet.dart`, `nearest_mosque_banner.dart`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **What connects `message`, `statusCode`, `isNetworkError` to the rest of the system?**
  _774 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Flutter Platform` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.04964539007092199 - nodes in this community are weakly interconnected._
- **Should `prayer_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05405405405405406 - nodes in this community are weakly interconnected._