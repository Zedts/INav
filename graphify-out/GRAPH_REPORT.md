# Graph Report - inav  (2026-08-19)

## Corpus Check
- 124 files · ~79,802 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1858 nodes · 2536 edges · 136 communities (102 shown, 34 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `59aa24f6`
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
- verse_provider.dart
- hadith_provider.dart
- prayer_service.dart
- theme_provider.dart
- qibla_provider.dart
- PrayerProvider
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
- 9. POST-REVISION AUDIT & FEASIBILITY ANALYSIS
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
- app_images.dart
- ayah_model.dart
- refreshNearbyMosques
- bool?
- pill_badge.dart
- qibla_screen.dart
- quran_screen.dart
- nearest_mosque_banner.dart
- qibla_info_grid.dart
- verse_model.dart
- mosque_quick_actions.dart
- focus_lock_provider.dart
- prayer_notification_settings_model.dart
- hadith_service.dart
- 3. ARCHITECTURE & FILE STRUCTURE
- latLngForTest
- StatelessWidget
- package:flutter/material.dart
- hadith_model.dart
- FOCUS LOCK FEATURE - IMPLEMENTATION PLAN
- surah_reading_screen.dart
- lock_overlay_screen.dart
- lock_schedule.dart
- _SurahReadingScreenState
- app_selection_dialog.dart
- State
- accessibility_service_helper.dart
- main.dart
- streak_card.dart
- lock_engine.dart
- FocusLockForegroundService
- default_apps.dart
- 4. IMPLEMENTATION PHASES
- 8. REVISION PLAN — BUG FIXES & CORRECTIONS
- app_exceptions.dart
- static const String
- 2. LOCK SCREEN FEATURE SPECIFICATION
- InavDeviceAdminReceiver
- AppDelegate
- FlutterMacOS
- package:flutter/foundation.dart
- AccessibilityHelper
- ios/RunnerTests/RunnerTests.swift
- BootReceiver
- AppDelegate
- 1. TECHNICAL RESEARCH & APPROACH ANALYSIS
- RegisterGeneratedPlugins
- 5. EDGE CASES & RISK MITIGATION
- app_header.dart
- RunnerTests

## God Nodes (most connected - your core abstractions)
1. `QuranProvider` - 33 edges
2. `MosqueProvider` - 32 edges
3. `Win32Window` - 22 edges
4. `PrayerProvider` - 21 edges
5. `StreakProvider` - 14 edges
6. `FocusLockProvider` - 13 edges
7. `MainActivity` - 12 edges
8. `ThemeProvider` - 12 edges
9. `MessageHandler` - 12 edges
10. `FOCUS LOCK FEATURE - IMPLEMENTATION PLAN` - 12 edges

## Surprising Connections (you probably didn't know these)
- `Android Launcher Icon (hdpi)` --references--> `inav`  [INFERRED]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → pubspec.yaml
- `iOS App Icon (1024x1024)` --references--> `inav`  [INFERRED]
  ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png → pubspec.yaml
- `Launch Screen Assets README` --references--> `iOS Launch Image`  [INFERRED]
  ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png
- `build` --references--> `FocusLockProvider`  [EXTRACTED]
  lib/screens/settings/focus_lock_config_screen.dart → lib/core/providers/focus_lock_provider.dart
- `_buildLikeButton` --references--> `MosqueProvider`  [EXTRACTED]
  lib/widgets/common/app_header.dart → lib/core/providers/mosque_provider.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Flutter Platform Build System** — linux_cmakelists, windows_cmakelists, linux_flutter_cmakelists, windows_flutter_cmakelists [EXTRACTED 1.00]

## Communities (136 total, 34 thin omitted)

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
Nodes (18): audioUrl, fromJson, isMeccan, nameEn, nameId, nameLong, nameShort, number (+10 more)

### Community 10 - "api_service.dart"
Cohesion: 0.18
Nodes (10): Client, dart:convert, ../errors/app_exceptions.dart, _baseUrl, _client, _defaultBaseUrl, dispose, _handleResponse (+2 more)

### Community 11 - "app_colors.dart"
Cohesion: 0.10
Nodes (19): AppColors, cardDark, cardLight, hairlineDark, hairlineLight, primary, primaryDark, primaryLight (+11 more)

### Community 12 - "mosque_provider.dart"
Cohesion: 0.05
Nodes (38): _cityName, clearSelection, closeSidebar, dispose, _errorMessage, _favoriteMosqueIds, _featuredMosqueId, initialize (+30 more)

### Community 13 - "prayer_times_model.dart"
Cohesion: 0.12
Nodes (15): asr, cityName, date, dhuhr, fajr, fromJson, getAllPrayerTimes, getPrayerTime (+7 more)

### Community 14 - "verse_service.dart"
Cohesion: 0.12
Nodes (15): _apiService, _cacheVerse, clearCache, dispose, _fetchFromApi, forceRefresh, _getCachedVerse, getDailyVerse (+7 more)

### Community 15 - "focus_lock_config_screen.dart"
Cohesion: 0.05
Nodes (37): ../../core/models/lock_schedule.dart, GlobalKey, _addCustomSchedule, _allPrayerKeys, _AppDisplayItem, build, _buildAppsToLockSection, _buildCustomFocusTimesSection (+29 more)

### Community 16 - "prayer_settings_provider.dart"
Cohesion: 0.05
Nodes (41): Color get, int get, AppDefinition, color, colorARGB, copyWith, fromJson, hashCode (+33 more)

### Community 17 - "mosque_service.dart"
Cohesion: 0.08
Nodes (24): dart:io, Duration, _distance, _distanceKm, _extractList, findNearby, _httpClient, isNetworkError (+16 more)

### Community 18 - "main_screen.dart"
Cohesion: 0.10
Nodes (20): home/home_screen.dart, build, createState, _currentIndex, _getHeaderMode, MainScreen, _MainScreenState, _onTabTapped (+12 more)

### Community 19 - "MosqueProvider"
Cohesion: 0.07
Nodes (37): ../../core/providers/mosque_provider.dart, MosqueProvider, build, _buildContent, _buildLoadingView, createState, initState, MosqueScreen (+29 more)

### Community 20 - "QuranProvider"
Cohesion: 0.07
Nodes (36): ../../core/models/surah_model.dart, ../../core/providers/quran_provider.dart, QuranProvider, _loadSurahDetail, _onVisibleItemsChanged, build, BookmarksSidebar, build (+28 more)

### Community 21 - "verse_provider.dart"
Cohesion: 0.15
Nodes (12): VerseModel, dispose, _errorMessage, _isLoading, loadDailyVerse, refresh, _verse, _verseService (+4 more)

### Community 22 - "hadith_provider.dart"
Cohesion: 0.17
Nodes (11): HadithModel? get, dispose, _errorMessage, _hadith, _hadithService, _isLoading, loadDailyHadith, refresh (+3 more)

### Community 23 - "prayer_service.dart"
Cohesion: 0.20
Nodes (9): api_service.dart, _apiService, _defaultTimezone, dispose, getPrayerTimesByDate, getTodayPrayerTimes, PrayerService, ../models/prayer_times_model.dart (+1 more)

### Community 24 - "theme_provider.dart"
Cohesion: 0.15
Nodes (12): bool get, isDarkMode, loadThemePreference, _prefs, _saveThemePreference, setThemeMode, _themeKey, _themeMode (+4 more)

### Community 25 - "qibla_provider.dart"
Cohesion: 0.06
Nodes (34): CompassStatus get, double get, _alignedThresholdDeg, _calibratedAccuracyDeg, _cityName, _currentPosition, dispose, _errorMessage (+26 more)

### Community 26 - "PrayerProvider"
Cohesion: 0.26
Nodes (14): ChangeNotifier, ../../core/constants/default_apps.dart, FocusLockProvider, HadithProvider, PrayerProvider, VerseProvider, build, _HomeScreenState (+6 more)

### Community 27 - "../errors/error_messages.dart"
Cohesion: 0.20
Nodes (9): ../errors/error_messages.dart, ApiService, _apiService, CalendarService, _convertToHijri, dispose, getCalendarByDate, getTodayCalendar (+1 more)

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
Cohesion: 0.25
Nodes (7): _channel, getAppInfo, getInstalledApps, InstalledAppsService, searchApps, ../models/app_definition.dart, static const MethodChannel

### Community 32 - "random_content_card.dart"
Cohesion: 0.09
Nodes (22): accent, arabic, build, child, createState, dispose, headerIcon, headerLabel (+14 more)

### Community 33 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 34 - "quran_service.dart"
Cohesion: 0.17
Nodes (11): _apiService, _apiServiceV3, _cachedSurahs, dispose, getAllSurahs, getSurahDetail, loadCompleteSurah, QuranService (+3 more)

### Community 35 - "inav"
Cohesion: 0.29
Nodes (4): Android Launcher Icon (hdpi), Flutter Lints, inav, iOS App Icon (1024x1024)

### Community 36 - "error_messages.dart"
Cohesion: 0.05
Nodes (39): app_exceptions.dart, audioPlaybackFailed, audioStopFailed, audioUnavailableForSurah, calendarUnavailable, categorizeErrorMessage, cityLookupFailed, dataUnavailable (+31 more)

### Community 37 - "calendar_model.dart"
Cohesion: 0.12
Nodes (15): CalendarModel, date, day, dayOfMonth, formattedDate, fromJson, gregorian, GregorianDate (+7 more)

### Community 38 - "services_tools_grid.dart"
Cohesion: 0.13
Nodes (14): Color, IconData, build, color, icon, isActive, isDark, label (+6 more)

### Community 39 - "compass_dial.dart"
Cohesion: 0.08
Nodes (25): CustomPainter, CompassStatus, _DoughnutPainter, _PinTailPainter, bearing, build, _buildAccuracyBadge, _buildCardinalLabels (+17 more)

### Community 40 - "9. POST-REVISION AUDIT & FEASIBILITY ANALYSIS"
Cohesion: 0.06
Nodes (32): 9.1 REVISION PLAN (SECTION 8) COMPLETION STATUS — ✅ **MOSTLY COMPLETE** with Critical Blocker, 9.2 ANDROID LOCK SCREEN FEASIBILITY — ✅ **FEASIBLE BUT WITH DEVICE-SPECIFIC CAVEATS**, 9.3 VALIDATION RESULTS — ✅ **ALL BUILDS PASSING**, 9.4 BUILD DOCUMENTATION — CRITICAL REQUIREMENTS, 9.4 REMAINING WORK — SEQUENCED FIX PLAN, 9.5 FINAL RECOMMENDATION — **PROCEED WITH DIRECTORY FIX (R5) IMMEDIATELY**, 9.5 FINAL VALIDATION RESULTS — ✅ **ALL TESTS PASSING**, 9.6 FINAL RECOMMENDATION — ✅ **PRODUCTION READY** (+24 more)

### Community 41 - "widget_test.dart"
Cohesion: 0.33
Nodes (5): package:flutter_test/flutter_test.dart, package:inav/core/providers/focus_lock_provider.dart, package:inav/core/theme/theme_provider.dart, package:inav/main.dart, main

### Community 42 - "MainActivity"
Cohesion: 0.23
Nodes (5): Intent, MainActivity, FlutterActivity, FlutterEngine, MethodChannel

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
Cohesion: 0.14
Nodes (13): Animation, _buildPrayerStep, _calculateProgress, color, _controller, createState, dispose, _getCircleContent (+5 more)

### Community 82 - "prayer_notification_settings_screen.dart"
Cohesion: 0.11
Nodes (20): class, ../../core/models/prayer_notification_settings_model.dart, PrayerSettingsProvider, build, _buildAdhanPlaybackCard, _buildHeader, _buildMasterToggleCard, _buildOptionSwitchRow (+12 more)

### Community 83 - "surah_detail_sheet.dart"
Cohesion: 0.12
Nodes (16): build, _buildActionButton, _buildBadge, _buildBadgesRow, _buildDragHandle, _buildHeader, _buildTafsirSection, _buildTranslationRow (+8 more)

### Community 84 - "section_skeleton.dart"
Cohesion: 0.15
Nodes (12): double?, borderRadius, build, children, CircleSkeleton, height, ScreenSkeleton, SectionSkeleton (+4 more)

### Community 85 - "app_images.dart"
Cohesion: 0.33
Nodes (5): AppImages, iconDark, iconPath, iconWhite, imagePath

### Community 86 - "ayah_model.dart"
Cohesion: 0.07
Nodes (29): arab, audioUrl, AyahMeta, AyahModel, ayahNumber, AyahSajda, AyahTafsir, fromJson (+21 more)

### Community 89 - "pill_badge.dart"
Cohesion: 0.12
Nodes (15): AnimationController, _animation, backgroundColor, build, color, _controller, createState, dispose (+7 more)

### Community 90 - "qibla_screen.dart"
Cohesion: 0.12
Nodes (20): ../../core/providers/qibla_provider.dart, QiblaProvider, build, _buildContent, _buildLoadingView, createState, _handleAlignmentFeedback, initState (+12 more)

### Community 92 - "quran_screen.dart"
Cohesion: 0.15
Nodes (13): build, _buildAllSurahHeader, _buildLoadingState, _buildNoResultsState, createState, initState, _openSurahDetail, QuranScreen (+5 more)

### Community 93 - "nearest_mosque_banner.dart"
Cohesion: 0.07
Nodes (30): ../common/error_state_view.dart, ../../core/errors/error_messages.dart, ../../core/models/mosque_model.dart, MosqueModel, build, ErrorStateView, message, onOpenSettings (+22 more)

### Community 94 - "qibla_info_grid.dart"
Cohesion: 0.07
Nodes (26): ../../core/models/qibla_model.dart, direction, distanceKm, formattedDistance, fromJson, latitude, longitude, QiblaModel (+18 more)

### Community 95 - "verse_model.dart"
Cohesion: 0.18
Nodes (10): arabic, ayahNumber, formattedReference, fromCachedJson, fromJson, surahName, surahNumber, toJson (+2 more)

### Community 96 - "mosque_quick_actions.dart"
Cohesion: 0.17
Nodes (11): build, compact, isFavorite, MosqueFavoriteButton, MosqueInfoButton, MosqueNavigateButton, MosqueQuickActionsRow, onInfo (+3 more)

### Community 97 - "focus_lock_provider.dart"
Cohesion: 0.03
Nodes (63): ../constants/app_constants.dart, ../constants/default_apps.dart, addCustomSchedule, addLockedApp, _allowEmergency, canSkip, _checkAndResetDailyCount, _customSchedules (+55 more)

### Community 98 - "prayer_notification_settings_model.dart"
Cohesion: 0.12
Nodes (15): copyWith, defaults, enabled, fromJson, key, maxReminderMinutes, minReminderMinutes, name (+7 more)

### Community 99 - "hadith_service.dart"
Cohesion: 0.12
Nodes (15): _apiService, _cacheHadith, clearCache, dispose, _fetchFromApi, forceRefresh, _getCachedHadith, getDailyHadith (+7 more)

### Community 100 - "3. ARCHITECTURE & FILE STRUCTURE"
Cohesion: 0.50
Nodes (4): 3.1 New Files to Create, 3.2 Android Native Code, 3.3 Android Manifest Changes, 3. ARCHITECTURE & FILE STRUCTURE

### Community 102 - "StatelessWidget"
Cohesion: 0.18
Nodes (11): _AyahItem, _ContentBody, _ContentPageScaffold, _EmptyState, _ErrorState, _LoadingState, _RandomHadithPage, _RandomVersePage (+3 more)

### Community 103 - "package:flutter/material.dart"
Cohesion: 0.12
Nodes (14): app_colors.dart, ../../core/theme/app_colors.dart, AppTheme, darkTheme, lightTheme, build, SettingsScreen, build (+6 more)

### Community 104 - "hadith_model.dart"
Cohesion: 0.22
Nodes (8): arabic, fromCachedJson, fromJson, HadithModel, narrator, number, toJson, translation

### Community 105 - "FOCUS LOCK FEATURE - IMPLEMENTATION PLAN"
Cohesion: 0.17
Nodes (11): 6.1 New Flutter Dependencies, 6.2 Native Android Dependencies (make sure again this is correct, adjust!), 6. DEPENDENCIES, 7.1 Technical Metrics, 7.2 User Experience Metrics, 7. SUCCESS METRICS, APPENDIX A: REFERENCE LINKS, Example Projects (+3 more)

### Community 106 - "surah_reading_screen.dart"
Cohesion: 0.05
Nodes (38): ItemPositionsListener, ItemScrollController, _arabicBaseFontSize, arabicStyle, ayah, ayahNumberStyle, build, _buildAppBar (+30 more)

### Community 107 - "lock_overlay_screen.dart"
Cohesion: 0.05
Nodes (39): ../../core/models/unlock_config.dart, copyWith, fromJson, method, mindfulPauseSeconds, toJson, UnlockConfig, UnlockMethod (+31 more)

### Community 108 - "lock_schedule.dart"
Cohesion: 0.09
Nodes (23): copyWith, CustomLockSchedule, durationMinutes, enabled, enabledPrayers, endTime, fromJson, getActivePrayerName (+15 more)

### Community 110 - "app_selection_dialog.dart"
Cohesion: 0.11
Nodes (18): ../../core/constants/app_constants.dart, ../../core/models/app_definition.dart, ../../core/services/installed_apps_service.dart, _allApps, AppSelectionDialog, _AppSelectionDialogState, build, _buildAppItem (+10 more)

### Community 111 - "State"
Cohesion: 0.19
Nodes (16): HomeScreen, LockOverlayScreen, _LockOverlayScreenState, FocusLockConfigScreen, _FocusLockConfigScreenState, _PulsingDot, _PulsingDotState, _PulsingRing (+8 more)

### Community 112 - "accessibility_service_helper.dart"
Cohesion: 0.08
Nodes (25): AccessibilityServiceHelper, _accessStreamSubscription, _appOpenedController, _channel, dispose, hasUsageStatsPermission, hideLockOverlay, initialize (+17 more)

### Community 113 - "main.dart"
Cohesion: 0.08
Nodes (25): @pragma, ../../core/providers/focus_lock_provider.dart, ../../core/providers/hadith_provider.dart, ../../core/providers/prayer_settings_provider.dart, ../../core/providers/verse_provider.dart, ../../core/services/accessibility_service_helper.dart, core/theme/app_theme.dart, accessibilityOverlay (+17 more)

### Community 114 - "streak_card.dart"
Cohesion: 0.10
Nodes (22): ../../core/providers/streak_provider.dart, StreakProvider, initState, _startPrayerCheckTimer, _animationController, build, createState, _currentProgress (+14 more)

### Community 115 - "lock_engine.dart"
Cohesion: 0.10
Nodes (20): accessibility_service_helper.dart, dart:async, _appOpenedSubscription, _appOpenedSubscriptionIsListening, dispose, _handleAppOpened, _isActive, LockEngine (+12 more)

### Community 116 - "FocusLockForegroundService"
Cohesion: 0.22
Nodes (8): FocusLockForegroundService, Context, Intent, start(), stop(), IBinder, Notification, Service

### Community 117 - "default_apps.dart"
Cohesion: 0.17
Nodes (11): apps, createGenericApp, DefaultApps, defaultPackages, essentialAppsWhitelist, getApp, isDefaultApp, isEssentialApp (+3 more)

### Community 118 - "4. IMPLEMENTATION PHASES"
Cohesion: 0.18
Nodes (11): 4. IMPLEMENTATION PHASES, Phase 10: Testing & Bug Fixes (Week 10), Phase 1: Foundation (Week 1), Phase 2: Lock Overlay (Week 2), Phase 3: Lock Schedule Engine (Week 3), Phase 4: Advanced Unlock Methods (Week 4), Phase 5: App Selection & Management (Week 5), Phase 6: Exceptions & Limits (Week 6) (+3 more)

### Community 119 - "8. REVISION PLAN — BUG FIXES & CORRECTIONS"
Cohesion: 0.18
Nodes (11): 8.0 How to Read This Section, 8.1 Issue #1 — KGP Warning from `workmanager_android` (P3), 8.2 Issue #2 — ListTile `background color or ink splashes may be invisible` (×3) (P2), 8.3 Issue #3 — MissingPluginException: `device_admin` channel (×3) (P0), 8.4 Issue #4 — Lock Overlay NOT Appearing Despite App-Open Detected (P0), 8.5 Issue #5 — Cannot Re-Add Instagram/TikTok/YouTube After Unchecking + Add Any App UX (P1), 8.6 Issue #6 — UI: Permissions Section Title + Duplicate Device Admin/Prevent-Uninstall Consolidation (P2), 8.7 Sequenced Fix Order (Dependency Graph) (+3 more)

### Community 120 - "app_exceptions.dart"
Cohesion: 0.24
Nodes (9): Exception, int?, ApiException, isNetworkError, LocationException, message, MosqueServiceException, statusCode (+1 more)

### Community 121 - "static const String"
Cohesion: 0.33
Nodes (5): AppConstants, kEmergencyNonLockablePackages, version, static const Set, static const String

### Community 122 - "2. LOCK SCREEN FEATURE SPECIFICATION"
Cohesion: 0.20
Nodes (10): 2.1 Default Apps Configuration, 2.2 Lock Schedule Types, 2.3 Unlock Methods, 2.4 Exceptions & Limits, 2. LOCK SCREEN FEATURE SPECIFICATION, **A. Allow Calls & Messages**, **A. Prayer-Based Lock Schedule**, **B. Custom Focus Times** (+2 more)

### Community 123 - "InavDeviceAdminReceiver"
Cohesion: 0.31
Nodes (6): getComponentName(), InavDeviceAdminReceiver, Context, Intent, ComponentName, DeviceAdminReceiver

### Community 124 - "AppDelegate"
Cohesion: 0.25
Nodes (6): Any, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, AppDelegate, Bool, UIApplication

### Community 125 - "FlutterMacOS"
Cohesion: 0.32
Nodes (5): Cocoa, FlutterMacOS, MainFlutterWindow, NSWindow, XCTest

### Community 127 - "package:flutter/foundation.dart"
Cohesion: 0.14
Nodes (13): _channel, DeviceAdminService, isDeviceAdminEnabled, removeDeviceAdmin, requestDeviceAdmin, _channel, getAppUsageTime, getCurrentApp (+5 more)

### Community 130 - "ios/RunnerTests/RunnerTests.swift"
Cohesion: 0.38
Nodes (4): Flutter, FlutterSceneDelegate, SceneDelegate, UIKit

### Community 132 - "BootReceiver"
Cohesion: 0.33
Nodes (4): BootReceiver, Context, Intent, BroadcastReceiver

### Community 133 - "AppDelegate"
Cohesion: 0.47
Nodes (4): FlutterAppDelegate, AppDelegate, Bool, NSApplication

### Community 134 - "1. TECHNICAL RESEARCH & APPROACH ANALYSIS"
Cohesion: 0.33
Nodes (6): 1.1 Package Research: flutter\_accessibility\_service, 1.2 Alternative Approaches Considered, 1.3 Recommended Approach: **flutter\_accessibility\_service + UsageStatsManager**, 1. TECHNICAL RESEARCH & APPROACH ANALYSIS, **Option A: flutter\_screentime Package**, **Option B: UsageStatsManager Only (No Overlay)**

### Community 135 - "RegisterGeneratedPlugins"
Cohesion: 0.50
Nodes (3): FlutterPluginRegistry, FlutterViewController, RegisterGeneratedPlugins()

### Community 136 - "5. EDGE CASES & RISK MITIGATION"
Cohesion: 0.33
Nodes (6): 5.1 Accessibility Service Disabled by User, 5.2 Overlay Dismissed After Screen Lock/Unlock, 5.3 Performance & Battery Impact, 5.4 Android Version Compatibility, 5.5 Security & Privacy Concerns, 5. EDGE CASES & RISK MITIGATION

### Community 138 - "app_header.dart"
Cohesion: 0.11
Nodes (22): ../../core/theme/theme_provider.dart, ThemeProvider, build, _buildActions, _buildLeading, _buildLikeButton, _buildMosqueLeading, _buildNotificationButton (+14 more)

### Community 139 - "RunnerTests"
Cohesion: 0.40
Nodes (3): RunnerTests, RunnerTests, XCTestCase

## Knowledge Gaps
- **1162 isolated node(s):** `AppConstants`, `version`, `kEmergencyNonLockablePackages`, `DefaultApps`, `apps` (+1157 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **34 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `MosqueProvider` connect `MosqueProvider` to `qibla_screen.dart`, `app_header.dart`, `mosque_provider.dart`, `main_screen.dart`, `PrayerProvider`, `nearest_mosque_banner.dart`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **Why does `MosqueModel` connect `nearest_mosque_banner.dart` to `mosque_model.dart`, `MosqueProvider`, `mosque_provider.dart`, `map_view_section.dart`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **Why does `QuranProvider` connect `QuranProvider` to `quran_provider.dart`, `surah_reading_screen.dart`, `_SurahReadingScreenState`, `main_screen.dart`, `surah_detail_sheet.dart`, `PrayerProvider`, `quran_screen.dart`, `search_bar.dart`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **What connects `AppConstants`, `version`, `kEmergencyNonLockablePackages` to the rest of the system?**
  _1162 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Flutter Platform` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `prayer_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05555555555555555 - nodes in this community are weakly interconnected._
- **Should `quran_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.041666666666666664 - nodes in this community are weakly interconnected._