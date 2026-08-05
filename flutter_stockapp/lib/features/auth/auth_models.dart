class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String username;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: _requiredInt(json, 'id'),
      username: _requiredString(json, 'username'),
      role: _requiredString(json, 'role'),
      status: _requiredString(json, 'status'),
      createdAt: _requiredDateTime(json, 'created_at'),
      updatedAt: _requiredDateTime(json, 'updated_at'),
    );
  }
}

class AuthToken {
  const AuthToken({required this.accessToken, required this.tokenType});

  final String accessToken;
  final String tokenType;

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    final accessToken = json['access_token'];
    final tokenType = json['token_type'];
    if (accessToken is! String || accessToken.trim().isEmpty ||
        tokenType is! String || tokenType.trim().isEmpty) {
      throw const FormatException('Invalid authentication response.');
    }
    return AuthToken(accessToken: accessToken, tokenType: tokenType);
  }
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('Missing or invalid $key.');
  }
  return value;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing or invalid $key.');
  }
  return value;
}

DateTime _requiredDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Missing or invalid $key.');
  }
  try {
    return DateTime.parse(value);
  } on FormatException {
    throw FormatException('Missing or invalid $key.');
  }
}
