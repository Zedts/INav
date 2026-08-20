import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service, bool loading = false})
    : _service = service ?? AuthService(),
      // ignore: prefer_initializing_formals
      _loading = loading;
  final AuthService _service;
  AuthUser? _user;
  bool _loading;
  String? _startupError;
  bool _submitting = false;
  AuthUser? get user => _user;
  int? get userId => _user?.id;
  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get startupError => _startupError;
  Future<void> restoreSession() async {
    _loading = true;
    _startupError = null;
    notifyListeners();
    try {
      _user = await _service.restoreSession();
    } catch (_) {
      _startupError = 'Unable to open your local account. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async =>
      _submit(() => _service.login(email: email, password: password));
  Future<void> register(String name, String email, String password) async =>
      _submit(
        () =>
            _service.register(fullName: name, email: email, password: password),
      );

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String currentPassword,
    String? newPassword,
  }) async {
    final user = _user;
    if (user == null) throw const AuthException('You are not logged in.');
    await _submit(
      () => _service.updateProfile(
        user: user,
        fullName: fullName,
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
  }

  Future<bool> verifyCurrentPassword(String password) async {
    final user = _user;
    return user != null &&
        await _service.verifyCurrentPassword(user: user, password: password);
  }

  Future<void> deleteAccount(String password) async {
    final user = _user;
    if (user == null) throw const AuthException('You are not logged in.');
    _submitting = true;
    notifyListeners();
    try {
      await _service.deleteAccount(user: user, password: password);
      _user = null;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
  Future<void> _submit(Future<AuthUser> Function() action) async {
    _submitting = true;
    notifyListeners();
    try {
      _user = await action();
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    notifyListeners();
  }
}
