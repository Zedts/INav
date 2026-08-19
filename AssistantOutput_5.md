# Debug INav App Issues & Refactor Lock Screen

> **Workspace:** c:\Users\USER\Desktop\Ian\School\Code\Android\inav

---

**User**

i already sent this prompt and it was limit immediately when you try to research, can you continue:

now only 3 bug / error left:
1. when user open INav apps, its working and opening the inav apps BUT the lock screen still there, user must to close it using X button and walaa, its work, its little bit bug not first priorities, and the first priorities is:

2. when user try to close the lock screen using the X button the log says error:E/OpenGLRenderer(17474): EglManager::makeCurrent mED = 0xb400007129051e90, surface = 0x0, mEC = 0xb4000070c90774e0, error = EGL_SUCCESS
I/BufferQueueProducer(17474): [ViewRootImpl[]#15(BLAST Consumer)15](id:444200000014,api:1,p:17474,c:17474) disconnect: api 1
D/View    (17474): [Warning] assignParent to null: this = io.flutter.embedding.android.FlutterView{ed3b94c VFED..... ........ 0,0-1080,2352}
I/flutter (17474): Lock overlay hidden
I/BufferQueueProducer(17474): [SurfaceTexture-0-17474-5](id:444200000015,api:1,p:17474,c:17474) disconnect: api 1
I/BufferQueueConsumer(17474): [SurfaceTexture-0-17474-5](id:444200000015,api:0,p:-1,c:17474) disconnect
I/BLASTBufferQueue(17474): [ViewRootImpl[]#15] destructor()
I/BufferQueueConsumer(17474): [ViewRootImpl[]#15(BLAST Consumer)15](id:444200000014,api:0,p:-1,c:17474) disconnect
I/BLASTBufferQueue(17474): releaseBufferCallbackThunk bufferId:75050258530399 framenumber:2 blastBufferQueue is dead
I/flutter (17474): AccessibilityHelper: Cooldown re-check error: MissingPluginException(No implementation found for method getCurrentApp on channel com.zedt.inav/usage_stats)
This make the lock screen didn't appear again after 3 second cooldown. If you have any recommendation about this features or if you can make it work perfectly fine then lets do it, just deep research about this with perplexity mcp server or tools

3. the timer still didn't shows anything, BUT sometimes its appear, but sometimes no, also if you have any recommendation about this issue like second idea just let me know and lets do it

4. lastly check the theme changer about the lock overlay screen, just remove it and make it only using 1 color, and it was the dark theme. I change idea to this because im sick of this issue of the theme, lets just go with 1 theme only in lock overlay screen.

make the best approach / practices for this, use graphify for removing the theme configuration for the lock screen to make sure it was delete the whole code and make no trace (no unused code).

for context of the conversation session:
this is the last thing `/c:/Users/USER/Desktop/Ian/School/Code/Android/inav/AssistantOutput_4.md`, and earlier is: `/c:/Users/USER/Desktop/Ian/School/Code/Android/inav/AssitantOutput_3.md` then `/c:/Users/USER/Desktop/Ian/School/Code/Android/inav/AssistantOutput_2.md` and `/c:/Users/USER/Desktop/Ian/School/Code/Android/inav/AssistantOutput.md`that make `/c:/Users/USER/Desktop/Ian/School/Code/Android/inav/PLAN_2.md`

now can you make sure to continue the last conversation and tru to fix that 3 bug / error and remove the theme on the lock screen. Take your time to understand the context and the code that i already make, to make sure you're not deviating from the changes that needed. Use tools perplexitiy mcp server, web tools and graphify if needed (to better understand).

**Assistant**

I'll start by understanding the current codebase and previous context, then systematically fix the remaining bugs. Let me first read the context files and explore the relevant code.

Now I have thorough context. Let me read the current state of the key files in the codebase to understand exactly what needs to be fixed. I'll also use graphify to understand the relationships better.

Now let me read the remaining critical files - focus_lock_provider.dart, main.dart, and MainActivity.kt to understand the full picture and confirm my root cause analysis.

Excellent. Now I have complete understanding. Let me do the deep research via Perplexity for Bug 2 as the user requested, and also check lock_engine.dart to understand the full cooldown flow.

Now let me run the Perplexity research for best practices on cross-isolate MethodChannel handling in Flutter, then implement all fixes.

Perfect! The Perplexity research confirms my root cause analysis 100% and recommends exactly the SharedPreferences-based cross-engine "mailbox" approach I planned. Now let me implement all 4 fixes efficiently.

Now implementing Bug 2 fix. The key change is: use SharedPreferences as the cross-engine cooldown "mailbox" (perplexity-recommended), remove the overlay's expiry Timer and the `_usageStatsChannel.getCurrentApp` call that causes MissingPluginException, and make the main isolate's FocusLockProvider tick fire the re-trigger.

Now rewrite `showLockOverlay()` to check the disk-based cooldown via prefs.reload(), and rewrite the two hideWithCooldown methods to use the cross-engine "mailbox" pattern.

Now clean up the `dispose()` method (remove the deleted `_cooldownExpiryTimer` reference) and then hook the cooldown expiry check into FocusLockProvider's main tick timer.

Now I need to fix the race condition in `checkAndFireCooldownExpiry` (overlay isolate must not write the ack) and add the call into FocusLockProvider's tick timer.

Now hook the cooldown expiry check into FocusLockProvider's 1s tick timer, also add the immediate snapshot saves to fix Bug 3 (timer empty).

Now add the cooldown expiry check to the tick timer and fix Bug 3 (timer empty) by saving snapshots immediately after init and after prayer time updates.

Now add the Bug 3 fixes: save snapshot immediately at end of `_loadState()` (if already in a lock window) and after prayer updates, plus fix the `openInavApp()` to also hide the overlay (Bug 1).

Now find and edit the `updatePrayerTimes` method to save a snapshot after updating, then fix the LockEngine to save snapshots immediately at block-time.

Now add on-demand snapshot save to LockEngine (saves at exact moment it decides to block an app, so overlay has fresh data instantaneously on open) and fix Bug 1 by hiding the overlay after `openInavApp()` succeeds.

Now fix Bug 1: `openInavApp()` should hide the overlay window right after launching MainActivity.

Bug 2 (MissingPluginException + X cooldown not re-locking) and Bug 1 (open INav leaves overlay on top) + Bug 3 (timer dash) code edits in. Now let me update the todo list and tackle Item #4: strip all theme-watching code from the overlay.

Let me use graphify to trace all theme-related references in the lock overlay entry points before I strip them.

Good, graph confirms the chain: accessibilityOverlay (main.dart) → ThemeProvider (init) → LockOverlayScreen (reads isDarkMode). Let me now read the actual files to make the surgical theme-removal edits.

Now strip ThemeProvider from the overlay entry in main.dart. Keep only dark theme with no dynamic watcher.

Now strip theme code from LockOverlayScreen. First let me read the top of the file and the _ThemedColors class structure.

Now fix the `build()` method to remove the ThemeProvider watcher and use the fixed dark palette.

All 4 items are now edited. Let me run diagnostics to catch any unused imports or type errors, then run graphify update.

7 warnings, no errors. Let me clean up the `_ThemedColors` unused optional parameter warnings by making fields have hardcoded defaults with a simpler zero-arg constructor.

Zero errors/warnings across all 5 modified files. Now run graphify update as required by workspace rules.

All 4 items are now fixed and verified clean (dart analyze 0 errors/warnings + GetDiagnostics clean on all 5 modified files). Here's a summary of everything changed:

---

## Bug 2 (HIGH PRIORITY — X button `MissingPluginException` + no re-lock after 3s)

### Root cause (two-part, confirmed by Perplexity research):
1. **Dart isolate statics are per-isolate.** There are 2 FlutterEngines (main app + overlay spawned by `flutter_accessibility_service` native plugin). So `_lastCloseCooldownUntil` written by the overlay isolate's X button was invisible to the main isolate's `showLockOverlay` → either instant re-lock or permanent unlock depending on event timing.
2. **MethodChannels are per-BinaryMessenger.** The `com.zedt.inav/usage_stats` handler is registered ONLY on MainActivity's main-engine `binaryMessenger` ([MainActivity.kt L163-194](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/android/app/src/main/kotlin/com/zedt/inav/MainActivity.kt#L163-L194)). The overlay isolate's 3s `Timer` called `_usageStatsChannel.invokeMethod('getCurrentApp')` → no handler on overlay engine → **MissingPluginException** (exactly what you saw in the log) → `_appOpenedController` never re-added the package → blocked app stayed permanently unlocked after the X cooldown.

### Fix (cross-engine SharedPreferences "mailbox" pattern, Perplexity best-practice):
All changes in [accessibility_service_helper.dart](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/core/services/accessibility_service_helper.dart):
- **Removed** `Timer? _cooldownExpiryTimer` and `static const MethodChannel _usageStatsChannel` (the two direct causes of the crash).
- **Added** two new SharedPreferences keys: `_kCooldownRequestKey` and `_kCooldownAckKey`.
- Rewrote `hideLockOverlayWithCooldown()` and `hideLockOverlayWithSkipCooldown()` to **persist a JSON cooldown record** `{id, untilMs, pkg, type}` to disk instead of scheduling an overlay-local Timer. Works correctly from EITHER isolate (both engines share the Android XML SharedPreferences file on disk, with explicit `prefs.reload()` to bypass per-engine Dart in-memory cache).
- Added method `_getRemainingCooldown()`: combines the in-memory `_lastCloseCooldownUntil` static (fast path, same-isolate) WITH a disk read + reload (cross-engine source of truth). `showLockOverlay()` now uses this combined check so both isolates correctly suppress re-show during cooldown.
- Added new public static `checkAndFireCooldownExpiry()`: called every 1s from the FocusLockProvider tick timer but SHORT-CIRCUITS immediately unless `_appOpenedController.hasListener` — this is the "detector-isolate guard" (only the main isolate that called `LockEngine.start()` → `_subscribeToStreams()` → `AccessibilityServiceHelper.onAppOpened.listen()` has a listener). The overlay isolate has `startEngine: false` so this method is a complete no-op for it → **no race condition** where overlay writes the ack before main can fire the event. When cooldown actually expires on the MAIN isolate: it re-emits `pkg` via `_appOpenedController.add(pkg)` → routes through EXISTING `LockEngine._handleAppOpened` pipeline → re-blocks → overlay re-shows automatically.
- Integrated into [FocusLockProvider._startTickTimer()](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/core/providers/focus_lock_provider.dart#L168) (await `AccessibilityServiceHelper.checkAndFireCooldownExpiry()` right after the existing `_prefs?.reload()`).

---

## Bug 1 (LOW — "Open INav" leaves overlay on top of MainActivity)

Fix in [AccessibilityServiceHelper.openInavApp()](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/core/services/accessibility_service_helper.dart#L437-L485): Added `await hideLockOverlay()` after EVERY successful launch path — (1) inav_launcher MethodChannel success, (2) intent:// url_launcher success, (3) legacy focus_lock channel success. Works from overlay isolate because `hideLockOverlay()` no longer early-returns based on the isolate-local `_isOverlayShowing` static (that was fixed in a prior session — it always forwards to `FlutterAccessibilityService.hideOverlayWindow()` which tracks true window state natively).

---

## Bug 3 (HIGH — countdown timer intermittently shows "—")

### Root cause:
`ActiveLockInfo` snapshot was saved ONLY every 5th tick (5s intervals). If the overlay opened during:
- The first 0–5 seconds of app life after a fresh boot, OR
- The first 0–5 seconds after `PrayerProvider.updatePrayerTimes()` injected new prayer times, OR
- A new app was blocked by `LockEngine._handleAppOpened()` (which calls `showLockOverlay()` immediately, without waiting for the next 5s tick save)

…then `getActiveLockInfo()` in the overlay isolate would read a stale/null snapshot → return null → header shows '—'.

### Fix (3 on-demand snapshot saves):
1. In [FocusLockProvider._loadState()](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/core/providers/focus_lock_provider.dart#L151-L163): saves a snapshot immediately on boot if `isInLockWindow()` is true.
2. In [FocusLockProvider.updatePrayerTimes()](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/core/providers/focus_lock_provider.dart#L542-L561): saves a snapshot immediately whenever prayer times are injected AND we're inside a lock window.
3. In [LockEngine._handleAppOpened()](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/core/services/lock_engine.dart#L80-L108): calls new public wrapper `saveActiveLockSnapshotNow()` **RIGHT BEFORE** `showLockOverlay()` — guarantees the overlay's `_loadState` sees a valid snapshot even if it starts mid-lock before any periodic tick.
4. Added public wrapper in FocusLockProvider: `Future<void> saveActiveLockSnapshotNow() => _saveActiveLockSnapshot();` (Dart's `_` private is library-level, not package-level; LockEngine lives in a different library in `lib/core/services/` vs FocusLockProvider in `lib/core/providers/`, so cross-library access needs a public surface).

---

## Item #4 (MEDIUM — remove ALL dynamic theming from lock overlay; keep dark-only)

Two files changed. The chain `accessibilityOverlay() creates ThemeProvider → MaterialApp wrapped in Consumer<ThemeProvider> → LockOverlayScreen.build() context.watch<ThemeProvider>() → _ThemedColors.resolve(isDark)` was **completely removed and replaced with fixed dark palette.**

### [lib/main.dart accessibilityOverlay()](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/main.dart#L81-L173):
- **Removed** `final themeProvider = ThemeProvider();` + `await themeProvider.loadThemePreference()` (10 lines of async init — saves startup time in the overlay isolate too).
- **Removed** `ChangeNotifierProvider.value(value: themeProvider)` from MultiProvider providers list.
- **Removed** `Consumer<ThemeProvider>(builder: (context, tp, _) => MaterialApp(...))` wrapper entirely. MaterialApp is now a direct child of MultiProvider.
- **Fixed** MaterialApp to: `theme: AppTheme.darkTheme(), darkTheme: AppTheme.darkTheme(), themeMode: ThemeMode.dark` — both slots = dark, mode forced to dark so it can never flip to light even if system brightness is light.

### [lib/screens/lock_overlay_screen.dart](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/screens/lock_overlay_screen.dart):
- **Removed** `import '../core/theme/theme_provider.dart';` (no import = no dependency trace).
- **Rewrote `_ThemedColors`**: Deleted the factory `_ThemedColors.resolve(bool isDark)` that had both light + dark branches. Fields are now final with **direct hardcoded `AppColors.*Dark` defaults** (`surfaceDark`, `cardDark`, `textMainDark`, `textMutedDark`, `hairlineDark`, `primaryDark`, `roseAccent`). Constructor is `const _ThemedColors();` with zero args. This guarantees NO code path anywhere in lock overlay can ever resolve a light color — `AppColors.surfaceLight` etc are literally not referenced in the overlay anymore.
- **Rewrote build()**: Removed the 3-line `isDark` calculation that was double-watching ThemeProvider (`context.watch<ThemeProvider>().themeMode == ThemeMode.system ? MediaQuery.platformBrightness : context.watch<ThemeProvider>().isDarkMode`). Replaced with single `const colors = _ThemedColors();`. No ThemeProvider in the widget tree for this route = no chance of "used before being inserted" cross-engine bugs.

---

### Verification
All 5 modified files pass with **0 errors and 0 warnings** on both `dart analyze` and VS Code GetDiagnostics:
- [main.dart](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/main.dart)
- [accessibility_service_helper.dart](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/core/services/accessibility_service_helper.dart)
- [focus_lock_provider.dart](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/core/providers/focus_lock_provider.dart)
- [lock_engine.dart](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/core/services/lock_engine.dart)
- [lock_overlay_screen.dart](file:///c:/Users/USER/Desktop/Ian/School/Code/Android/inav/lib/screens/lock_overlay_screen.dart)

Graphify MCP server's read-only tools were used at the start to confirm the dependency chain (accessibilityOverlay → ThemeProvider → _ThemedColors → build methods), and `npx graphify-cli update .` is not available locally (package not on npm) so the graph-out files will be slightly stale, but the workspace AGENTS.md explicitly says "Dirty graphify-out/ files are expected after hooks or incremental updates — dirty graph files are not a reason to skip."

---

**User**

YEAH all fixes and dont have any more bugs, now i need you to make the add apps have more selection apps, just like "adb shell pm list packages" that shows ALL of the apps installed on user devices so user can make sure they can 100% custom what apps they want to lock.

deep research about this using mcp perplexity and web tools and make the best approach / practices to make sure that the list of the apps showing all the installed apps on user devices just like when i try to run "adb shell pm list packages".

**Assistant**

Let me start by doing deep research via Perplexity MCP about listing all installed Android apps, and simultaneously read the current code that handles the "add locked apps" flow.

Excellent research from Perplexity. Now let me read the current add-apps UI and locked-apps flow to understand the existing architecture.

I'll search for all the key terms you mentioned across the codebase. Let me run several parallel searches to find the relevant files and code.

Good, I found the key files. Now let me read all the relevant source files in detail.

Let me also check the navigation entry points, the focus_lock_card widget, and the installed apps service for the complete flow.

Let me also check the settings screen for additional navigation routes and the app constants file.

Now I have all the relevant information. Here is a complete structured report of the locked apps selection UI and related code.

---

## Locked Apps Selection UI - Complete Code Map

### 1. Main Screen: FocusLockConfigScreen

**File:** `c:\Users\USER\Desktop\Ian\School\Code\Android\inav\lib\screens\settings\focus_lock_config_screen.dart`

| Item | Details |
|---|---|
| **Widget class** | `FocusLockConfigScreen` (StatefulWidget, line 15-20) |
| **State class** | `_FocusLockConfigScreenState` (line 22) |

#### Key Functions / Lines in FocusLockConfigScreen:

- **`_showAddAppsDialog()` (lines 40-50)** -- Opens the app selection dialog.
  - Line 41-44: Calls `showDialog<AppDefinition>()` with `AppSelectionDialog(currentlyLockedApps: provider.lockedApps)`
  - Line 48: On result, calls `provider.addLockedApp(result)`

- **`_buildAppsToLockSection()` (lines 783-948)** -- Renders the "APPS TO LOCK" UI section.
  - Lines 811-833: **"Add Apps" button** (`ElevatedButton.icon`) at top-right of the section.
    - Line 812: `onPressed: () => _showAddAppsDialog(provider)`
    - Line 814: Label: `const Text('Add Apps')`
  - Lines 838-945: Container/card listing all locked apps.
  - Lines 856-943: Iterates `appItems` list, renders each app with:
    - Icon (colored circle, lines 877-885)
    - App name + package name subtitle (lines 887-912)
    - `Switch.adaptive` toggle (lines 914-937) calling `provider.toggleLockedApp(target, value)`

- **`_resolveAppDefinition()` (lines 950-962)** -- Converts internal `_AppDisplayItem` to `AppDefinition` model.
  - Line 951: First checks `DefaultApps.getApp(app.packageName)` for known defaults.
  - Lines 953-961: Falls back to constructing a new generic `AppDefinition`.

- **appItems building (lines 330-371)** -- Builds the list shown in the UI:
  - Lines 331-347: Maps `provider.lockedApps` into `_AppDisplayItem` objects.
  - Lines 357-371: Sorts with Instagram/TikTok/YouTube pinned first.

---

### 2. App Selection Dialog (App Picker List UI)

**File:** `c:\Users\USER\Desktop\Ian\School\Code\Android\inav\lib\widgets\dialogs\app_selection_dialog.dart`

| Item | Details |
|---|---|
| **Widget class** | `AppSelectionDialog` (StatefulWidget, lines 10-17) |
| **Parameter** | `currentlyLockedApps: List<AppDefinition>` -- used to exclude already-locked apps from the picker list |

#### Key Functions / Lines:

- **`_loadApps()` (lines 32-144)** -- Loads and merges installed apps with default app definitions.
  - Line 35: `InstalledAppsService.getInstalledApps()` fetches real installed apps via platform channel.
  - Lines 37-97: Merges installed apps with `DefaultApps.apps.values` (enriches icons/colors for known apps).
    - Lines 44-48: Skips emergency/non-lockable packages (`AppConstants.kEmergencyNonLockablePackages`).
    - Lines 51-97: For each default app, resolves aliases (e.g., TikTok `com.ss.android.ugc.trill` vs `com.zhiliaoapp.musically`) and merges icon/color metadata.
  - Lines 99-114: Filters out any apps already in `currentlyLockedApps` (by packageName and aliases).
  - Lines 116-137: Sorts result with Instagram/TikTok/YouTube pinned first, then alphabetical by name.

- **`_filterApps()` (lines 146-158)** -- Search filter by app name (case-insensitive, substring match).

- **`build()` UI (lines 167-305)** -- The dialog layout:
  - Lines 178-212: Header with `Icons.apps` icon, title "Select Apps to Lock", close button.
  - Lines 215-247: Search TextField (`hintText: 'Search apps...'`).
  - Lines 252-299: `ListView.builder` of filtered apps, or loading spinner, or empty state.

- **`_buildAppItem()` (lines 307-371)** -- Single tappable app row.
  - Line 309: `onTap: () => Navigator.pop(context, app)` -- returns selected `AppDefinition` to the caller.
  - Lines 316-329: Generic `Icons.apps` icon in a rounded colored container.
  - Lines 335-358: App name (line 336) and package name subtitle (line 349).
  - Lines 362-366: `Icons.add_circle_outline` trailing icon.

---

### 3. FocusLockProvider (State Management)

**File:** `c:\Users\USER\Desktop\Ian\School\Code\Android\inav\lib\core\providers\focus_lock_provider.dart`

| Item | Details |
|---|---|
| **Class** | `FocusLockProvider with ChangeNotifier` (line 18) |
| **State field** | `List<AppDefinition> _lockedApps = []` (line 41) |
| **Getter** | `List<AppDefinition> get lockedApps => List.unmodifiable(_lockedApps)` (line 55) |

#### Key Functions:

- **`addLockedApp(AppDefinition app)` (lines 385-391)**
  - Line 386: Checks `!_lockedApps.contains(app)` (no duplicates).
  - Line 387: Adds to list.
  - Line 388: Calls `_saveLockedApps()` to persist.
  - Line 389: `notifyListeners()`.

- **`removeLockedApp(AppDefinition app)` (lines 394-398)**
  - Line 395: Removes from list.
  - Line 396: Persists. Line 397: Notifies.

- **`toggleLockedApp(AppDefinition app, bool locked)` (lines 401-407)**
  - Line 402-403: If `locked==true`, calls `addLockedApp(app)`.
  - Line 404-405: Else calls `removeLockedApp(app)`.

- **`_saveLockedApps()` (lines 410-415)**
  - Lines 411-413: JSON-encodes `_lockedApps` via `AppDefinition.toJson()`.
  - Line 414: Writes to `SharedPreferences` key `_keyLockedApps` (`'focus_lock_locked_apps'`).

- **`_loadState()` / default apps init (lines 285-303)**
  - Lines 291-303: Loads from SharedPreferences, or defaults to `DefaultApps.defaultPackages` (Instagram, TikTok, YouTube) on first run.

- **`shouldBlockApp(String packageName)` (lines 509-524)**
  - Line 512: Skips if package is in `kEmergencyNonLockablePackages`.
  - Line 516: Skips if emergency is on and app is an essential whitelisted app (dialer/SMS).
  - Line 520: Checks `_lockedApps.any((app) => app.matchesPackage(packageName))`.
  - Line 523: Only blocks if `isInLockWindow()` is also true.

---

### 4. AppDefinition Model

**File:** `c:\Users\USER\Desktop\Ian\School\Code\Android\inav\lib\core\models\app_definition.dart`

| Item | Details |
|---|---|
| **Class** | `class AppDefinition` (line 4) |

**Fields (lines 5-13):**
- `packageName: String` (Android package, primary key)
- `packageAliases: List<String>?` (e.g., TikTok has multiple package names)
- `name: String` (display name)
- `iconCodePoint: int` / `iconFontFamily: String?` / `iconFontPackage: String?` / `iconMatchTextDirection: bool` (Flutter IconData serialization)
- `colorARGB: int` (app accent color; getter `Color get color => Color(colorARGB)` at line 15)
- `isDefault: bool` (whether it ships with DefaultApps)

**Key methods:**
- `matchesPackage(String candidate)` (lines 29-35) -- matches by `packageName` or any alias.
- `toJson()` / `fromJson()` (lines 37-66) -- serialization for SharedPreferences.
- `operator ==` and `hashCode` (lines 91-99) -- uses only `packageName`, so list membership checks treat same package as equal.

---

### 5. DefaultApps Constants

**File:** `c:\Users\USER\Desktop\Ian\School\Code\Android\inav\lib\core\constants\default_apps.dart`

| Item | Details |
|---|---|
| **Class** | `class DefaultApps` (line 4) |

**`Map<String, AppDefinition> apps` (lines 5-37) -- 3 pre-configured default apps:**

| Package | Name | Icon | Color | Notes |
|---|---|---|---|---|
| `com.instagram.android` | Instagram | `Icons.photo_camera` | `0xFFD946EF` (magenta) | |
| `com.ss.android.ugc.trill` | TikTok | `Icons.music_note` | `0xFF475569` (slate) | alias: `com.zhiliaoapp.musically` |
| `com.google.android.youtube` | YouTube | `Icons.play_circle_filled` | `0xFFEF4444` (red) | |

**Static helpers:**
- `getApp(String packageName)` (lines 39-46) -- direct lookup + alias scan.
- `isDefaultApp(String packageName)` (lines 48-50).
- `defaultPackages` getter (line 52) -- `apps.keys.toList()`.
- `createGenericApp(String packageName, String appName)` (lines 54-64) -- factory for unknown apps (grey `Icons.apps`, `0xFF64748B`).
- `essentialAppsWhitelist` (lines 66-73) -- dialer & SMS packages that bypass lock when emergency is enabled.
- `isEssentialApp(String packageName)` (lines 75-76).

---

### 6. InstalledAppsService (Platform Bridge)

**File:** `c:\Users\USER\Desktop\Ian\School\Code\Android\inav\lib\core\services\installed_apps_service.dart`

| Item | Details |
|---|---|
| **Class** | `class InstalledAppsService` (line 5) |
| **Method channel** | `MethodChannel('com.zedt.inav/apps')` (line 6) |

- **`getInstalledApps({includeSystemApps = false})` (lines 8-34)**
  - Invokes native method `'getInstalledApps'`.
  - Returns `List<AppDefinition>` with generic `Icons.apps` icon + grey color (enrichment happens in AppSelectionDialog).

- **`searchApps(String query)` (lines 36-50)** -- wrapper that filters `getInstalledApps()` by name.

- **`getAppInfo(String packageName)` (lines 52-73)** -- single-app lookup via native `'getAppInfo'`.

---

### 7. AppConstants (Non-Lockable Packages)

**File:** `c:\Users\USER\Desktop\Ian\School\Code\Android\inav\lib\core\constants\app_constants.dart`

- **Line 5:** `static const Set<String> kEmergencyNonLockablePackages` -- system-level packages that can NEVER be added to locked apps. Used as a filter in `AppSelectionDialog._loadApps()` (lines 45, 55-57, 76-77, 93) and `FocusLockProvider.shouldBlockApp()` (line 512).

---

### 8. Navigation Entry Points to FocusLockConfigScreen

**File:** `c:\Users\USER\Desktop\Ian\School\Code\Android\inav\lib\widgets\home\focus_lock_card.dart`

| Item | Details |
|---|---|
| **Widget class** | `FocusLockCard` (StatelessWidget, line 12) |
| **Navigation (lines 72-78)** | `InkWell` on the entire card. On tap: `Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusLockConfigScreen()))` |

This is the **sole navigation route** discovered to `FocusLockConfigScreen` -- the Focus Lock summary card on the home screen.

---

### 9. "Add App" Button Navigation Flow (Summary)

```
Home Screen tap FocusLockCard
  -> Navigator.push -> FocusLockConfigScreen
       -> User taps "Add Apps" button (line 811-833 in _buildAppsToLockSection)
            -> _showAddAppsDialog(provider) (line 40)
                 -> showDialog -> AppSelectionDialog(currentlyLockedApps: provider.lockedApps)
                      -> User taps an app row (line 309: Navigator.pop(context, app))
                           -> provider.addLockedApp(result) (line 48)
                                -> _saveLockedApps() -> SharedPreferences persist + notifyListeners
                                     -> UI rebuilds with updated appItems list
```

Now let me read the actual native implementation and the Dart service + dialog to understand the exact state of what's currently there.

Now let me read the MainActivity.kt to see the current native MethodChannel handler for 'getInstalledApps'.

Now I understand the root cause. The existing native `getInstalledApps()` has TWO filters that make it NOT equivalent to `adb shell pm list packages`: (1) drops every package without a launchable MAIN/LAUNCHER intent (Settings/SystemUI/dialer/etc are already in a blacklist), (2) no `QUERY_ALL_PACKAGES` permission in manifest means Android 11+ visibility filter hides even more. Also the Dart service defaults `includeSystemApps: false` (but the param was ignored native-side anyway).

Let me implement the complete fix: manifest permission → upgraded native `getInstalledApps` with Perplexity-recommended compat APIs → richer Dart service → UI with filter toggles + package search.

Now rewrite the native MethodChannel handler in MainActivity.kt using the Perplexity-recommended pattern: executor off main thread, compat typed flags for Android 33+, getInstalledApplications() (no more launch-intent-only filter), launcher-activity enrichment for best labels, rich metadata, lazy separate icon endpoint with PNG drawable→bitmap serialization.

Native side done. Now upgrade the Dart service to capture all the rich metadata and add a `getAppIcon()` method.

Now rewrite the AppSelectionDialog to use the new `InstalledAppInfo` wrapper, add filter chips (All / Launchable / User-only), search both name and package name, and lazily load real app icons via `MemoryImage`.

Now let me run dart analyze + GetDiagnostics to verify everything is clean.

---

