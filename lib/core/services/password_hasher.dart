import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hashlib/hashlib.dart';

class PasswordHasher {
  Future<String> hash(String password) => compute(_hash, password);
  Future<bool> verify(String encoded, String password) =>
      compute(_verify, [encoded, password]);
  static String _hash(String password) {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    return argon2id(
      utf8.encode(password),
      salt,
      security: Argon2Security.moderate,
    ).toString();
  }

  static bool _verify(List<String> input) =>
      argon2Verify(input[0], utf8.encode(input[1]));
}
