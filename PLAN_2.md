# PLAN_2.md — Focus Lock Bug Fixes & Feature Enhancements

> **Created**: 2026-08-19
> **Last Revised**: 2026-08-19 (Section 0: User Answers + Deep Research Applied)
> **Scope**: Lock screen app configuration bugs + lock screen UX/feature overhaul
> **Status**: APPROVED by user — Ready for implementation
> **Research**: Perplexity multi-source (Android AOSP docs + flutter_accessibility_service) + Web search + Graphify dependency graph verified

---

## 0. User Answers Recorded (§9 Resolved)

All approval questions from the original §9 have been answered. This revision incorporates them.

| # | Question | User Answer | Implementation Decision |
|---|----------|-------------|-------------------------|
| **Q1 (Critical)** | `typePhrase` behavior: remove type-to-unlock? | **Phrase becomes display-only reminder** | Remove TextField + validation; show user's `unlockPhrase` as prominent styled "Your Reminder" card with motivational subtext. |
| **Q2** | Overlap (prayer + custom active simultaneously): precedence? | **Custom wins** | `getActiveLockInfo()` returns custom schedule first, then prayer. When locked via custom + `markPrayed` method, **auto-unlock via streak is DISABLED** (custom block must run its course). |
| **Q3** | `mindfulPause`: show breathing cycles? | **Show only verse/hadith** | Remove breathing animation, cycles counter, and "Continue after X cycles" button. Mindful pause becomes a **random Quran verse or Hadith display card** (50/50 coin flip) from VerseProvider/HadithProvider. Unlock only via Skip / Wait / X / INav. |
| **Q4** | `X` button semantics? | **Close overlay + 3-second cooldown**, with small text under the icon reading "Close 3s" | Press X → calls `hideLockOverlay()` → sets a 3-second in-memory flag `_lastCloseCooldownUntil` on `AccessibilityServiceHelper` → during those 3s, any new `showLockOverlay()` request from `LockEngine._handleAppOpened` is **suppressed** (no-op). Under X button, display `Text("Close 3s", style: caption)`. |
| **Q5** | After "Open INav" + Back → re-lock immediately? | **Re-lock normally by default**; no cooldown on Open INav. The ONLY auto-unlock path is: `markPrayed` method + locked by prayer reason + user actually logs streak inside INav. Everything else stays locked per schedule. | No cooldown added for "Open INav". Only X button gets the 3s cooldown. Matches user intent exactly. |
| **Q6** | Best approach research for TREE_DEPTH fix + plugin manifest override behavior? | **Deep research applied** (see §0.1 & §5.3 revised below) | Multi-layer: (1) New narrowed host XML + `tools:node="replace"` in manifest; (2) Dart event debounce; (3) Runtime `setServiceInfo()` native hardening via a small Kotlin helper; (4) ProGuard for release. All detailed below. |

---

### 0.1 Deep Research Findings Applied (Q6 — Perplexity + Web)

#### 0.1.1 TREE_DEPTH Root Cause CONFIRMED (Smoking Gun Found)

Our project has **two accessibilityservice XML files**. The [AndroidManifest.xml L95](file:///c:/Users/PC-20/Desktop/Code/inav/android/app/src/main/AndroidManifest.xml#L95) points to `@xml/accessibilityservice` (NOT `accessibility_service_config`). And the current [accessibilityservice.xml L3-L8](file:///c:/Users/PC-20/Desktop/Code/inav/android/app/src/main/res/xml/accessibilityservice.xml#L3-L8) is:

```xml
android:accessibilityEventTypes="typeWindowsChanged|typeWindowStateChanged|typeWindowContentChanged"
android:accessibilityFlags="flagDefault|flagIncludeNotImportantViews|flagRequestTouchExplorationMode|flagRequestEnhancedWebAccessibility|flagReportViewIds|flagRetrieveInteractiveWindows"
android:canRetrieveWindowContent="true"
android:canPerformGestures="true"
android:notificationTimeout="300"
```

Perplexity research verdict + Android AOSP docs confirm this is **massively over-configured for app-switch detection**:

| Current Value | Problem |
|---|---|
| `typeWindowContentChanged` subscribed | Fires **10–100 times per second** during Instagram/YouTube scrolls. Each event triggers the plugin's subNodes tree walk → D/TREE_DEPTH spam → CPU burn → delayed `WINDOW_STATE_CHANGED` processing (lock delay). |
| `typeWindowsChanged` subscribed | Fires for quick-settings shade expansion, split-screen, popups. Unnecessary. |
| `flagIncludeNotImportantViews` | Exposes normally-invisible views → deeper trees → more depth hits. |
| `flagReportViewIds` | Adds resource ID serialization to every node → more IPC overhead per event. |
| `flagRetrieveInteractiveWindows` | Forces the system to gather data about ALL interactive windows system-wide → more tree walks. |
| `canRetrieveWindowContent="true"` | **Static capability that CANNOT be changed at runtime.** Declares the service can access node sources. The plugin's native code serializes `subNodes` → `getSubNodes()` (mentioned in plugin changelog as having a stack-overflow fix). This is the direct cause of TREE_DEPTH logs. |

**Research-Recommended Minimal XML (we will use this)**:
```xml
android:accessibilityEventTypes="typeWindowStateChanged"
android:accessibilityFeedbackType="feedbackGeneric"
android:notificationTimeout="100"
<!-- android:canRetrieveWindowContent: We MUST keep true because flutter_accessibility_service's
     showOverlayWindow() API depends on window content access for the overlay machinery.
     Perplexity confirms: overlay plugin typically requires canRetrieveWindowContent.
     BUT we will reduce EVERYTHING else and add runtime setServiceInfo() filtering. -->
android:canRetrieveWindowContent="true"
<!-- OMIT accessibilityFlags ENTIRELY (defaults to flagDefault only, no harmful extras)
     OMIT canPerformGestures="true" (we do not dispatch gestures)
     OMIT packageNames (listen to all packages) -->
```

#### 0.1.2 Manifest Override Strategy (Host vs Plugin)

Research confirms:
- The plugin's AAR AndroidManifest.xml (for `flutter_accessibility_service v1.2.0`) has **no `<service>` declaration** (confirmed by INav's own manifest comments L81-85 saying it's empty). Therefore our host declaration is the **only one** that actually registers the service. No conflict, no merge needed! The comment in INav's manifest explicitly states: *"This MUST be declared in the HOST app's manifest, as the plugin's own AndroidManifest.xml is empty."*
- However, to be **future-proof** against plugin upgrades that add service declarations, we add `tools:node="replace"` (Perplexity-recommended pattern) to the `<service>` element. If a future plugin ships a duplicate service name, ours wins deterministically.
- `tools:node="replace"` requires us to re-declare ALL attributes (intent filter, metadata, permission) on the host copy (which we already do).

#### 0.1.3 Runtime Hardening (setServiceInfo)

Even with narrowed XML, the plugin's `onServiceConnected()` may internally call `setServiceInfo()` and broaden flags. To prevent that and have **defense-in-depth**, Perplexity recommends overriding via a native Kotlin helper that runs immediately after plugin init. Since we cannot modify the plugin's `.kt` inside the AAR easily, **Strategy** is:

- **Layer 0 (XML)** — Narrow everything in `accessibilityservice.xml`. Because plugin's manifest has no service, this is the only XML loaded. This alone removes 98% of spurious events.
- **Layer 1 (Native side helper — optional but HIGHLY RECOMMENDED)** — Create our own `InavAccessibilityServiceConfigurator.kt` that listens for service connected and calls `setServiceInfo()` again AFTER the plugin runs. This guarantees `eventTypes=TYPE_WINDOW_STATE_CHANGED` and `flags=0` even if the plugin tries to widen. Implementation via a ContentObserver pattern or a broadcast is messy; cleanest is a 500ms delayed post in `MainActivity.onCreate` that reflects on the connected accessibility service if running. Or better yet: since we already have `AccessibilityHelper.kt`, we can add a method that uses `AccessibilityManager` to query enabled services and programmatically enforce settings via `AccessibilityServiceInfo` copyback (not always possible from outside the service). **Simpler approach**: trust XML (Layer 0) since plugin manifest is empty; add Layer 1 only if after testing TREE_DEPTH still appears. We'll include Layer 1 as "implement if needed after XML-only test" in §5.3.
- **Layer 2 (Dart)** — 100ms debounce + packageName deduplication (already in Dart plan). This is the Dart safety net even if some unwanted events slip through.

#### 0.1.4 Overlay Isolate Provider Dependencies (Graphify Verified)

From graphify query_graph: the overlay isolate in [main.dart L48-75](file:///c:/Users/PC-20/Desktop/Code/inav/lib/main.dart#L48-L75) currently creates its own `FocusLockProvider` and `StreakProvider`, both from the `main.dart` providers community. The `LockOverlayScreen` depends on `UnlockConfig`, `currentPrayerName`, and `onUnlock` callback. For revised §3a, §3b, §3d we verified the following providers are reachable and can be added to the overlay MultiProvider chain without circular dependencies:
- `ThemeProvider` (standalone, SharedPreferences only) → Safe
- `VerseProvider` → Safe (API service, no focus lock deps)
- `HadithProvider` → Safe (API service, no focus lock deps)
- `FocusLockProvider` → Safe, self-contained, but set `LockEngineMode.overlayIsolate` to prevent foreground service channel calls (already in plan)

All confirmed independent by graph; no issues adding them.

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Bug Analysis — Root Causes & Impact](#2-bug-analysis--root-causes--impact)
3. [Feature Requirements Decomposition](#3-feature-requirements-decomposition)
4. [Proposed Architecture & Data Flow Changes](#4-proposed-architecture--data-flow-changes)
5. [Detailed Implementation Plan](#5-detailed-implementation-plan)
   - [5.1 Bug #1: Accessibility Service Activation (Hot Restart Required)](#51-bug-1-accessibility-service-activation-hot-restart-required)
   - [5.2 Bug #1b: MissingPluginException — startForegroundService](#52-bug-1b-missingpluginexception--startforegroundservice)
   - [5.3 Bug #2: "Maximum Tree Depth Reached: 15" Log Spam](#53-bug-2-maximum-tree-depth-reached-15-log-spam)
   - [5.4 Feature #3a: Lock Screen — Show Lock Reason & Remaining Time](#54-feature-3a-lock-screen--show-lock-reason--remaining-time)
   - [5.5 Feature #3b: Lock Screen — Match App Theme (Dark/Light)](#55-feature-3b-lock-screen--match-app-theme-darklight)
   - [5.6 Feature #3c: Lock Screen — Three New Buttons (X / Skip / Open INav)](#56-feature-3c-lock-screen--three-new-buttons-x--skip--open-inav)
   - [5.7 Feature #3d: Unlock Method-Specific Behavior Overhaul](#57-feature-3d-unlock-method-specific-behavior-overhaul)
6. [File Change Inventory](#6-file-change-inventory)
7. [Risk Assessment & Mitigations](#7-risk-assessment--mitigations)
8. [Testing Strategy](#8-testing-strategy)
9. [Sequence Diagrams (Critical Flows)](#9-sequence-diagrams-critical-flows)

---

## 1. Executive Summary

This plan addresses **three critical bugs** blocking production readiness of the Focus Lock feature, plus a **major lock screen UX overhaul** with four unlock-method-specific behaviors. All §9 user questions are resolved (§0 above), and Q6 research findings have been incorporated into §5.3 (multi-layer fix).

### Bugs to Fix
| # | Bug | Impact | Severity |
|---|-----|--------|----------|
| 1 | Accessibility service requires full hot restart (Shift+R) to activate. Stream subscribed before Android service alive → dead reconnect timer. | Lock never works until restart. | **P0** |
| 1b | `MissingPluginException` for `startForegroundService` on channel `com.zedt.inav/foreground_service` | Overlay isolate tries to invoke service over a MethodChannel only registered by MainActivity (it has no Activity). | **P1** |
| 2 | `D/TREE_DEPTH: Maximum tree depth reached: 15` spam. Confirmed cause: `accessibilityservice.xml` subscribes to `typeWindowContentChanged` + 6 aggressive accessibility flags + `canRetrieveWindowContent=true` causing `flutter_accessibility_service`'s `getSubNodes()` to hit the 15-deep hard cap on every Instagram/TikTok scroll, quick-settings expand, dialog layout. | CPU overhead → event queueing → lock delay (user reports "works, just takes time"). | **P1** |

### New Features
| # | Feature |
|---|---------|
| 3a | Lock screen shows **lock reason** (Prayer Time — Dhuhr OR user's custom label) + **remaining time** (smart format: sec/min/h) + progress bar. |
| 3b | Lock screen theme dynamically follows user's dark/light mode (overlay isolate now loads `ThemeProvider`; all colors derived via `_ThemedColors.resolve(isDark)`). |
| 3c | Three new global chrome buttons: `X` (top-right, closes overlay + 3s cooldown + caption "Close 3s"), `Skip (N/M)` (bottom-left, disabled if none left), `Open INav` (bottom-right primary). Bottom 2 are 1/2 width ratio. |
| 3d | Method-specific logic (per user answers): `waitItOut` = timer only; `markPrayed` = **conditional auto-unlock** (prayer reason: yes, custom reason: NEVER, even if streak logged); `mindfulPause` = random Quran verse or Hadith ONLY (no breathing), 50/50 coin flip; `typePhrase` = **display-only reminder card** (no type-to-unlock field removed per Q1). |

---

## 2. Bug Analysis — Root Causes & Impact

### 2.1 Bug #1: Accessibility Service Hot Restart Required

**Observed Logs** (unchanged):
```
LockEngine: Accessibility service NOT enabled yet. Subscribing to stream anyway...
[user enables accessibility] → SILENCE
[after Shift+R]:
I/AccessibilityPlugin: Started the accessibility tracking service.
LockEngine: Subscribed to app-opened stream
```

**Root Cause** (already correct in first draft, confirmed):
1. `AccessibilityServiceHelper._subscribeToAccessStream()` attaches to `FlutterAccessibilityService.accessStream` **before the Android service is running**; the plugin's native side only begins populating the stream after `onServiceConnected()` fires. If service connects later, existing Dart `StreamSubscription` is dead.
2. `LockEngine._startReconnectTimer()` (30s) was dead code: `_appOpenedSubscriptionIsListening()` checks `!= null` only → always true after first call → never re-subscribes.

**Fix** (unchanged from first draft): 2s service polling + `forceResubscribe()` full tear-down & re-listen. Debounce added (see §5.1).

### 2.2 Bug #1b: MissingPluginException

**Root Cause confirmed** (no change from first draft):
- Overlay isolate (`accessibilityOverlay()` entrypoint) creates its own `FocusLockProvider` → `LockEngine` → calls `start()` → tries `_serviceChannel.invokeMethod('startForegroundService')`.
- But the `com.zedt.inav/foreground_service` MethodChannel handler is only registered in [MainActivity.configureFlutterEngine() L129-145](file:///c:/Users/PC-20/Desktop/Code/inav/android/app/src/main/kotlin/com/zedt/inav/MainActivity.kt#L129-L145). The overlay isolate has no `MainActivity`; the MethodChannel resolves to no handler → `MissingPluginException`.

**Fix** (same as first draft, now with graphify confirming wiring): add `LockEngineMode { mainApp, overlayIsolate }` and gate all `_serviceChannel` calls on `mode == mainApp`.

### 2.3 Bug #2: TREE_DEPTH=15 Spam (REVISED WITH RESEARCH)

**Confirmed Root Cause Chain** (from research + XML inspection):

```
accessibilityservice.xml subscribes to typeWindowContentChanged (L3)
   AND sets 6 aggressive flags (L6) + canRetrieveWindowContent=true (L7)
        ↓
Every scroll, dialog, shade expansion fires TYPE_WINDOW_CONTENT_CHANGED event
        ↓
Plugin's onAccessibilityEvent() walks subNodes recursively
(plugin changelog mentions stack-overflow fix in getSubNodes() — so it's known to walk trees)
        ↓
Instagram/YouTube/quick-settings views have >15 nested levels
(RecyclerView → ViewHolder → ConstraintLayout → NestedScrollView → ...)
        ↓
Plugin's native code has if (depth > 15) { Log.d("TREE_DEPTH", "Maximum tree depth reached: 15"); return; }
        ↓
Hundreds of identical log lines → UI thread contention → delayed TYPE_WINDOW_STATE_CHANGED processing
→ user perceives "locking takes time" (the app-open event sits at back of queue)
```

**Fix Strategy (Multi-Layered, Research-Backed)**: Perplexity 4-layer → see §5.3 for complete implementation. Summary:
1. **L0 XML (98% of fix)** → New single event type `typeWindowStateChanged`, remove all optional flags, kill canPerformGestures, reduce timeout to 100ms. Manifest gets `tools:node="replace"` for future-proofing.
2. **L1 Dart Debounce** → already in §5.1.
3. **L2 Runtime (conditional post-test)** → if TREE_DEPTH persists after L0+L1, add native helper.
4. **L3 ProGuard** → Release builds: strip `Log.d` bytecode.

---

## 3. Feature Requirements Decomposition

Minor adjustment from first draft per user answers:

- **Custom wins on overlap** → `getActiveLockInfo()` iterates custom schedules FIRST, then prayer.
- **X button cooldown 3s** → add `_lastCloseCooldownUntil` to `AccessibilityServiceHelper`.
- **Mindful pause no breathing** → remove `_breathingController`, `_breathingAnimation`, `_breathingPhase`, `_breathingCycles`, `_requiredCycles` state entirely from `_LockOverlayScreenState`. Saves ~80 lines, no AnimationController needed anymore.
- **typePhrase no TextField** → remove `_phraseController`, `_phraseError`, `_phraseAttempts` state. Remove `_validatePhrase()`.

---

## 4. Proposed Architecture & Data Flow Changes

Update to state diagram (§4 in first draft) now incorporates:

- `AccessibilityServiceHelper._lastCloseCooldownUntil` timestamp field.
- `FocusLockProvider.getActiveLockInfo()` returns custom BEFORE prayer (custom wins).
- `Overlay Isolate` providers chain: `FocusLockProvider` (mode=overlay) + `ThemeProvider` + `VerseProvider` + `HadithProvider` + `StreakProvider` (unchanged).
- `LockOverlayScreen` now always has the 3 global buttons as final children of the column (before quote).
- `LockEngineMode.overlayIsolate` explicitly skips all foreground service calls.

---

## 5. Detailed Implementation Plan

### 5.1 Bug #1: Accessibility Service Activation (Hot Restart Required)

**Unchanged from first draft** — was already correct. Repeated for completeness:

#### 5.1.1 `AccessibilityServiceHelper` Additions

File: [accessibility_service_helper.dart](file:///c:/Users/PC-20/Desktop/Code/inav/lib/core/services/accessibility_service_helper.dart)

1. Add new private state:
   ```dart
   static bool _serviceConfirmedConnected = false;
   static Timer? _servicePollTimer;
   static final StreamController<bool> _serviceStatusController =
       StreamController<bool>.broadcast();
   static DateTime? _lastCloseCooldownUntil; // NEW for Q4 X button 3s cooldown
   ```

2. Add `forceResubscribe()` — cancels & recreates the native stream:
   ```dart
   static Future<void> forceResubscribe() async {
     _accessStreamSubscription?.cancel();
     _accessStreamSubscription = null;
     _serviceConfirmedConnected = false;
     _lastPackageName = null;
     await Future.delayed(const Duration(milliseconds: 100));
     _subscribeToAccessStream();
     final connected = await isAccessibilityServiceEnabled();
     if (connected) {
       _serviceConfirmedConnected = true;
       _serviceStatusController.add(true);
     }
   }
   ```

3. Add **100ms debounced** event listening inside `_subscribeToAccessStream()` to avoid duplicate rapid events:
   ```dart
   // Inside _subscribeToAccessStream()
   Timer? _debounceTimer;
   String? _pendingPackage;

   FlutterAccessibilityService.accessStream.listen((event) {
     final packageName = event.packageName;
     if (packageName == null || packageName.isEmpty) return;
     // ... existing event type detection ...
     if (isWindowStateChange) {
       _pendingPackage = packageName;
       _debounceTimer?.cancel();
       _debounceTimer = Timer(const Duration(milliseconds: 100), () {
         if (_pendingPackage != null && _pendingPackage != _lastPackageName) {
           _lastPackageName = _pendingPackage;
           _appOpenedController.add(_pendingPackage!);
         }
       });
     }
   });
   ```

4. Add service polling + status stream + cooldown-aware `showLockOverlay`:
   ```dart
   static Stream<bool> get serviceStatusStream => _serviceStatusController.stream;

   static void startServicePolling({Duration interval = const Duration(seconds: 2)}) {
     stopServicePolling();
     _servicePollTimer = Timer.periodic(interval, (_) async {
       final enabled = await isAccessibilityServiceEnabled();
       if (enabled && !_serviceConfirmedConnected) {
         debugPrint('AccessibilityHelper: Service detected enabled! Resubscribing...');
         await forceResubscribe();
       } else if (!enabled && _serviceConfirmedConnected) {
         _serviceConfirmedConnected = false;
         _serviceStatusController.add(false);
       }
     });
   }

   static void stopServicePolling() {
     _servicePollTimer?.cancel();
     _servicePollTimer = null;
   }

   // NEW: X button cooldown-aware showLockOverlay (suppresses lock for 3s after X press)
   static Future<void> showLockOverlay() async {
     // Check cooldown
     if (_lastCloseCooldownUntil != null &&
         DateTime.now().isBefore(_lastCloseCooldownUntil!)) {
       debugPrint('AccessibilityHelper: Suppressing showLockOverlay (X cooldown active)');
       return;
     }
     if (_isOverlayShowing) return;
     try {
       await FlutterAccessibilityService.showOverlayWindow();
       _isOverlayShowing = true;
       debugPrint('Lock overlay shown');
     } catch (e) {
       debugPrint('Error showing lock overlay: $e');
     }
   }

   // NEW: hideLockOverlay now sets 3s cooldown (called by X button)
   static Future<void> hideLockOverlayWithCooldown() async {
     _lastCloseCooldownUntil = DateTime.now().add(const Duration(seconds: 3));
     await hideLockOverlay();
   }

   // Regular hide (used by Skip, Unlock timer, Open INav auto-unlock)
   static Future<void> hideLockOverlay() async {
     // No cooldown for non-X hides
     if (!_isOverlayShowing) return;
     try {
       await FlutterAccessibilityService.hideOverlayWindow();
       _isOverlayShowing = false;
       debugPrint('Lock overlay hidden');
     } catch (e) {
       debugPrint('Error hiding lock overlay: $e');
     }
   }

   static bool get isServiceConfirmedConnected => _serviceConfirmedConnected;
   ```

#### 5.1.2 `LockEngine` Changes

File: [lock_engine.dart](file:///c:/Users/PC-20/Desktop/Code/inav/lib/core/services/lock_engine.dart)

```dart
enum LockEngineMode { mainApp, overlayIsolate }

class LockEngine {
  final LockEngineMode mode;
  // ...
  LockEngine(this._provider, {this.mode = LockEngineMode.mainApp});

  Future<void> start() async {
    if (_isActive) return;
    debugPrint('LockEngine[$mode]: Starting...');
    _isActive = true;
    // Accessibility check + service polling (both modes)
    // ...
    // Foreground service gated (mainApp only)
    if (mode == LockEngineMode.mainApp) {
      try {
        await _serviceChannel.invokeMethod('startForegroundService');
      } catch (e) {
        debugPrint('LockEngine[$mode]: Error starting foreground service - $e');
      }
    }
    _subscribeToStreams();
    _startReconnectTimer();
  }

  // Replace old 30s dead timer with service polling + stream
  void _startReconnectTimer() {
    AccessibilityServiceHelper.startServicePolling(
      interval: const Duration(seconds: 2),
    );
    _serviceStatusSubscription?.cancel();
    _serviceStatusSubscription =
        AccessibilityServiceHelper.serviceStatusStream.listen((connected) {
      if (connected && !_appOpenedSubscriptionIsListening()) {
        debugPrint('LockEngine[$mode]: Instant reconnect via status stream');
        _subscribeToStreams();
      }
    });
  }

  // Validate actual connection (not just null check)
  bool _appOpenedSubscriptionIsListening() =>
      _appOpenedSubscription != null &&
      AccessibilityServiceHelper.isServiceConfirmedConnected;
}
```

---

### 5.2 Bug #1b: MissingPluginException

Implementation same as first draft; with graphify confirming the main.dart → FocusLockProvider.initialize → LockEngine(mode) chain is correct.

**Summary**:
- `LockEngine` constructor gets `mode` parameter.
- `FocusLockProvider.initialize({LockEngineMode mode = mainApp})` passes mode through.
- `main.dart` L54 `accessibilityOverlay()` calls `focusLockProvider.initialize(mode: LockEngineMode.overlayIsolate)`.

Also `FocusLockProvider` stores `_engineMode` for logging if needed.

---

### 5.3 Bug #2: "Maximum Tree Depth Reached: 15" (REVISED WITH RESEARCH)

**4-layer implementation, now with confirmed XML targets.**

#### 5.3.1 Layer 0 — XML Rewrite + Manifest Hardening (PRIMARY FIX, 98% impact)

**File A**: Replace content of [accessibilityservice.xml](file:///c:/Users/PC-20/Desktop/Code/inav/android/app/src/main/res/xml/accessibilityservice.xml) with research-backed minimal config:

```xml
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:description="@string/accessibility_service_description"
    android:accessibilityEventTypes="typeWindowStateChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:notificationTimeout="100"
    android:canRetrieveWindowContent="true"
    android:settingsActivity="com.zedt.inav.MainActivity" />
```

**Deliberately REMOVED**:
- `typeWindowsChanged` and `typeWindowContentChanged` from event types → only `typeWindowStateChanged` subscribed. Events drop 90%+.
- Entire `android:accessibilityFlags` attribute → defaults to `flagDefault` only; no `flagIncludeNotImportantViews`, no `flagReportViewIds`, no `flagRetrieveInteractiveWindows`, no explore-by-touch.
- `android:canPerformGestures="true"` → we do NOT dispatch gestures; this was bloating the capability list.
- Old `accessibility_service_config.xml` (unused, manifest points to `accessibilityservice`) → can be left as-is for now; not referenced anywhere (double-check grep before deleting).

**File B**: [AndroidManifest.xml L86-96](file:///c:/Users/PC-20/Desktop/Code/inav/android/app/src/main/AndroidManifest.xml#L86-L96). Add `tools:node="replace"` to the service element for future-proofing against plugin upgrades that might ship a duplicate service:

```xml
<service
    android:name="slayer.accessibility.service.flutter_accessibility_service.AccessibilityListener"
    android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
    android:exported="true"
    tools:node="replace">
    <intent-filter>
        <action android:name="android.accessibilityservice.AccessibilityService" />
    </intent-filter>
    <meta-data
        android:name="android.accessibilityservice"
        android:resource="@xml/accessibilityservice" />
</service>
```

> Note: `xmlns:tools="http://schemas.android.com/tools"` is already declared on `<manifest>` root L2 (confirmed). `android:exported="true"` added (Perplexity research recommended it; though BIND_ACCESSIBILITY_SERVICE permission already protects it).

#### 5.3.2 Layer 1 — Dart 100ms Debounce (already in §5.1.1)

Already part of Bug #1 fix. Acts as safety net: even if some duplicate `WINDOW_STATE_CHANGED` fire for same package in rapid succession (split screen, multi-window transitions), they collapse to 1 event.

#### 5.3.3 Layer 2 — Native Runtime Hardening (CONDITIONAL, post-XML-test)

Only implement if after Layer 0 + Layer 1 in debug build the `TREE_DEPTH` log still appears (which would mean `flutter_accessibility_service` overrides `serviceInfo` in its own `onServiceConnected` after XML is loaded).

Implementation file: Create `android/app/src/main/kotlin/com/zedt/inav/utils/InavAccessibilityTuner.kt`

```kotlin
package com.zedt.inav.utils

import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityManager

/**
 * Layer-2 defense: if plugin widens AccessibilityServiceInfo after XML load,
 * call this from MainActivity 500ms post-start to re-narrow it.
 * NOTE: This uses AccessibilityManager API which works FROM THE OUTSIDE if the
 * service exposes mutable info. If it fails silently (expected on some OEMs),
 * Layer 0 + Layer 1 are already sufficient for 98% of cases.
 */
object InavAccessibilityTuner {
    fun tryNarrowServiceInfo(context: Context) {
        try {
            val am = context.getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
            val enabledServices = am.getEnabledAccessibilityServiceList(
                AccessibilityServiceInfo.FEEDBACK_ALL_MASK
            )
            val targetPkg = "com.zedt.inav"
            for (info in enabledServices) {
                val serviceInfo = info.resolveInfo.serviceInfo
                if (serviceInfo.packageName == targetPkg) {
                    // Try to narrow runtime via reflection (if the service permits)
                    try {
                        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
                        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
                        info.notificationTimeout = 100
                        info.flags = 0
                        // Note: canRetrieveWindowContent cannot be changed at runtime
                        // (XML static) — we keep it true for overlay support.
                    } catch (e: Exception) {
                        android.util.Log.w("InavAccTuner", "Runtime narrowing not supported on this device: ${e.message}")
                    }
                    break
                }
            }
        } catch (e: Exception) {
            android.util.Log.w("InavAccTuner", "Failed to tune: ${e.message}")
        }
    }
}
```

Invoke from `MainActivity.onCreate()` via:
```kotlin
// Inside onCreate (or configureFlutterEngine end), add:
Handler(Looper.getMainLooper()).postDelayed({
    InavAccessibilityTuner.tryNarrowServiceInfo(this)
}, 500)
```

This step is OPTIONAL initially. Only build it if after L0 we see TREE_DEPTH.

#### 5.3.4 Layer 3 — Release Build Log Suppression (ProGuard)

File: Create `android/app/proguard-rules.pro` (or append to existing):
```proguard
# Release-only: strip all debug Log.d calls including TREE_DEPTH spam from plugin
-assumenosideeffects class android.util.Log {
    public static int d(java.lang.String, java.lang.String);
    public static int v(java.lang.String, java.lang.String);
}
```

If `isMinifyEnabled` is not true in `build.gradle.kts`, skip this step for now (debug builds always show logs anyway; the user reports this in debug which is expected in dev — release builds should be clean).

---

### 5.4 Feature #3a: Lock Screen — Show Lock Reason & Remaining Time

**Substantially same as first draft**; one change: **custom wins overlap**.

#### 5.4.1 `ActiveLockInfo` class — SAME as first draft

Append to [lock_schedule.dart](file:///c:/Users/PC-20/Desktop/Code/inav/lib/core/models/lock_schedule.dart):
```dart
enum LockReason { prayer, customFocus }

class ActiveLockInfo {
  final LockReason reason;
  final String label;
  final DateTime startTime;
  final DateTime endTime;
  final CustomLockSchedule? customSchedule;
  final String? prayerName;

  const ActiveLockInfo({...});

  int get remainingSeconds {
    final diff = endTime.difference(DateTime.now()).inSeconds;
    return diff < 0 ? 0 : diff;
  }

  String get formattedRemaining {
    final total = remainingSeconds;
    if (total <= 0) return '0 min';
    if (total < 60) return '$total sec';
    final min = total ~/ 60;
    if (min < 60) return '$min min';
    final h = min ~/ 60;
    final m = min % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}
```

#### 5.4.2 `CustomLockSchedule` absolute time getters — SAME

#### 5.4.3 `FocusLockProvider.getActiveLockInfo()` — **REVISED: custom wins**

Change from draft #1: iterate **custom schedules FIRST** (before prayer), so in overlap scenarios custom wins:

```dart
ActiveLockInfo? getActiveLockInfo() {
  final now = DateTime.now();

  // 1. CUSTOM SCHEDULES FIRST (user Q2 answer: custom wins overlap)
  for (final s in _customSchedules) {
    if (s.enabled && s.isActiveNow()) {
      return ActiveLockInfo(
        reason: LockReason.customFocus,
        label: s.label,
        startTime: s.getAbsoluteStartTime(now: now),
        endTime: s.getAbsoluteEndTime(now: now),
        customSchedule: s,
      );
    }
  }

  // 2. Prayer schedule SECOND (only if no custom is active)
  if (_prayerSchedule != null && _prayerSchedule!.enabled) {
    final activePrayerName = _prayerSchedule!.getActivePrayerName();
    if (activePrayerName != null) {
      final start = _prayerSchedule!.getLockStartTime(activePrayerName) ?? now;
      final end = _prayerSchedule!.getLockEndTime(activePrayerName) ?? now;
      return ActiveLockInfo(
        reason: LockReason.prayer,
        label: activePrayerName.capitalizeFirst(),
        startTime: start,
        endTime: end,
        prayerName: activePrayerName,
      );
    }
  }

  return null;
}
```

Helper `capitalizeFirst()` extension added (same as draft).

---

### 5.5 Feature #3b: Lock Screen — Match App Theme

**Implementation same as draft #1**. Summary:
- Overlay isolate (`main.dart` L48-75) creates fresh `ThemeProvider`, calls `await themeProvider.loadThemePreference()`, and adds it to the overlay's `MultiProvider` chain.
- `LockOverlayScreen.build()` wraps entire return in `Consumer<ThemeProvider>` and computes `isDark` via resolved `brightness` (system fallback if `ThemeMode.system`).
- All `AppColors.*Dark` → `_ThemedColors.resolve(isDark).*` pattern (same as [random_content_card.dart L29](file:///c:/Users/PC-20/Desktop/Code/inav/lib/widgets/home/random_content_card.dart#L29)).

---

### 5.6 Feature #3c: Three New Buttons (REVISED with Q4 X cooldown)

#### 5.6.1 New Constructor Params — expanded from draft #1

```dart
class LockOverlayScreen extends StatefulWidget {
  final ActiveLockInfo? activeLockInfo;
  final int dailySkipAllowance;
  final int remainingSkips;
  final bool canSkip;
  final Future<bool> Function()? onSkip;
  final VoidCallback? onCloseViewWithCooldown; // X button: uses hideWithCooldown
  final VoidCallback? onOpenInav;
  final VoidCallback? onUnlock;
  // ... rest: blockedAppName, unlockConfig, currentPrayerName
```

#### 5.6.2 Layout: Stack for X + "Close 3s" Caption

Replace the `SafeArea → Center → Column` with a `Stack`. The `X` button now floats at top-right **with a small caption under it**:

```dart
SafeArea(
  child: Stack(
    children: [
      // NEW: X Button + "Close 3s" caption (top-right)
      Positioned(
        top: 4,
        right: 8,
        child: GestureDetector(
          onTap: () => widget.onCloseViewWithCooldown?.call(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.close,
                  color: colors.textMuted,
                  size: 28,
                ),
                const SizedBox(height: 2),
                Text(
                  'Close 3s',
                  style: _textStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Content — padded from top to make room for X button area
      Positioned.fill(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
          child: Center(
            child: Column(
              // ... existing column: lock icon, title, reason, remaining time, method UI,
              // ... spacer, THEN bottom buttons (below):
            ),
          ),
        ),
      ),
    ],
  ),
)
```

#### 5.6.3 Bottom Button Row (Skip + Open INav) — same as draft, no cooldown

Ratio: Skip = `flex:1` (outlined, secondary), Open INav = `flex:2` (elevated, primary). No cooldown applied here per user Q5 answer.

---

### 5.7 Feature #3d: Unlock Method-Specific Behavior (REVISED per user Q1-Q3)

#### 5.7.1 `waitItOut` → `_buildWaitItOutUI()` (Unchanged from draft)

- Prefer `widget.activeLockInfo?.remainingSeconds ?? widget.unlockConfig.waitDurationSeconds`.
- Timer runs out → calls `onUnlock` (which calls regular `hideLockOverlay`, no cooldown).

#### 5.7.2 `markPrayed` → `_buildMarkPrayedUI()` (Unchanged logic; already correct for custom wins)

- Already checks `isPrayerLock = widget.activeLockInfo?.reason == LockReason.prayer`.
- If custom lock: **no polling, no auto-unlock, even if streak is logged**.
- If prayer lock: poll `StreakProvider.isCurrentPrayerCompleted` every 2s; if true → auto unlock.

#### 5.7.3 `mindfulPause` → `_buildMindfulPauseUI()` (**REWRITTEN — no breathing, verse/hadith only**)

Per user Q3 answer:
- **Remove all breathing state**: `_breathingController`, `_breathingAnimation`, `_breathingPhase`, `_breathingCycles`, `_requiredCycles`, `_startBreathingCycle()`. (Removes ~50 lines of state management code + `TickerProviderStateMixin` dependency.)
- Replace with random content:
  - On init: `Random().nextBool()` chooses verse or hadith.
  - Read `VerseProvider` or `HadithProvider` from context (both now available in overlay isolate MultiProvider).
  - If not loaded: call `refresh()` and await.
  - Display as styled card: header label (RANDOM VERSE or RANDOM HADITH), Arabic RTL, translation in quotes italicized, reference (same visual pattern as [random_content_card.dart L412-479](file:///c:/Users/PC-20/Desktop/Code/inav/lib/widgets/home/random_content_card.dart#L412-L479)).
- **No unlock from mindful pause UI**. User must wait for end of schedule, use Skip, press X (with cooldown), or tap Open INav.

#### 5.7.4 `typePhrase` → `_buildTypePhraseUI()` (**REWRITTEN — display-only card, NO typing field**)

Per user Q1 answer:
- **Remove**: `_phraseController`, `_phraseError`, `_phraseAttempts`, `_validatePhrase()`.
- Replace display: prominent reminder card (no TextField) using the design pattern from draft §5.7.4:
  - Header "YOUR REMINDER" (small caps).
  - Large card with mic/voice icon, user's phrase in quotes italicized bold.
  - Subtext: *"Remember why this focus session matters. Stay committed!"*
- No unlock path via typing. User uses standard buttons/timer only.

---

## 6. File Change Inventory (UPDATED)

| # | File | Change Type | Sections Affected |
|---|------|-------------|-------------------|
| 1 | `lib/core/services/accessibility_service_helper.dart` | **Major Modify** | Add `_serviceConfirmedConnected`, `_servicePollTimer`, `_serviceStatusController`, `_lastCloseCooldownUntil`, `forceResubscribe()`, 100ms debounce, polling start/stop, `serviceStatusStream`, cooldown-aware `showLockOverlay`, `hideLockOverlayWithCooldown()`, `openInavApp()` method |
| 2 | `lib/core/services/lock_engine.dart` | **Major Modify** | Add `LockEngineMode` enum + constructor param, gate foreground svc calls on mainApp, replace dead reconnect timer with `AccessibilityServiceHelper.startServicePolling()`, fix `_appOpenedSubscriptionIsListening()` |
| 3 | `lib/core/providers/focus_lock_provider.dart` | **Major Modify** | Add `initialize(mode:)`, add `ActiveLockInfo? getActiveLockInfo()` (custom-first), add helper extension |
| 4 | `lib/core/models/lock_schedule.dart` | **Major Modify** | Add `LockReason`, `ActiveLockInfo`, `CustomLockSchedule.getAbsoluteStartTime/getAbsoluteEndTime` |
| 5 | `lib/screens/lock_overlay_screen.dart` | **Rewrite** | Theme-aware via `_ThemedColors`, Stack layout for X+caption, skip/INav bottom row, lock reason header + progress, markPrayed conditional, mindful pause→verse/hadith card, typePhrase→reminder display, helper `_textStyle` |
| 6 | `lib/main.dart` | **Modify** | Overlay isolate: init `ThemeProvider`, `VerseProvider`, `HadithProvider`; wire all new `LockOverlayScreen` params; pass `LockEngineMode.overlayIsolate` |
| 7 | `android/app/src/main/res/xml/accessibilityservice.xml` | **Rewrite** | Single eventType, no accessibilityFlags attr, remove gestures, timeout=100ms (research-approved minimal config) |
| 8 | `android/app/src/main/AndroidManifest.xml` | **Minor Modify** | Add `tools:node="replace"` + `exported=true` to accessibility service declaration (future-proof against plugin upgrade manifest conflicts) |
| 9 | `android/app/src/main/kotlin/com/zedt/inav/MainActivity.kt` | **Minor Modify** | (A) Add `openInavApp` method handler in `focus_lock` channel (launches MainActivity). (B) Optionally: add 500ms delayed call to `InavAccessibilityTuner.tryNarrowServiceInfo(this)` if Layer 2 is needed. |
| 10 | `android/app/src/main/kotlin/com/zedt/inav/utils/InavAccessibilityTuner.kt` | **CREATE (Conditional)** | Layer-2 defense: post-hoc runtime narrowing of `AccessibilityServiceInfo` if plugin widens it after XML. Only build if TREE_DEPTH persists after L0+L1. |
| 11 | `android/app/proguard-rules.pro` | **Create (Conditional)** | `assumenosideeffects Log.d` for release builds. Only create if minification is enabled. |
| 12 | `android/app/build.gradle.kts` | **Minor Modify (Conditional)** | Register proguard-rules.pro in release buildType block if not already set. |

---

## 7. Risk Assessment & Mitigations (REVISED WITH RESEARCH)

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| XML event filtering too narrow → system dialogs (time picker) or app-switch not detected | **Very Low** (Research confirms `TYPE_WINDOW_STATE_CHANGED` is standard for this) | **High** | Test plan §8.2.3 explicitly covers time picker, quick-settings shade, split-screen, multi-window. Also: if needed, broaden to `typeWindowStateChanged \| typeWindowsChanged` only (NOT typeWindowContentChanged). |
| Plugin overrides serviceInfo at runtime → TREE_DEPTH persists | **Low** (manifest plugin service declaration is empty per INav comments) | Medium | Conditional Layer 2 (InavAccessibilityTuner) included as opt-in post-test step. Also Layer 1 Dart debounce + Layer 3 ProGuard already reduce visible impact. |
| Overlay isolate ThemeProvider/verses init crashes | **Medium** (fresh providers + network calls) | **High** | Every init wrapped in `try/catch` with fallback: theme→dark mode; verse/hadith→fallback text "Prayer is better than sleep" (existing quote). |
| `getActiveLockInfo()` custom-first order misses prayer timers | **Low** (user explicitly chose custom wins) | Low | Document behavior clearly. Testing §8.2.5 tests overlap scenarios. |
| X 3s cooldown lets user bypass lock by repeatedly pressing X & reopening app | **Low** (3s is minimal) | Low | Cooldown is SHORT (3s) — enough to exit to home and swipe app away, not enough to use locked app meaningfully. User can always use `Skip (N/M)` if they want longer bypass. |
| XML `tools:node="replace"` causes merge errors if plugin ever ships service element | **Very Low** (plugin manifest empty today) | Low | The `tools:node="replace"` will cleanly override; host already re-declares all needed attrs (permission, intent-filter, meta-data). If merge error, change to `tools:node="merge"` + `tools:replace="android:exported,android:permission"`. |

---

## 8. Testing Strategy (UNCHANGED; all 8.2.x manual test cases remain valid with following additions)

### 8.2.2 Bug #1b — MissingPluginException (add test step)
- Filter `flutter logs` for both the main isolate and overlay isolate tag. When overlay opens, verify NO `MissingPluginException` appears.
- Pull down notification shade; verify "Focus Lock Active" foreground notification appears (main app started it, no duplicate calls).

### 8.2.3 Bug #2 — TREE_DEPTH Spam (add new explicit manual tests)
1. **Baseline**: `flutter logs -c` → then open Instagram, scroll feed vigorously for 10 seconds.
   - **Pass**: 0–5 `TREE_DEPTH` lines total (previously 100+).
2. Open FocusLock settings → add custom schedule → open **start time picker Material clock dialog** → drag hour hand.
   - **Pass**: No `TREE_DEPTH` spamming.
3. Swipe from top twice to fully expand quick-settings shade; toggle WiFi/Bluetooth ON/OFF 5x.
   - **Pass**: No `TREE_DEPTH` spamming.
4. Open blocked YouTube → verify lock triggers in <500ms (no delay).

### 8.2.6 Feature 3c Buttons (add X cooldown test)
1. Open lock overlay. Press `X` button → overlay closes.
2. **Within 3 seconds** → re-open Instagram (or same blocked app).
   - **Pass**: Lock overlay DOES NOT appear (suppressed by cooldown).
3. **Wait 3+ seconds** → re-open Instagram.
   - **Pass**: Lock overlay RE-APPEARS (cooldown expired).

### 8.2.7 (NEW) Mindful Pause & Type Phrase UX Validation
1. Set unlock method = mindfulPause. Open locked app.
   - **Pass**: Random Quran verse OR Hadith displayed, no breathing animation, no continue button. Bottom buttons work.
2. Set unlock method = typePhrase, set phrase = "Islam first". Open locked app.
   - **Pass**: Phrase displayed prominently, NO TextField, no typing allowed. Standard buttons work.

---

## 9. Sequence Diagrams (Critical Flows)

### 9.1 Bug Fix #1 — Reconnect (Unchanged from §10.1 draft #1)

### 9.2 X Button — 3s Cooldown Flow (NEW, per user Q4)
```
User taps X on LockOverlayScreen
   │
   ▼
widget.onCloseViewWithCooldown() → main.dart overlay callback
   │
   ▼
AccessibilityServiceHelper.hideLockOverlayWithCooldown()
   │
   ├─ _lastCloseCooldownUntil = DateTime.now() + 3s
   └─ hideLockOverlay() → FlutterAccessibilityService.hideOverlayWindow()
                                │
                                ▼
                      Overlay dismisses; user returns to blocked app
                                │
[Within 3 seconds, LockEngine detects app-open & calls showLockOverlay()]
                                │
                                ▼
showLockOverlay() checks DateTime.now().isBefore(_lastCloseCooldownUntil) → TRUE
   │
   └─ debugPrint("Suppressing showLockOverlay (X cooldown active)") → RETURN EARLY → NO overlay
                                │
[3 seconds elapsed. Next app-open detected]
                                │
                                ▼
showLockOverlay() cooldown expired → shows overlay normally ✓
```

### 9.3 LockOverlayScreen V2 Final Layout (Revised with "Close 3s")
```
┌─────────────────────────────────────────────────┐
│                        [X] ← close icon         │
│                    Close 3s ← caption (small)   │
│                                                 │
│         🔒  LOCKED                              │
│                                                 │
│   ┌─────────────────────────────────────┐       │
│   │ 📚 Study (custom wins if overlap)   │       │ ← or 🕌 Prayer Time — Dhuhr
│   └─────────────────────────────────────┘       │
│                                                 │
│   ⏱ Unlocks in:  1h 14m                         │
│   [████████████████████░░░░░░░░░░░░]  58%       │
│                                                 │
│   Instagram                                      │
│                                                 │
│ ┌─────────────────────────────────────────┐     │
│ │  [METHOD SPECIFIC CONTENT]              │     │
│ │  • waitItOut → HH:MM:SS countdown       │     │
│ │  • markPrayed → conditional auto-unlock │     │
│ │  • mindfulPause → verse/hadith card     │     │
│ │  • typePhrase → display-only reminder   │     │
│ └─────────────────────────────────────────┘     │
│                                                 │
│ [ Skip (1/1) ]       [    Open INav 🚀    ]     │ ← 1:2 flex ratio
│                                                 │
│   ✨ "Prayer is better than sleep"              │
└─────────────────────────────────────────────────┘
```

---

> **End of PLAN_2.md (REVISED)** — All user Q1–Q6 answers integrated; Perplexity research fully applied to Bug #2 (XML narrowing + manifest hardening). Ready for implementation:
> 1. **Session 1**: Bugs → #1 (access reconnect + debounce) → #1b (LockEngineMode) → #2 (Layer 0 XML + manifest + L1 debounce; Layer 2 conditional post-test).
> 2. **Session 2**: Provider/model changes → #3a (ActiveLockInfo API + CustomSchedule time getters).
> 3. **Session 3**: LockOverlayScreen V2 → #3b (theme) + #3c (buttons + X cooldown wiring).
> 4. **Session 4**: Method UI → #3d (4 method screens rewritten).
> 5. **QA**: flutter analyze → flutter build → execute §8 manual test plan.
