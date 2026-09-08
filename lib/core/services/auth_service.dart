import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    return AuthUser(
      id: u.uid,
      fullName: u.displayName ?? '',
      email: u.email ?? '',
    );
  }

  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (password.length < 8 || password.length > 64) {
      throw const AuthException('Your new password must be 8–64 characters.');
    }
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final u = cred.user!;
      final name = fullName.trim();
      if (name.isNotEmpty) await u.updateDisplayName(name);
      await _firestore.collection('users').doc(u.uid).set({
        'displayName': name,
        'email': u.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return AuthUser(
        id: u.uid,
        fullName: name,
        email: u.email ?? '',
      );
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    }
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final u = cred.user!;
      final snapshot = await _firestore.collection('users').doc(u.uid).get();
      if (!snapshot.exists) {
        await _firestore.collection('users').doc(u.uid).set({
          'displayName': u.displayName ?? '',
          'email': u.email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return AuthUser(
        id: u.uid,
        fullName: u.displayName ?? '',
        email: u.email ?? '',
      );
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    }
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

    final u = _auth.currentUser;
    if (u == null || u.uid != user.id) {
      throw const AuthException('Your account is no longer available.');
    }

    try {
      await _reauthenticate(u, currentPassword);

      if (normalizedEmail != u.email) {
        await u.verifyBeforeUpdateEmail(normalizedEmail);
      }
      if (name.isNotEmpty && name != u.displayName) {
        await u.updateDisplayName(name);
      }
      if (passwordChange) {
        await u.updatePassword(newPassword!);
      }

      await _firestore.collection('users').doc(u.uid).set({
        'displayName': name,
        'email': normalizedEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return AuthUser(id: u.uid, fullName: name, email: normalizedEmail);
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    }
  }

  Future<bool> verifyCurrentPassword({
    required AuthUser user,
    required String password,
  }) async {
    if (password.isEmpty) return false;
    final u = _auth.currentUser;
    if (u == null || u.uid != user.id) return false;
    try {
      await _reauthenticate(u, password);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  Future<void> deleteAccount({
    required AuthUser user,
    required String password,
  }) async {
    if (!await verifyCurrentPassword(user: user, password: password)) {
      throw const AuthException('Your current password is incorrect.');
    }
    final u = _auth.currentUser;
    if (u == null) return;
    final uid = u.uid;
    final batch = _firestore.batch();
    batch.delete(_firestore.collection('users').doc(uid));
    final bookmarksSnapshot = await _firestore
        .collection('users/$uid/quranBookmarks')
        .limit(500)
        .get();
    for (final doc in bookmarksSnapshot.docs) {
      batch.delete(doc.reference);
    }
    final favoritesSnapshot = await _firestore
        .collection('users/$uid/mosqueFavorites')
        .limit(500)
        .get();
    for (final doc in favoritesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_firestore.doc('users/$uid/quranLastRead/current'));
    await batch.commit();
    await u.delete();
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  Future<void> _reauthenticate(User u, String password) async {
    final credential = EmailAuthProvider.credential(
      email: u.email ?? '',
      password: password,
    );
    await u.reauthenticateWithCredential(credential);
  }

  AuthException _translateAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthException('An account with this email already exists.');
      case 'weak-password':
        return const AuthException('Your new password must be 8–64 characters.');
      case 'invalid-email':
        return const AuthException('Enter a valid name and email address.');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthException('Email or password is incorrect.');
      case 'requires-recent-login':
        return const AuthException('Please log out and back in before making this change.');
      case 'network-request-failed':
        return const AuthException('No internet connection. Try again when online.');
      case 'too-many-requests':
        return const AuthException('Too many attempts. Try again later.');
      case 'operation-not-allowed':
        return const AuthException('Sign-in method is disabled. Please contact support.');
      case 'user-disabled':
        return const AuthException('This account has been disabled.');
      case 'email-already-exists':
        return const AuthException('An account with this email already exists.');
      case 'credential-already-in-use':
        return const AuthException('This credential is already associated with another account.');
      case 'invalid-verification-code':
        return const AuthException('Invalid verification code.');
      case 'session-expired':
        return const AuthException('Session expired. Please log in again.');
      case 'account-exists-with-different-credential':
        return const AuthException('An account with this email already exists. Please sign in with the original method.');
      case 'missing-email':
        return const AuthException('Enter a valid name and email address.');
      default:
        return AuthException(
          e.message?.isNotEmpty == true
              ? e.message!
              : 'An unexpected error occurred. Please try again.',
        );
    }
  }
}
