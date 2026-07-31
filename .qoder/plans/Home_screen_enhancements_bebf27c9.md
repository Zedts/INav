# Home Screen Enhancements Plan

## Summary
Four changes driven by `ref/home_ref.html` (layout reference only — styling adapted to the existing `AppColors`/theme system, not copied from CSS). All new code follows the existing folder structure: `core/models` + `core/services` + `core/providers` + `screens` + `widgets/home`. First action: write this plan into `PLAN.md` at the repo root as a task checklist.

## 1. Stepper card -> Prayer Notification Settings (Navigator.push)

New files:
- `lib/core/models/prayer_notification_settings_model.dart` — `PrayerNotificationSetting` (prayer key/name, `enabled`, `playAdhan`, `preReminderMinutes` clamped 0–30 in steps of 5, `vibrate`) with `toJson`/`fromJson` and a `defaults()` list for the 5 prayers (mirrors `DEFAULT_PRAYER_SETTINGS` in the ref).
- `lib/core/providers/prayer_settings_provider.dart` — `ChangeNotifier` holding the 5 per-prayer settings plus global `adhanVolume` (0–100), `playOnSilent`, `vibrateOnSilent`; master toggle setter (sets all `enabled`); `resetToDefaults()`; persisted as one JSON string in SharedPreferences (same load/save/try-catch style as `StreakProvider`). Registered in `main.dart` `MultiProvider`.
- `lib/screens/settings/prayer_notification_settings_screen.dart` — full-screen `Scaffold`:
  - Header row: back button (`Navigator.pop`), title "Prayer Notifications" + subtitle "Adhan & alert preferences", "Reset" text button.
  - Master toggle card ("All Prayer Notifications", `Switch.adaptive`).
  - Per-prayer cards: icon (reuse `PrayerProvider.getPrayerIcon`) + name + today's time from `PrayerProvider.prayerTimes` + enable switch; when enabled, an expanded section with "Remind before" minus/plus stepper, "Play Adhan" and "Vibrate" switches; when disabled, a one-line "Notifications off for X" footer.
  - "Adhan Playback" card group: volume `Slider` with % label, "Play Even On Silent" and "Vibrate on Silent" switches.
  - Styling: existing card idiom (rounded 24, `AppColors.cardDark/cardLight`, border, shadow), dark/light aware.

Changes to `horizontal_prayer_stepper.dart`:
- Wrap the whole card in `Material` + `InkWell` (borderRadius 24) so the entire card is one tap target; `onTap: Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerNotificationSettingsScreen()))` — this matches the ref's `pushPrayerSettings()` slide-in route and gives free back-button/pop behavior.
- Add a small `Icons.chevron_right` next to the hijri date badge (the ref's caret hint).
- No per-step tap targets (ref explicitly removed them). No other stepper logic changes.

Scope note (user-confirmed): settings are UI + saved preferences only — no notification plugin or scheduling.

## 2. Services & Tools — single horizontal scrolling row

In `services_tools_grid.dart`:
- Replace the `GridView.builder` with a fixed-height (~96) `ListView.separated`, `scrollDirection: Axis.horizontal`, `padding: EdgeInsets.symmetric(horizontal: 16)`, 10px separators, each `_ServiceButton` given a fixed width (~80) via `SizedBox`.
- Header row, service definitions, `_ServiceItem`, `_ServiceButton`, and navigation/snackbar behavior stay unchanged.

## 3. "Random Verse" + swipeable "Random Hadist" card

New files (mirroring the existing verse trio — no duplicated infrastructure, reuses `ApiService`):
- `lib/core/models/hadith_model.dart` — `arabic`, `translation` (`data.id`), `narrator` (`info.perawi.name`), `number` (`data.number`); `fromJson`, `toJson`/`fromCachedJson`, `formattedReference` => `HR. {narrator} No. {number}`. Endpoint verified: `GET /hadits/perawi/acak`.
- `lib/core/services/hadith_service.dart` — same cache-per-day pattern as `VerseService` (SharedPreferences keys + cached-date check, `getDailyHadith`, `forceRefresh`).
- `lib/core/providers/hadith_provider.dart` — same shape as `VerseProvider` (`isLoading`, `errorMessage`, `hadith`, `loadDailyHadith`, `refresh`). Registered in `main.dart`; loaded in `home_screen.dart` `initState` and pull-to-refresh alongside the verse.

Widget rework:
- Rename `lib/widgets/home/verse_of_day_card.dart` -> `lib/widgets/home/random_content_card.dart`; update the import/usage in `home_screen.dart`.
- Convert to a `StatefulWidget` with `PageController` + `SmoothPageIndicator` (`ExpandingDotsEffect`, same pattern/package as `glass_banner.dart`) with 2 pages inside one card shell:
  - Page 1 "RANDOM VERSE" (teal accent, existing verse content/loading/error/retry states).
  - Page 2 "RANDOM HADIST" (indigo accent, Arabic + Indonesian translation + `HR. {narrator} No. {number}`, with its own loading/error/retry driven by `HadithProvider`).
- Fixed card height (~300) since `PageView` needs bounded height; each page's text region wrapped in a vertical `SingleChildScrollView` because perawi hadiths can be very long (vertical scroll inside a horizontal `PageView` does not conflict).
- The existing share/copy bottom sheet is generalized to take pre-built text + subject so both pages reuse it (no duplicated sheet code).

## 4. Streak reset at Subuh instead of midnight

Problem in `streak_provider.dart`: `_checkAndResetDate` compares calendar dates, so at 00:00 (right after Isha) progress resets even though Subuh hasn't arrived.

Fix — introduce a "prayer day" boundary at Fajr:
- `StreakProvider.initialize` gains a required `fajrTime` (HH:mm string) parameter. Compute `effectiveDate`: if `currentDate` is before today's parsed Fajr time, use `currentDate - 1 day`; otherwise use `currentDate`. All existing logic in `_checkAndResetDate` (reset, streak increment when yesterday had 5/5, streak break) then operates on `effectiveDate` unchanged — so the reset only happens once Subuh time hits.
- `home_screen.dart`: both `streakProvider.initialize(...)` calls pass `fajrTime: prayerProvider.prayerTimes!.fajr`.
- `updatePrayerWindow` untouched (it never resets). Pre-Fajr `currentPrayer` is already reported as `Isha`, which stays consistent with the retained previous-day window.

## Test Plan
- `flutter analyze` — zero new issues.
- Run the app: tap anywhere on the stepper card -> settings screen pushes; toggles/slider/reminder steppers work; Reset restores defaults; kill + relaunch -> settings persisted.
- Services row scrolls horizontally, all 8 items reachable, Quran/Mosque/Qibla still navigate.
- Content card: swipe between Random Verse and Random Hadist, dots update, long hadith scrolls vertically, tap opens share sheet for the visible content, pull-to-refresh fetches new verse + hadith.
- Streak: verify no reset between midnight and Subuh (temporarily adjust device clock or Fajr input) and that reset + streak increment occur after Fajr.
- Per AGENTS.md, run `graphify update .` after code changes (best-effort; MCP server currently reports graph.json missing).

## Assumptions
- Notification settings are preferences only (user confirmed) — no adhan playback or scheduled notifications.
- Hadith is cached per day like the verse; pull-to-refresh forces a new random one.
- `PLAN.md` is created at the workspace root with this content as a checkbox task list and updated as tasks complete.