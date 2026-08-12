import 'package:flutter_stockapp/core/network/api_exception.dart';
import 'package:flutter_stockapp/features/auth/auth_models.dart';
import 'package:flutter_stockapp/features/auth/auth_remote_service.dart';
import 'package:flutter_stockapp/features/auth/auth_session.dart';
import 'package:flutter_stockapp/features/auth/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthSession', () {
    test('logs in, saves token, and loads the server user', () async {
      final api = FakeAuthApi();
      final storage = MemoryTokenStorage();
      final session = await AuthSession.load(api: api, tokenStorage: storage);

      await session.signIn(' TestUser ', 'password');

      expect(api.loginUsername, 'TestUser');
      expect(api.loginPassword, 'password');
      expect(api.currentUserToken, 'access-token');
      expect(storage.token, 'access-token');
      expect(session.username, 'testuser');
      expect(session.currentUser?.role, 'user');
    });

    test('maps an invalid login to a user-facing error', () async {
      final api = FakeAuthApi(loginError: _unauthorized());
      final storage = MemoryTokenStorage();
      final session = await AuthSession.load(api: api, tokenStorage: storage);

      await expectLater(
        session.signIn('testuser', 'wrong'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            '用户名或密码错误',
          ),
        ),
      );
      expect(storage.token, isNull);
    });

    test('maps a disabled account code to a clear user-facing error', () async {
      final api = FakeAuthApi(
        loginError: _apiError(403, code: 'ACCOUNT_DISABLED'),
      );
      final storage = MemoryTokenStorage();
      final session = await AuthSession.load(api: api, tokenStorage: storage);

      await expectLater(
        session.signIn('disabled-user', 'correct-password'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            '该账号已被禁用，请联系管理员',
          ),
        ),
      );
      expect(storage.token, isNull);
    });

    test('maps login validation errors to backend detail', () async {
      final api = FakeAuthApi(
        loginError: _apiError(422, detail: 'Password is too short.'),
      );
      final session = await AuthSession.load(
        api: api,
        tokenStorage: MemoryTokenStorage(),
      );

      await expectLater(
        session.signIn('testuser', 'short'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            'Password is too short.',
          ),
        ),
      );
    });

    test('deletes token when /auth/me fails after login', () async {
      final api = FakeAuthApi(currentUserError: _unauthorized());
      final storage = MemoryTokenStorage();
      final session = await AuthSession.load(api: api, tokenStorage: storage);

      await expectLater(
        session.signIn('testuser', 'password'),
        throwsA(isA<AuthException>()),
      );
      expect(storage.token, isNull);
      expect(session.isLoggedIn, isFalse);
    });

    test('restores a valid token through /auth/me', () async {
      final api = FakeAuthApi();
      final storage = MemoryTokenStorage(token: 'saved-token');

      final session = await AuthSession.load(api: api, tokenStorage: storage);

      expect(api.currentUserToken, 'saved-token');
      expect(session.username, 'testuser');
      expect(session.isLoggedIn, isTrue);
    });

    test('clears an invalid startup token', () async {
      final api = FakeAuthApi(currentUserError: _unauthorized());
      final storage = MemoryTokenStorage(token: 'expired-token');

      final session = await AuthSession.load(api: api, tokenStorage: storage);

      expect(session.isLoggedIn, isFalse);
      expect(storage.token, isNull);
    });

    test('signs out by clearing memory and secure storage', () async {
      final api = FakeAuthApi();
      final storage = MemoryTokenStorage(token: 'saved-token');
      final session = await AuthSession.load(api: api, tokenStorage: storage);

      await session.signOut();

      expect(session.isLoggedIn, isFalse);
      expect(storage.token, isNull);
      expect(storage.deleteCalls, 1);
    });

    test('exposes the current stored access token for API injection', () async {
      final api = FakeAuthApi();
      final storage = MemoryTokenStorage(token: 'saved-token');
      final session = await AuthSession.load(api: api, tokenStorage: storage);

      expect(await session.readAccessToken(), 'saved-token');

      storage.token = 'updated-token';
      expect(await session.readAccessToken(), 'updated-token');

      await session.signOut();
      expect(await session.readAccessToken(), isNull);
    });

    test('registers without creating a local session', () async {
      final api = FakeAuthApi();
      final storage = MemoryTokenStorage();
      final session = await AuthSession.load(api: api, tokenStorage: storage);

      await session.register('new-user', 'password');

      expect(api.registerUsername, 'new-user');
      expect(api.registerPassword, 'password');
      expect(session.isLoggedIn, isFalse);
      expect(storage.token, isNull);
    });

    test('maps duplicate registration to a clear error', () async {
      final api = FakeAuthApi(registerError: _apiError(409));
      final session = await AuthSession.load(
        api: api,
        tokenStorage: MemoryTokenStorage(),
      );

      await expectLater(
        session.register('testuser', 'password'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            'Username already exists.',
          ),
        ),
      );
    });

    test('maps registration validation errors', () async {
      final api = FakeAuthApi(
        registerError: _apiError(422, detail: 'Password is too short.'),
      );
      final session = await AuthSession.load(
        api: api,
        tokenStorage: MemoryTokenStorage(),
      );

      await expectLater(
        session.register('testuser', 'short'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            'Password is too short.',
          ),
        ),
      );
    });
  });
}

class FakeAuthApi implements AuthApi {
  FakeAuthApi({this.loginError, this.currentUserError, this.registerError});

  final ApiException? loginError;
  final ApiException? currentUserError;
  final ApiException? registerError;
  String? loginUsername;
  String? loginPassword;
  String? registerUsername;
  String? registerPassword;
  String? currentUserToken;

  @override
  Future<AuthUser> register({
    required String username,
    required String password,
  }) async {
    registerUsername = username;
    registerPassword = password;
    if (registerError != null) {
      throw registerError!;
    }
    return _user;
  }

  @override
  Future<AuthToken> login({
    required String username,
    required String password,
  }) async {
    loginUsername = username;
    loginPassword = password;
    if (loginError != null) {
      throw loginError!;
    }
    return const AuthToken(accessToken: 'access-token', tokenType: 'bearer');
  }

  @override
  Future<AuthUser> getCurrentUser(String accessToken) async {
    currentUserToken = accessToken;
    if (currentUserError != null) {
      throw currentUserError!;
    }
    return _user;
  }
}

class MemoryTokenStorage implements TokenStorage {
  MemoryTokenStorage({this.token, this.saveResult = true});

  String? token;
  final bool saveResult;
  int deleteCalls = 0;

  @override
  Future<bool> saveAccessToken(String accessToken) async {
    if (saveResult) {
      token = accessToken;
    }
    return saveResult;
  }

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> deleteAccessToken() async {
    deleteCalls++;
    token = null;
  }
}

final _user = AuthUser(
  id: 1,
  username: 'testuser',
  role: 'user',
  status: 'active',
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

ApiException _unauthorized() {
  return const ApiException(
    type: ApiErrorType.unauthorized,
    message: 'unauthorized',
    statusCode: 401,
  );
}

ApiException _apiError(int statusCode, {String? code, Object? detail}) {
  return ApiException(
    type: statusCode == 401
        ? ApiErrorType.unauthorized
        : statusCode == 403
        ? ApiErrorType.forbidden
        : ApiErrorType.unknown,
    message: 'error',
    statusCode: statusCode,
    code: code,
    detail: detail,
  );
}
