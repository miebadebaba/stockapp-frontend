import 'dart:convert';
import 'dart:io';

import 'auth_database_base.dart';

AuthDatabase createAuthDatabase() => FileAuthDatabase();

class FileAuthDatabase implements AuthDatabase {
  FileAuthDatabase({File? databaseFile})
    : _databaseFile = databaseFile ?? _defaultDatabaseFile();

  static const _databaseFileName = 'flutter_stockapp_auth_database.json';

  final File _databaseFile;

  @override
  Future<String?> readCurrentUsername() async {
    final data = await _readData();
    final session = data['session'];
    if (session is! Map<String, Object?>) {
      return null;
    }

    final username = session['username'];
    return username is String && username.trim().isNotEmpty
        ? username.trim()
        : null;
  }

  @override
  Future<void> upsertUser(String username) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty) {
      return;
    }

    final data = await _readData();
    final users = _usersTable(data);
    users[cleanUsername] = AuthUserRecord(
      username: cleanUsername,
      createdAt: DateTime.now(),
    ).toJson();
    await _writeData(data);
  }

  @override
  Future<void> setCurrentUsername(String username) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty) {
      return;
    }

    final data = await _readData();
    data['session'] = {'username': cleanUsername};
    await _writeData(data);
  }

  @override
  Future<void> clearCurrentUsername() async {
    final data = await _readData();
    data['session'] = <String, Object?>{};
    await _writeData(data);
  }

  static File _defaultDatabaseFile() {
    return File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}$_databaseFileName',
    );
  }

  Future<Map<String, Object?>> _readData() async {
    if (!await _databaseFile.exists()) {
      return _emptyDatabase();
    }

    final raw = await _databaseFile.readAsString();
    if (raw.trim().isEmpty) {
      return _emptyDatabase();
    }

    final decoded = jsonDecode(raw);
    return decoded is Map<String, Object?>
        ? Map<String, Object?>.from(decoded)
        : _emptyDatabase();
  }

  Future<void> _writeData(Map<String, Object?> data) async {
    await _databaseFile.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await _databaseFile.writeAsString(encoder.convert(data), flush: true);
  }

  static Map<String, Object?> _emptyDatabase() {
    return {'users': <String, Object?>{}, 'session': <String, Object?>{}};
  }

  static Map<String, Object?> _usersTable(Map<String, Object?> data) {
    final users = data['users'];
    if (users is Map<String, Object?>) {
      return users;
    }

    final createdUsers = <String, Object?>{};
    data['users'] = createdUsers;
    return createdUsers;
  }
}
