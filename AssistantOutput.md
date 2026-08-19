# Plan Lock Screen Bug Fixes and Features

> **Workspace:** c:\Users\PC-20\Desktop\Code\inav

---

**User**

make a NEW PLAN_2.md for this: 
 
 there's a bug for the lock scren app configuration: 
 
 1. when user didn't active the accessibility service it says: 
 I/flutter (23214): LockEngine: Starting... 
 I/flutter (23214): LockEngine: Starting... 
 D/FlutterRenderer(23214): Width is zero. 0,0 
 D/FlutterJNI(23214): Sending viewport metrics to the engine. 
 D/FlutterGeolocator(23214): Creating service. 
 D/FlutterGeolocator(23214): Binding to location service. 
 I/flutter (23214): LockEngine: Accessibility service NOT enabled yet. Subscribing to stream anyway (will activate once user enables it). 
 I/flutter (23214): LockEngine: Accessibility service NOT enabled yet. Subscribing to stream anyway (will activate once user enables it). 
 
 AND, when user activated the accessibility services it didnt says anything UNLESS i need to restart the application with shift + r in the cmd to make the accessibility service working: 
 Performing hot restart...                                               
 Restarted application in 3,879ms. 
 I/flutter (23214): LockEngine: Starting... 
 I/flutter (23214): LockEngine: Starting... 
 I/AccessibilityPlugin(23214): Started the accessibility tracking service. 
 I/flutter (23214): LockEngine: Subscribed to app-opened stream 
 
 Can you fix that? 
 
 Also there's a log that says: LockEngine: Error starting foreground service - MissingPluginException(No implementation found for method startForegroundService on channel com.zedt.inav/foreground_service) can you chek what is this and try to fix it too. 
 
 2. when user want to add custom time, they select the clock (start and end) then they need to named the focus time, but suddenly when its appear, it says in the log:  D/TREE_DEPTH(23214): Maximum tree depth reached: 15 
 D/TREE_DEPTH(23214): Maximum tree depth reached: 15 
 D/TREE_DEPTH(23214): Maximum tree depth reached: 15 
 
 not only that but when user swipe down their devices to open the device phone menu (like the menu for the wifi, bluetooth, etc) it also says that thing, when i open instagram it also says that (even tho the lock is working), and then when i open youtube, and when i open tiktok, Basically, whenever I open any of those locked apps, that always pops up repeatly, this could end up flooding the logs with those "maximum depth" error entries, causing the "LockEngine: App opened" and "LockEngine: Blocking app" logs to be overlooked and making the apps not lock (because of the delay cause the log spam the error maximum tree depth) but its still work, it just takes time because of the maximux depth error logs. can you check what's going on and fix this. 
 
 3. - On the lock screen, please indicate the reason for the lock—for example, whether it is due to prayer time or a custom focus period (displaying the text the user entered for that custom time)—and also show the remaining time (in minutes or hours) until it unlocks. 
 
 - Please ensure that the lock screen's visual theme matches the user's app theme (i.e., dark mode or light mode). 
 
 - Additionally, please add three buttons: an "X" button in the top-right corner to close the lock screen view (note that closing the view does not unlock the app; it simply allows the user to exit the lock screen display), and two buttons at the bottom—a "Skip" button (displaying the user's daily skip limit) and a button to open the INav apps. 
 
 - make the unlock based on the unlock method, For example: 
 1) "Wait it out": Display the timer custom time or timer prayer time until is unlock and add a button to open the INav app (this thing do nothing special, it just wait based on the timer). 
 2) "Mark prayer as read": Implement conditional logic (if/else). If locked due to prayer time, provide a button to open the INav app and make it auto-unlocks once the user logs the prayer/streak. However, if locked due to a custom time setting, provide the same button to open the INav app but ensure it remains locked even after the prayer is logged. 
 3) "Mindful pause": Display text on the lock screen—such as a Hadith or Quranic verse (similar to the random verse/Hadith features `c:\Users\PC-20\Desktop\Code\inav\lib\widgets\home\random_content_card.dart` )—along with a button to open the INav app. 
 4) "Type a reminder phrase": Display the reminder phrase entered by the user during configuration on the lock screen, with a button solely for opening the INav app. 
 The key point is that all these buttons open the INav app; there are three buttons in total: Button X, a "Skip" button (indicating the daily skip limit), and a button to open the INav app. 
 
 I want you to make sure to understand the context, the project structure the function, etc to make the best approach to fix the bug maximum tree depth, must restart after activated the accessibility services and adding new features for the lock screen for user experience. You can use the mcp server perplexity for deep research about anything or even you can use the web search tool if its not work, and if you want to try to understand the project, like the code, the function, related function / code / file, etc you can use the graphify mcp server (if you don't understand how to use it correctly you can serach the web what's graphify for ). 
 
 MAKE SURE to make the best plan FIRST for the best approach / practices based on the bug, and the new features that i mention, you can ask me to clarify thing if there's ambiguity, or need my clarify to do based on your recommendation so there will be not any bug again and the implementation is based on my approves and you recommendation for best practices / approach, feel free for it.

**Assistant**

I'll create a comprehensive PLAN_2.md to address all the bugs and new features you mentioned. Let me first explore the project structure and understand the current implementation.


Now let me check the focus lock provider, unlock config model, theme, and random content card widget:

Now let me create the comprehensive PLAN_2.md document:

I've created **[PLAN_2.md](file:///c:/Users/PC-20/Desktop/Code/inav/PLAN_2.md)** — a comprehensive 10-section plan covering all three bugs and the lock screen feature overhaul.

---

## Plan Summary

### Bugs (Root Cause Analyzed ✅)

| Bug | Root Cause | Fix Strategy |
|-----|-----------|---------------|
| **#1 Accessibility requires hot restart** | The reconnect timer (30s) was **dead code** — it only checked if `_appOpenedSubscription != null` (always true after first call), plus `FlutterAccessibilityService.accessStream` was listened to **before the Android service was alive**, so events never arrived. | Add 2s polling + `forceResubscribe()` that **tears down & recreates** the native stream subscription when service transitions from disabled → enabled. Add event debounce (100ms) for rapid UI transitions. |
| **#1b MissingPluginException (startForegroundService)** | Two isolates start their own LockEngine. The **overlay isolate** (no Activity) tries to invoke `startForegroundService` on a channel only registered by MainActivity's engine. | Add `LockEngineMode { mainApp, overlayIsolate }` — foreground service calls gated to `mainApp` only. |
| **#2 TREE_DEPTH:15 spam + lock delays** | `flutter_accessibility_service` walks the entire AccessibilityNodeInfo tree for EVERY incoming event (scrolls, content changes, window state). Apps like Instagram have 15+ depth. Events are delivered too broadly. | **Primary fix**: In [accessibilityservice.xml](file:///c:/Users/PC-20/Desktop/Code/inav/android/app/src/main/res/xml/accessibilityservice.xml) set `accessibilityEventTypes="typeWindowStateChanged"` only (stop receiving scroll/content events). Secondary: 100ms Dart debounce (already in Bug#1 fix). Defense: ProGuard `assumenosideeffects Log.d` for release builds. |

### Features (Architecture Designed ✅)

| Feature | Design |
|---------|--------|
| **3a Lock reason + remaining time** | New `ActiveLockInfo` class (LockReason.prayer/custom, label, absolute start/end times). `FocusLockProvider.getActiveLockInfo()` API. Custom schedule gets `getAbsoluteStartTime/EndTime` (handles midnight crossing). Shown as badge + countdown bar in header. |
| **3b Theme matching** | Overlay isolate now initializes `ThemeProvider` (it didn't before — only loaded Focus/Streak). New `_ThemedColors.resolve(isDark)` — replace all `AppColors.*Dark` hardcodes with conditional theme colors (same pattern as [random_content_card.dart](file:///c:/Users/PC-20/Desktop/Code/inav/lib/widgets/home/random_content_card.dart)). |
| **3c Three buttons** | Layout changed from SafeArea→Center→Column to **Stack**: X button floats top-right (closes overlay only, no unlock). Bottom row: `Skip (remaining/total)` (secondary outlined) + `Open INav` (primary elevated). Skip calls `FocusLockProvider.useSkip()`. INav button uses new MethodChannel `openInavApp` → `Intent` launcher with CLEAR_TOP. |
| **3d Method-specific overhaul** | 🔴 **Needs your clarifications** before implementing (see questions below). Matrix: `Wait it out` = timer only; `Mark prayer` = **conditional auto-unlock** (prayer lock → yes, custom lock → no even if streak logged); `Mindful pause` = **remove breathing cycle, replace with random Quran verse / Hadith card** (same providers as RandomContentCard); `Type phrase` = display only (likely remove type-to-unlock TextField). |

---

## 🔴 Clarification Questions (Blocking Implementation)

I need your answers to **§9 Q1–Q6** before I start coding. The most important ones:

1. **Q1 (Critical)** — `typePhrase` behavior: Do you want the **type-to-unlock TextField REMOVED** (phrase becomes display-only reminder) or **KEPT** with phrase also displayed above?
2. **Q2** — If a prayer schedule and custom focus schedule overlap, which takes precedence for auto-unlock logic? (Recommended: Custom wins, so markPrayed auto-unlock is disabled during custom sessions)
3. **Q3** — `mindfulPause`: Remove the breathing animation/unlock-after-3-cycles entirely and show only verse/hadith? (Yes per your stated requirement — just confirming)
4. **Q4** — `X` button: Silent instant close, or confirmation dialog, or 10s cooldown?
5. **Q5** — After "Open INav" and user presses Back → they're back to blocked app which re-locks instantly. Add 60s cooldown so they can briefly return?
6. **Q6** — If XML event filtering gets overridden by plugin manifest merge, are you OK with touching native AccessibilityListener code or should we fall back to Dart-side fixes only?

You can answer inline or approve the whole plan with your preferences. Once confirmed, implementation will be split into 4 sessions: `Bugs → 3a/3b → 3c → 3d`.

---

**User**

Q1 (Critical): make the phrase becomes display-only reminder 
 Q2: make it custom wins 
 Q3: show only verse/hadith 
 Q4: when user press X button, it close the lock screen overlay for 3s so user will not stuck on lock screen (they can close the apps), make a small text under the X button that says "Close 3s" 
 Q5: Nope, after open INav apps and they didn't log prayer streak, the lock screen (if it was a prayer time and must loged prayer streak to open) will open, beside that, if user open INav apps and back to apps, it will still lock the apps, because there's no reason to unlock the lock screen unless it was 1 condition where it was locked by prayer times and the unlock method its loged prayer streak to open. 
 Q6: Research about the best practices / approach for this, like on the web or even perplexity mcp server. 
 
 After my answer and deep research make sure to update the PLAN_2 `c:\Users\PC-20\Desktop\Code\inav\PLAN_2.md` based on ityeah. 
 
 I want you to make sure to understand the context, the project structure the function, etc to make the best approach to fix the bug maximum tree depth, must restart after activated the accessibility services and adding new features for the lock screen for user experience. You can use the mcp server perplexity for deep research about anything or even you can use the web search tool if its not work, and if you want to try to understand the project, like the code, the function, related function / code / file, etc you can use the graphify mcp server (if you don't understand how to use it correctly you can serach the web what's graphify for ). 
 make sure the plan you make you take your time to researching for the best approach / practices and understanding the context of my project so the fix implementation is 100% accurate.

**Assistant**

Got it! Let me work through your answers and do the deep research for Q6, then update PLAN_2.md thoroughly.


Found it! The [accessibilityservice.xml](file:///c:/Users/PC-20/Desktop/Code/inav/android/app/src/main/res/xml/accessibilityservice.xml#L3-L8) currently subscribes to **THREE event types** (`typeWindowsChanged|typeWindowStateChanged|typeWindowContentChanged`) plus has heavy flags including `flagIncludeNotImportantViews|flagReportViewIds|flagRetrieveInteractiveWindows` and `canRetrieveWindowContent="true"` — all of which force deep tree walks. This is 100% the TREE_DEPTH cause. Now let me do the deep research.


Now let me run research in parallel — Perplexity deep research, graphify for project relationships, and a web search for Android accessibility best practices.


Now I have everything — user answers, deep research from Perplexity, web results, and graph verification. Let me read the existing PLAN_2 first, then rewrite it comprehensively.


Now let me write the comprehensive update to PLAN_2.md with all user answers, research findings, and revised implementation details. I'll rewrite the entire file with a new dated section at the top plus updates throughout:


**PLAN_2.md has been fully updated with all your answers and deep research applied.** Status is now **APPROVED — Ready for implementation**.

Here's a summary of what changed in the revision:

---

## 📝 Key Updates to [PLAN_2.md](file:///c:/Users/PC-20/Desktop/Code/inav/PLAN_2.md)

### Section 0 (NEW) — User Answers + Q6 Research Recorded
All Q1–Q6 decisions documented explicitly with implementation impact:
- **Q1**: `typePhrase` → display-only card (**no typing field**).
- **Q2**: Custom schedule wins overlap → `getActiveLockInfo()` checks custom first, then prayer.
- **Q3**: Mindful pause → verse/hadith 50/50 card only (**breathing animation deleted entirely** — saves ~50 lines, removes `TickerProviderStateMixin`).
- **Q4**: `X` button → small icon + "Close 3s" caption, cooldown stored in `AccessibilityServiceHelper._lastCloseCooldownUntil`; `showLockOverlay()` suppressed for 3s post-close.
- **Q5**: Open INav → no cooldown; only auto-unlock path = `markPrayed` method + prayer-reason lock + streak actually logged.

### Q6 Deep Research Applied (Smoking Gun Found)
XML inspection confirmed Bug #2's root cause is exactly in [accessibilityservice.xml L3-L8](file:///c:/Users/PC-20/Desktop/Code/inav/android/app/src/main/res/xml/accessibilityservice.xml#L3-L8):
```xml
<!-- CURRENT (broken): 3 event types + 6 aggressive flags → TREE_DEPTH spam -->
android:accessibilityEventTypes="typeWindowsChanged|typeWindowStateChanged|typeWindowContentChanged"
android:accessibilityFlags="flagDefault|flagIncludeNotImportantViews|flagRequestTouchExplorationMode|flagRequestEnhancedWebAccessibility|flagReportViewIds|flagRetrieveInteractiveWindows"
android:canPerformGestures="true"
android:notificationTimeout="300"
```

Perplexity-recommended **new XML** (§5.3.1):
```xml
<!-- FIXED: 1 event type, 0 extra flags, no gestures, 100ms timeout → ~98% event reduction -->
android:accessibilityEventTypes="typeWindowStateChanged"
<!-- OMIT accessibilityFlags entirely (defaults to flagDefault only) -->
<!-- OMIT canPerformGestures entirely -->
android:notificationTimeout="100"
```

Also added to manifest: `tools:node="replace"` (future-proof against plugin upgrades) + conditional Layer-2 `InavAccessibilityTuner.kt` native helper (only build if XML-alone doesn't fully kill TREE_DEPTH).

### Graphify Verified Overlay Provider Dependencies
Confirmed ThemeProvider / VerseProvider / HadithProvider are independent from FocusLockProvider — safe to add to the overlay isolate's MultiProvider chain without circular deps.

### Revised Section 9: Sequence Diagrams
Added §9.2 X-cooldown flow diagram and §9.3 final layout with "Close 3s" caption visible.

### Revised §8 Testing
New explicit test cases for:
- X 3s cooldown behavior (§8.2.6)
- Mindful pause & type phrase display-only validation (§8.2.7)
- TREE_DEPTH spam manual test matrix (scroll Instagram, time picker, quick settings toggle, YouTube lock latency)

### Implementation Roadmap (Bottom of PLAN_2.md)
Split into **4 implementation sessions + QA** for clean separation:
1. Bug fixes (#1 reconnect, #1b LockEngineMode, #2 XML + debounce, conditional native layer 2)
2. Provider/model APIs (#3a ActiveLockInfo + schedule absolute time getters, custom-first)
3. LockOverlayScreen chrome (#3b theme, #3c X/Skip/INav buttons, X cooldown wiring)
4. Method UI overhaul (#3d — 4 method screens rewritten)
5. `flutter analyze` → `flutter build` → §8 manual test plan execution

---

The plan is now fully locked. Ready to start Session 1 whenever you say go! 🚀

---

**User**

okay proceed based on the plan `c:\Users\PC-20\Desktop\Code\inav\PLAN_2.md` and based on the research the web and perplexity mcp server or even graphify (related code, function that needed to fix, etc). Make sure to use the `c:\Users\PC-20\Desktop\Code\inav\ponytail.md` skill too so the changes are minimum but effective and not wasting tokens (do not overthink anything, if there's ambiguity for the code, function, etc just try to understand the context and make sure the flow that you built didn't make a potential bug, just take your time research it again).

**Assistant**

Let me start by reviewing the ponytail.md skill and then proceed with Session 1 implementation.


Got it — ponytail mode activated. Let me start Session 1 with minimal, surgical changes. First, re-reading the exact current state of all files I'll touch.


Now I have the exact current state. Applying **ponytail rules** (minimal code, no unnecessary abstractions):

Key decisions before coding:
- **Skip `serviceStatusStream`** (not needed; 2s polling is enough for reconnect, 0-2s latency is fine)
- **Use `Write` for files >40% changed**, surgical `Edit` for small changes
- **Reuse existing `_channel`** for `openInavApp` (no new MethodChannel)

Starting with Session 1.1:


Now 1.2: LockEngine (mode enum, service gating, reconnect fix):


Now Session 1.3: Bug #2 Layer 0 (XML + manifest). Small files, surgical:


Now Session 1.4: MainActivity - add `openInavApp` channel handler. Let me read the focus_lock channel section first:


Good. `Intent` is already imported. Now add `openInavApp` to the channel handler after `hideLockOverlay`:


Now Session 1.5 + 1.6: FocusLockProvider (initialize with mode) + lock_schedule models. First, lock_schedule model additions (needed for getActiveLockInfo return type):


Adding LockReason enum, ActiveLockInfo class, and CustomLockSchedule absolute time getters to lock_schedule.dart. Append to existing file:


Now FocusLockProvider - add `initialize(mode:)` and `getActiveLockInfo()`. Ponytail: modify in-place, add `_engineMode` field + helper extension:


Now add `getActiveLockInfo()` + helper extension. Add right after `getActivePrayerName()`:


---

