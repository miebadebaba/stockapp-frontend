import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_stockapp/app.dart';
import 'package:flutter_stockapp/core/network/api_exception.dart';
import 'package:flutter_stockapp/features/auth/auth_models.dart';
import 'package:flutter_stockapp/features/auth/auth_remote_service.dart';
import 'package:flutter_stockapp/features/auth/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    FlowAuthApi? api,
    FlowTokenStorage? storage,
    Size size = const Size(900, 1200),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      AppNameDemo(
        authApi: api ?? FlowAuthApi(),
        tokenStorage: storage ?? FlowTokenStorage(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> openRegister(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('login-sign-up')));
    await tester.pumpAndSettle();
  }

  Future<void> openLoginAndFill(
    WidgetTester tester, {
    String username = 'user',
    String password = 'password',
  }) async {
    await tester.tap(find.byKey(const Key('login-open-form')));
    await tester.pumpAndSettle();
    if (username.isNotEmpty) {
      await tester.enterText(find.byKey(const Key('login-username')), username);
    }
    if (password.isNotEmpty) {
      await tester.enterText(find.byKey(const Key('login-password')), password);
    }
  }

  Future<void> fillRegistration(
    WidgetTester tester, {
    String username = 'new-user',
    String password = 'password',
    String confirmPassword = 'password',
  }) async {
    await tester.ensureVisible(find.byKey(const Key('register-username')));
    await tester.enterText(
      find.byKey(const Key('register-username')),
      username,
    );
    await tester.ensureVisible(find.byKey(const Key('register-password')));
    await tester.enterText(
      find.byKey(const Key('register-password')),
      password,
    );
    await tester.ensureVisible(
      find.byKey(const Key('register-confirm-password')),
    );
    await tester.enterText(
      find.byKey(const Key('register-confirm-password')),
      confirmPassword,
    );
    tester.testTextInput.hide();
    tester.view.resetViewInsets();
    await tester.pump();
  }

  testWidgets('login page visibly exposes Sign up', (tester) async {
    await pumpApp(tester, size: const Size(360, 640));

    expect(find.text("Don't have an account? Sign up"), findsOneWidget);
    expect(
      find.byKey(const Key('login-sign-up')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('opens registration from the real login page', (tester) async {
    await pumpApp(tester);

    await openRegister(tester);

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.byKey(const Key('register-confirm-password')), findsOneWidget);
  });

  testWidgets('registration Sign in returns to login', (tester) async {
    await pumpApp(tester);
    await openRegister(tester);

    await tester.tap(find.byKey(const Key('register-sign-in')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byKey(const Key('login-sign-up')), findsOneWidget);
  });

  testWidgets('Sign up remains scroll-accessible with keyboard open', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(360, 640));
    await tester.tap(find.byKey(const Key('login-open-form')));
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.showKeyboard(find.byKey(const Key('login-username')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('login-sheet-sign-up')));
    await tester.pump();

    expect(
      find.byKey(const Key('login-sheet-sign-up')).hitTestable(),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('login-sheet-sign-up')));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);
  });

  testWidgets('empty login fields show required errors without a request', (
    tester,
  ) async {
    final api = FlowAuthApi();
    await pumpApp(tester, api: api);
    await openLoginAndFill(tester, username: '', password: '');

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('Please enter a username.'), findsOneWidget);
    expect(find.text('Please enter a password.'), findsOneWidget);
    expect(api.loginCalls, 0);
  });

  testWidgets('login enters loading immediately and ignores a second tap', (
    tester,
  ) async {
    final loginCompleter = Completer<AuthToken>();
    final api = FlowAuthApi(loginCompleter: loginCompleter);
    await pumpApp(tester, api: api);
    await openLoginAndFill(tester);

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const Key('login-submit')),
        matching: find.text('Signing in...'),
      ),
      findsOneWidget,
    );
    final submitInkWell = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const Key('login-submit')),
        matching: find.byType(InkWell),
      ),
    );
    expect(submitInkWell.onTap, isNull);
    expect(api.loginCalls, 1);

    loginCompleter.complete(
      const AuthToken(accessToken: 'access-token', tokenType: 'bearer'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('login connection failure is shown on the first request', (
    tester,
  ) async {
    final api = FlowAuthApi(
      loginError: const ApiException(
        type: ApiErrorType.connection,
        message: 'connection failed',
      ),
    );
    await pumpApp(tester, api: api);
    await openLoginAndFill(tester);

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('网络连接失败，请稍后重试'), findsOneWidget);
    expect(api.loginCalls, 1);
  });

  testWidgets('login timeout is shown on the first request', (tester) async {
    final api = FlowAuthApi(
      loginError: const ApiException(
        type: ApiErrorType.timeout,
        message: 'timed out',
      ),
    );
    await pumpApp(tester, api: api);
    await openLoginAndFill(tester);

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('请求超时，请稍后重试'),
      findsOneWidget,
    );
    expect(api.loginCalls, 1);
  });

  testWidgets('register controls remain accessible above keyboard insets', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(360, 640));
    await openRegister(tester);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.showKeyboard(find.byKey(const Key('register-username')));
    await tester.pump();

    for (final key in [
      const Key('register-password'),
      const Key('register-confirm-password'),
      const Key('register-submit'),
    ]) {
      await tester.ensureVisible(find.byKey(key));
      await tester.pump();
      expect(find.byKey(key).hitTestable(), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('mismatched passwords do not call register', (tester) async {
    final api = FlowAuthApi();
    await pumpApp(tester, api: api);
    await openRegister(tester);
    await fillRegistration(tester, confirmPassword: 'different');

    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pump();

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(api.registerCalls, 0);
  });

  testWidgets('short password does not call register', (tester) async {
    final api = FlowAuthApi();
    await pumpApp(tester, api: api);
    await openRegister(tester);
    await fillRegistration(tester, password: 'short', confirmPassword: 'short');

    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pump();

    expect(
      find.text('Password must be at least 8 characters.'),
      findsOneWidget,
    );
    expect(api.registerCalls, 0);
  });

  testWidgets('successful registration returns and retains username', (
    tester,
  ) async {
    final api = FlowAuthApi();
    await pumpApp(tester, api: api);
    await openRegister(tester);
    await fillRegistration(tester, username: 'remember-me');

    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('Registration successful. Please sign in.'),
      findsOneWidget,
    );
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.byKey(const Key('login-open-form')));
    await tester.pumpAndSettle();
    final usernameField = tester.widget<TextFormField>(
      find.byKey(const Key('login-username')),
    );
    final passwordField = tester.widget<TextFormField>(
      find.byKey(const Key('login-password')),
    );
    expect(usernameField.initialValue, 'remember-me');
    expect(passwordField.initialValue, isEmpty);
    expect(api.registerCalls, 1);
  });

  testWidgets('failed registration stays on registration page', (tester) async {
    final api = FlowAuthApi(
      registerError: const ApiException(
        type: ApiErrorType.unknown,
        message: 'duplicate',
        statusCode: 409,
      ),
    );
    await pumpApp(tester, api: api);
    await openRegister(tester);
    await fillRegistration(tester);

    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pump();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Username already exists.'), findsOneWidget);
    expect(api.registerCalls, 1);
  });

  testWidgets('register enters loading and ignores a second tap', (
    tester,
  ) async {
    final registerCompleter = Completer<AuthUser>();
    final api = FlowAuthApi(registerCompleter: registerCompleter);
    await pumpApp(tester, api: api);
    await openRegister(tester);
    await fillRegistration(tester);

    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pump();

    expect(find.text('Creating...'), findsOneWidget);
    final submitInkWell = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const Key('register-submit')),
        matching: find.byType(InkWell),
      ),
    );
    expect(submitInkWell.onTap, isNull);
    expect(api.registerCalls, 1);

    registerCompleter.complete(_user('new-user'));
    await tester.pumpAndSettle();
    expect(
      find.text('Registration successful. Please sign in.'),
      findsOneWidget,
    );
  });

  testWidgets('successful login opens the protected app shell', (tester) async {
    final api = FlowAuthApi();
    final storage = FlowTokenStorage();
    await pumpApp(tester, api: api, storage: storage);

    await tester.tap(find.byKey(const Key('login-open-form')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('login-username')), 'user');
    await tester.enterText(find.byKey(const Key('login-password')), 'password');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
    expect(storage.token, 'access-token');
  });

  testWidgets('failed login remains retryable', (tester) async {
    final api = FlowAuthApi(
      loginError: const ApiException(
        type: ApiErrorType.unauthorized,
        message: 'Unauthorized',
        statusCode: 401,
      ),
    );
    await pumpApp(tester, api: api);

    await tester.tap(find.byKey(const Key('login-open-form')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('login-username')), 'user');
    await tester.enterText(find.byKey(const Key('login-password')), 'password');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('用户名或密码错误'), findsOneWidget);
    expect(find.byKey(const Key('login-submit')).hitTestable(), findsOneWidget);

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(api.loginCalls, 2);
  });

  testWidgets('disabled account login shows the administrator contact message', (
    tester,
  ) async {
    final api = FlowAuthApi(
      loginError: const ApiException(
        type: ApiErrorType.forbidden,
        message: 'forbidden',
        statusCode: 403,
        code: 'ACCOUNT_DISABLED',
      ),
    );
    await pumpApp(tester, api: api);
    await openLoginAndFill(tester);

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('该账号已被禁用，请联系管理员'), findsOneWidget);
    expect(api.loginCalls, 1);
  });

  testWidgets('async login completion after dispose does not call setState', (
    tester,
  ) async {
    final loginCompleter = Completer<AuthToken>();
    final api = FlowAuthApi(loginCompleter: loginCompleter);
    await pumpApp(tester, api: api);
    await openLoginAndFill(tester);

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());

    loginCompleter.completeError(
      const ApiException(
        type: ApiErrorType.connection,
        message: 'connection failed',
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('sign out returns to login and cannot reveal RootShell', (
    tester,
  ) async {
    final storage = FlowTokenStorage(token: 'saved-token');
    await pumpApp(tester, storage: storage);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(storage.token, isNull);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });
}

class FlowAuthApi implements AuthApi {
  FlowAuthApi({
    this.registerError,
    this.loginError,
    this.registerCompleter,
    this.loginCompleter,
  });

  final ApiException? registerError;
  final ApiException? loginError;
  final Completer<AuthUser>? registerCompleter;
  final Completer<AuthToken>? loginCompleter;
  int registerCalls = 0;
  int loginCalls = 0;

  @override
  Future<AuthUser> register({
    required String username,
    required String password,
  }) async {
    registerCalls++;
    if (registerError != null) {
      throw registerError!;
    }
    if (registerCompleter != null) {
      return registerCompleter!.future;
    }
    return _user(username);
  }

  @override
  Future<AuthToken> login({
    required String username,
    required String password,
  }) async {
    loginCalls++;
    if (loginError != null) {
      throw loginError!;
    }
    if (loginCompleter != null) {
      return loginCompleter!.future;
    }
    return const AuthToken(accessToken: 'access-token', tokenType: 'bearer');
  }

  @override
  Future<AuthUser> getCurrentUser(String accessToken) async => _user('user');
}

class FlowTokenStorage implements TokenStorage {
  FlowTokenStorage({this.token});

  String? token;

  @override
  Future<bool> saveAccessToken(String accessToken) async {
    token = accessToken;
    return true;
  }

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> deleteAccessToken() async => token = null;
}

AuthUser _user(String username) {
  return AuthUser(
    id: 1,
    username: username,
    role: 'user',
    status: 'active',
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}
