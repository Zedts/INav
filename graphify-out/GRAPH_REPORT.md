# Graph Report - inav  (2026-07-29)

## Corpus Check
- 85 files · ~44,367 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1025 nodes · 1365 edges · 89 communities (57 shown, 32 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `72122ef9`
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
- horizontal_prayer_stepper.dart
- State
- mosque_service.dart
- main_screen.dart
- MosqueProvider
- quran_screen.dart
- verse_provider.dart
- home_screen.dart
- package:provider/provider.dart
- theme_provider.dart
- StatelessWidget
- glass_banner.dart
- QuranProvider
- qibla_service.dart
- search_bar.dart
- wWinMain
- main.dart
- verse_of_day_card.dart
- manifest.json
- calendar_service.dart
- inav
- quran_service.dart
- prayer_service.dart
- qibla_model.dart
- bookmarks_sidebar.dart
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
- Mosque Screen Enhancement Plan
- mosque_detail_sheet.dart
- surah_detail_sheet.dart
- nearest_mosque_banner.dart
- app_header.dart
- favorites_sidebar.dart
- refreshNearbyMosques
- bool?

## God Nodes (most connected - your core abstractions)
1. `MosqueProvider` - 32 edges
2. `QuranProvider` - 28 edges
3. `Win32Window` - 22 edges
4. `PrayerProvider` - 15 edges
5. `ThemeProvider` - 12 edges
6. `MessageHandler` - 12 edges
7. `StreakProvider` - 10 edges
8. `FlutterWindow` - 10 edges
9. `Create` - 10 edges
10. `WndProc` - 10 edges

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

## Communities (89 total, 32 thin omitted)

### Community 0 - "Windows Flutter Platform"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (34): Any, audio_session, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS (+26 more)

### Community 2 - "prayer_provider.dart"
Cohesion: 0.05
Nodes (39): CalendarModel? get, Duration get, _calendar, _calendarService, _countdownTimer, _currentPosition, _currentPrayer, dispose (+31 more)

### Community 3 - "quran_provider.dart"
Cohesion: 0.05
Nodes (40): AudioPlayer, AudioSourceId? get, _advanceToNextSurah, _allSurahs, _audioLoading, _audioPlayer, _audioPlaying, AudioSourceId (+32 more)

### Community 4 - "location_service.dart"
Cohesion: 0.07
Nodes (26): Exception, Geocoding, ApiException, checkPermission, city, country, countryCode, _formatAddress (+18 more)

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
Cohesion: 0.11
Nodes (21): CustomPainter, StreakProvider, _animationController, build, createState, _currentProgress, didChangeDependencies, didUpdateWidget (+13 more)

### Community 9 - "surah_model.dart"
Cohesion: 0.11
Nodes (18): audioUrl, fromJson, isMeccan, nameEn, nameId, nameLong, nameShort, number (+10 more)

### Community 10 - "quran_banner.dart"
Cohesion: 0.17
Nodes (11): _buildAudioButton, _buildContinuousBadge, _buildDefaultContent, _buildExitButton, _buildNowPlayingBadge, _buildNowPlayingContent, createState, _defaultAudioUrl (+3 more)

### Community 11 - "app_colors.dart"
Cohesion: 0.11
Nodes (17): accent, AppColors, borderDark, borderLight, cardDark, cardLight, primaryDark, primaryLight (+9 more)

### Community 12 - "mosque_provider.dart"
Cohesion: 0.05
Nodes (41): _cityName, clearSelection, closeSidebar, dispose, _errorMessage, _favoriteMosqueIds, _featuredMosqueId, initialize (+33 more)

### Community 13 - "prayer_times_model.dart"
Cohesion: 0.12
Nodes (15): asr, cityName, date, dhuhr, fajr, fromJson, getAllPrayerTimes, getPrayerTime (+7 more)

### Community 14 - "verse_service.dart"
Cohesion: 0.12
Nodes (15): _apiService, _cacheVerse, clearCache, dispose, _fetchFromApi, forceRefresh, _getCachedVerse, getDailyVerse (+7 more)

### Community 15 - "horizontal_prayer_stepper.dart"
Cohesion: 0.07
Nodes (30): Animation, AnimationController, Color, _animation, build, color, _controller, createState (+22 more)

### Community 16 - "State"
Cohesion: 0.27
Nodes (10): MosqueScreen, _MosqueScreenState, QuranScreen, _QuranScreenState, QuranBanner, _QuranBannerState, SurahDetailSheet, _SurahDetailSheetState (+2 more)

### Community 17 - "mosque_service.dart"
Cohesion: 0.05
Nodes (37): @visibleForTesting, Client, dart:async, dart:convert, dart:io, Duration, int?, _baseUrl (+29 more)

### Community 18 - "main_screen.dart"
Cohesion: 0.11
Nodes (18): home/home_screen.dart, createState, _currentIndex, _getHeaderMode, MainScreen, _MainScreenState, _onTabTapped, _openMosqueDetail (+10 more)

### Community 19 - "MosqueProvider"
Cohesion: 0.14
Nodes (19): MosqueProvider, build, build, _buildContent, _buildErrorView, _buildLoadingView, createState, initState (+11 more)

### Community 20 - "quran_screen.dart"
Cohesion: 0.15
Nodes (12): build, _buildAllSurahHeader, _buildErrorState, _buildLoadingState, _buildNoResultsState, createState, initState, _openSurahDetail (+4 more)

### Community 21 - "verse_provider.dart"
Cohesion: 0.14
Nodes (13): bool get, dispose, _errorMessage, _isLoading, loadDailyVerse, _parseErrorMessage, refresh, _verse (+5 more)

### Community 22 - "home_screen.dart"
Cohesion: 0.14
Nodes (19): ChangeNotifier, ../../core/providers/streak_provider.dart, PrayerProvider, VerseProvider, build, createState, HomeScreen, _HomeScreenState (+11 more)

### Community 23 - "package:provider/provider.dart"
Cohesion: 0.21
Nodes (12): ../../core/theme/app_colors.dart, ../../core/theme/theme_provider.dart, ThemeProvider, build, build, ThemeToggleButton, BottomNavBar, build (+4 more)

### Community 24 - "theme_provider.dart"
Cohesion: 0.14
Nodes (13): isDarkMode, loadThemePreference, _prefs, _saveThemePreference, setThemeMode, _themeKey, _themeMode, toggleTheme (+5 more)

### Community 25 - "StatelessWidget"
Cohesion: 0.05
Nodes (42): IconData, MosqueModel, QiblaScreen, build, SettingsScreen, GlassPillBadge, build, color (+34 more)

### Community 26 - "glass_banner.dart"
Cohesion: 0.17
Nodes (12): ../common/glass_pill_badge.dart, _buildGlassCard, _buildPrayerSlide, _buildQuranSlide, createState, dispose, GlassBanner, _GlassBannerState (+4 more)

### Community 27 - "QuranProvider"
Cohesion: 0.18
Nodes (13): ../../core/models/surah_model.dart, QuranProvider, build, _exitActivePlayback, _toggleAudio, _buildBottomActions, _toggleAudio, build (+5 more)

### Community 28 - "qibla_service.dart"
Cohesion: 0.15
Nodes (12): dart:math, _apiService, _calculateQiblaDirection, _degreesToRadians, dispose, getQiblaDirection, _kaabaLatitude, _kaabaLongitude (+4 more)

### Community 29 - "search_bar.dart"
Cohesion: 0.18
Nodes (11): FocusNode, build, _controller, createState, dispose, _focusNode, initState, _isFocused (+3 more)

### Community 30 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 31 - "main.dart"
Cohesion: 0.18
Nodes (10): ../../core/providers/prayer_provider.dart, ../../core/providers/verse_provider.dart, core/theme/app_theme.dart, build, load, loadThemePreference, main, MyApp (+2 more)

### Community 32 - "verse_of_day_card.dart"
Cohesion: 0.17
Nodes (11): dart:ui, build, _buildEmptyState, _buildErrorState, _buildHeader, _buildLoadingState, _buildVerseContent, _showShareOptions (+3 more)

### Community 33 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 34 - "calendar_service.dart"
Cohesion: 0.20
Nodes (9): ApiService, _apiService, CalendarService, _convertToHijri, dispose, getCalendarByDate, getTodayCalendar, ../models/calendar_model.dart (+1 more)

### Community 35 - "inav"
Cohesion: 0.22
Nodes (6): Android Launcher Icon (hdpi), Dark Theme Logo, White Theme Logo, Flutter Lints, inav, iOS App Icon (1024x1024)

### Community 36 - "quran_service.dart"
Cohesion: 0.22
Nodes (8): api_service.dart, _apiService, _cachedSurahs, dispose, getAllSurahs, QuranService, List, ../models/surah_model.dart

### Community 37 - "prayer_service.dart"
Cohesion: 0.22
Nodes (8): _apiService, _defaultTimezone, dispose, getPrayerTimesByDate, getTodayPrayerTimes, PrayerService, ../models/prayer_times_model.dart, package:flutter_dotenv/flutter_dotenv.dart

### Community 38 - "qibla_model.dart"
Cohesion: 0.25
Nodes (7): direction, fromJson, latitude, longitude, QiblaModel, toJson, toString

### Community 39 - "bookmarks_sidebar.dart"
Cohesion: 0.25
Nodes (7): ../../core/providers/quran_provider.dart, BookmarksSidebar, build, _buildBookmarksList, _buildEmptyState, _buildFooter, _buildHeader

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

### Community 81 - "Mosque Screen Enhancement Plan"
Cohesion: 0.11
Nodes (17): 1. Header favorite button — color + wiring, 2. Header GPS refresh — full screen refresh, 3. In-memory favorites sidebar, 4. Featured mosque from map + banner sync + rewind, 5. Mosque detail sheet (list tile inspection), Core state model (extend `[MosqueProvider](lib/core/providers/mosque_provider.dart)`), Current State, Deduplication Strategy (+9 more)

### Community 82 - "mosque_detail_sheet.dart"
Cohesion: 0.15
Nodes (12): build, _buildBadge, _buildBadgesRow, _buildBottomActions, _buildDetailsSection, _buildDragHandle, _buildHeader, mosque (+4 more)

### Community 83 - "surah_detail_sheet.dart"
Cohesion: 0.15
Nodes (12): build, _buildActionButton, _buildBadge, _buildBadgesRow, _buildDragHandle, _buildHeader, _buildTafsirSection, _buildTranslationRow (+4 more)

### Community 84 - "nearest_mosque_banner.dart"
Cohesion: 0.17
Nodes (11): build, _buildContent, _buildEmptyContent, isOverridden, mosque, _navigate, NearestMosqueBanner, onResetToNearest (+3 more)

### Community 85 - "app_header.dart"
Cohesion: 0.18
Nodes (10): _buildActions, _buildLikeButton, _buildMosqueLeading, _buildNotificationButton, _buildQuranBookmarkButton, _buildThemeButton, HeaderMode, mode (+2 more)

### Community 86 - "favorites_sidebar.dart"
Cohesion: 0.22
Nodes (8): ../../core/models/mosque_model.dart, ../../core/providers/mosque_provider.dart, build, _buildEmptyState, _buildFavoritesList, _buildFooter, _buildHeader, FavoritesSidebar

## Knowledge Gaps
- **572 isolated node(s):** `GregorianDate`, `HijriDate`, `gregorian`, `hijri`, `date` (+567 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **32 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PrayerTimesModel` connect `prayer_times_model.dart` to `prayer_provider.dart`?**
  _High betweenness centrality (0.034) - this node is a cross-community bridge._
- **Why does `MosqueModel` connect `StatelessWidget` to `mosque_provider.dart`, `map_view_section.dart`, `mosque_model.dart`, `mosque_detail_sheet.dart`, `nearest_mosque_banner.dart`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Why does `MosqueProvider` connect `MosqueProvider` to `mosque_provider.dart`, `State`, `main_screen.dart`, `mosque_detail_sheet.dart`, `nearest_mosque_banner.dart`, `app_header.dart`, `home_screen.dart`, `favorites_sidebar.dart`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **What connects `GregorianDate`, `HijriDate`, `gregorian` to the rest of the system?**
  _572 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Flutter Platform` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.04964539007092199 - nodes in this community are weakly interconnected._
- **Should `prayer_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._