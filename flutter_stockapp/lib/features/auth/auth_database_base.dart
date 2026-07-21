class AuthUserRecord {
  const AuthUserRecord({required this.username, required this.createdAt});

  final String username;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return {'username': username, 'createdAt': createdAt.toIso8601String()};
  }

  static AuthUserRecord fromJson(Map<String, Object?> json) {
    return AuthUserRecord(
      username: json['username'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

abstract class AuthDatabase {
  Future<String?> readCurrentUsername();

  Future<void> upsertUser(String username);

  Future<void> setCurrentUsername(String username);

  Future<void> clearCurrentUsername();
}
