import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import 'auth_models.dart';
import 'auth_remote_service.dart';
import 'token_storage.dart';

class AuthSession extends ChangeNotifier {
  AuthSession._(this._api, this._tokenStorage, this._currentUser);

  final AuthApi _api;
  final TokenStorage _tokenStorage;
  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;
  String? get username => _currentUser?.username;
  bool get isLoggedIn => _currentUser != null;

  static Future<AuthSession> load({
    AuthApi? api,
    TokenStorage? tokenStorage,
  }) async {
    final authApi = api ?? HttpAuthApi();
    final storage = tokenStorage ?? SecureTokenStorage();
    final token = await storage.readAccessToken();
    if (token == null) {
      return AuthSession._(authApi, storage, null);
    }

    try {
      final user = await authApi.getCurrentUser(token);
      return AuthSession._(authApi, storage, user);
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await storage.deleteAccessToken();
      }
      return AuthSession._(authApi, storage, null);
    } on FormatException {
      return AuthSession._(authApi, storage, null);
    } catch (_) {
      // A temporary backend failure must not leave the app stuck on a splash.
      return AuthSession._(authApi, storage, null);
    }
  }

  Future<void> signIn(String username, String password) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty || password.isEmpty) {
      throw const AuthException('Please enter your username and password.');
    }

    try {
      final token = await _api.login(
        username: cleanUsername,
        password: password,
      );
      final saved = await _tokenStorage.saveAccessToken(token.accessToken);
      if (!saved) {
        throw const AuthException(
          'Unable to securely save your login session.',
        );
      }

      try {
        _currentUser = await _api.getCurrentUser(token.accessToken);
      } catch (_) {
        await _tokenStorage.deleteAccessToken();
        rethrow;
      }
      notifyListeners();
    } on AuthException {
      rethrow;
    } on ApiException catch (error) {
      throw _authException(error, login: true);
    } on FormatException {
      await _tokenStorage.deleteAccessToken();
      throw const AuthException('The server returned an invalid response.');
    } catch (_) {
      await _tokenStorage.deleteAccessToken();
      throw const AuthException('Unable to connect to the server.');
    }
  }

  Future<void> register(String username, String password) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty || password.isEmpty) {
      throw const AuthException('Please enter your username and password.');
    }

    try {
      await _api.register(username: cleanUsername, password: password);
    } on ApiException catch (error) {
      throw _authException(error, login: false);
    } on FormatException {
      throw const AuthException('The server returned an invalid response.');
    } catch (_) {
      throw const AuthException('Unable to connect to the server.');
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
    await _tokenStorage.deleteAccessToken();
  }

  AuthException _authException(ApiException error, {required bool login}) {
    if (login && error.statusCode == 401) {
      return const AuthException(
        'Username or password is incorrect.',
        statusCode: 401,
      );
    }
    if (!login && error.statusCode == 409) {
      return const AuthException('Username already exists.', statusCode: 409);
    }
    if (error.statusCode == 422) {
      final detail = error.detail;
      if (detail is String && detail.trim().isNotEmpty) {
        return AuthException(detail, statusCode: 422);
      }
      if (detail is List) {
        final messages = detail
            .whereType<Map>()
            .map((item) => item['msg'])
            .whereType<String>()
            .where((message) => message.trim().isNotEmpty)
            .join(' ');
        if (messages.isNotEmpty) {
          return AuthException(messages, statusCode: 422);
        }
      }
      return const AuthException(
        'Please check the username and password.',
        statusCode: 422,
      );
    }
    if (error.type == ApiErrorType.connection) {
      return const AuthException('Unable to connect to the server.');
    }
    if (error.type == ApiErrorType.timeout) {
      return const AuthException('The request timed out. Please try again.');
    }
    if (error.statusCode != null && error.statusCode! >= 500) {
      return const AuthException('The server is temporarily unavailable.');
    }
    return const AuthException('Authentication failed. Please try again.');
  }
}
