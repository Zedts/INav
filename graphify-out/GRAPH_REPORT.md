# Graph Report - inav  (2026-08-27)

## Corpus Check
- 138 files · ~88,296 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1896 nodes · 2632 edges · 117 communities (97 shown, 20 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `922fa3e1`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Windows Flutter Platform
- GeneratedPluginRegistrant.swift
- prayer_provider.dart
- quran_provider.dart
- location_service.dart
- surah_detail_model.dart
- my_application.cc
- streak_provider.dart
- banner.dart
- surah_model.dart
- api_service.dart
- app_colors.dart
- mosque_provider.dart
- prayer_times_model.dart
- verse_service.dart
- focus_lock_config_screen.dart
- prayer_settings_provider.dart
- mosque_service.dart
- main_screen.dart
- MosqueProvider
- QuranProvider
- State
- hadith_provider.dart
- app_definition.dart
- theme_provider.dart
- qibla_provider.dart
- verse_provider.dart
- ../errors/error_messages.dart
- qibla_service.dart
- search_bar.dart
- wWinMain
- installed_apps_service.dart
- random_content_card.dart
- manifest.json
- quran_service.dart
- inav
- error_messages.dart
- calendar_model.dart
- services_tools_grid.dart
- compass_dial.dart
- widget_test.dart
- MainActivity
- Linux Project CMakeLists
- Web Index HTML
- Windows Project CMakeLists
- iOS Launch Image
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
- app_images.dart
- ayah_model.dart
- refreshNearbyMosques
- bool?
- pill_badge.dart
- qibla_screen.dart
- PLAN.md — Local auth (Get Started + Log In / Register) + sqflite
- quran_screen.dart
- mosque_detail_sheet.dart
- qibla_info_grid.dart
- verse_model.dart
- mosque_quick_actions.dart
- focus_lock_provider.dart
- prayer_notification_settings_model.dart
- hadith_service.dart
- static const String
- unlock_config.dart
- hadith_model.dart
- surah_reading_screen.dart
- lock_overlay_screen.dart
- lock_schedule.dart
- RunnerTests
- app_selection_dialog.dart
- PrayerProvider
- accessibility_service_helper.dart
- home_screen.dart
- streak_card.dart
- lock_engine.dart
- FocusLockForegroundService
- default_apps.dart
- async_app_icon.dart
- StatelessWidget
- app_exceptions.dart
- _SurahReadingScreenState
- AppDelegate
- FlutterMacOS
- package:flutter/foundation.dart
- InavLauncherPlugin
- AccessibilityHelper
- ios/RunnerTests/RunnerTests.swift
- package:flutter/material.dart
- BootReceiver
- AppDelegate
- RegisterGeneratedPlugins
- app_header.dart
- InavApplication

## God Nodes (most connected - your core abstractions)
1. `QuranProvider` - 33 edges
2. `MosqueProvider` - 32 edges
3. `Win32Window` - 22 edges
4. `PrayerProvider` - 21 edges
5. `MainActivity` - 17 edges
6. `FocusLockProvider` - 14 edges
7. `StreakProvider` - 14 edges
8. `PLAN.md — Local auth (Get Started + Log In / Register) + sqflite` - 12 edges
9. `ThemeProvider` - 12 edges
10. `MessageHandler` - 12 edges

## Surprising Connections (you probably didn't know these)
- `Android Launcher Icon (hdpi)` --references--> `inav`  [INFERRED]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → pubspec.yaml
- `Launch Screen Assets README` --references--> `iOS Launch Image`  [INFERRED]
  ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png
- `build` --references--> `FocusLockProvider`  [EXTRACTED]
  lib/screens/settings/focus_lock_config_screen.dart → lib/core/providers/focus_lock_provider.dart
- `_buildLikeButton` --references--> `MosqueProvider`  [EXTRACTED]
  lib/widgets/common/app_header.dart → lib/core/providers/mosque_provider.dart
- `_buildMosqueLeading` --references--> `MosqueProvider`  [EXTRACTED]
  lib/widgets/common/app_header.dart → lib/core/providers/mosque_provider.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Flutter Platform Build System** — linux_cmakelists, windows_cmakelists, linux_flutter_cmakelists, windows_flutter_cmakelists [EXTRACTED 1.00]

## Communities (117 total, 20 thin omitted)

### Community 0 - "Windows Flutter Platform"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.15
Nodes (12): audio_session, device_info_plus, flutter_local_notifications, Foundation, geocoding_darwin, geolocator_apple, just_audio, package_info_plus (+4 more)

### Community 2 - "prayer_provider.dart"
Cohesion: 0.06
Nodes (35): CalendarModel? get, Duration get, _calendar, _calendarService, _countdownTimer, _currentPosition, _currentPrayer, dispose (+27 more)

### Community 3 - "quran_provider.dart"
Cohesion: 0.04
Nodes (47): AudioPlayer, AudioSourceId? get, _advanceToNextSurah, _allSurahs, _audioLoading, _audioPlayer, _audioPlaying, AudioSourceId (+39 more)

### Community 4 - "location_service.dart"
Cohesion: 0.09
Nodes (21): Geocoding, checkPermission, city, country, countryCode, _formatAddress, formattedAddress, _geocoding (+13 more)

### Community 5 - "surah_detail_model.dart"
Cohesion: 0.12
Nodes (15): ayah_model.dart, audioUrl, ayahs, description, fromJson, isMeccan, name, nameLatin (+7 more)

### Community 6 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 7 - "streak_provider.dart"
Cohesion: 0.10
Nodes (20): DateTime?, _checkAndResetDate, _checkPrayerWindow, completedCount, _completedPrayers, _currentPrayerWindow, _effectivePrayerDate, initialize (+12 more)

### Community 8 - "banner.dart"
Cohesion: 0.15
Nodes (13): ../common/pill_badge.dart, ../../core/providers/prayer_provider.dart, build, _buildCard, _buildPrayerSlide, _buildQuranSlide, createState, dispose (+5 more)

### Community 9 - "surah_model.dart"
Cohesion: 0.11
Nodes (17): audioUrl, fromJson, isMeccan, nameEn, nameId, nameLong, nameShort, number (+9 more)

### Community 10 - "api_service.dart"
Cohesion: 0.17
Nodes (11): Client, dart:convert, ../errors/app_exceptions.dart, _baseUrl, _client, _defaultBaseUrl, dispose, _fallbackBaseUrl (+3 more)

### Community 11 - "app_colors.dart"
Cohesion: 0.10
Nodes (19): AppColors, cardDark, cardLight, hairlineDark, hairlineLight, primary, primaryDark, primaryLight (+11 more)

### Community 12 - "mosque_provider.dart"
Cohesion: 0.05
Nodes (39): _cityName, clearSelection, closeSidebar, dispose, _errorMessage, _favoriteMosqueIds, _featuredMosqueId, initialize (+31 more)

### Community 13 - "prayer_times_model.dart"
Cohesion: 0.12
Nodes (15): asr, cityName, date, dhuhr, fajr, fromJson, getAllPrayerTimes, getPrayerTime (+7 more)

### Community 14 - "verse_service.dart"
Cohesion: 0.12
Nodes (15): _apiService, _cacheVerse, clearCache, dispose, _fetchFromApi, forceRefresh, _getCachedVerse, getDailyVerse (+7 more)

### Community 15 - "focus_lock_config_screen.dart"
Cohesion: 0.05
Nodes (39): ../../core/models/lock_schedule.dart, ../../core/models/unlock_config.dart, GlobalKey, _addCustomSchedule, _allPrayerKeys, _AppDisplayItem, build, _buildAppsToLockSection (+31 more)

### Community 16 - "prayer_settings_provider.dart"
Cohesion: 0.09
Nodes (22): _adhanVolume, adjustPreReminder, initialize, _isInitialized, _keySettings, _loadState, masterEnabled, _playOnSilent (+14 more)

### Community 17 - "mosque_service.dart"
Cohesion: 0.07
Nodes (26): @visibleForTesting, dart:io, Duration, _distance, _distanceKm, _extractList, findNearby, _httpClient (+18 more)

### Community 18 - "main_screen.dart"
Cohesion: 0.11
Nodes (18): home/home_screen.dart, createState, _currentIndex, _getHeaderMode, MainScreen, _MainScreenState, _onTabTapped, _openMosqueDetail (+10 more)

### Community 19 - "MosqueProvider"
Cohesion: 0.10
Nodes (27): ../../core/providers/mosque_provider.dart, MosqueProvider, build, build, _buildContent, _buildLoadingView, createState, initState (+19 more)

### Community 20 - "QuranProvider"
Cohesion: 0.07
Nodes (36): ../../core/models/surah_model.dart, ../../core/providers/quran_provider.dart, QuranProvider, _loadSurahDetail, _onVisibleItemsChanged, build, BookmarksSidebar, build (+28 more)

### Community 21 - "State"
Cohesion: 0.18
Nodes (17): HomeScreen, LockOverlayScreen, FocusLockConfigScreen, _FocusLockConfigScreenState, AsyncAppIcon, _AsyncAppIconState, _PulsingDot, _PulsingDotState (+9 more)

### Community 22 - "hadith_provider.dart"
Cohesion: 0.18
Nodes (10): bool get, HadithModel? get, dispose, _errorMessage, _hadith, _hadithService, _isLoading, loadDailyHadith (+2 more)

### Community 23 - "app_definition.dart"
Cohesion: 0.11
Nodes (18): Color get, int get, color, colorARGB, copyWith, fromJson, hashCode, iconCodePoint (+10 more)

### Community 24 - "theme_provider.dart"
Cohesion: 0.14
Nodes (13): _getPrefsWithRetry, isDarkMode, loadThemePreference, _prefs, _saveThemePreference, setThemeMode, _themeKey, _themeMode (+5 more)

### Community 25 - "qibla_provider.dart"
Cohesion: 0.06
Nodes (34): CompassStatus get, double get, _alignedThresholdDeg, _calibratedAccuracyDeg, _cityName, _currentPosition, dispose, _errorMessage (+26 more)

### Community 26 - "verse_provider.dart"
Cohesion: 0.17
Nodes (11): dispose, _errorMessage, _isLoading, loadDailyVerse, refresh, _verse, _verseService, VerseService (+3 more)

### Community 27 - "../errors/error_messages.dart"
Cohesion: 0.11
Nodes (18): api_service.dart, ../errors/error_messages.dart, ApiService, _apiService, CalendarService, _convertToHijri, dispose, getCalendarByDate (+10 more)

### Community 28 - "qibla_service.dart"
Cohesion: 0.13
Nodes (14): dart:math, _apiService, _calculateDistanceKm, _calculateQiblaDirection, _degreesToRadians, dispose, getQiblaDirection, _kaabaLatitude (+6 more)

### Community 29 - "search_bar.dart"
Cohesion: 0.18
Nodes (11): FocusNode, build, _controller, createState, dispose, _focusNode, initState, _isFocused (+3 more)

### Community 30 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 31 - "installed_apps_service.dart"
Cohesion: 0.12
Nodes (16): AppDefinition, activityName, app, _channel, getAppIcon, getAppInfo, getInstalledApps, hasLauncherActivity (+8 more)

### Community 32 - "random_content_card.dart"
Cohesion: 0.08
Nodes (24): accent, arabic, build, child, createState, dispose, headerIcon, headerLabel (+16 more)

### Community 33 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 34 - "quran_service.dart"
Cohesion: 0.17
Nodes (11): _apiService, _apiServiceV3, _cachedSurahs, dispose, getAllSurahs, getSurahDetail, loadCompleteSurah, QuranService (+3 more)

### Community 35 - "inav"
Cohesion: 0.33
Nodes (3): Android Launcher Icon (hdpi), Flutter Lints, inav

### Community 36 - "error_messages.dart"
Cohesion: 0.05
Nodes (39): app_exceptions.dart, audioPlaybackFailed, audioStopFailed, audioUnavailableForSurah, calendarUnavailable, categorizeErrorMessage, cityLookupFailed, dataUnavailable (+31 more)

### Community 37 - "calendar_model.dart"
Cohesion: 0.12
Nodes (15): CalendarModel, date, day, dayOfMonth, formattedDate, fromJson, gregorian, GregorianDate (+7 more)

### Community 38 - "services_tools_grid.dart"
Cohesion: 0.14
Nodes (13): Color, build, color, icon, isActive, isDark, label, onTap (+5 more)

### Community 39 - "compass_dial.dart"
Cohesion: 0.08
Nodes (25): CustomPainter, CompassStatus, _DoughnutPainter, _PinTailPainter, bearing, build, _buildAccuracyBadge, _buildCardinalLabels (+17 more)

### Community 41 - "widget_test.dart"
Cohesion: 0.33
Nodes (5): package:flutter_test/flutter_test.dart, package:inav/core/providers/focus_lock_provider.dart, package:inav/core/theme/theme_provider.dart, package:inav/main.dart, main

### Community 42 - "MainActivity"
Cohesion: 0.10
Nodes (15): getComponentName(), InavDeviceAdminReceiver, Context, Intent, Intent, MethodChannel, MainActivity, ApplicationInfo (+7 more)

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
Nodes (14): Animation, AnimationController, _buildPrayerStep, _calculateProgress, color, _controller, createState, dispose (+6 more)

### Community 82 - "prayer_notification_settings_screen.dart"
Cohesion: 0.11
Nodes (20): class, ../../core/models/prayer_notification_settings_model.dart, PrayerSettingsProvider, build, _buildAdhanPlaybackCard, _buildHeader, _buildMasterToggleCard, _buildOptionSwitchRow (+12 more)

### Community 83 - "surah_detail_sheet.dart"
Cohesion: 0.12
Nodes (17): SurahModel, build, _buildActionButton, _buildBadge, _buildBadgesRow, _buildDragHandle, _buildHeader, _buildTafsirSection (+9 more)

### Community 84 - "section_skeleton.dart"
Cohesion: 0.15
Nodes (12): double?, borderRadius, build, children, CircleSkeleton, height, ScreenSkeleton, SectionSkeleton (+4 more)

### Community 85 - "app_images.dart"
Cohesion: 0.22
Nodes (8): AppImages, appleDark, appleWhite, google, iconDark, iconPath, iconWhite, imagePath

### Community 86 - "ayah_model.dart"
Cohesion: 0.07
Nodes (29): arab, audioUrl, AyahMeta, AyahModel, ayahNumber, AyahSajda, AyahTafsir, fromJson (+21 more)

### Community 89 - "pill_badge.dart"
Cohesion: 0.12
Nodes (15): IconData, _animation, backgroundColor, build, color, _controller, createState, dispose (+7 more)

### Community 90 - "qibla_screen.dart"
Cohesion: 0.12
Nodes (20): ../../core/providers/qibla_provider.dart, QiblaProvider, build, _buildContent, _buildLoadingView, createState, _handleAlignmentFeedback, initState (+12 more)

### Community 91 - "PLAN.md — Local auth (Get Started + Log In / Register) + sqflite"
Cohesion: 0.09
Nodes (20): 0. Locked decisions (your answers + blind-spot solutions), 10. What I will not do without permission (all now resolved or approved), 1. What exists today (graph + code), 2. Security (Perplexity + NIST/OWASP 2026) — local-only ceiling, 3. Folder / code layout (§0 Q6 + existing tree), 4.1 `users`, 4.2 `sessions`, 4.3 `quran_bookmarks` (+12 more)

### Community 92 - "quran_screen.dart"
Cohesion: 0.15
Nodes (13): build, _buildAllSurahHeader, _buildLoadingState, _buildNoResultsState, createState, initState, _openSurahDetail, QuranScreen (+5 more)

### Community 93 - "mosque_detail_sheet.dart"
Cohesion: 0.05
Nodes (42): ../common/error_state_view.dart, ../../core/errors/error_messages.dart, ../../core/models/mosque_model.dart, MosqueModel, build, ErrorStateView, message, onOpenSettings (+34 more)

### Community 94 - "qibla_info_grid.dart"
Cohesion: 0.07
Nodes (26): ../../core/models/qibla_model.dart, direction, distanceKm, formattedDistance, fromJson, latitude, longitude, QiblaModel (+18 more)

### Community 95 - "verse_model.dart"
Cohesion: 0.17
Nodes (11): arabic, ayahNumber, formattedReference, fromCachedJson, fromJson, surahName, surahNumber, toJson (+3 more)

### Community 96 - "mosque_quick_actions.dart"
Cohesion: 0.17
Nodes (11): build, compact, isFavorite, MosqueFavoriteButton, MosqueInfoButton, MosqueNavigateButton, MosqueQuickActionsRow, onInfo (+3 more)

### Community 97 - "focus_lock_provider.dart"
Cohesion: 0.03
Nodes (73): ../constants/app_constants.dart, ../constants/default_apps.dart, addCustomSchedule, addLockedApp, _allowEmergency, canSkip, capitalizeFirst, _checkAndResetDailyCount (+65 more)

### Community 98 - "prayer_notification_settings_model.dart"
Cohesion: 0.12
Nodes (15): copyWith, defaults, enabled, fromJson, key, maxReminderMinutes, minReminderMinutes, name (+7 more)

### Community 99 - "hadith_service.dart"
Cohesion: 0.12
Nodes (16): _apiService, _cacheHadith, clearCache, dispose, _fetchFromApi, forceRefresh, _getCachedHadith, getDailyHadith (+8 more)

### Community 101 - "static const String"
Cohesion: 0.33
Nodes (5): AppConstants, kEmergencyNonLockablePackages, version, static const Set, static const String

### Community 102 - "unlock_config.dart"
Cohesion: 0.20
Nodes (9): copyWith, fromJson, method, mindfulPauseSeconds, toJson, UnlockConfig, UnlockMethod, unlockPhrase (+1 more)

### Community 104 - "hadith_model.dart"
Cohesion: 0.22
Nodes (8): arabic, fromCachedJson, fromJson, HadithModel, narrator, number, toJson, translation

### Community 106 - "surah_reading_screen.dart"
Cohesion: 0.05
Nodes (38): ItemPositionsListener, ItemScrollController, _arabicBaseFontSize, arabicStyle, ayah, ayahNumberStyle, build, _buildAppBar (+30 more)

### Community 107 - "lock_overlay_screen.dart"
Cohesion: 0.05
Nodes (43): activeLockInfo, blockedAppName, blockedPackageName, build, _buildBlockedAppLabel, _buildBottomButtons, _buildContentCard, _buildHeader (+35 more)

### Community 108 - "lock_schedule.dart"
Cohesion: 0.07
Nodes (29): ActiveLockInfo, copyWith, CustomLockSchedule, customSchedule, durationMinutes, enabled, enabledPrayers, endTime (+21 more)

### Community 109 - "RunnerTests"
Cohesion: 0.40
Nodes (3): RunnerTests, RunnerTests, XCTestCase

### Community 110 - "app_selection_dialog.dart"
Cohesion: 0.07
Nodes (29): ../../core/constants/app_constants.dart, ../../core/constants/default_apps.dart, ../../core/models/app_definition.dart, _allInstalled, _AppFilter, _applyFilters, AppSelectionDialog, _AppSelectionDialogState (+21 more)

### Community 111 - "PrayerProvider"
Cohesion: 0.25
Nodes (15): ChangeNotifier, ../common/async_app_icon.dart, FocusLockProvider, HadithProvider, PrayerProvider, VerseProvider, build, _HomeScreenState (+7 more)

### Community 112 - "accessibility_service_helper.dart"
Cohesion: 0.04
Nodes (44): AccessibilityServiceHelper, _accessStreamSubscription, _appOpenedController, _channel, checkAndFireCooldownExpiry, _debounceTimer, dispose, _doSubscribe (+36 more)

### Community 113 - "home_screen.dart"
Cohesion: 0.09
Nodes (24): @pragma, ../../core/providers/focus_lock_provider.dart, ../../core/providers/hadith_provider.dart, ../../core/providers/prayer_settings_provider.dart, ../../core/providers/streak_provider.dart, ../../core/providers/verse_provider.dart, ../../core/services/accessibility_service_helper.dart, core/services/lock_engine.dart (+16 more)

### Community 114 - "streak_card.dart"
Cohesion: 0.11
Nodes (19): StreakProvider, initState, _startPrayerPoll, _animationController, build, createState, _currentProgress, didChangeDependencies (+11 more)

### Community 115 - "lock_engine.dart"
Cohesion: 0.11
Nodes (18): accessibility_service_helper.dart, dart:async, _appOpenedSubscription, dispose, _handleAppOpened, _isActive, LockEngine, LockEngineMode (+10 more)

### Community 116 - "FocusLockForegroundService"
Cohesion: 0.22
Nodes (8): FocusLockForegroundService, Context, Intent, start(), stop(), IBinder, Notification, Service

### Community 117 - "default_apps.dart"
Cohesion: 0.15
Nodes (12): apps, createGenericApp, DefaultApps, defaultPackages, essentialAppsWhitelist, getApp, isDefaultApp, isEssentialApp (+4 more)

### Community 118 - "async_app_icon.dart"
Cohesion: 0.09
Nodes (21): ../../core/services/installed_apps_service.dart, dart:typed_data, activityName, build, _bytes, cache, color, createState (+13 more)

### Community 119 - "StatelessWidget"
Cohesion: 0.14
Nodes (14): _AyahItem, _Badge, _BadgeRow, _FilterChip, _ContentBody, _ContentPageScaffold, _EmptyState, _ErrorState (+6 more)

### Community 120 - "app_exceptions.dart"
Cohesion: 0.24
Nodes (9): Exception, int?, ApiException, isNetworkError, LocationException, message, MosqueServiceException, statusCode (+1 more)

### Community 124 - "AppDelegate"
Cohesion: 0.25
Nodes (6): Any, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, AppDelegate, Bool, UIApplication

### Community 125 - "FlutterMacOS"
Cohesion: 0.32
Nodes (5): Cocoa, FlutterMacOS, MainFlutterWindow, NSWindow, XCTest

### Community 127 - "package:flutter/foundation.dart"
Cohesion: 0.14
Nodes (14): _channel, DeviceAdminService, isDeviceAdminEnabled, removeDeviceAdmin, requestDeviceAdmin, _channel, getAppUsageTime, getCurrentApp (+6 more)

### Community 128 - "InavLauncherPlugin"
Cohesion: 0.33
Nodes (5): FlutterPlugin, MethodCall, InavLauncherPlugin, Context, MethodChannel

### Community 130 - "ios/RunnerTests/RunnerTests.swift"
Cohesion: 0.38
Nodes (4): Flutter, FlutterSceneDelegate, SceneDelegate, UIKit

### Community 131 - "package:flutter/material.dart"
Cohesion: 0.12
Nodes (14): app_colors.dart, ../../core/theme/app_colors.dart, AppTheme, darkTheme, lightTheme, build, SettingsScreen, build (+6 more)

### Community 132 - "BootReceiver"
Cohesion: 0.33
Nodes (4): BootReceiver, Context, Intent, BroadcastReceiver

### Community 133 - "AppDelegate"
Cohesion: 0.47
Nodes (4): FlutterAppDelegate, AppDelegate, Bool, NSApplication

### Community 135 - "RegisterGeneratedPlugins"
Cohesion: 0.50
Nodes (3): FlutterPluginRegistry, FlutterViewController, RegisterGeneratedPlugins()

### Community 138 - "app_header.dart"
Cohesion: 0.11
Nodes (22): ../../core/theme/theme_provider.dart, ThemeProvider, build, _buildActions, _buildLeading, _buildLikeButton, _buildMosqueLeading, _buildNotificationButton (+14 more)

## Knowledge Gaps
- **1174 isolated node(s):** `Blind-spot solutions approved by you`, `Persistence map (important)`, `2. Security (Perplexity + NIST/OWASP 2026) — local-only ceiling`, `3. Folder / code layout (§0 Q6 + existing tree)`, `4.1 `users`` (+1169 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **20 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `MosqueProvider` connect `MosqueProvider` to `app_header.dart`, `mosque_provider.dart`, `PrayerProvider`, `main_screen.dart`, `qibla_screen.dart`, `mosque_detail_sheet.dart`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **Why does `UnlockConfig` connect `unlock_config.dart` to `focus_lock_provider.dart`, `lock_overlay_screen.dart`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **Why does `MosqueModel` connect `mosque_detail_sheet.dart` to `mosque_model.dart`, `mosque_provider.dart`, `map_view_section.dart`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **What connects `Blind-spot solutions approved by you`, `Persistence map (important)`, `2. Security (Perplexity + NIST/OWASP 2026) — local-only ceiling` to the rest of the system?**
  _1174 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Flutter Platform` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `prayer_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05555555555555555 - nodes in this community are weakly interconnected._
- **Should `quran_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.041666666666666664 - nodes in this community are weakly interconnected._