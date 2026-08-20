import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static Future<Database>? _opening;
  static Future<Database> get database => _opening ??= _open();

  static Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'inav.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE users (
            id            INTEGER PRIMARY KEY,
            full_name     TEXT    NOT NULL,
            email         TEXT    NOT NULL UNIQUE,
            password_hash TEXT    NOT NULL,
            created_at    INTEGER NOT NULL,
            updated_at    INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE sessions (
            id         INTEGER PRIMARY KEY,
            user_id    INTEGER NOT NULL,
            token_hash TEXT    NOT NULL UNIQUE,
            created_at INTEGER NOT NULL,
            expires_at INTEGER NOT NULL,
            revoked_at INTEGER,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE quran_bookmarks (
            user_id      INTEGER NOT NULL,
            surah_number INTEGER NOT NULL,
            created_at   INTEGER NOT NULL,
            PRIMARY KEY (user_id, surah_number),
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE quran_last_read (
            user_id      INTEGER PRIMARY KEY,
            surah_number INTEGER NOT NULL,
            ayah_number  INTEGER NOT NULL,
            updated_at   INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
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
        ''');
      },
    );
  }
}
