class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
  });
  final int id;
  final String fullName;
  final String email;

  factory AuthUser.fromMap(Map<String, Object?> map) => AuthUser(
    id: map['id'] as int,
    fullName: map['full_name'] as String,
    email: map['email'] as String,
  );
}
