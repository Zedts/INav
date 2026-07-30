# Graph Report - inav  (2026-07-30)

## Corpus Check
- 90 files · ~47,293 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1128 nodes · 1515 edges · 89 communities (57 shown, 32 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `0134e638`
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
- package:provider/provider.dart
- app_header.dart
- mosque_service.dart
- main_screen.dart
- mosque_screen.dart
- quran_screen.dart
- main.dart
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
- qibla_model.dart
- surah_detail_sheet.dart
- StatelessWidget
- home_screen.dart
- streak_card.dart
- refreshNearbyMosques
- bool?
- State
- nearest_mosque_banner.dart
- nearby_mosque_list_tile.dart
- qibla_screen.dart

## God Nodes (most connected - your core abstractions)
1. `MosqueProvider` - 23 edges
2. `QuranProvider` - 23 edges
3. `Win32Window` - 22 edges
4. `MessageHandler` - 12 edges
5. `FlutterWindow` - 10 edges
6. `Create` - 10 edges
7. `WndProc` - 10 edges
8. `ThemeProvider` - 9 edges
9. `MessageHandler` - 9 edges
10. `QiblaProvider` - 7 edges

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
Nodes (36): CalendarModel? get, Duration get, _calendar, _calendarService, _countdownTimer, _currentPosition, _currentPrayer, dispose (+28 more)

### Community 3 - "quran_provider.dart"
Cohesion: 0.05
Nodes (40): AudioPlayer, AudioSourceId? get, _advanceToNextSurah, _allSurahs, _audioLoading, _audioPlayer, _audioPlaying, AudioSourceId (+32 more)

### Community 4 - "location_service.dart"
Cohesion: 0.08
Nodes (25): Exception, Geocoding, ApiException, checkPermission, city, country, countryCode, _formatAddress (+17 more)

### Community 5 - "calendar_model.dart"
Cohesion: 0.12
Nodes (15): CalendarModel, date, day, dayOfMonth, formattedDate, fromJson, gregorian, GregorianDate (+7 more)

### Community 6 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 7 - "streak_provider.dart"
Cohesion: 0.10
Nodes (20): DateTime?, int get, _checkAndResetDate, _checkPrayerWindow, completedCount, _completedPrayers, _currentPrayerWindow, initialize (+12 more)

### Community 8 - "glass_pill_badge.dart"
Cohesion: 0.05
Nodes (38): AnimationController, Color, IconData, _animation, build, color, _controller, createState (+30 more)

### Community 9 - "surah_model.dart"
Cohesion: 0.11
Nodes (17): audioUrl, fromJson, isMeccan, nameEn, nameId, nameLong, nameShort, number (+9 more)

### Community 10 - "quran_banner.dart"
Cohesion: 0.14
Nodes (17): build, _buildAudioButton, _buildContinuousBadge, _buildDefaultContent, _buildExitButton, _buildNowPlayingBadge, _buildNowPlayingContent, createState (+9 more)

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
Cohesion: 0.05
Nodes (38): arabic, ayahNumber, formattedReference, fromCachedJson, fromJson, surahName, surahNumber, toJson (+30 more)

### Community 15 - "package:provider/provider.dart"
Cohesion: 0.23
Nodes (11): ../../core/theme/app_colors.dart, ../../core/theme/theme_provider.dart, ThemeProvider, build, ThemeToggleButton, BottomNavBar, build, currentIndex (+3 more)

### Community 16 - "app_header.dart"
Cohesion: 0.19
Nodes (13): AppHeader, build, _buildActions, _buildNotificationButton, _buildQiblaLeading, _buildQuranBookmarkButton, _buildThemeButton, HeaderMode (+5 more)

### Community 17 - "mosque_service.dart"
Cohesion: 0.05
Nodes (37): @visibleForTesting, Client, dart:async, dart:convert, dart:io, Duration, int?, _baseUrl (+29 more)

### Community 18 - "main_screen.dart"
Cohesion: 0.11
Nodes (17): home/home_screen.dart, build, createState, _currentIndex, _getHeaderMode, _onTabTapped, _openMosqueDetail, _openSurahDetail (+9 more)

### Community 19 - "mosque_screen.dart"
Cohesion: 0.07
Nodes (39): ../../core/models/mosque_model.dart, ../../core/providers/mosque_provider.dart, MosqueModel, MosqueProvider, build, _buildContent, _buildErrorView, _buildLoadingView (+31 more)

### Community 20 - "quran_screen.dart"
Cohesion: 0.15
Nodes (12): build, _buildAllSurahHeader, _buildErrorState, _buildLoadingState, _buildNoResultsState, createState, initState, _openSurahDetail (+4 more)

### Community 22 - "main.dart"
Cohesion: 0.17
Nodes (11): ../../core/providers/qibla_provider.dart, ../../core/providers/streak_provider.dart, ../../core/providers/verse_provider.dart, core/theme/app_theme.dart, build, load, loadThemePreference, main (+3 more)

### Community 24 - "theme_provider.dart"
Cohesion: 0.14
Nodes (13): bool get, isDarkMode, loadThemePreference, _prefs, _saveThemePreference, setThemeMode, _themeKey, _themeMode (+5 more)

### Community 25 - "qibla_provider.dart"
Cohesion: 0.05
Nodes (36): CompassStatus get, double get, _alignedThresholdDeg, _calibratedAccuracyDeg, _cityName, CompassStatus, _currentPosition, dispose (+28 more)

### Community 26 - "glass_banner.dart"
Cohesion: 0.14
Nodes (16): ../../core/providers/prayer_provider.dart, _buildLeading, build, _buildGlassCard, _buildPrayerSlide, _buildQuranSlide, createState, dispose (+8 more)

### Community 27 - "QuranProvider"
Cohesion: 0.17
Nodes (15): ../../core/models/surah_model.dart, ../../core/providers/quran_provider.dart, QuranProvider, BookmarksSidebar, build, _buildBookmarksList, _buildEmptyState, _buildFooter (+7 more)

### Community 28 - "qibla_service.dart"
Cohesion: 0.12
Nodes (15): dart:math, _apiService, _calculateDistanceKm, _calculateQiblaDirection, _degreesToRadians, dispose, getQiblaDirection, _kaabaLatitude (+7 more)

### Community 29 - "search_bar.dart"
Cohesion: 0.18
Nodes (11): FocusNode, build, _controller, createState, dispose, _focusNode, initState, _isFocused (+3 more)

### Community 30 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 32 - "verse_of_day_card.dart"
Cohesion: 0.17
Nodes (11): build, _buildEmptyState, _buildErrorState, _buildHeader, _buildLoadingState, _buildVerseContent, _showShareOptions, VerseOfTheDayCard (+3 more)

### Community 33 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 34 - "calendar_service.dart"
Cohesion: 0.22
Nodes (8): ApiService, _apiService, CalendarService, _convertToHijri, dispose, getCalendarByDate, getTodayCalendar, ../models/calendar_model.dart

### Community 35 - "inav"
Cohesion: 0.22
Nodes (6): Android Launcher Icon (hdpi), Dark Theme Logo, White Theme Logo, Flutter Lints, inav, iOS App Icon (1024x1024)

### Community 36 - "quran_service.dart"
Cohesion: 0.22
Nodes (8): api_service.dart, _apiService, _cachedSurahs, dispose, getAllSurahs, QuranService, List, ../models/surah_model.dart

### Community 37 - "prayer_service.dart"
Cohesion: 0.22
Nodes (8): _apiService, _defaultTimezone, dispose, getPrayerTimesByDate, getTodayPrayerTimes, PrayerService, ../models/prayer_times_model.dart, package:flutter_dotenv/flutter_dotenv.dart

### Community 39 - "compass_dial.dart"
Cohesion: 0.08
Nodes (25): CompassStatus, CustomPainter, _DoughnutPainter, _PinTailPainter, bearing, build, _buildAccuracyBadge, _buildCardinalLabels (+17 more)

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
Cohesion: 0.15
Nodes (13): Animation, _buildPrayerStep, _calculateProgress, color, _controller, createState, dispose, _getCircleContent (+5 more)

### Community 82 - "qibla_model.dart"
Cohesion: 0.18
Nodes (10): direction, distanceKm, formattedDistance, fromJson, latitude, longitude, QiblaModel, toJson (+2 more)

### Community 83 - "surah_detail_sheet.dart"
Cohesion: 0.12
Nodes (16): SurahModel, build, _buildActionButton, _buildBadge, _buildBadgesRow, _buildBottomActions, _buildDragHandle, _buildHeader (+8 more)

### Community 84 - "StatelessWidget"
Cohesion: 0.05
Nodes (42): ../../core/models/qibla_model.dart, double?, borderRadius, build, children, CircleSkeleton, height, ScreenSkeleton (+34 more)

### Community 85 - "home_screen.dart"
Cohesion: 0.26
Nodes (13): ChangeNotifier, PrayerProvider, StreakProvider, VerseProvider, build, createState, _HomeScreenState, initState (+5 more)

### Community 86 - "streak_card.dart"
Cohesion: 0.12
Nodes (19): _animationController, build, createState, _currentProgress, didChangeDependencies, didUpdateWidget, dispose, _FireButton (+11 more)

### Community 89 - "State"
Cohesion: 0.24
Nodes (11): HomeScreen, MainScreen, _MainScreenState, MosqueScreen, _MosqueScreenState, QuranScreen, _QuranScreenState, SurahDetailSheet (+3 more)

### Community 90 - "nearest_mosque_banner.dart"
Cohesion: 0.16
Nodes (15): ../common/glass_pill_badge.dart, _buildLikeButton, _buildMosqueLeading, build, _buildContent, _buildEmptyContent, isOverridden, mosque (+7 more)

### Community 92 - "nearby_mosque_list_tile.dart"
Cohesion: 0.18
Nodes (10): build, _buildIcon, _buildTrailing, isSelected, mosque, NearbyMosqueListTile, onNavigate, onTap (+2 more)

### Community 93 - "qibla_screen.dart"
Cohesion: 0.14
Nodes (17): QiblaProvider, build, _buildContent, _buildErrorView, _buildLoadingView, createState, _handleAlignmentFeedback, initState (+9 more)

## Knowledge Gaps
- **638 isolated node(s):** `HeaderMode`, `mode`, `onToggleBookmarks`, `onToggleFavorites`, `_buildActions` (+633 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **32 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PrayerTimesModel` connect `prayer_times_model.dart` to `prayer_provider.dart`?**
  _High betweenness centrality (0.035) - this node is a cross-community bridge._
- **Why does `MosqueProvider` connect `mosque_screen.dart` to `State`, `main_screen.dart`, `mosque_provider.dart`, `home_screen.dart`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **Why does `QiblaModel` connect `qibla_model.dart` to `qibla_provider.dart`, `prayer_provider.dart`, `StatelessWidget`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **What connects `HeaderMode`, `mode`, `onToggleBookmarks` to the rest of the system?**
  _638 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Flutter Platform` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.04964539007092199 - nodes in this community are weakly interconnected._
- **Should `prayer_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05405405405405406 - nodes in this community are weakly interconnected._