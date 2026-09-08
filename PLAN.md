---
title: SQFlite → Firebase Migration Plan
project: inav
author: Auto-generated
status: Approved — Pending Implementation
---

# SQFlite → Firebase Migration Plan

> **Ponytail Principle Applied**: Every row below was validated against YAGNI. No abstractions added that aren't forced by the backend switch. Minimal file surface. One write path per entity.

---

## 1. Executive Summary

| Aspect | Before (SQFlite) | After (Firebase) |
|---|---|---|
| Auth | Local: `users` + `sessions` tables, PasswordHasher, FlutterSecureStorage token | **Firebase Auth Email/Password**. `authStateChanges()` drives AuthGate. UIDs are Strings. |
| Quran Bookmarks | `quran_bookmarks` table, composite PK (user_id int, surah_number) | Subcollection: `/users/{uid}/quranBookmarks/{surahNumber}` |
| Quran Last Read | `quran_last_read` table, 1:1 per user | Subcollection: `/users/{uid}/quranLastRead/current` (single doc) |
| Mosque Favorites | `mosque_favorites` table, snapshot (name, address, lat, lng) stored inline | Subcollection: `/users/{uid}/mosqueFavorites/{mosqueId}`, snapshot preserved |
| User ID Type | `int` (autoincrement) | `String` (Firebase Auth UID) |
| Offline | 100% local SQLite | Firestore **persistenceEnabled: true** (default on Android). Last-write-wins conflict resolution. |
| Multi-Device | None | **Real-time sync** via `.snapshots()` streams. Same account → bookmarks follow user. |
| DB Init | `AppDatabase._open()` → `openDatabase()` with `onCreate` DDL | No schema init client-side. Security rules + first write create documents. |

### Scope Decisions (Confirmed)
- ✅ **Full Firebase Auth replacement** — delete SQFlite `users`/`sessions` tables, PasswordHasher usage
- ✅ **Cloud sync across devices** — Firestore snapshots, not one-way backup
- ✅ **Fresh deployment** — no legacy data migration code needed
- ✅ **Snapshot storage for mosque favorites** — preserve name/address/lat/lng inline
- ✅ **No anonymous auth** — require sign-in for any persisted user data
- ✅ **Android + Web targets** only — no Apple/desktop FlutterFire reconfigure

---

## 2. Current SQFlite Inventory (Complete)

### 2.1 Files to Modify or Delete

| File | Action | SQFlite Touchpoints |
|---|---|---|
| `lib/core/databases/app_database.dart` | **DELETE** | Entire file: schema + 5 table CREATE statements |
| `lib/core/services/auth_service.dart` | **REWRITE** | 8 methods use `AppDatabase.database`: `restoreSession`, `register`, `login`, `logout`, `updateProfile`, `verifyCurrentPassword`, `deleteAccount`, `_startSession` |
| `lib/core/providers/quran_provider.dart` | **MODIFY** | 3 methods: `setUser()` (load bookmarks + lastRead), `toggleBookmark()`, `setLastRead()` |
| `lib/core/providers/mosque_provider.dart` | **MODIFY** | 2 methods: `setUser()` (load favorites), `toggleFavoriteMosque()` |
| `lib/core/providers/auth_provider.dart` | **MODIFY** | Type changes: `AuthUser.id` int→String, add `authStateChanges()` subscription |
| `lib/core/models/auth_user.dart` | **MODIFY** | Field `id`: `int` → `String` |
| `lib/main.dart` | **MODIFY** | `AuthProvider.userId` is now String. ProxyProvider signatures for QuranProvider/MosqueProvider change. |
| `pubspec.yaml` | **MODIFY** | Remove `sqflite: ^2.4.3` and `sqflite_common_ffi: ^2.4.2+1` |

### 2.2 Complete SQFlite Schema → CRUD Matrix

#### Table: `users` (DELETED — replaced by Firebase Auth)
```sql
CREATE TABLE users (
  id            INTEGER PRIMARY KEY,
  full_name     TEXT    NOT NULL,
  email         TEXT    NOT NULL UNIQUE,
  password_hash TEXT    NOT NULL,
  created_at    INTEGER NOT NULL,
  updated_at    INTEGER NOT NULL
)
```
| Operation | Location | Replacement |
|---|---|---|
| INSERT (register) | `AuthService.register()` L49-55 | `FirebaseAuth.createUserWithEmailAndPassword()` + Firestore `/users/{uid}` doc set |
| SELECT WHERE email (login) | `AuthService.login()` L66-73 | `FirebaseAuth.signInWithEmailAndPassword()` |
| SELECT WHERE id (profile verify) | `AuthService.updateProfile()` L113, `verifyCurrentPassword()` L144-151 | `FirebaseAuth.currentUser` + `reauthenticateWithCredential()` |
| UPDATE (profile) | `AuthService.updateProfile()` L128-134 transaction | `User.updateDisplayName()`, `User.updateEmail()`, `User.updatePassword()` + Firestore merge |
| DELETE (account) | `AuthService.deleteAccount()` L161-165 | `User.delete()` + Firestore recursive delete or batch |

#### Table: `sessions` (DELETED — replaced by Firebase Auth token management)
```sql
CREATE TABLE sessions (
  id         INTEGER PRIMARY KEY,
  user_id    INTEGER NOT NULL,
  token_hash TEXT    NOT NULL UNIQUE,
  created_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL,
  revoked_at INTEGER,
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
)
```
| Operation | Location | Replacement |
|---|---|---|
| INSERT + UPDATE (revoke old) | `AuthService._startSession()` L175-188 transaction | Firebase Auth manages ID/refresh tokens automatically. No client session writes. |
| JOIN query restoreSession | `AuthService.restoreSession()` L24-27 | `FirebaseAuth.authStateChanges()` + `FirebaseAuth.currentUser` |
| UPDATE (revoke on logout) | `AuthService.logout()` L82-87 | `FirebaseAuth.signOut()` |

#### Table: `quran_bookmarks` → Subcollection
```sql
CREATE TABLE quran_bookmarks (
  user_id      INTEGER NOT NULL,
  surah_number INTEGER NOT NULL,
  created_at   INTEGER NOT NULL,
  PRIMARY KEY (user_id, surah_number),
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
)
```
| Operation | Location | Replacement |
|---|---|---|
| SELECT WHERE user_id = ? | `QuranProvider.setUser()` L329-337 | `.collection('users/$uid/quranBookmarks').snapshots()` → stream into `_bookmarkedSurahNumbers` |
| DELETE (unbookmark) | `QuranProvider.toggleBookmark()` L355-359 | `.doc('users/$uid/quranBookmarks/$surahNum').delete()` |
| INSERT (bookmark) | `QuranProvider.toggleBookmark()` L363-367 | `.doc('users/$uid/quranBookmarks/$surahNum').set({surahNumber, createdAt})` |

#### Table: `quran_last_read` → Single doc in subcollection
```sql
CREATE TABLE quran_last_read (
  user_id      INTEGER PRIMARY KEY,
  surah_number INTEGER NOT NULL,
  ayah_number  INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
)
```
| Operation | Location | Replacement |
|---|---|---|
| SELECT WHERE user_id = ? | `QuranProvider.setUser()` L338-345 | `.doc('users/$uid/quranLastRead/current').get()` |
| INSERT OR REPLACE | `QuranProvider.setLastRead()` L417-422 | `.doc('users/$uid/quranLastRead/current').set(data, SetOptions(merge: true))` |

#### Table: `mosque_favorites` → Subcollection (snapshot preserved)
```sql
CREATE TABLE mosque_favorites (
  user_id    INTEGER NOT NULL,
  mosque_id  TEXT    NOT NULL,
  name       TEXT    NOT NULL,
  latitude   REAL    NOT NULL,
  longitude  REAL    NOT NULL,
  address    TEXT,
  created_at INTEGER NOT NULL,
  PRIMARY KEY (user_id, mosque_id),
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
)
```
| Operation | Location | Replacement |
|---|---|---|
| SELECT WHERE user_id = ? | `MosqueProvider.setUser()` L217-233 | `.collection('users/$uid/mosqueFavorites').snapshots()` → rebuild `_favoriteMosqueIds` + `_favoriteSnapshots` |
| DELETE (unfavorite) | `MosqueProvider.toggleFavoriteMosque()` L245-249 | `.doc('users/$uid/mosqueFavorites/$mosqueId').delete()` |
| INSERT OR REPLACE | `MosqueProvider.toggleFavoriteMosque()` L254-262 | `.doc('users/$uid/mosqueFavorites/$mosqueId').set(snapshotData)` |

---

## 3. Target Firebase Architecture

### 3.1 Firestore Data Model

```
/users/{uid}                                    ← AuthUser profile (read/write by owner only)
  displayName:    string
  email:          string
  createdAt:      Timestamp
  updatedAt:      Timestamp

/users/{uid}/quranBookmarks/{surahNumberStr}    ← doc ID = surah number as string (1..114)
  surahNumber:    number                        ← redundant for queries/rules
  createdAt:      Timestamp

/users/{uid}/quranLastRead/current              ← single known document ID
  surahNumber:    number
  ayahNumber:     number
  updatedAt:      Timestamp

/users/{uid}/mosqueFavorites/{mosqueId}         ← doc ID = mosque.place_id / API ID
  mosqueId:       string                        ← redundant for rules
  name:           string
  address:        string
  latitude:       number
  longitude:      number
  createdAt:      Timestamp
```

**Design Rationale (Ponytail-validated)**:
- **Subcollections under `/users/{uid}/...`** — simplest security rules pattern. No ownerUid field to validate on every write. Rules = 1 line per subcollection.
- **Doc ID encodes the relationship key** — `surahNumberStr`, `mosqueId` as doc ID. No extra uniqueness transaction needed. Deterministic path = idempotent writes for free.
- **`quranLastRead/current` as single doc** — avoids a query for something with exactly one row. Simpler than a collection with 1 document.
- **Snapshot preserved on mosqueFavorites** — matches current SQFlite pattern. No live API dependency for favorites display. Works fully offline after first write.

### 3.2 Firebase Auth Integration Design

- **Auth state source of truth**: `FirebaseAuth.instance.authStateChanges()` stream
- **No local session tokens**: FlutterSecureStorage `inav.session.token` key RETIRED. Firebase SDK persists credentials natively.
- **No PasswordHasher**: SDK handles scrypt hashing server-side. Remove hash verification client code entirely.
- **Profile re-auth flow**: `updateProfile`/`deleteAccount` use `FirebaseAuth.currentUser.reauthenticateWithCredential(EmailAuthProvider.credential(...))` instead of local password_hash SELECT + verify.

### 3.3 Firestore Offline Configuration

```dart
// lib/main.dart — call once after Firebase.initializeApp()
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,    // default on Android/iOS; explicit for clarity
  cacheSizeBytes: 64 * 1024 * 1024,  // 64 MB cap; prevents unbounded growth
);
```

- No explicit `enablePersistence()` call on Android. Default is on.
- Cache metadata exposed to UI: `snapshots(includeMetadataChanges: true)` → read `snapshot.metadata.isFromCache` / `hasPendingWrites` where UX matters (e.g., favorite toggle confirmation).

### 3.4 Firestore Security Rules (Production)

```javascript
// firestore.rules — deploy via Firebase Console or CLI
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function signedIn() {
      return request.auth != null;
    }

    function isOwner(uid) {
      return signedIn() && request.auth.uid == uid;
    }

    // ------------------------------
    // User profile
    // ------------------------------
    match /users/{uid} {
      allow read: if isOwner(uid);

      allow create: if isOwner(uid)
        && request.resource.data.keys().hasOnly(['displayName', 'email', 'createdAt', 'updatedAt'])
        && request.resource.data.displayName is string
        && request.resource.data.email is string
        && request.resource.data.createdAt is timestamp;

      allow update: if isOwner(uid)
        && request.resource.data.keys().hasOnly(['displayName', 'email', 'updatedAt'])
        && request.resource.data.displayName is string
        && request.resource.data.email is string;

      allow delete: if isOwner(uid);
    }

    // ------------------------------
    // Quran Bookmarks
    // docId must match surahNumber field (1..114)
    // ------------------------------
    match /users/{uid}/quranBookmarks/{surahStr} {
      allow read, delete: if isOwner(uid);

      allow create, update: if isOwner(uid)
        && request.resource.data.keys().hasOnly(['surahNumber', 'createdAt'])
        && request.resource.data.surahNumber is int
        && request.resource.data.surahNumber >= 1
        && request.resource.data.surahNumber <= 114
        && request.resource.data.surahNumber == int(surahStr)
        && request.resource.data.createdAt is timestamp;
    }

    // ------------------------------
    // Quran Last Read (single doc: "current")
    // ------------------------------
    match /users/{uid}/quranLastRead/{docId} {
      allow read, delete: if isOwner(uid) && docId == 'current';

      allow create, update: if isOwner(uid) && docId == 'current'
        && request.resource.data.keys().hasOnly(['surahNumber', 'ayahNumber', 'updatedAt'])
        && request.resource.data.surahNumber is int
        && request.resource.data.surahNumber >= 1
        && request.resource.data.surahNumber <= 114
        && request.resource.data.ayahNumber is int
        && request.resource.data.ayahNumber >= 1
        && request.resource.data.updatedAt is timestamp;
    }

    // ------------------------------
    // Mosque Favorites (snapshot stored inline)
    // ------------------------------
    match /users/{uid}/mosqueFavorites/{mosqueId} {
      allow read, delete: if isOwner(uid);

      allow create, update: if isOwner(uid)
        && request.resource.data.keys().hasOnly([
            'mosqueId', 'name', 'address', 'latitude', 'longitude', 'createdAt'
        ])
        && request.resource.data.mosqueId == mosqueId
        && request.resource.data.name is string
        && request.resource.data.name.size() > 0
        && request.resource.data.address is string
        && request.resource.data.latitude is number
        && request.resource.data.longitude is number
        && request.resource.data.createdAt is timestamp;
    }
  }
}
```

**Index requirements** — Firestore will auto-generate links on first failed query. Anticipated composite index:
- `mosqueFavorites`: `(createdAt Ascending)` — if we ever show favorites sorted by newest first (current code doesn't, but it's a likely UX ask).

---

## 4. Step-by-Step Migration Plan

Execute in order. Each step is independently verifiable.

### Phase 0 — Prerequisites (Before any code change)
1. **Firebase Console setup**:
   - Enable **Email/Password** sign-in method in Firebase Auth → Sign-in method
   - Deploy the `firestore.rules` from §3.4 (via Console → Firestore → Rules tab, or CLI: `firebase deploy --only firestore:rules`)
   - Verify Firestore database is in **Native mode** (not Datastore mode)
   - Set Firestore location to nearest multi-region for your user base (already set during project init: confirm in Console → Firestore → Data → top banner)
2. **Run baseline**:
   ```bash
   flutter pub get
   flutter analyze
   flutter build apk --debug    # or flutter build web --profile
   ```
   Fix any pre-existing errors before touching migration code.

### Phase 1 — AuthUser model + AuthProvider plumbing (id int→String)
**Goal**: Type-safe ripple of UID change through the provider layer before touching services.

1. **Modify `lib/core/models/auth_user.dart`**:
   - `final int id` → `final String id`
   - `fromMap`: `map['id'] as int` → `map['id'] as String`
   - Constructor signature accepts `String id`

2. **Modify `lib/core/providers/auth_provider.dart`**:
   - Add `StreamSubscription<User?>? _authSub;`
   - Constructor: subscribe to `FirebaseAuth.instance.authStateChanges()` → convert `User` → `AuthUser(id: uid, fullName: displayName ?? '', email: email ?? '')` → set `_user`, notifyListeners
   - `restoreSession()` simplified: waits for first `authStateChanges()` emit, or reads `currentUser` directly. No SQFlite query.
   - `userId` getter returns `String?` (was `int?`)
   - `dispose()` cancels `_authSub`

3. **Fix type references in `lib/main.dart`**:
   - `ChangeNotifierProxyProvider<AuthProvider, QuranProvider>` — `auth.userId` is now `String?`. `quran.setUser(auth.userId)` signature changes to `setUser(String? uid)`.
   - Same for `MosqueProvider.setUser(String? uid)`.

### Phase 2 — Rewrite AuthService to use Firebase Auth
**Goal**: Zero SQFlite import in `auth_service.dart`. Delete PasswordHasher dependency for credential checks.

1. **Import changes**:
   - Remove: `import '../databases/app_database.dart';`, `import 'password_hasher.dart';`, `import 'package:hashlib/hashlib.dart';`, `import 'package:flutter_secure_storage/flutter_secure_storage.dart';`
   - Add: `import 'package:firebase_auth/firebase_auth.dart';`, `import 'package:cloud_firestore/cloud_firestore.dart';`

2. **Remove fields**: `_hasher`, `_key`, `_storage`. Constructor simplified to no-arg.

3. **Rewrite each method** (see §5 for exact method bodies):
   - `restoreSession()` → read `FirebaseAuth.instance.currentUser` → return `AuthUser?` or null.
   - `register({fullName, email, password})` → `createUserWithEmailAndPassword` + `updateDisplayName` + Firestore `/users/{uid}` doc set.
   - `login({email, password})` → `signInWithEmailAndPassword` + ensure `/users/{uid}` profile doc exists.
   - `logout()` → `FirebaseAuth.instance.signOut()` (no session revoke query; SDK invalidates token).
   - `updateProfile({user, fullName, email, currentPassword, newPassword})` → `reauthenticateWithCredential(EmailAuthProvider.credential(user.email, currentPassword))` → `updateDisplayName` → `updateEmail` → (optional) `updatePassword` → Firestore doc merge.
   - `verifyCurrentPassword({user, password})` → `reauthenticateWithCredential(...)` → returns `true` on success, `false` on `FirebaseAuthException`.
   - `deleteAccount({user, password})` → `reauthenticateWithCredential` → `FirebaseFirestore.instance.doc('users/${user.uid}').delete()` (note: subcollections NOT auto-deleted; for full cleanup use `WriteBatch` or Cloud Function) → `user.delete()` → `signOut()`.
   - Delete `_startSession()` and `_tokenHash()` entirely.

4. **Verify**: No `AppDatabase` references remain in this file. No raw SQL. No password hash logic.

### Phase 3 — Refactor QuranProvider to Firestore
**Goal**: Replace `AppDatabase.database` calls with Firestore streams + writes.

1. **Imports**:
   - Remove: `import '../databases/app_database.dart';`, `import 'package:sqflite/sqflite.dart';`
   - Add: `import 'package:cloud_firestore/cloud_firestore.dart';`, `import 'package:firebase_auth/firebase_auth.dart';`

2. **Fields**:
   - Add `StreamSubscription<QuerySnapshot>? _bookmarksSub;`
   - Add `StreamSubscription<DocumentSnapshot>? _lastReadSub;`
   - Add `String? _currentUid;` (already exists as `_userId`; rename or reuse)

3. **`setUser(String? uid)`** rewrite:
   - If same uid → return (unchanged)
   - Cancel old `_bookmarksSub` + `_lastReadSub` if active
   - Clear `_bookmarkedSurahNumbers`, `_lastReadSurahKey`
   - If uid != null:
     ```dart
     _bookmarksSub = FirebaseFirestore.instance
         .collection('users/$uid/quranBookmarks')
         .snapshots()
         .listen((snap) {
           _bookmarkedSurahNumbers
             ..clear()
             ..addAll(snap.docs.map((d) => d.id));
           notifyListeners();
         });
     _lastReadSub = FirebaseFirestore.instance
         .doc('users/$uid/quranLastRead/current')
         .snapshots()
         .listen((snap) {
           if (snap.exists) {
             final data = snap.data()!;
             _lastReadSurahKey = '${data['surahNumber']}:${data['ayahNumber']}';
           } else {
             _lastReadSurahKey = null;
           }
           notifyListeners();
         });
     ```
   - If uid == null: subs cancelled, state cleared.

4. **`toggleBookmark(String surahNumber)`** rewrite:
   - Update in-memory state IMMEDIATELY (optimistic UI), then fire Firestore write:
   ```dart
   final uid = _currentUid;
   final wasBookmarked = _bookmarkedSurahNumbers.contains(surahNumber);
   if (wasBookmarked) {
     _bookmarkedSurahNumbers.remove(surahNumber);
     notifyListeners();
     if (uid != null) {
       await FirebaseFirestore.instance
           .doc('users/$uid/quranBookmarks/$surahNumber')
           .delete();
     }
   } else {
     _bookmarkedSurahNumbers.add(surahNumber);
     notifyListeners();
     if (uid != null) {
       await FirebaseFirestore.instance
           .doc('users/$uid/quranBookmarks/$surahNumber')
           .set({
         'surahNumber': int.parse(surahNumber),
         'createdAt': FieldValue.serverTimestamp(),
       });
     }
   }
   ```
   **Rationale**: Optimistic local update + async server write = no UI spinner needed. Firestore's offline queue ensures write happens when back online. Conflict = server write wins on next snapshot, which repaints UI correctly.

5. **`setLastRead(int surahNumber, int ayahNumber)`** rewrite:
   ```dart
   _lastReadSurahKey = '$surahNumber:$ayahNumber';
   notifyListeners();
   final uid = _currentUid;
   if (uid != null) {
     await FirebaseFirestore.instance
         .doc('users/$uid/quranLastRead/current')
         .set({
       'surahNumber': surahNumber,
       'ayahNumber': ayahNumber,
       'updatedAt': FieldValue.serverTimestamp(),
     }, SetOptions(merge: true));
   }
   ```

6. **`dispose()`**: Add cancellation of `_bookmarksSub` and `_lastReadSub`.

### Phase 4 — Refactor MosqueProvider to Firestore
**Goal**: Same pattern as QuranProvider — snapshot streams for favorites, optimistic writes on toggle.

1. **Imports**:
   - Remove: `import '../databases/app_database.dart';`, `import 'package:sqflite/sqflite.dart';`
   - Add: `import 'package:cloud_firestore/cloud_firestore.dart';`

2. **Fields**:
   - Add `StreamSubscription<QuerySnapshot>? _favoritesSub;`

3. **`setUser(String? uid)`** rewrite:
   - Cancel old `_favoritesSub`
   - Clear `_favoriteMosqueIds`, `_favoriteSnapshots`
   - If uid != null:
     ```dart
     _favoritesSub = FirebaseFirestore.instance
         .collection('users/$uid/mosqueFavorites')
         .snapshots()
         .listen((snap) {
           _favoriteMosqueIds.clear();
           _favoriteSnapshots.clear();
           for (final doc in snap.docs) {
             final data = doc.data();
             final mosque = MosqueModel(
               id: data['mosqueId'] as String,
               name: data['name'] as String,
               address: data['address'] as String? ?? 'Address not available',
               latitude: (data['latitude'] as num).toDouble(),
               longitude: (data['longitude'] as num).toDouble(),
               distanceKm: 0,
             );
             _favoriteMosqueIds.add(mosque.id);
             _favoriteSnapshots.add(mosque);
           }
           notifyListeners();
         });
     ```

4. **`toggleFavoriteMosque(MosqueModel mosque)`** rewrite:
   - Optimistic UI first, async Firestore write second:
   ```dart
   final idx = _favoriteMosqueIds.indexOf(mosque.id);
   final uid = _userId;
   if (idx >= 0) {
     // Remove from UI immediately
     _favoriteMosqueIds.removeAt(idx);
     _favoriteSnapshots.removeWhere((m) => m.id == mosque.id);
     notifyListeners();
     if (uid != null) {
       await FirebaseFirestore.instance
           .doc('users/$uid/mosqueFavorites/${mosque.id}')
           .delete();
     }
   } else {
     // Add to UI immediately
     _favoriteMosqueIds.add(mosque.id);
     _favoriteSnapshots.add(mosque);
     notifyListeners();
     if (uid != null) {
       await FirebaseFirestore.instance
           .doc('users/$uid/mosqueFavorites/${mosque.id}')
           .set({
         'mosqueId': mosque.id,
         'name': mosque.name,
         'address': mosque.address,
         'latitude': mosque.latitude,
         'longitude': mosque.longitude,
         'createdAt': FieldValue.serverTimestamp(),
       }, SetOptions(merge: true));
     }
   }
   ```

5. **`dispose()`**: Cancel `_favoritesSub`.

### Phase 5 — Cleanup (Delete old code, remove dependencies)
1. **Delete files**:
   - `lib/core/databases/app_database.dart`
   - `lib/core/services/password_hasher.dart` (if not used elsewhere — verify first with grep)
   - Remove FlutterSecureStorage `inav.session.token` key writes/reads EVERYWHERE. Check if FlutterSecureStorage is used for other keys; if not, can remove the package entirely.

2. **Edit `pubspec.yaml`**:
   - Remove from `dependencies`: `sqflite: ^2.4.3`
   - Remove from `dependencies`: `hashlib: ^2.4.2` (if PasswordHasher is the only user)
   - Remove from `dev_dependencies`: `sqflite_common_ffi: ^2.4.2+1`
   - Keep `path: ^1.9.1` only if used elsewhere (grep first); it was transitive for sqflite but may be used for other file ops.
   - Keep `flutter_secure_storage` if other features use it.

3. **Run**:
   ```bash
   flutter pub get
   flutter clean
   flutter pub get
   ```

### Phase 6 — Firestore settings + AuthGate verification
1. **Add to `lib/main.dart` after `Firebase.initializeApp()`**:
   ```dart
   FirebaseFirestore.instance.settings = const Settings(
     persistenceEnabled: true,
     cacheSizeBytes: 64 * 1024 * 1024,
   );
   ```

2. **Verify AuthGate behavior**:
   - `authStateChanges()` emits null → AuthGate shows login/register
   - After sign-in → AuthGate emits User → navigate to MainScreen
   - `AuthProvider.userId` (String) correctly propagates through `ChangeNotifierProxyProvider` → `QuranProvider.setUser(uid)` and `MosqueProvider.setUser(uid)` fire → streams subscribe → UI populates bookmarks/favorites from Firestore

### Phase 7 — Verification & QA
1. **Run analyzer**: `flutter analyze` — 0 errors, 0 warnings related to migration
2. **Build**:
   ```bash
   flutter build apk --debug        # or --release
   # and/or
   flutter build web --profile
   ```
3. **Manual test matrix**:
   | Test Case | Expected |
   |---|---|
   | Register new account | Account appears in Firebase Auth console + `/users/{uid}` doc created |
   | Logout + Login | Session restored, bookmarks/favorites load from Firestore |
   | Toggle quran bookmark | Instant UI change, doc appears in `/users/{uid}/quranBookmarks/` |
   | Toggle mosque favorite | Instant UI change, snapshot doc appears with name/address/lat/lng |
   | Scroll in surah → setLastRead | `/users/{uid}/quranLastRead/current` updated with surah+ayah |
   | Update profile (same password, new email) | Email changes in Auth + Firestore doc |
   | Change password | Next login requires new password |
   | Delete account | User removed from Auth, `/users/{uid}` doc deleted |
   | **Device A bookmarks → Device B same account** | Within ~2 seconds, device B shows new bookmark via snapshot stream |
   | **Toggle AIRPLANE MODE → toggle bookmark → turn off airplane** | Write syncs automatically when online; no error UI needed |
   | **No internet → first app launch → try register** | `FirebaseAuthException` caught → friendly error (already handled by `friendlyErrorMessage` pattern in providers) |

4. **Security rules validation** (Firebase Console → Rules → Playground or use `firebase emulators:exec`):
   - Unauthenticated read of `/users/{anyUid}` → DENY
   - Authenticated user A read of `/users/{userB}` → DENY
   - Authenticated user A create doc in `/users/{userA}/quranBookmarks/115` (surah 115 invalid) → DENY (rules enforce 1-114)
   - Authenticated user A create favorite with missing `latitude` field → DENY

---

## 5. Method-by-Method Replacement Reference

### 5.1 AuthService.register() — New Implementation Sketch

```dart
// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_user.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AuthUser?> restoreSession() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    return AuthUser(id: u.uid, fullName: u.displayName ?? '', email: u.email ?? '');
  }

  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final u = cred.user!;
      await u.updateDisplayName(fullName.trim());
      await _firestore.collection('users').doc(u.uid).set({
        'displayName': fullName.trim(),
        'email': u.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return AuthUser(id: u.uid, fullName: fullName.trim(), email: u.email ?? '');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw const AuthException('An account with this email already exists.');
        case 'weak-password':
          throw const AuthException('Password should be at least 6 characters.');
        case 'invalid-email':
          throw const AuthException('Enter a valid email address.');
        default:
          throw AuthException(e.message ?? 'Registration failed. Please try again.');
      }
    }
  }
  // ... see §4 Phase 2 for remaining methods
}
```

### 5.2 Error Code Translation Map (FirebaseAuthException → AuthException)

| FirebaseAuthException.code | AuthException message (keep existing UX copy) |
|---|---|
| `user-not-found`, `wrong-password`, `invalid-credential` | "Email or password is incorrect." |
| `email-already-in-use` | "An account with this email already exists." |
| `weak-password` | "Your new password must be 8–64 characters." (keep existing length rule; note Firebase default is 6, enforce 8 client-side before calling) |
| `invalid-email` | "Enter a valid name and email address." |
| `requires-recent-login` | "Please log out and back in before making this change." |
| `network-request-failed` | "No internet connection. Try again when online." |
| `too-many-requests` | "Too many attempts. Try again later." |
| Everything else | e.message ?? fallback |

---

## 6. Dependencies Change Summary

```yaml
# pubspec.yaml — BEFORE
dependencies:
  sqflite: ^2.4.3                 # REMOVE
  hashlib: ^2.4.2                 # REMOVE (only used by PasswordHasher)
  path: ^1.9.1                    # KEEP if used elsewhere; grep first
  flutter_secure_storage: ^10.3.1 # KEEP unless session.key is only usage

dev_dependencies:
  sqflite_common_ffi: ^2.4.2+1    # REMOVE

# pubspec.yaml — AFTER (Firebase deps already present)
dependencies:
  cloud_firestore: ^6.9.0         # Already installed; no change
  firebase_auth: ^6.6.1           # Already installed; no change
  firebase_core: ^4.14.0          # Already installed; no change
```

---

## 7. Known Edge Cases & Handling

| Edge Case | Mitigation |
|---|---|
| Firestore rules deny write (broken client schema) | Client snapshot `Stream` will not receive the bad write. Wrap Firestore writes in try/catch and revert optimistic UI update on `FirebaseException` (permissions-denied). |
| Surah bookmark toggled → offline → toggled back → online | Last-write-wins (Firestore default). If user toggles 5 times offline, final state is the 5th toggle. This is correct and acceptable for non-critical data. |
| Set-last-read on two devices simultaneously | Newest `updatedAt` timestamp wins. Use `FieldValue.serverTimestamp()` (not `DateTime.now()`) so comparison uses server clock not drifting device clocks. |
| User deletes account — subcollections (`quranBookmarks`, etc.) remain | **Known trade-off, accepted for v1**. Firebase does NOT cascade delete. Options: (a) accept orphaned subcollections (cheap, low risk; user has no UID so no access path), (b) add `WriteBatch` to delete each known subcollection path client-side, (c) deploy Cloud Function `onDelete:/users/{uid}` with `firebase-tools` recursive delete. Recommend option **(a)** for this iteration, upgrade to (c) only if GDPR-style right-to-erasure requires it. |
| `mosque_id` special chars in Firestore doc ID | Valid per Firestore spec as long as not `/`, `.`, `..`, or `__*__`. Current API IDs are Google `place_id` tokens or UUIDs → safe. Add escape guard only if issues arise in QA. |
| `AuthUser.id` type ripple through screens | Any screen reading `context.read<AuthProvider>().userId` and treating it as `int` will break at analysis time. Fix with `flutter analyze` in Phase 7. All comparisons (`==`) with setUser parameters are now `String?`. |

---

## 8. File Change Count (Minimal Ponytail Diff)

| Metric | Count |
|---|---|
| Files DELETED | 1–2 (`app_database.dart` + optionally `password_hasher.dart`) |
| Files MODIFIED | 6 (`auth_service.dart`, `quran_provider.dart`, `mosque_provider.dart`, `auth_provider.dart`, `auth_user.dart`, `main.dart`) |
| Files NEW | 0 (no new abstractions; reuse Firebase SDK classes directly) |
| Total lines REMOVED | ~260 (app_database CREATE statements + PasswordHasher + local session token logic) |
| Total lines ADDED | ~220 (Firestore stream subscription boilerplate + FirebaseAuth method wrappers) |

**Net LOC change**: Small decrease. No new patterns or classes introduced. No repositories layer (ponytail: existing Provider→Service pattern is sufficient; adding an abstraction gains zero when there's exactly one backend).

---

## 9. Rollback Plan

If catastrophic issue in production within 7 days of launch:

1. **Git revert** the migration commit(s). Restore `app_database.dart`, `password_hasher.dart`, old `auth_service.dart`.
2. **Re-add** to `pubspec.yaml`: `sqflite`, `sqflite_common_ffi`, `hashlib`. Run `flutter pub get`.
3. **Rebuild and redeploy**. Local SQFlite database files were never deleted by the migration (fresh deployment confirmed), so existing installations still have their data.
4. **Firebase rollback is not destructive**: New documents in Firestore are simply orphaned; they have no effect when app reverts to reading SQFlite. No data loss.

---

## 10. Post-Migration Future Enhancements (Out of Scope — Ponytail Backlog)

Do not build these now. Documented only for roadmap:

- [ ] **Multi-device last-read merge strategy**: Newest timestamp wins is correct, but add `deviceId` field for debug if users report "lost my position".
- [ ] **Account deletion with recursive subcollection cleanup**: Deploy Cloud Function or Admin SDK script.
- [ ] **Firebase App Check**: Enforce after user base >10k to reduce API abuse. Complementary to Security Rules, not a replacement.
- [ ] **Email verification**: Send verification email after `register()`, gate some features until verified.
- [ ] **Password reset email**: `FirebaseAuth.sendPasswordResetEmail()` in forgot-password screen (no screen exists today).
