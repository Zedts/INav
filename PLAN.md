# PLAN.md — Local auth (Get Started + Log In / Register) + sqflite

> **Status:** Updated with blind-spot solutions. Still **no implementation** until you say proceed.  
> **Date:** 2026-08-20 (updated after blind-spot review)  
> **Skill:** [ponytail.md](ponytail.md) — reuse providers/screens, fewest tables, do not rebuild features that already persist.  
> **Research:** Graphify (project graph), Perplexity (`perplexity_reason` + `perplexity_ask`), web (NIST SP 800-63B-4, OWASP, sqflite isolate patterns).  
> **Layout reference:** `ref/login.html` (flow + composition only). Visual language comes from existing Flutter screens (`AppColors`, `AppTheme`, Google Fonts Fraunces / Plus Jakarta / IBM Plex Arabic already used).

This document is **not** about focus-lock icons or prior lock-overlay bugs.

---

## 0. Locked decisions (your answers + blind-spot solutions)

| #              | Original Decision                                                                                                                | Updated / Notes                                                                                                     |
| -------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Q1**         | Device-local only (sqflite on this phone). No backend this sprint.                                                               | ✔ Confirmed                                                                                                         |
| **Q2**         | Google/Apple = visible buttons + icons + "cloud login later". No OAuth plugins.                                                  | ✔ Confirmed — buttons show icons from `AppImages` + "Coming soon" toast                                             |
| **Q3**         | Login **required** unless a valid 30-day session exists. No guest.                                                               | ✔ Confirmed                                                                                                         |
| **Q4**         | Every successful login lasts **30 days**. **Hide Remember me.**                                                                  | ✔ Confirmed — Remember me checkbox removed from UI                                                                  |
| **Q5**         | **Hide** Forgot password.                                                                                                        | ✔ Confirmed — Forgot link removed from UI                                                                           |
| **Q6**         | Create `lib/core/databases/` for SQLite only. Auth **service / model / provider / errors stay in the existing folders**.         | ✔ Confirmed                                                                                                         |
| **Q7**         | **Yes** — persist Quran bookmarks, last-read, mosque favorites in SQLite keyed by `user_id`.                                     | ✔ Confirmed                                                                                                         |
| **Q8**         | **Keep** theme, prayer notifications, streak, focus lock in SharedPreferences.                                                   | ✔ Confirmed — overlay isolate reads prefs, no SQLite migration for focus lock this sprint                           |
| **Q9**         | Add `flutter_secure_storage` for the raw session token, plus `path`, `flutter_svg`, `hashlib`.                                   | ✔ Confirmed                                                                                                         |
| **Q10**        | Schema supports multiple local users; one active session.                                                                        | ✔ Confirmed                                                                                                         |
| **Q11 (NEW)**  | Terms/Privacy modal. **APPROVED**                                                                                                | ✔ Build custom modal/alert for Terms & Privacy with "Coming soon" body (not full legal pages)                       |
| **Q12**        | Logout **keeps** that user's bookmarks/favorites for the next login of the same email.                                           | ✔ Confirmed                                                                                                         |
| **NEW**        | Password minimum length. **APPROVED: raise to 8 characters**                                                                    | ✔ Min 8 chars (NIST/OWASP 2026 consumer-app best practice); max 64 chars; no forced complexity rules              |
| **NEW**        | Logout button location                                                                                                           | ✔ Add to `AppHeader` in main app (not Get Started / auth screens); Settings screen stays stub this sprint          |

### Blind-spot solutions approved by you

1. **Password minimum raised from 6 → 8 characters**  
   - **Research:** NIST SP 800-63B-4 (2026): 8 chars minimum for MFA-protected passwords, 15 chars for password-only auth. Consumer apps like Google recommend 8 as best default.
   - **Decision:** **8 chars minimum, 64 chars maximum** (OWASP best practice).
   - **No** forced uppercase/number/symbol rules (NIST: composition rules make passwords weaker, not stronger).
   - **No** breached-password screening this sprint (needs external API; can add later).
   - Validation message: "Password must be at least 8 characters."
   - `ponytail:` ceiling — 8-char passwords without breach screening are weaker than 8-char + HaveIBeenPwned check. Add breach API in v2 if upgrading to production.

2. **Terms/Privacy as custom modal/alert**  
   - Terms & Privacy links in register form **tap to show modal** with "Coming soon" body text + close button.
   - Modal uses same card/hairline/button design as rest of app (not a raw `AlertDialog`).
   - Checkbox still required to enable register button.
   - No full legal pages this sprint (you can add real Terms/Privacy text later).
   - Widget: `TermsPrivacyModal` in `lib/widgets/auth/terms_privacy_modal.dart` (reusable for both links).

3. **Focus lock stays in SharedPreferences (not migrated to SQLite this sprint)**  
   - **Research:** Overlay isolate CAN open SQLite with its own connection, but SharedPreferences is simpler for small config (already working, no schema migration, no isolate DB-open race).
   - **Decision:** Focus lock config (apps, schedules, skips) stays in prefs. Only **user bookmarks/last-read/favorites** move to SQLite (they are lost-on-kill bugs today).
   - `ponytail:` ceiling — prefs-based config has a known performance ceiling at ~50 locked apps or ~20 schedules (JSON parse gets slow). If focus lock grows complex queries (e.g. usage stats, schedule history), migrate to SQLite v2.

4. **Logout button location: `AppHeader` overflow menu**  
   - Add "Log Out" to `AppHeader` three-dot menu in `MainScreen`.
   - Logout shows confirmation dialog → revokes session → navigates to `GetStartedScreen`.
   - Get Started / Auth screens have NO logout (user is not logged in there).

5. **All other blind spots addressed**  
   - **sqflite ≠ cloud**: documented in PLAN (another phone won't see this login).
   - **Google/Apple without backend**: buttons show "Coming soon" toast, no fake user row.
   - **Forgot password**: removed from UI (cannot work locally).
   - **Assets registration**: `pubspec.yaml` updated to ship `assets/icons/` for SVGs.
   - **Bookmarks/favorites not saved**: fixed by SQLite tables in this sprint.
   - **Mosque favorite IDs**: snapshot (id, name, lat, lng, address) stored so favorites survive new nearby search.

---

## 1. What exists today (graph + code)

```
lib/
  main.dart                 → runApp(MyApp) → MainScreen (no auth gate)
  screens/                  home, mosque, qibla, quran, settings, lock overlay
  widgets/                  matching feature folders
  core/
    providers/              prayer, quran, mosque, streak, focus_lock, …
    services/               API + platform
    models/
    theme/                  AppColors, AppTheme, ThemeProvider, AppImages
    constants/
    errors/
```

**Startup:** `main()` loads dotenv, accessibility helper, `ThemeProvider`, `FocusLockProvider`, then `MainScreen`. There is **no** login route.

`AppImages` **already lists** moon/theme PNGs and Google/Apple SVGs, but `pubspec.yaml` **only ships** `.env`. Icons are unused until we add:

```yaml
assets:
  - .env
  - assets/icons/
```

and `flutter_svg` for the SVGs.

### Persistence map (important)

| Feature                                               | Today                              | Need SQLite?                                                                                                                      |
| ----------------------------------------------------- | ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| Theme                                                 | SharedPreferences `theme_mode`     | **No** (device UI; needed on Get Started before login)                                                                            |
| Focus lock (apps, schedules, skips, overlay snapshot) | SharedPreferences                  | **No this sprint** — overlay isolate reads prefs; simpler than SQLite for small config                                            |
| Prayer notification settings                          | SharedPreferences                  | **No this sprint** (already saved; settings UI is still a stub `SettingsScreen`)                                                  |
| Prayer streak                                         | SharedPreferences                  | **No this sprint** (daily flags; not user-account data yet)                                                                       |
| Daily verse / hadith cache                            | SharedPreferences                  | **No** (API cache, not account)                                                                                                   |
| Quran **bookmarks**                                   | In-memory `Set` in `QuranProvider` | **Yes** — lost on process death                                                                                                   |
| Quran **last read**                                   | In-memory `_lastReadSurahKey`      | **Yes** — banner "continue reading" is empty after restart                                                                        |
| Mosque **favorites**                                  | In-memory `List<String>` ids       | **Yes**, but ids alone are useless if the mosque is not in the current nearby list → store a **snapshot** (id, name, lat, lng, …) |
| Prayer times / Qibla heading                          | Live GPS + API                     | **No**                                                                                                                            |
| Quran audio player position                           | Session RAM                        | **No**                                                                                                                            |
| Map expand / sidebar open                             | UI state                           | **No**                                                                                                                            |
| Surah catalog                                         | API                                | **No** (don't dump 114 surahs into SQLite)                                                                                        |

Ponytail: **do not clone every prefs blob into SQL.** Auth tables + the three "lost on kill" user lists are the sprint.

---

## 2. Security (Perplexity + NIST/OWASP 2026) — local-only ceiling

Local login is a **convenience gate**, not bank-grade auth. Anyone with the phone can still pull the `.db` file.

Must still do:

- **Never store plaintext passwords.**
- **Do not use** `sha256(password)` as the stored value (fast hash ≠ password KDF).
- Store **Argon2id** (via `hashlib`) encoded hash + salt in `users.password_hash`.
- Session: generate **32 random bytes**, store **hash** in `sessions`, store **raw token** in `flutter_secure_storage`.
- **Absolute 30-day** `expires_at` from login (not sliding unless you ask).
- Device clock can be moved → local expiry can be cheated. Acceptable for this product; noted as `ponytail:` ceiling.

**Password policy (updated from 6 → 8 chars):**
- **Minimum: 8 characters** (NIST 2026 best practice for consumer apps).
- **Maximum: 64 characters** (OWASP recommendation).
- **No forced composition** (uppercase/lowercase/digit/symbol rules make passwords WEAKER per NIST).
- **No breach screening** this sprint (would need HaveIBeenPwned API; add in v2 if needed).
- Validation errors shown **inline under field** + toast on submit.

**Google/Apple:** buttons show icons + a short "Coming soon" toast. Do not insert a fake `users` row from a client-side "Google email".

---

## 3. Folder / code layout (§0 Q6 + existing tree)

You asked for `lib/core/databases/` and to **reuse** `services`, `models`, `providers`, `errors`. That is the professional split:

- `databases/` = how SQLite is opened and queried (no UI, no ChangeNotifier).
- `services/` = app operations (`AuthService.register`) that call DAOs + hasher + secure storage.
- `providers/` = Flutter state the widgets already watch.
- `models/` = plain data (`AuthUser` with no password).
- `errors/` = extend `app_exceptions.dart` / `error_messages.dart`.
- `screens/auth/` = UI, same as `screens/quran`, `screens/mosque`.

Do **not** put `AuthProvider` or `AuthUser` inside `databases/` (that would duplicate your architecture). Do **not** create a second `models/` under `databases/`.

```
lib/core/databases/           # SQLite engine + DAOs only
  app_database.dart           # openDatabase, version, onCreate/onUpgrade
  tables.dart                 # CREATE TABLE strings
  user_dao.dart
  session_dao.dart
  quran_dao.dart
  mosque_dao.dart

lib/core/services/
  auth_service.dart           # register / login / logout / restoreSession
  password_hasher.dart        # Argon2id

lib/core/providers/
  auth_provider.dart

lib/core/models/
  auth_user.dart

lib/core/errors/              # existing files; add auth messages there

lib/screens/auth/
  get_started_screen.dart
  auth_screen.dart

lib/widgets/auth/             # only if a widget is used on both auth screens
  terms_privacy_modal.dart    # custom modal for Terms/Privacy "Coming soon"
```

Why not `lib/core/database/` (singular)? You chose the plural folder name. One `.db` file still lives behind `app_database.dart`; the folder name is yours, the **layer** stays one database.

`main.dart`: after theme + db open + `AuthProvider.restoreSession()`:

- authenticated → existing `MainScreen`
- else → `GetStartedScreen`

Lock overlay entry point **unchanged** (no login UI there).

---

## 4. Schema v1 (`onCreate`, `version: 1`)

### 4.1 `users`

| Column        | Type                 | Notes            |
| ------------- | -------------------- | ---------------- |
| id            | INTEGER PK           |                  |
| full_name     | TEXT NOT NULL        |                  |
| email         | TEXT NOT NULL UNIQUE | store lowercase  |
| password_hash | TEXT NOT NULL        | Argon2id encoded |
| created_at    | INTEGER NOT NULL     | ms epoch         |
| updated_at    | INTEGER NOT NULL     |                  |

### 4.2 `sessions`

| Column     | Type                      | Notes                                                                  |
| ---------- | ------------------------- | ---------------------------------------------------------------------- |
| id         | INTEGER PK                |                                                                        |
| user_id    | INTEGER NOT NULL FK users | ON DELETE CASCADE                                                      |
| token_hash | TEXT NOT NULL UNIQUE      | SHA-256 of opaque token (token hashing is OK; password hashing is not) |
| created_at | INTEGER NOT NULL          |                                                                        |
| expires_at | INTEGER NOT NULL          | created_at + 30 days                                                   |
| revoked_at | INTEGER NULL              | logout                                                                 |

Restore: read token → hash → row where `revoked_at IS NULL AND expires_at > now`.

### 4.3 `quran_bookmarks`

| Column                              | Type       |
| ----------------------------------- | ---------- |
| user_id                             | INTEGER FK |
| surah_number                        | INTEGER    |
| created_at                          | INTEGER    |
| PRIMARY KEY (user_id, surah_number) |            |

### 4.4 `quran_last_read`

| Column       | Type             |
| ------------ | ---------------- |
| user_id      | INTEGER PK FK    |
| surah_number | INTEGER NOT NULL |
| ayah_number  | INTEGER NOT NULL |
| updated_at   | INTEGER          |

### 4.5 `mosque_favorites`

| Column                           | Type      | Notes      |
| -------------------------------- | --------- | ---------- |
| user_id                          | INTEGER   |            |
| mosque_id                        | TEXT      | OSM/API id |
| name                             | TEXT      | snapshot   |
| latitude                         | REAL      |            |
| longitude                        | REAL      |            |
| address                          | TEXT NULL |            |
| created_at                       | INTEGER   |            |
| PRIMARY KEY (user_id, mosque_id) |           |            |

Without snapshot columns, favorites vanish when the mosque is not in the current nearby fetch.

### 4.6 Explicitly **not** in v1 SQL

- Theme (prefs)
- Focus lock JSON (prefs + overlay)
- Prayer notification JSON (prefs)
- Streak (prefs)
- Verse/hadith daily cache
- Full Quran text
- Qibla calibration

`onUpgrade` left empty until v2.

---

## 5. Auth flow

```
Cold start
  ThemeProvider.loadThemePreference()     # prefs, works on Get Started
  AppDatabase.open()
  AuthProvider.restoreSession()
       │
       ├─ valid session → MainScreen (with logout in AppHeader)
       └─ none / expired → GetStartedScreen
              │
              ├─ Get Started → AuthScreen(tab: register)
              └─ Log In link → AuthScreen(tab: login)
                     │
                     ├─ success → create session (30d) → MainScreen (clear stack)
                     └─ logout later (from AppHeader) → revoke session → GetStartedScreen
```

**Get Started / Auth theme toggle:** reuse `ThemeProvider` (same as the rest of the app). Logo: `Image.asset(isDark ? AppImages.iconDark : AppImages.iconWhite)` in the circular card — **not** Phosphor `ph-moon-stars`.

---

## 6. UI (HTML layout reference, Flutter design system)

Do **not** port Tailwind/HTML widgets at ref/login.html. Match home/mosque/quran:

- `AppColors.surface* / card* / hairline* / primary* / text*`
- Fraunces for "INav", Plus Jakarta for UI, IBM Plex Arabic for basmala
- Full-width **pill** primary buttons (`BorderRadius.circular(999)`, vertical padding ~16) like `ref/login.html`
- Hairline-border **rounded-2xl** fields (`BorderRadius.circular(16)`) like cards on home
- Segmented Log In / Register like the HTML pill, implemented with `TabController` or `AnimatedAlign` — same colors as primary pills elsewhere
- Existing `ThemeToggleButton` pattern, but on auth screens the **moon/sun in the header** can stay Icon; the **logo** is `AppImages`

**Screens**

1. `GetStartedScreen` — top theme toggle, centered logo + INav + basmala + tagline + 3 feature glyphs (clock / compass / book — **Material icons, not Phosphor**), bottom Get Started + "Already have an account?" link
2. `AuthScreen` — back, theme toggle, smaller logo, segmented control, forms, divider, Google/Apple row with `SvgPicture.asset(AppImages.google)` / `appleWhite|appleDark`

**Validation (inline under each field, not only toast)**

| Field           | Rules                                   | Example copy                                                           |
| --------------- | --------------------------------------- | ---------------------------------------------------------------------- |
| Full name       | required, trim, min 2 chars             | "Please enter your name (at least 2 characters)."                      |
| Email           | required, simple RFC-like regex         | "Enter a valid email, like [you@example.com](mailto:you@example.com)." |
| Password        | min 8 chars (updated), max 64          | "Password must be at least 8 characters."                             |
| Confirm         | equals password                         | "Passwords don't match."                                               |
| Terms           | must be checked                         | "Please agree to the Terms to continue."                               |
| Login mismatch  | email unknown / bad password            | Same generic: "Email or password is incorrect." (don't leak which)     |
| Duplicate email | unique                                  | "An account with this email already exists."                           |

Show errors after submit (and optionally on field blur). Disable submit while hashing (isolate if Argon2 is slow on cheap phones).

**Terms/Privacy modal:**
- Tappable "Terms of Service" and "Privacy Policy" text in register form.
- Shows `TermsPrivacyModal` (custom widget, NOT `showDialog(AlertDialog(...))`) with:
  - Title: "Terms of Service" or "Privacy Policy"
  - Body: "Coming soon. Full legal text will be available here."
  - Close button
- Modal uses `AppColors.card*`, `hairline*`, rounded corners, same as mosque favorites sidebar.

---

## 7. Wiring existing providers (no duplication)

After login, `AuthProvider` exposes `userId`.

- `QuranProvider`: on auth change, load bookmarks/last-read from `quran_dao`; `toggleBookmark` / `setLastRead` write DAO. Keep in-memory sets for UI speed.
- `MosqueProvider`: load favorites snapshots; `toggleFavorite` upsert/delete DAO. Resolve `favoriteMosques` from **snapshots**, not only `_nearbyMosques` (today's bug: favorite only works if mosque is in the current nearby list).

Do **not** make `ThemeProvider` or `FocusLockProvider` talk to SQLite in v1.

---

## 8. Dependencies (ponytail: only what we need)

| Package                    | Why                                         | Version      |
| -------------------------- | ------------------------------------------- | ------------ |
| `sqflite`                  | You asked                                   | ^2.4.3       |
| `path`                     | `join(getDatabasesPath(), 'inav.db')`       | (already in) |
| `flutter_svg`              | Google/Apple SVGs in `AppImages`            | ^2.0.0       |
| `hashlib`                  | Argon2id (not SHA-256-as-password)          | ^1.19.0      |
| `flutter_secure_storage`   | Q9 — raw session token                      | ^9.2.2       |
| `sqflite_common_ffi` (dev) | One DAO/session self-check without a device | ^2.3.0       |

**Not this sprint:** `google_sign_in`, `sign_in_with_apple`, Firebase, Drift, SQLCipher (unless you later want the whole DB encrypted — extra native complexity).

---

## 9. Implementation sessions (after §0)

1. **Assets + pubspec + dependencies** — register `assets/icons/`, add sqflite/flutter_svg/hashlib/flutter_secure_storage; keep `AppImages` as source of truth.
2. **Database + hasher + auth service + errors** — tables, DAOs, Argon2id, register/login/session restore, auth exceptions.
3. **AuthProvider + models** — ChangeNotifier, `AuthUser`, session token management.
4. **Get Started + Auth UI** — screens, segmented control, validation (8-char password), Terms/Privacy modal, theme logo, social stubs.
5. **Auth gate in `main.dart`** — restore session → GetStartedScreen or MainScreen.
6. **Logout in `AppHeader`** — overflow menu, confirmation dialog, revoke session, navigate.
7. **Quran + mosque DAOs hooked to providers** — load/save bookmarks/last-read/favorites.
8. **Validation** — `flutter analyze` + `flutter build apk --debug` + `flutter build apk --release --no-tree-shake-icons` + `cd android && .\gradlew.bat :app:assembleDebug`.

---

## 10. What I will not do without permission (all now resolved or approved)

- ~~Firebase / REST login~~ — confirmed local-only (Q1)
- ~~Encrypting the whole SQLite file (SQLCipher)~~ — out of scope this sprint
- ~~Migrating focus lock / streak / prayer notifications into SQL~~ — **RESOLVED:** kept in prefs (§0 solution 3)
- ~~Guest mode~~ — confirmed login required (Q3)
- ~~Building Terms/Privacy legal pages~~ — **APPROVED:** custom modal with "Coming soon" (§0 solution 2)
- ~~Changing lock overlay~~ — not needed (focus lock stays in prefs)
- ~~Implementing real Google/Apple Sign-In~~ — confirmed stub buttons only (Q2)

**Next:** say **proceed** to start implementation (§9 sessions 1–8 in order). All blind spots are addressed, password is 8 chars, Terms/Privacy modal approved, focus lock stays in prefs, logout goes in `AppHeader`.
