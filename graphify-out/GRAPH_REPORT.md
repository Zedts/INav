# Graph Report - inav  (2026-07-30)

## Corpus Check
- 91 files · ~49,065 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1131 nodes · 1528 edges · 91 communities (59 shown, 32 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `d7cdf2ab`
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
- streak_card.dart
- surah_model.dart
- quran_banner.dart
- app_colors.dart
- mosque_provider.dart
- prayer_times_model.dart
- verse_service.dart
- glass_pill_badge.dart
- State
- mosque_service.dart
- main_screen.dart
- MosqueProvider
- quran_screen.dart
- verse_provider.dart
- PrayerProvider
- home_screen.dart
- theme_provider.dart
- qibla_provider.dart
- glass_banner.dart
- QuranProvider
- qibla_service.dart
- search_bar.dart
- wWinMain
- verse_of_day_card.dart
- manifest.json
- calendar_service.dart
- inav
- quran_service.dart
- prayer_service.dart
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
- mosque_detail_sheet.dart
- surah_detail_sheet.dart
- nearest_mosque_banner.dart
- favorites_sidebar.dart
- refreshNearbyMosques
- bool?
- Qibla Compass Screen Implementation
- nearby_mosque_list_tile.dart
- StatelessWidget
- app_header.dart
- Qibla Compass Screen — Implementation Plan

## God Nodes (most connected - your core abstractions)
1. `MosqueProvider` - 32 edges
2. `QuranProvider` - 28 edges
3. `Win32Window` - 22 edges
4. `PrayerProvider` - 15 edges
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

## Communities (91 total, 32 thin omitted)

### Community 0 - "Windows Flutter Platform"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (34): Any, audio_session, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS (+26 more)

### Community 2 - "prayer_provider.dart"
Cohesion: 0.06
Nodes (35): CalendarModel? get, Duration get, _calendar, _calendarService, _countdownTimer, _currentPosition, _currentPrayer, dispose (+27 more)

### Community 3 - "quran_provider.dart"
Cohesion: 0.05
Nodes (40): AudioPlayer, AudioSourceId? get, _advanceToNextSurah, _allSurahs, _audioLoading, _audioPlayer, _audioPlaying, AudioSourceId (+32 more)

### Community 4 - "location_service.dart"
Cohesion: 0.08
Nodes (25): Exception, Geocoding, ApiException, checkPermission, city, country, countryCode, _formatAddress (+17 more)

### Community 5 - "calendar_model.dart"
Cohesion: 0.07
Nodes (26): CalendarModel, date, day, dayOfMonth, formattedDate, fromJson, gregorian, GregorianDate (+18 more)

### Community 6 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 7 - "streak_provider.dart"
Cohesion: 0.10
Nodes (20): DateTime?, int get, _checkAndResetDate, _checkPrayerWindow, completedCount, _completedPrayers, _currentPrayerWindow, initialize (+12 more)

### Community 8 - "streak_card.dart"
Cohesion: 0.13
Nodes (15): _animationController, build, createState, _currentProgress, dispose, initState, isActive, isDark (+7 more)

### Community 9 - "surah_model.dart"
Cohesion: 0.11
Nodes (17): audioUrl, fromJson, isMeccan, nameEn, nameId, nameLong, nameShort, number (+9 more)

### Community 10 - "quran_banner.dart"
Cohesion: 0.13
Nodes (14): build, _buildAudioButton, _buildContinuousBadge, _buildDefaultContent, _buildExitButton, _buildNowPlayingBadge, _buildNowPlayingContent, createState (+6 more)

### Community 11 - "app_colors.dart"
Cohesion: 0.11
Nodes (17): accent, AppColors, borderDark, borderLight, cardDark, cardLight, primaryDark, primaryLight (+9 more)

### Community 12 - "mosque_provider.dart"
Cohesion: 0.05
Nodes (40): _cityName, clearSelection, closeSidebar, dispose, _errorMessage, _favoriteMosqueIds, _featuredMosqueId, initialize (+32 more)

### Community 13 - "prayer_times_model.dart"
Cohesion: 0.12
Nodes (15): asr, cityName, date, dhuhr, fajr, fromJson, getAllPrayerTimes, getPrayerTime (+7 more)

### Community 14 - "verse_service.dart"
Cohesion: 0.12
Nodes (15): _apiService, _cacheVerse, clearCache, dispose, _fetchFromApi, forceRefresh, _getCachedVerse, getDailyVerse (+7 more)

### Community 15 - "glass_pill_badge.dart"
Cohesion: 0.06
Nodes (37): AnimationController, Color, IconData, _animation, build, color, _controller, createState (+29 more)

### Community 16 - "State"
Cohesion: 0.23
Nodes (12): MainScreen, _MainScreenState, MosqueScreen, _MosqueScreenState, QiblaScreen, _QiblaScreenState, QuranBanner, _QuranBannerState (+4 more)

### Community 17 - "mosque_service.dart"
Cohesion: 0.05
Nodes (37): @visibleForTesting, Client, dart:async, dart:convert, dart:io, Duration, int?, _baseUrl (+29 more)

### Community 18 - "main_screen.dart"
Cohesion: 0.11
Nodes (18): home/home_screen.dart, build, createState, _currentIndex, _getHeaderMode, _onTabTapped, _openMosqueDetail, _openSurahDetail (+10 more)

### Community 19 - "MosqueProvider"
Cohesion: 0.16
Nodes (17): MosqueProvider, build, _buildContent, _buildErrorView, _buildLoadingView, createState, initState, _navigateTo (+9 more)

### Community 20 - "quran_screen.dart"
Cohesion: 0.14
Nodes (14): build, _buildAllSurahHeader, _buildErrorState, _buildLoadingState, _buildNoResultsState, createState, initState, _openSurahDetail (+6 more)

### Community 21 - "verse_provider.dart"
Cohesion: 0.14
Nodes (13): bool get, dispose, _errorMessage, _isLoading, loadDailyVerse, _parseErrorMessage, refresh, _verse (+5 more)

### Community 22 - "PrayerProvider"
Cohesion: 0.21
Nodes (14): ChangeNotifier, PrayerProvider, StreakProvider, VerseProvider, build, HomeScreen, _HomeScreenState, initState (+6 more)

### Community 23 - "home_screen.dart"
Cohesion: 0.22
Nodes (8): ../../core/providers/streak_provider.dart, ../../core/theme/app_colors.dart, createState, ../../widgets/home/glass_banner.dart, ../../widgets/home/horizontal_prayer_stepper.dart, ../../widgets/home/services_tools_grid.dart, ../../widgets/home/streak_card.dart, ../../widgets/home/verse_of_day_card.dart

### Community 24 - "theme_provider.dart"
Cohesion: 0.14
Nodes (13): isDarkMode, loadThemePreference, _prefs, _saveThemePreference, setThemeMode, _themeKey, _themeMode, toggleTheme (+5 more)

### Community 25 - "qibla_provider.dart"
Cohesion: 0.05
Nodes (36): CompassStatus get, double get, _alignedThresholdDeg, _calibratedAccuracyDeg, _cityName, _currentPosition, dispose, _errorMessage (+28 more)

### Community 26 - "glass_banner.dart"
Cohesion: 0.17
Nodes (12): ../common/glass_pill_badge.dart, ../../core/providers/prayer_provider.dart, _buildGlassCard, _buildPrayerSlide, _buildQuranSlide, createState, dispose, GlassBanner (+4 more)

### Community 27 - "QuranProvider"
Cohesion: 0.17
Nodes (14): ../../core/models/surah_model.dart, QuranProvider, BookmarksSidebar, build, _buildBookmarksList, _buildEmptyState, _buildFooter, _buildHeader (+6 more)

### Community 28 - "qibla_service.dart"
Cohesion: 0.12
Nodes (15): dart:math, _apiService, _calculateDistanceKm, _calculateQiblaDirection, _degreesToRadians, dispose, getQiblaDirection, _kaabaLatitude (+7 more)

### Community 29 - "search_bar.dart"
Cohesion: 0.17
Nodes (12): ../../core/providers/quran_provider.dart, FocusNode, build, _controller, createState, dispose, _focusNode, initState (+4 more)

### Community 30 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 32 - "verse_of_day_card.dart"
Cohesion: 0.17
Nodes (11): ../../core/providers/verse_provider.dart, dart:ui, build, _buildEmptyState, _buildErrorState, _buildHeader, _buildLoadingState, _buildVerseContent (+3 more)

### Community 33 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 34 - "calendar_service.dart"
Cohesion: 0.20
Nodes (9): api_service.dart, _apiService, CalendarService, _convertToHijri, dispose, getCalendarByDate, getTodayCalendar, ../models/calendar_model.dart (+1 more)

### Community 35 - "inav"
Cohesion: 0.22
Nodes (6): Android Launcher Icon (hdpi), Dark Theme Logo, White Theme Logo, Flutter Lints, inav, iOS App Icon (1024x1024)

### Community 36 - "quran_service.dart"
Cohesion: 0.22
Nodes (8): ApiService, _apiService, _cachedSurahs, dispose, getAllSurahs, QuranService, List, ../models/surah_model.dart

### Community 37 - "prayer_service.dart"
Cohesion: 0.22
Nodes (8): _apiService, _defaultTimezone, dispose, getPrayerTimesByDate, getTodayPrayerTimes, PrayerService, ../models/prayer_times_model.dart, package:flutter_dotenv/flutter_dotenv.dart

### Community 39 - "compass_dial.dart"
Cohesion: 0.08
Nodes (24): CustomPainter, CompassStatus, _DoughnutPainter, _PinTailPainter, bearing, build, _buildAccuracyBadge, _buildCardinalLabels (+16 more)

### Community 40 - "package:flutter/material.dart"
Cohesion: 0.25
Nodes (6): app_colors.dart, AppTheme, darkTheme, lightTheme, build, package:flutter/material.dart

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
Nodes (20): double?, LatLng? get, address, copyWith, distanceKm, fromJson, iconTag, id (+12 more)

### Community 81 - "horizontal_prayer_stepper.dart"
Cohesion: 0.15
Nodes (13): Animation, _buildPrayerStep, _calculateProgress, color, _controller, createState, dispose, _getCircleContent (+5 more)

### Community 82 - "mosque_detail_sheet.dart"
Cohesion: 0.15
Nodes (12): build, _buildBadge, _buildBadgesRow, _buildBottomActions, _buildDetailsSection, _buildDragHandle, _buildHeader, mosque (+4 more)

### Community 83 - "surah_detail_sheet.dart"
Cohesion: 0.12
Nodes (15): SurahModel, build, _buildActionButton, _buildBadge, _buildBadgesRow, _buildBottomActions, _buildDragHandle, _buildHeader (+7 more)

### Community 84 - "nearest_mosque_banner.dart"
Cohesion: 0.17
Nodes (11): build, _buildContent, _buildEmptyContent, isOverridden, mosque, _navigate, NearestMosqueBanner, onResetToNearest (+3 more)

### Community 86 - "favorites_sidebar.dart"
Cohesion: 0.22
Nodes (8): ../../core/models/mosque_model.dart, ../../core/providers/mosque_provider.dart, build, _buildEmptyState, _buildFavoritesList, _buildFooter, _buildHeader, FavoritesSidebar

### Community 89 - "Qibla Compass Screen Implementation"
Cohesion: 0.12
Nodes (15): API service — `lib/core/services/api_service.dart`, Assumptions, Core Layer Changes, Dependency, Header — title change only, Home Glass Banner, Model — `lib/core/models/qibla_model.dart`, New provider — `lib/core/providers/qibla_provider.dart` (+7 more)

### Community 90 - "nearby_mosque_list_tile.dart"
Cohesion: 0.20
Nodes (9): MosqueModel, build, _buildIcon, _buildTrailing, isSelected, mosque, NearbyMosqueListTile, onNavigate (+1 more)

### Community 91 - "StatelessWidget"
Cohesion: 0.05
Nodes (45): ../../core/models/qibla_model.dart, direction, distanceKm, formattedDistance, fromJson, latitude, longitude, QiblaModel (+37 more)

### Community 93 - "app_header.dart"
Cohesion: 0.05
Nodes (47): ../../core/providers/qibla_provider.dart, core/theme/app_theme.dart, ../../core/theme/theme_provider.dart, QiblaProvider, ThemeProvider, build, load, loadThemePreference (+39 more)

### Community 95 - "Qibla Compass Screen — Implementation Plan"
Cohesion: 0.29
Nodes (6): Architecture (clean structure, mirrors mosque feature), Behavior Details, Data Sources, Goal, Qibla Compass Screen — Implementation Plan, Task Checklist

## Knowledge Gaps
- **648 isolated node(s):** `GregorianDate`, `HijriDate`, `gregorian`, `hijri`, `date` (+643 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **32 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `MosqueModel` connect `nearby_mosque_list_tile.dart` to `mosque_provider.dart`, `map_view_section.dart`, `mosque_model.dart`, `mosque_detail_sheet.dart`, `nearest_mosque_banner.dart`?**
  _High betweenness centrality (0.030) - this node is a cross-community bridge._
- **Why does `MosqueProvider` connect `MosqueProvider` to `mosque_provider.dart`, `State`, `main_screen.dart`, `mosque_detail_sheet.dart`, `nearest_mosque_banner.dart`, `PrayerProvider`, `favorites_sidebar.dart`, `app_header.dart`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **Why does `QuranProvider` connect `QuranProvider` to `quran_provider.dart`, `quran_banner.dart`, `State`, `main_screen.dart`, `surah_detail_sheet.dart`, `quran_screen.dart`, `PrayerProvider`, `search_bar.dart`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **What connects `GregorianDate`, `HijriDate`, `gregorian` to the rest of the system?**
  _648 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Flutter Platform` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.04964539007092199 - nodes in this community are weakly interconnected._
- **Should `prayer_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05555555555555555 - nodes in this community are weakly interconnected._