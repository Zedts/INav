# Graph Report - inav  (2026-08-13)

## Corpus Check
- 124 files · ~82,472 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1923 nodes · 2632 edges · 139 communities (107 shown, 32 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `25b7374d`
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
- State
- surah_model.dart
- quran_banner.dart
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
- mosque_detail_sheet.dart
- theme_provider.dart
- qibla_provider.dart
- FocusLockProvider
- qibla_model.dart
- qibla_service.dart
- search_bar.dart
- wWinMain
- RunnerTests
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
- home_screen.dart
- ayah_model.dart
- refreshNearbyMosques
- bool?
- pill_badge.dart
- qibla_screen.dart
- quran_screen.dart
- nearest_mosque_banner.dart
- ../../core/theme/app_colors.dart
- String? get
- mosque_quick_actions.dart
- focus_lock_provider.dart
- prayer_notification_settings_model.dart
- hadith_service.dart
- app_header.dart
- nearby_mosque_list_tile.dart
- StatelessWidget
- package:flutter/material.dart
- hadith_model.dart
- FOCUS LOCK FEATURE - IMPLEMENTATION PLAN
- surah_reading_screen.dart
- lock_overlay_screen.dart
- lock_schedule.dart
- app_definition.dart
- app_selection_dialog.dart
- calibration_alert.dart
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
- VoidCallback
- installed_apps_service.dart
- favorites_sidebar.dart
- AccessibilityHelper
- ios/RunnerTests/RunnerTests.swift
- package:flutter/foundation.dart
- BootReceiver
- AppDelegate
- 1. TECHNICAL RESEARCH & APPROACH ANALYSIS
- RegisterGeneratedPlugins
- 5. EDGE CASES & RISK MITIGATION
- 3. ARCHITECTURE & FILE STRUCTURE
- package:provider/provider.dart

## God Nodes (most connected - your core abstractions)
1. `QuranProvider` - 33 edges
2. `MosqueProvider` - 32 edges
3. `Win32Window` - 22 edges
4. `PrayerProvider` - 21 edges
5. `FocusLockProvider` - 19 edges
6. `StreakProvider` - 17 edges
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
- `_buildLikeButton` --references--> `MosqueProvider`  [EXTRACTED]
  lib/widgets/common/app_header.dart → lib/core/providers/mosque_provider.dart
- `_buildMosqueLeading` --references--> `MosqueProvider`  [EXTRACTED]
  lib/widgets/common/app_header.dart → lib/core/providers/mosque_provider.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Flutter Platform Build System** — linux_cmakelists, windows_cmakelists, linux_flutter_cmakelists, windows_flutter_cmakelists [EXTRACTED 1.00]

## Communities (139 total, 32 thin omitted)

### Community 0 - "Windows Flutter Platform"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.15
Nodes (12): audio_session, device_info_plus, flutter_local_notifications, Foundation, geocoding_darwin, geolocator_apple, just_audio, package_info_plus (+4 more)

### Community 2 - "prayer_provider.dart"
Cohesion: 0.06
Nodes (34): CalendarModel? get, Duration get, _calendar, _calendarService, _countdownTimer, _currentPosition, _currentPrayer, dispose (+26 more)

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

### Community 8 - "State"
Cohesion: 0.09
Nodes (28): ../common/pill_badge.dart, HomeScreen, LockOverlayScreen, _LockOverlayScreenState, MainScreen, _MainScreenState, FocusLockConfigScreen, _FocusLockConfigScreenState (+20 more)

### Community 9 - "surah_model.dart"
Cohesion: 0.11
Nodes (17): audioUrl, fromJson, isMeccan, nameEn, nameId, nameLong, nameShort, number (+9 more)

### Community 10 - "quran_banner.dart"
Cohesion: 0.14
Nodes (14): _buildAudioButton, _buildContinuousBadge, _buildExitButton, _buildNowPlayingBadge, _buildNowPlayingContent, createState, _defaultAudioUrl, _defaultSurahKey (+6 more)

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
Nodes (37): ../../core/models/lock_schedule.dart, ../../core/models/unlock_config.dart, GlobalKey, _addCustomSchedule, _allPrayerKeys, _AppDisplayItem, _buildAppsToLockSection, _buildCustomFocusTimesSection (+29 more)

### Community 16 - "prayer_settings_provider.dart"
Cohesion: 0.09
Nodes (22): _adhanVolume, adjustPreReminder, initialize, _isInitialized, _keySettings, _loadState, masterEnabled, _playOnSilent (+14 more)

### Community 17 - "mosque_service.dart"
Cohesion: 0.06
Nodes (37): @visibleForTesting, Client, dart:async, dart:convert, dart:io, Duration, ../errors/app_exceptions.dart, _baseUrl (+29 more)

### Community 18 - "main_screen.dart"
Cohesion: 0.05
Nodes (42): home/home_screen.dart, copyWith, fromJson, method, mindfulPauseSeconds, toJson, UnlockConfig, UnlockMethod (+34 more)

### Community 19 - "MosqueProvider"
Cohesion: 0.15
Nodes (19): MosqueProvider, build, _buildContent, _buildLoadingView, createState, initState, MosqueScreen, _MosqueScreenState (+11 more)

### Community 20 - "QuranProvider"
Cohesion: 0.11
Nodes (21): ../../core/models/surah_model.dart, SurahModel, QuranProvider, build, _loadSurahDetail, _onVisibleItemsChanged, BookmarksSidebar, build (+13 more)

### Community 21 - "verse_provider.dart"
Cohesion: 0.17
Nodes (11): dispose, _errorMessage, _isLoading, loadDailyVerse, refresh, _verse, _verseService, VerseService (+3 more)

### Community 22 - "hadith_provider.dart"
Cohesion: 0.15
Nodes (12): bool get, HadithModel? get, dispose, _errorMessage, _hadith, _hadithService, _isLoading, loadDailyHadith (+4 more)

### Community 23 - "mosque_detail_sheet.dart"
Cohesion: 0.15
Nodes (12): build, _buildBadge, _buildBadgesRow, _buildBottomActions, _buildDetailsSection, _buildDragHandle, _buildHeader, mosque (+4 more)

### Community 24 - "theme_provider.dart"
Cohesion: 0.15
Nodes (12): isDarkMode, loadThemePreference, _prefs, _saveThemePreference, setThemeMode, _themeKey, _themeMode, toggleTheme (+4 more)

### Community 25 - "qibla_provider.dart"
Cohesion: 0.06
Nodes (35): CompassStatus get, double get, _alignedThresholdDeg, _calibratedAccuracyDeg, _cityName, _currentPosition, dispose, _errorMessage (+27 more)

### Community 26 - "FocusLockProvider"
Cohesion: 0.13
Nodes (16): ../../core/constants/default_apps.dart, ../../core/providers/focus_lock_provider.dart, ../../core/providers/prayer_provider.dart, FocusLockProvider, _refreshLockWindowRemaining, _showPendingUnlockDialog, build, build (+8 more)

### Community 27 - "qibla_model.dart"
Cohesion: 0.18
Nodes (10): direction, distanceKm, formattedDistance, fromJson, latitude, longitude, QiblaModel, toJson (+2 more)

### Community 28 - "qibla_service.dart"
Cohesion: 0.13
Nodes (14): dart:math, _apiService, _calculateDistanceKm, _calculateQiblaDirection, _degreesToRadians, dispose, getQiblaDirection, _kaabaLatitude (+6 more)

### Community 29 - "search_bar.dart"
Cohesion: 0.18
Nodes (11): ../../core/providers/quran_provider.dart, FocusNode, build, _controller, createState, dispose, _focusNode, initState (+3 more)

### Community 30 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 31 - "RunnerTests"
Cohesion: 0.40
Nodes (3): RunnerTests, RunnerTests, XCTestCase

### Community 32 - "random_content_card.dart"
Cohesion: 0.08
Nodes (24): accent, arabic, build, child, createState, dispose, headerIcon, headerLabel (+16 more)

### Community 33 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 34 - "quran_service.dart"
Cohesion: 0.07
Nodes (29): api_service.dart, ../errors/error_messages.dart, ApiService, _apiService, CalendarService, _convertToHijri, dispose, getCalendarByDate (+21 more)

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
Cohesion: 0.14
Nodes (13): Color, build, color, icon, isActive, isDark, label, onTap (+5 more)

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
Cohesion: 0.24
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
Cohesion: 0.12
Nodes (16): class, ../../core/models/prayer_notification_settings_model.dart, _buildAdhanPlaybackCard, _buildHeader, _buildMasterToggleCard, _buildOptionSwitchRow, _buildPlaybackToggleRow, _buildPrayerCard (+8 more)

### Community 83 - "surah_detail_sheet.dart"
Cohesion: 0.14
Nodes (14): build, _buildActionButton, _buildBadge, _buildBadgesRow, _buildDragHandle, _buildHeader, _buildTafsirSection, _buildTranslationRow (+6 more)

### Community 84 - "section_skeleton.dart"
Cohesion: 0.15
Nodes (12): double?, borderRadius, build, children, CircleSkeleton, height, ScreenSkeleton, SectionSkeleton (+4 more)

### Community 85 - "home_screen.dart"
Cohesion: 0.16
Nodes (21): ChangeNotifier, ../../core/providers/hadith_provider.dart, ../../core/providers/prayer_settings_provider.dart, ../../core/providers/streak_provider.dart, ../../core/providers/verse_provider.dart, HadithProvider, PrayerProvider, PrayerSettingsProvider (+13 more)

### Community 86 - "ayah_model.dart"
Cohesion: 0.07
Nodes (29): arab, audioUrl, AyahMeta, AyahModel, ayahNumber, AyahSajda, AyahTafsir, fromJson (+21 more)

### Community 89 - "pill_badge.dart"
Cohesion: 0.12
Nodes (15): IconData, _animation, backgroundColor, build, color, _controller, createState, dispose (+7 more)

### Community 90 - "qibla_screen.dart"
Cohesion: 0.13
Nodes (19): ../../core/providers/qibla_provider.dart, QiblaProvider, build, _buildContent, _buildLoadingView, createState, _handleAlignmentFeedback, initState (+11 more)

### Community 92 - "quran_screen.dart"
Cohesion: 0.14
Nodes (14): build, _buildAllSurahHeader, _buildLoadingState, _buildNoResultsState, createState, initState, _openSurahDetail, QuranScreen (+6 more)

### Community 93 - "nearest_mosque_banner.dart"
Cohesion: 0.15
Nodes (12): ../common/error_state_view.dart, build, _buildContent, _buildEmptyContent, isOverridden, mosque, _navigate, NearestMosqueBanner (+4 more)

### Community 94 - "../../core/theme/app_colors.dart"
Cohesion: 0.11
Nodes (17): ../../core/models/qibla_model.dart, ../../core/theme/app_colors.dart, build, _buildBadge, cityName, isAligned, qiblaData, QiblaHeroBanner (+9 more)

### Community 95 - "String? get"
Cohesion: 0.17
Nodes (11): arabic, ayahNumber, formattedReference, fromCachedJson, fromJson, surahName, surahNumber, toJson (+3 more)

### Community 96 - "mosque_quick_actions.dart"
Cohesion: 0.17
Nodes (11): build, compact, isFavorite, MosqueFavoriteButton, MosqueInfoButton, MosqueNavigateButton, MosqueQuickActionsRow, onInfo (+3 more)

### Community 97 - "focus_lock_provider.dart"
Cohesion: 0.03
Nodes (67): ../constants/default_apps.dart, addCustomSchedule, addLockedApp, _allowEmergency, canSkip, _checkAndResetDailyCount, consumeSkip, _customSchedules (+59 more)

### Community 98 - "prayer_notification_settings_model.dart"
Cohesion: 0.12
Nodes (15): copyWith, defaults, enabled, fromJson, key, maxReminderMinutes, minReminderMinutes, name (+7 more)

### Community 99 - "hadith_service.dart"
Cohesion: 0.13
Nodes (14): _apiService, _cacheHadith, clearCache, dispose, _fetchFromApi, forceRefresh, _getCachedHadith, getDailyHadith (+6 more)

### Community 100 - "app_header.dart"
Cohesion: 0.17
Nodes (11): _buildActions, _buildLeading, _buildLikeButton, _buildMosqueLeading, _buildNotificationButton, _buildQuranBookmarkButton, _buildThemeButton, HeaderMode (+3 more)

### Community 101 - "nearby_mosque_list_tile.dart"
Cohesion: 0.18
Nodes (10): ../../core/models/mosque_model.dart, MosqueModel, build, _buildIcon, _buildTrailing, isSelected, mosque, NearbyMosqueListTile (+2 more)

### Community 102 - "StatelessWidget"
Cohesion: 0.18
Nodes (11): _AyahItem, _ContentBody, _ContentPageScaffold, _EmptyState, _ErrorState, _LoadingState, _RandomHadithPage, _RandomVersePage (+3 more)

### Community 103 - "package:flutter/material.dart"
Cohesion: 0.20
Nodes (8): app_colors.dart, AppTheme, darkTheme, lightTheme, build, SettingsScreen, package:flutter/material.dart, package:google_fonts/google_fonts.dart

### Community 104 - "hadith_model.dart"
Cohesion: 0.22
Nodes (8): arabic, fromCachedJson, fromJson, HadithModel, narrator, number, toJson, translation

### Community 105 - "FOCUS LOCK FEATURE - IMPLEMENTATION PLAN"
Cohesion: 0.17
Nodes (11): 6.1 New Flutter Dependencies, 6.2 Native Android Dependencies (make sure again this is correct, adjust!), 6. DEPENDENCIES, 7.1 Technical Metrics, 7.2 User Experience Metrics, 7. SUCCESS METRICS, APPENDIX A: REFERENCE LINKS, Example Projects (+3 more)

### Community 106 - "surah_reading_screen.dart"
Cohesion: 0.05
Nodes (40): ItemPositionsListener, ItemScrollController, _arabicBaseFontSize, arabicStyle, ayah, ayahNumberStyle, build, _buildAppBar (+32 more)

### Community 107 - "lock_overlay_screen.dart"
Cohesion: 0.05
Nodes (40): blockedAppName, blockedPackageName, _breathingAnimation, _breathingController, _breathingCycles, _breathingPhase, build, _buildChipButton (+32 more)

### Community 108 - "lock_schedule.dart"
Cohesion: 0.09
Nodes (23): copyWith, CustomLockSchedule, durationMinutes, enabled, enabledPrayers, endTime, fromJson, getActivePrayerName (+15 more)

### Community 109 - "app_definition.dart"
Cohesion: 0.10
Nodes (19): Color get, int get, AppDefinition, color, colorARGB, copyWith, fromJson, hashCode (+11 more)

### Community 110 - "app_selection_dialog.dart"
Cohesion: 0.11
Nodes (19): ../../core/constants/app_constants.dart, ../../core/models/app_definition.dart, ../../core/services/installed_apps_service.dart, _allApps, AppSelectionDialog, _AppSelectionDialogState, build, _buildAppItem (+11 more)

### Community 111 - "calibration_alert.dart"
Cohesion: 0.25
Nodes (8): AnimationController, build, CalibrationAlert, _CalibrationAlertState, _controller, createState, dispose, initState

### Community 112 - "accessibility_service_helper.dart"
Cohesion: 0.04
Nodes (46): AccessibilityServiceHelper, _accessStreamSubscription, _appOpenedController, _channel, consumePendingUnlockRequest, _currentlyBlockingPackage, _dedupWindowMs, dispose (+38 more)

### Community 113 - "main.dart"
Cohesion: 0.11
Nodes (17): @pragma, ../../core/services/accessibility_service_helper.dart, core/theme/app_theme.dart, accessibilityOverlay, build, displayAppName, focusLockProvider, initialize (+9 more)

### Community 114 - "streak_card.dart"
Cohesion: 0.10
Nodes (22): StreakProvider, initState, _startPrayerCheckTimer, initState, _animationController, build, createState, _currentProgress (+14 more)

### Community 115 - "lock_engine.dart"
Cohesion: 0.08
Nodes (24): accessibility_service_helper.dart, ../constants/app_constants.dart, _appOpenedSubscription, _currentlyBlockingPkg, dispose, _handleAppOpened, _isActive, _lastEventCount (+16 more)

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
Cohesion: 0.17
Nodes (10): AppConstants, kEmergencyNonLockablePackages, version, AppImages, iconDark, iconPath, iconWhite, imagePath (+2 more)

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

### Community 126 - "VoidCallback"
Cohesion: 0.22
Nodes (8): ../../core/errors/error_messages.dart, build, ErrorStateView, message, onOpenSettings, onRetry, showErrorSnackBar, VoidCallback

### Community 127 - "installed_apps_service.dart"
Cohesion: 0.13
Nodes (14): _channel, getAppInfo, getInstalledApps, InstalledAppsService, searchApps, _channel, getAppUsageTime, getCurrentApp (+6 more)

### Community 128 - "favorites_sidebar.dart"
Cohesion: 0.25
Nodes (7): ../../core/providers/mosque_provider.dart, build, _buildEmptyState, _buildFavoritesList, _buildFooter, _buildHeader, FavoritesSidebar

### Community 130 - "ios/RunnerTests/RunnerTests.swift"
Cohesion: 0.38
Nodes (4): Flutter, FlutterSceneDelegate, SceneDelegate, UIKit

### Community 131 - "package:flutter/foundation.dart"
Cohesion: 0.29
Nodes (6): _channel, DeviceAdminService, isDeviceAdminEnabled, removeDeviceAdmin, requestDeviceAdmin, package:flutter/foundation.dart

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

### Community 137 - "3. ARCHITECTURE & FILE STRUCTURE"
Cohesion: 0.50
Nodes (4): 3.1 New Files to Create, 3.2 Android Native Code, 3.3 Android Manifest Changes, 3. ARCHITECTURE & FILE STRUCTURE

### Community 138 - "package:provider/provider.dart"
Cohesion: 0.23
Nodes (11): ../../core/theme/theme_provider.dart, ThemeProvider, build, build, ThemeToggleButton, BottomNavBar, build, currentIndex (+3 more)

## Knowledge Gaps
- **1216 isolated node(s):** `AppConstants`, `version`, `kEmergencyNonLockablePackages`, `DefaultApps`, `apps` (+1211 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **32 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `MosqueProvider` connect `MosqueProvider` to `favorites_sidebar.dart`, `app_header.dart`, `State`, `mosque_provider.dart`, `main_screen.dart`, `QuranProvider`, `home_screen.dart`, `mosque_detail_sheet.dart`, `qibla_screen.dart`, `nearest_mosque_banner.dart`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **Why does `MosqueModel` connect `nearby_mosque_list_tile.dart` to `mosque_provider.dart`, `map_view_section.dart`, `mosque_model.dart`, `mosque_detail_sheet.dart`, `nearest_mosque_banner.dart`?**
  _High betweenness centrality (0.010) - this node is a cross-community bridge._
- **Why does `QuranProvider` connect `QuranProvider` to `quran_provider.dart`, `State`, `surah_reading_screen.dart`, `quran_banner.dart`, `main_screen.dart`, `surah_detail_sheet.dart`, `home_screen.dart`, `FocusLockProvider`, `quran_screen.dart`, `search_bar.dart`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **What connects `AppConstants`, `version`, `kEmergencyNonLockablePackages` to the rest of the system?**
  _1216 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Flutter Platform` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `prayer_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05714285714285714 - nodes in this community are weakly interconnected._
- **Should `quran_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.041666666666666664 - nodes in this community are weakly interconnected._