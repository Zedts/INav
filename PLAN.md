# Home Screen Enhancements — Task Plan

Reference: `ref/home_ref.html` (layout only — styling adapted to the existing
`AppColors`/theme system, never copied from CSS).

## 1. Stepper card -> Prayer Notification Settings (Navigator.push)

- [ ] `lib/core/models/prayer_notification_settings_model.dart` —
      `PrayerNotificationSetting` (key/name, `enabled`, `playAdhan`,
      `preReminderMinutes` 0–30 in steps of 5, `vibrate`), JSON round-trip,
      `defaults()` for the 5 prayers.
- [ ] `lib/core/providers/prayer_settings_provider.dart` — per-prayer settings +
      global `adhanVolume`, `playOnSilent`, `vibrateOnSilent`; master toggle;
      `resetToDefaults()`; persisted via SharedPreferences; registered in
      `main.dart`.
- [ ] `lib/screens/settings/prayer_notification_settings_screen.dart` —
      back header, master toggle card, per-prayer cards (time + enable switch +
      remind-before stepper + adhan/vibrate switches), Adhan Playback group.
- [ ] `horizontal_prayer_stepper.dart` — whole card is one `InkWell` tap target
      pushing the settings screen; chevron hint next to hijri badge.
- Scope (user-confirmed): UI + saved preferences only, no real notifications.

## 2. Services & Tools — single horizontal row

- [ ] `services_tools_grid.dart` — replace 4x2 `GridView` with fixed-height
      horizontal `ListView.separated`; fixed-width buttons; behavior unchanged.

## 3. Random Verse + Random Hadist swipeable card

- [ ] `lib/core/models/hadith_model.dart` — from `GET /hadits/perawi/acak`
      (`data.arab`, `data.id`, `info.perawi.name`, `data.number`).
- [ ] `lib/core/services/hadith_service.dart` — cache-per-day pattern mirroring
      `VerseService`.
- [ ] `lib/core/providers/hadith_provider.dart` — mirrors `VerseProvider`;
      registered in `main.dart`; loaded in home screen init + pull-to-refresh.
- [ ] Rename `verse_of_day_card.dart` -> `random_content_card.dart`; PageView
      with 2 pages ("RANDOM VERSE" teal, "RANDOM HADIST" indigo) +
      SmoothPageIndicator dots; long text scrolls vertically; shared
      copy/share bottom sheet.

## 4. Streak resets at Subuh, not midnight

- [ ] `streak_provider.dart` — `initialize` takes `fajrTime`; effective "prayer
      day" starts at Fajr, so the pre-Fajr window keeps yesterday's progress.
- [ ] `home_screen.dart` — pass `fajrTime: prayerProvider.prayerTimes!.fajr`.

## Verification

- [ ] `flutter analyze` clean (no new issues).
- [ ] Manual: stepper tap -> settings push/pop, persistence across relaunch,
      horizontal services scroll, verse/hadist swipe + share, streak boundary.
- [ ] `graphify update .` after code changes (best-effort).
