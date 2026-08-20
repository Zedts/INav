# Graph Report - inav  (2026-08-20)

## Corpus Check
- 133 files · ~96,545 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1983 nodes · 2700 edges · 138 communities (105 shown, 33 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 24 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `649d3cab`
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
- quran_banner.dart
- Locked Apps Selection UI - Complete Code Map
- hadith_provider.dart
- app_definition.dart
- theme_provider.dart
- qibla_provider.dart
- ✅ Implementation Complete — All Bugs + Features Delivered
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
- 📝 Key Updates to [PLAN_2.md](file:///c:/Users/PC-20/Desktop/Code/inav/PLAN_2.md)
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
- static const String
- ayah_model.dart
- refreshNearbyMosques
- bool?
- pill_badge.dart
- qibla_screen.dart
- PLAN_1 — Locked-app launcher icons + installed-only defaults
- quran_screen.dart
- nearest_mosque_banner.dart
- package:flutter/material.dart
- verse_model.dart
- mosque_quick_actions.dart
- focus_lock_provider.dart
- prayer_notification_settings_model.dart
- hadith_service.dart
- mosque_detail_sheet.dart
- qibla_model.dart
- unlock_config.dart
- nearby_mosque_list_tile.dart
- hadith_model.dart
- FocusLockProvider
- surah_reading_screen.dart
- lock_overlay_screen.dart
- lock_schedule.dart
- Fix Flutter Platform and Plugin Errors
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
- VoidCallback
- favorites_sidebar.dart
- AppDelegate
- FlutterMacOS
- QuranProvider
- package:flutter/foundation.dart
- InavLauncherPlugin
- AccessibilityHelper
- ios/RunnerTests/RunnerTests.swift
- calibration_alert.dart
- BootReceiver
- AppDelegate
- RegisterGeneratedPlugins
- ✅ All Bugs Fixed — All 4 Validations Passed
- ../../core/theme/app_colors.dart
- InavApplication

## God Nodes (most connected - your core abstractions)
1. `QuranProvider` - 33 edges
2. `MosqueProvider` - 32 edges
3. `Win32Window` - 22 edges
4. `PrayerProvider` - 21 edges
5. `MainActivity` - 17 edges
6. `FocusLockProvider` - 14 edges
7. `StreakProvider` - 14 edges
8. `ThemeProvider` - 12 edges
9. `MessageHandler` - 12 edges
10. `HadithProvider` - 10 edges

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

## Communities (138 total, 33 thin omitted)

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

### Community 8 - "banner.dart"
Cohesion: 0.17
Nodes (11): ../common/pill_badge.dart, ../../core/providers/prayer_provider.dart, build, _buildCard, _buildPrayerSlide, _buildQuranSlide, createState, dispose (+3 more)

### Community 9 - "surah_model.dart"
Cohesion: 0.11
Nodes (18): audioUrl, fromJson, isMeccan, nameEn, nameId, nameLong, nameShort, number (+10 more)

### Community 10 - "api_service.dart"
Cohesion: 0.17
Nodes (11): Client, dart:convert, ../errors/app_exceptions.dart, _baseUrl, _client, _defaultBaseUrl, dispose, _fallbackBaseUrl (+3 more)

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
Cohesion: 0.07
Nodes (27): VerseModel, dispose, _errorMessage, _isLoading, loadDailyVerse, refresh, _verse, _verseService (+19 more)

### Community 15 - "focus_lock_config_screen.dart"
Cohesion: 0.05
Nodes (38): ../../core/models/lock_schedule.dart, ../../core/models/unlock_config.dart, GlobalKey, _addCustomSchedule, _allPrayerKeys, _AppDisplayItem, _buildAppsToLockSection, _buildCustomFocusTimesSection (+30 more)

### Community 16 - "prayer_settings_provider.dart"
Cohesion: 0.09
Nodes (22): _adhanVolume, adjustPreReminder, initialize, _isInitialized, _keySettings, _loadState, masterEnabled, _playOnSilent (+14 more)

### Community 17 - "mosque_service.dart"
Cohesion: 0.07
Nodes (26): @visibleForTesting, dart:io, Duration, _distance, _distanceKm, _extractList, findNearby, _httpClient (+18 more)

### Community 18 - "main_screen.dart"
Cohesion: 0.11
Nodes (19): home/home_screen.dart, createState, _currentIndex, _getHeaderMode, MainScreen, _MainScreenState, _onTabTapped, _openMosqueDetail (+11 more)

### Community 19 - "MosqueProvider"
Cohesion: 0.15
Nodes (19): MosqueProvider, build, _buildContent, _buildLoadingView, createState, initState, MosqueScreen, _MosqueScreenState (+11 more)

### Community 20 - "quran_banner.dart"
Cohesion: 0.13
Nodes (15): _buildAudioButton, _buildContinuousBadge, _buildDefaultContent, _buildExitButton, _buildNowPlayingBadge, _buildNowPlayingContent, createState, _defaultAudioUrl (+7 more)

### Community 21 - "Locked Apps Selection UI - Complete Code Map"
Cohesion: 0.08
Nodes (25): 1. Main Screen: FocusLockConfigScreen, 2. App Selection Dialog (App Picker List UI), 3. FocusLockProvider (State Management), 4. AppDefinition Model, 5. DefaultApps Constants, 6. InstalledAppsService (Platform Bridge), 7. AppConstants (Non-Lockable Packages), 8. Navigation Entry Points to FocusLockConfigScreen (+17 more)

### Community 22 - "hadith_provider.dart"
Cohesion: 0.15
Nodes (12): bool get, HadithModel? get, dispose, _errorMessage, _hadith, _hadithService, _isLoading, loadDailyHadith (+4 more)

### Community 23 - "app_definition.dart"
Cohesion: 0.11
Nodes (18): Color get, int get, color, colorARGB, copyWith, fromJson, hashCode, iconCodePoint (+10 more)

### Community 24 - "theme_provider.dart"
Cohesion: 0.14
Nodes (13): _getPrefsWithRetry, isDarkMode, loadThemePreference, _prefs, _saveThemePreference, setThemeMode, _themeKey, _themeMode (+5 more)

### Community 25 - "qibla_provider.dart"
Cohesion: 0.05
Nodes (36): CompassStatus get, double get, _alignedThresholdDeg, _calibratedAccuracyDeg, _cityName, _currentPosition, dispose, _errorMessage (+28 more)

### Community 26 - "✅ Implementation Complete — All Bugs + Features Delivered"
Cohesion: 0.14
Nodes (13): 🛠️ 3 Minimal Fixes (ponytail-compatible: one guard on shared function + two entrypoint hardening), ✅ Both Bugs Fixed — Validated (all 4 builds passed), 🐛 Bug Fixes (Session 1), Continue Development with Validation, ✅ Implementation Complete — All Bugs + Features Delivered, 📱 Lock Screen Overhaul (Sessions 2–3), 🏗️ Model/Provider API (§3a), 🔌 New Channel (+5 more)

### Community 27 - "../errors/error_messages.dart"
Cohesion: 0.22
Nodes (8): ../errors/error_messages.dart, _apiService, CalendarService, _convertToHijri, dispose, getCalendarByDate, getTodayCalendar, ../models/calendar_model.dart

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
Cohesion: 0.09
Nodes (21): api_service.dart, ApiService, _apiService, _defaultTimezone, dispose, getPrayerTimesByDate, getTodayPrayerTimes, PrayerService (+13 more)

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
Nodes (13): IconData, build, color, icon, isActive, isDark, label, onTap (+5 more)

### Community 39 - "compass_dial.dart"
Cohesion: 0.08
Nodes (25): CustomPainter, CompassStatus, _DoughnutPainter, _PinTailPainter, bearing, build, _buildAccuracyBadge, _buildCardinalLabels (+17 more)

### Community 40 - "📝 Key Updates to [PLAN_2.md](file:///c:/Users/PC-20/Desktop/Code/inav/PLAN_2.md)"
Cohesion: 0.15
Nodes (12): Bugs (Root Cause Analyzed ✅), 🔴 Clarification Questions (Blocking Implementation), Features (Architecture Designed ✅), Graphify Verified Overlay Provider Dependencies, Implementation Roadmap (Bottom of PLAN_2.md), 📝 Key Updates to [PLAN_2.md](file:///c:/Users/PC-20/Desktop/Code/inav/PLAN_2.md), Plan Lock Screen Bug Fixes and Features, Plan Summary (+4 more)

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
Nodes (15): Animation, _buildPrayerStep, _calculateProgress, color, _controller, createState, dispose, _getCircleContent (+7 more)

### Community 82 - "prayer_notification_settings_screen.dart"
Cohesion: 0.12
Nodes (16): class, ../../core/models/prayer_notification_settings_model.dart, _buildAdhanPlaybackCard, _buildHeader, _buildMasterToggleCard, _buildOptionSwitchRow, _buildPlaybackToggleRow, _buildPrayerCard (+8 more)

### Community 83 - "surah_detail_sheet.dart"
Cohesion: 0.12
Nodes (16): build, _buildActionButton, _buildBadge, _buildBadgesRow, _buildDragHandle, _buildHeader, _buildTafsirSection, _buildTranslationRow (+8 more)

### Community 84 - "section_skeleton.dart"
Cohesion: 0.15
Nodes (12): double?, borderRadius, build, children, CircleSkeleton, height, ScreenSkeleton, SectionSkeleton (+4 more)

### Community 85 - "static const String"
Cohesion: 0.17
Nodes (10): AppConstants, kEmergencyNonLockablePackages, version, AppImages, iconDark, iconPath, iconWhite, imagePath (+2 more)

### Community 86 - "ayah_model.dart"
Cohesion: 0.07
Nodes (29): arab, audioUrl, AyahMeta, AyahModel, ayahNumber, AyahSajda, AyahTafsir, fromJson (+21 more)

### Community 89 - "pill_badge.dart"
Cohesion: 0.12
Nodes (15): Color, _animation, backgroundColor, build, color, _controller, createState, dispose (+7 more)

### Community 90 - "qibla_screen.dart"
Cohesion: 0.13
Nodes (19): ../../core/providers/qibla_provider.dart, QiblaProvider, build, _buildContent, _buildLoadingView, createState, _handleAlignmentFeedback, initState (+11 more)

### Community 91 - "PLAN_1 — Locked-app launcher icons + installed-only defaults"
Cohesion: 0.14
Nodes (12): Change, Change (one helper, all callers), Device checks (after implement), Files, Goal, Order, Part 1 — Same icon as Add Apps, Part 2 — Defaults only if installed (+4 more)

### Community 92 - "quran_screen.dart"
Cohesion: 0.14
Nodes (14): build, _buildAllSurahHeader, _buildLoadingState, _buildNoResultsState, createState, initState, _openSurahDetail, QuranScreen (+6 more)

### Community 93 - "nearest_mosque_banner.dart"
Cohesion: 0.17
Nodes (11): build, _buildContent, _buildEmptyContent, isOverridden, mosque, _navigate, NearestMosqueBanner, onResetToNearest (+3 more)

### Community 94 - "package:flutter/material.dart"
Cohesion: 0.08
Nodes (24): app_colors.dart, ../../core/models/qibla_model.dart, AppTheme, darkTheme, lightTheme, build, SettingsScreen, build (+16 more)

### Community 95 - "verse_model.dart"
Cohesion: 0.18
Nodes (10): arabic, ayahNumber, formattedReference, fromCachedJson, fromJson, surahName, surahNumber, toJson (+2 more)

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
Cohesion: 0.13
Nodes (14): _apiService, _cacheHadith, clearCache, dispose, _fetchFromApi, forceRefresh, _getCachedHadith, getDailyHadith (+6 more)

### Community 100 - "mosque_detail_sheet.dart"
Cohesion: 0.15
Nodes (12): ../common/error_state_view.dart, build, _buildBadge, _buildBadgesRow, _buildBottomActions, _buildDetailsSection, _buildDragHandle, _buildHeader (+4 more)

### Community 101 - "qibla_model.dart"
Cohesion: 0.18
Nodes (10): direction, distanceKm, formattedDistance, fromJson, latitude, longitude, QiblaModel, toJson (+2 more)

### Community 102 - "unlock_config.dart"
Cohesion: 0.20
Nodes (9): copyWith, fromJson, method, mindfulPauseSeconds, toJson, UnlockConfig, UnlockMethod, unlockPhrase (+1 more)

### Community 103 - "nearby_mosque_list_tile.dart"
Cohesion: 0.18
Nodes (10): ../../core/models/mosque_model.dart, MosqueModel, build, _buildIcon, _buildTrailing, isSelected, mosque, NearbyMosqueListTile (+2 more)

### Community 104 - "hadith_model.dart"
Cohesion: 0.22
Nodes (8): arabic, fromCachedJson, fromJson, HadithModel, narrator, number, toJson, translation

### Community 105 - "FocusLockProvider"
Cohesion: 0.18
Nodes (12): ../common/async_app_icon.dart, ../../core/providers/focus_lock_provider.dart, FocusLockProvider, build, build, FocusLockCard, _formatNextLockCountdown, build (+4 more)

### Community 106 - "surah_reading_screen.dart"
Cohesion: 0.05
Nodes (40): ItemPositionsListener, ItemScrollController, _arabicBaseFontSize, arabicStyle, ayah, ayahNumberStyle, build, _buildAppBar (+32 more)

### Community 107 - "lock_overlay_screen.dart"
Cohesion: 0.05
Nodes (43): activeLockInfo, blockedAppName, blockedPackageName, build, _buildBlockedAppLabel, _buildBottomButtons, _buildContentCard, _buildHeader (+35 more)

### Community 108 - "lock_schedule.dart"
Cohesion: 0.07
Nodes (29): ActiveLockInfo, copyWith, CustomLockSchedule, customSchedule, durationMinutes, enabled, enabledPrayers, endTime (+21 more)

### Community 109 - "Fix Flutter Platform and Plugin Errors"
Cohesion: 0.08
Nodes (23): 1. Fixed: [settings.gradle.kts](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/android/settings.gradle.kts#L20-L25) — added `com.android.library` plugin version, 1. [pubspec.yaml](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/pubspec.yaml#L118-L128) — Removed stale `plugin: InavNativePlugin` block, 2. Cleaned: [gradle.properties](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/android/gradle.properties#L1-L8) — removed obsolete duplicate, 2. [theme_provider.dart](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/core/theme/theme_provider.dart#L25-L46) — Prefs retry + wider catch, 3. CREATED: [build.gradle.kts](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/packages/inav_launcher/android/build.gradle.kts) — the MISSING file that caused the NPE, 3. [focus_lock_provider.dart](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/core/providers/focus_lock_provider.dart#L68-L152) — Retry + default fallbacks, 4. [accessibility_service_helper.dart](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/core/services/accessibility_service_helper.dart#L36-L143) — Two-layer race fix, 4. CREATED: [AndroidManifest.xml](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/packages/inav_launcher/android/src/main/AndroidManifest.xml) — empty library manifest (+15 more)

### Community 110 - "app_selection_dialog.dart"
Cohesion: 0.07
Nodes (29): ../../core/constants/app_constants.dart, ../../core/constants/default_apps.dart, ../../core/models/app_definition.dart, _allInstalled, _AppFilter, _applyFilters, AppSelectionDialog, _AppSelectionDialogState (+21 more)

### Community 111 - "PrayerProvider"
Cohesion: 0.19
Nodes (21): ChangeNotifier, HadithProvider, PrayerProvider, PrayerSettingsProvider, VerseProvider, build, HomeScreen, _HomeScreenState (+13 more)

### Community 112 - "accessibility_service_helper.dart"
Cohesion: 0.04
Nodes (44): AccessibilityServiceHelper, _accessStreamSubscription, _appOpenedController, _channel, checkAndFireCooldownExpiry, _debounceTimer, dispose, _doSubscribe (+36 more)

### Community 113 - "home_screen.dart"
Cohesion: 0.09
Nodes (23): @pragma, ../../core/providers/hadith_provider.dart, ../../core/providers/prayer_settings_provider.dart, ../../core/providers/streak_provider.dart, ../../core/providers/verse_provider.dart, ../../core/services/accessibility_service_helper.dart, core/services/lock_engine.dart, core/theme/app_theme.dart (+15 more)

### Community 114 - "streak_card.dart"
Cohesion: 0.11
Nodes (21): StreakProvider, initState, _startPrayerPoll, _animationController, build, createState, _currentProgress, didChangeDependencies (+13 more)

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
Nodes (23): ../../core/services/installed_apps_service.dart, dart:typed_data, activityName, AsyncAppIcon, _AsyncAppIconState, build, _bytes, cache (+15 more)

### Community 119 - "StatelessWidget"
Cohesion: 0.14
Nodes (14): _AyahItem, _Badge, _BadgeRow, _FilterChip, _ContentBody, _ContentPageScaffold, _EmptyState, _ErrorState (+6 more)

### Community 120 - "app_exceptions.dart"
Cohesion: 0.24
Nodes (9): Exception, int?, ApiException, isNetworkError, LocationException, message, MosqueServiceException, statusCode (+1 more)

### Community 121 - "VoidCallback"
Cohesion: 0.22
Nodes (8): ../../core/errors/error_messages.dart, build, ErrorStateView, message, onOpenSettings, onRetry, showErrorSnackBar, VoidCallback

### Community 122 - "favorites_sidebar.dart"
Cohesion: 0.25
Nodes (7): ../../core/providers/mosque_provider.dart, build, _buildEmptyState, _buildFavoritesList, _buildFooter, _buildHeader, FavoritesSidebar

### Community 124 - "AppDelegate"
Cohesion: 0.25
Nodes (6): Any, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, AppDelegate, Bool, UIApplication

### Community 125 - "FlutterMacOS"
Cohesion: 0.32
Nodes (4): Cocoa, FlutterMacOS, RunnerTests, XCTest

### Community 126 - "QuranProvider"
Cohesion: 0.14
Nodes (18): ../../core/models/surah_model.dart, ../../core/providers/quran_provider.dart, QuranProvider, build, _loadSurahDetail, _onVisibleItemsChanged, BookmarksSidebar, build (+10 more)

### Community 127 - "package:flutter/foundation.dart"
Cohesion: 0.14
Nodes (14): _channel, DeviceAdminService, isDeviceAdminEnabled, removeDeviceAdmin, requestDeviceAdmin, _channel, getAppUsageTime, getCurrentApp (+6 more)

### Community 128 - "InavLauncherPlugin"
Cohesion: 0.33
Nodes (5): FlutterPlugin, MethodCall, InavLauncherPlugin, Context, MethodChannel

### Community 130 - "ios/RunnerTests/RunnerTests.swift"
Cohesion: 0.24
Nodes (6): Flutter, FlutterSceneDelegate, SceneDelegate, RunnerTests, UIKit, XCTestCase

### Community 131 - "calibration_alert.dart"
Cohesion: 0.18
Nodes (11): AnimationController, _PulsingDot, _PulsingDotState, build, CalibrationAlert, _CalibrationAlertState, _controller, createState (+3 more)

### Community 132 - "BootReceiver"
Cohesion: 0.33
Nodes (4): BootReceiver, Context, Intent, BroadcastReceiver

### Community 133 - "AppDelegate"
Cohesion: 0.47
Nodes (4): FlutterAppDelegate, AppDelegate, Bool, NSApplication

### Community 135 - "RegisterGeneratedPlugins"
Cohesion: 0.33
Nodes (5): FlutterPluginRegistry, FlutterViewController, RegisterGeneratedPlugins(), MainFlutterWindow, NSWindow

### Community 136 - "✅ All Bugs Fixed — All 4 Validations Passed"
Cohesion: 0.33
Nodes (5): ✅ All Bugs Fixed — All 4 Validations Passed, Code Review Result, Continue Debugging Lock Screen Issues, How to test the APKs, ✅ Validation Results

### Community 138 - "../../core/theme/app_colors.dart"
Cohesion: 0.11
Nodes (23): ../../core/theme/app_colors.dart, ../../core/theme/theme_provider.dart, ThemeProvider, build, _buildActions, _buildLeading, _buildLikeButton, _buildMosqueLeading (+15 more)

## Knowledge Gaps
- **1237 isolated node(s):** `AppConstants`, `version`, `kEmergencyNonLockablePackages`, `DefaultApps`, `apps` (+1232 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **33 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PrayerTimesModel` connect `prayer_times_model.dart` to `prayer_provider.dart`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **Why does `MosqueProvider` connect `MosqueProvider` to `mosque_detail_sheet.dart`, `favorites_sidebar.dart`, `../../core/theme/app_colors.dart`, `mosque_provider.dart`, `PrayerProvider`, `main_screen.dart`, `qibla_screen.dart`, `nearest_mosque_banner.dart`, `QuranProvider`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **Why does `FocusLockProvider` connect `FocusLockProvider` to `focus_lock_provider.dart`, `lock_overlay_screen.dart`, `PrayerProvider`, `focus_lock_config_screen.dart`, `home_screen.dart`, `lock_engine.dart`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **What connects `AppConstants`, `version`, `kEmergencyNonLockablePackages` to the rest of the system?**
  _1237 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Flutter Platform` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `prayer_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05714285714285714 - nodes in this community are weakly interconnected._
- **Should `quran_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.041666666666666664 - nodes in this community are weakly interconnected._