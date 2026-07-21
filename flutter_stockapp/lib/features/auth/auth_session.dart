import 'package:flutter/foundation.dart';

import 'auth_database.dart';

class AuthSession extends ChangeNotifier {
  AuthSession._(this._database, this._username);

  static AuthDatabase? debugDatabase;

  final AuthDatabase _database;
  String? _username;

  String? get username => _username;
  bool get isLoggedIn => _username != null && _username!.isNotEmpty;

  static Future<AuthSession> load() async {
    final database = debugDatabase ?? createAuthDatabase();
    return AuthSession._(database, await database.readCurrentUsername());
  }

  Future<void> signIn(String username) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty) {
      return;
    }

    await _database.upsertUser(cleanUsername);
    await _database.setCurrentUsername(cleanUsername);
    _username = cleanUsername;
    notifyListeners();
  }

  Future<void> register(String username) => signIn(username);

  Future<void> signOut() async {
    await _database.clearCurrentUsername();
    _username = null;
    notifyListeners();
  }
}
