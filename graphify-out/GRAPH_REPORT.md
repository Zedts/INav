# Graph Report - .  (2026-07-28)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 798 nodes · 1043 edges · 78 communities (49 shown, 29 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `7c214777`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Windows Flutter Platform
- macOS Flutter Platform
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
- package:flutter/material.dart
- prayer_times_model.dart
- verse_service.dart
- glass_pill_badge.dart
- surah_detail_sheet.dart
- horizontal_prayer_stepper.dart
- main_screen.dart
- app_header.dart
- quran_screen.dart
- verse_provider.dart
- home_screen.dart
- package:provider/provider.dart
- theme_provider.dart
- services_tools_grid.dart
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
- app_theme.dart
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

## God Nodes (most connected - your core abstractions)
1. `QuranProvider` - 28 edges
2. `Win32Window` - 22 edges
3. `PrayerProvider` - 15 edges
4. `ThemeProvider` - 12 edges
5. `MessageHandler` - 12 edges
6. `StreakProvider` - 10 edges
7. `FlutterWindow` - 10 edges
8. `Create` - 10 edges
9. `WndProc` - 10 edges
10. `MessageHandler` - 9 edges

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

## Communities (78 total, 29 thin omitted)

### Community 0 - "Windows Flutter Platform"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "macOS Flutter Platform"
Cohesion: 0.05
Nodes (33): Any, audio_session, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS (+25 more)

### Community 2 - "prayer_provider.dart"
Cohesion: 0.05
Nodes (41): CalendarModel? get, dart:async, Duration, Duration get, _calendar, _calendarService, _countdownTimer, _currentPosition (+33 more)

### Community 3 - "quran_provider.dart"
Cohesion: 0.05
Nodes (40): AudioPlayer, AudioSourceId? get, _advanceToNextSurah, _allSurahs, _audioLoading, _audioPlayer, _audioPlaying, AudioSourceId (+32 more)

### Community 4 - "location_service.dart"
Cohesion: 0.05
Nodes (38): Client, dart:convert, Exception, Geocoding, int?, ApiException, _baseUrl, _client (+30 more)

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
Nodes (19): CustomPainter, _animationController, build, createState, _currentProgress, didChangeDependencies, didUpdateWidget, dispose (+11 more)

### Community 9 - "surah_model.dart"
Cohesion: 0.11
Nodes (18): audioUrl, fromJson, isMeccan, nameEn, nameId, nameLong, nameShort, number (+10 more)

### Community 10 - "quran_banner.dart"
Cohesion: 0.12
Nodes (18): MainScreen, _MainScreenState, _buildAudioButton, _buildContinuousBadge, _buildDefaultContent, _buildExitButton, _buildNowPlayingBadge, _buildNowPlayingContent (+10 more)

### Community 11 - "app_colors.dart"
Cohesion: 0.11
Nodes (17): accent, AppColors, borderDark, borderLight, cardDark, cardLight, primaryDark, primaryLight (+9 more)

### Community 12 - "package:flutter/material.dart"
Cohesion: 0.12
Nodes (15): MyApp, build, MosqueScreen, build, QiblaScreen, build, SettingsScreen, GlassPillBadge (+7 more)

### Community 13 - "prayer_times_model.dart"
Cohesion: 0.12
Nodes (15): asr, cityName, date, dhuhr, fajr, fromJson, getAllPrayerTimes, getPrayerTime (+7 more)

### Community 14 - "verse_service.dart"
Cohesion: 0.12
Nodes (15): _apiService, _cacheVerse, clearCache, dispose, _fetchFromApi, forceRefresh, _getCachedVerse, getDailyVerse (+7 more)

### Community 15 - "glass_pill_badge.dart"
Cohesion: 0.13
Nodes (15): _animation, build, color, _controller, createState, dispose, icon, initState (+7 more)

### Community 16 - "surah_detail_sheet.dart"
Cohesion: 0.13
Nodes (15): build, _buildActionButton, _buildBadge, _buildBadgesRow, _buildBottomActions, _buildDragHandle, _buildHeader, _buildTafsirSection (+7 more)

### Community 17 - "horizontal_prayer_stepper.dart"
Cohesion: 0.14
Nodes (14): Animation, AnimationController, _buildPrayerStep, _calculateProgress, color, _controller, createState, dispose (+6 more)

### Community 18 - "main_screen.dart"
Cohesion: 0.13
Nodes (14): home/home_screen.dart, createState, _currentIndex, _getHeaderMode, _onTabTapped, _openSurahDetail, _screens, mosque/mosque_screen.dart (+6 more)

### Community 19 - "app_header.dart"
Cohesion: 0.15
Nodes (14): PrayerProvider, AppHeader, _buildActions, _buildLeading, _buildNotificationButton, _buildQuranBookmarkButton, _buildThemeButton, HeaderMode (+6 more)

### Community 20 - "quran_screen.dart"
Cohesion: 0.14
Nodes (14): build, _buildAllSurahHeader, _buildErrorState, _buildLoadingState, _buildNoResultsState, createState, initState, _openSurahDetail (+6 more)

### Community 21 - "verse_provider.dart"
Cohesion: 0.14
Nodes (13): bool get, dispose, _errorMessage, _isLoading, loadDailyVerse, _parseErrorMessage, refresh, _verse (+5 more)

### Community 22 - "home_screen.dart"
Cohesion: 0.23
Nodes (13): ChangeNotifier, StreakProvider, VerseProvider, build, createState, HomeScreen, _HomeScreenState, initState (+5 more)

### Community 23 - "package:provider/provider.dart"
Cohesion: 0.21
Nodes (12): ../../core/theme/app_colors.dart, core/theme/theme_provider.dart, ThemeProvider, build, build, ThemeToggleButton, BottomNavBar, build (+4 more)

### Community 24 - "theme_provider.dart"
Cohesion: 0.14
Nodes (13): isDarkMode, loadThemePreference, _prefs, _saveThemePreference, setThemeMode, _themeKey, _themeMode, toggleTheme (+5 more)

### Community 25 - "services_tools_grid.dart"
Cohesion: 0.15
Nodes (12): Color, IconData, build, color, icon, isActive, isDark, label (+4 more)

### Community 26 - "glass_banner.dart"
Cohesion: 0.17
Nodes (12): ../common/glass_pill_badge.dart, _buildGlassCard, _buildPrayerSlide, _buildQuranSlide, createState, dispose, GlassBanner, _GlassBannerState (+4 more)

### Community 27 - "QuranProvider"
Cohesion: 0.19
Nodes (12): core/providers/quran_provider.dart, QuranProvider, build, build, _exitActivePlayback, _toggleAudio, build, _buildNumberBadge (+4 more)

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
Nodes (10): core/providers/prayer_provider.dart, core/providers/streak_provider.dart, core/providers/verse_provider.dart, core/theme/app_theme.dart, build, load, loadThemePreference, main (+2 more)

### Community 32 - "verse_of_day_card.dart"
Cohesion: 0.18
Nodes (10): dart:ui, build, _buildEmptyState, _buildErrorState, _buildHeader, _buildLoadingState, _buildVerseContent, _showShareOptions (+2 more)

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

### Community 38 - "qibla_model.dart"
Cohesion: 0.25
Nodes (7): direction, fromJson, latitude, longitude, QiblaModel, toJson, toString

### Community 39 - "bookmarks_sidebar.dart"
Cohesion: 0.29
Nodes (6): ../core/models/surah_model.dart, build, _buildBookmarksList, _buildEmptyState, _buildFooter, _buildHeader

### Community 40 - "app_theme.dart"
Cohesion: 0.40
Nodes (4): app_colors.dart, AppTheme, darkTheme, lightTheme

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

## Knowledge Gaps
- **424 isolated node(s):** `GregorianDate`, `HijriDate`, `gregorian`, `hijri`, `date` (+419 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **29 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PrayerTimesModel` connect `prayer_times_model.dart` to `prayer_provider.dart`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **Why does `QuranProvider` connect `QuranProvider` to `quran_provider.dart`, `bookmarks_sidebar.dart`, `quran_banner.dart`, `package:flutter/material.dart`, `surah_detail_sheet.dart`, `main_screen.dart`, `quran_screen.dart`, `home_screen.dart`, `search_bar.dart`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Why does `PrayerProvider` connect `app_header.dart` to `horizontal_prayer_stepper.dart`, `prayer_provider.dart`, `glass_banner.dart`, `home_screen.dart`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **What connects `GregorianDate`, `HijriDate`, `gregorian` to the rest of the system?**
  _424 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Flutter Platform` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `macOS Flutter Platform` be split into smaller, more focused modules?**
  _Cohesion score 0.05087881591119334 - nodes in this community are weakly interconnected._
- **Should `prayer_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.047619047619047616 - nodes in this community are weakly interconnected._