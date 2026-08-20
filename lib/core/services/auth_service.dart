import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hashlib/hashlib.dart';
import '../databases/app_database.dart';
import '../models/auth_user.dart';
import 'password_hasher.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  AuthService({PasswordHasher? hasher}) : _hasher = hasher ?? PasswordHasher();
  final PasswordHasher _hasher;
  static const _key = 'inav.session.token';
  static const _storage = FlutterSecureStorage();
  Future<AuthUser?> restoreSession() async {
    final token = await _storage.read(key: _key);
    if (token == null) return null;
    final rows = await (await AppDatabase.database).rawQuery(
      'SELECT u.id,u.full_name,u.email FROM sessions s JOIN users u ON u.id=s.user_id WHERE s.token_hash=? AND s.revoked_at IS NULL AND s.expires_at>?',
      [_tokenHash(token), DateTime.now().millisecondsSinceEpoch],
    );
    if (rows.isEmpty) {
      await _storage.delete(key: _key);
      return null;
    }
    return AuthUser.fromMap(Map<String, Object?>.from(rows.first));
  }

  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final db = await AppDatabase.database;
    final normalized = email.trim().toLowerCase();
    if ((await db.query(
      'users',
      where: 'email=?',
      whereArgs: [normalized],
    )).isNotEmpty)
      throw const AuthException('An account with this email already exists.');
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await db.insert('users', {
      'full_name': fullName.trim(),
      'email': normalized,
      'password_hash': await _hasher.hash(password),
      'created_at': now,
      'updated_at': now,
    });
    final user = AuthUser(id: id, fullName: fullName.trim(), email: normalized);
    await _startSession(user.id);
    return user;
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      'users',
      where: 'email=?',
      whereArgs: [email.trim().toLowerCase()],
    );
    if (rows.isEmpty ||
        !await _hasher.verify(rows.first['password_hash'] as String, password))
      throw const AuthException('Email or password is incorrect.');
    final user = AuthUser.fromMap(rows.first);
    await _startSession(user.id);
    return user;
  }

  Future<void> logout() async {
    final token = await _storage.read(key: _key);
    if (token != null)
      await (await AppDatabase.database).update(
        'sessions',
        {'revoked_at': DateTime.now().millisecondsSinceEpoch},
        where: 'token_hash=?',
        whereArgs: [_tokenHash(token)],
      );
    await _storage.delete(key: _key);
  }

  Future<AuthUser> updateProfile({
    required AuthUser user,
    required String fullName,
    required String email,
    required String currentPassword,
    String? newPassword,
  }) async {
    final name = fullName.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (name.length < 2 || normalizedEmail.isEmpty) {
      throw const AuthException('Enter a valid name and email address.');
    }
    if (currentPassword.isEmpty) {
      throw const AuthException('Enter your current password to save changes.');
    }
    final passwordChange = newPassword?.isNotEmpty == true;
    if (passwordChange && (newPassword!.length < 8 || newPassword.length > 64)) {
      throw const AuthException('Your new password must be 8–64 characters.');
    }

    final db = await AppDatabase.database;
    return db.transaction((txn) async {
      final users = await txn.query('users', where: 'id=?', whereArgs: [user.id]);
      if (users.isEmpty) throw const AuthException('Your account is no longer available.');
      if (!await _hasher.verify(users.first['password_hash'] as String, currentPassword)) {
        throw const AuthException('Your current password is incorrect.');
      }
      final emailMatches = await txn.query(
        'users',
        columns: ['id'],
        where: 'email=? AND id<>?',
        whereArgs: [normalizedEmail, user.id],
      );
      if (emailMatches.isNotEmpty) {
        throw const AuthException('An account with this email already exists.');
      }

      final values = <String, Object>{
        'full_name': name,
        'email': normalizedEmail,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };
      if (passwordChange) values['password_hash'] = await _hasher.hash(newPassword!);
      await txn.update('users', values, where: 'id=?', whereArgs: [user.id]);
      return AuthUser(id: user.id, fullName: name, email: normalizedEmail);
    });
  }

  Future<bool> verifyCurrentPassword({
    required AuthUser user,
    required String password,
  }) async {
    if (password.isEmpty) return false;
    final rows = await (await AppDatabase.database).query(
      'users',
      columns: ['password_hash'],
      where: 'id=?',
      whereArgs: [user.id],
    );
    return rows.isNotEmpty &&
        await _hasher.verify(rows.first['password_hash'] as String, password);
  }

  Future<void> deleteAccount({
    required AuthUser user,
    required String password,
  }) async {
    if (!await verifyCurrentPassword(user: user, password: password)) {
      throw const AuthException('Your current password is incorrect.');
    }
    await (await AppDatabase.database).delete(
      'users',
      where: 'id=?',
      whereArgs: [user.id],
    );
    await _storage.delete(key: _key);
  }

  Future<void> _startSession(int userId) async {
    final db = await AppDatabase.database;
    final token = base64UrlEncode(
      List<int>.generate(32, (_) => Random.secure().nextInt(256)),
    );
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      await txn.update(
        'sessions',
        {'revoked_at': now},
        where: 'user_id=? AND revoked_at IS NULL',
        whereArgs: [userId],
      );
      await txn.insert('sessions', {
        'user_id': userId,
        'token_hash': _tokenHash(token),
        'created_at': now,
        'expires_at': now + const Duration(days: 30).inMilliseconds,
      });
    });
    await _storage.write(key: _key, value: token);
  }

  String _tokenHash(String token) => sha256.string(token).toString();
}
