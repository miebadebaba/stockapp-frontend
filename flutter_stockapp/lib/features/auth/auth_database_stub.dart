import 'auth_database_base.dart';

AuthDatabase createAuthDatabase() => MemoryAuthDatabase();

class MemoryAuthDatabase implements AuthDatabase {
  MemoryAuthDatabase({String? currentUsername}) : this._(currentUsername);

  MemoryAuthDatabase._(this._currentUsername);

  final Map<String, AuthUserRecord> _users = {};
  String? _currentUsername;

  @override
  Future<String?> readCurrentUsername() async => _currentUsername;

  @override
  Future<void> upsertUser(String username) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty) {
      return;
    }

    _users[cleanUsername] = AuthUserRecord(
      username: cleanUsername,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> setCurrentUsername(String username) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isNotEmpty) {
      _currentUsername = cleanUsername;
    }
  }

  @override
  Future<void> clearCurrentUsername() async {
    _currentUsername = null;
  }
}
