import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStorage {
  Future<bool> saveAccessToken(String accessToken);

  Future<String?> readAccessToken();

  Future<void> deleteAccessToken();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const accessTokenKey = 'access_token';

  final FlutterSecureStorage _storage;

  @override
  Future<bool> saveAccessToken(String accessToken) async {
    try {
      await _storage.write(key: accessTokenKey, value: accessToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> readAccessToken() async {
    try {
      final token = await _storage.read(key: accessTokenKey);
      return token == null || token.trim().isEmpty ? null : token;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteAccessToken() async {
    try {
      await _storage.delete(key: accessTokenKey);
    } catch (_) {
      // The session is cleared in memory even when secure storage is unavailable.
    }
  }
}
