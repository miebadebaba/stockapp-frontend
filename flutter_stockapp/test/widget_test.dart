import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/app.dart';
import 'package:flutter_stockapp/features/auth/auth_models.dart';
import 'package:flutter_stockapp/features/auth/auth_remote_service.dart';
import 'package:flutter_stockapp/features/auth/token_storage.dart';

void main() {
  testWidgets('signs in with username and opens shell', (tester) async {
    final storage = TestTokenStorage();
    final api = TestAuthApi();

    await tester.pumpWidget(AppNameDemo(authApi: api, tokenStorage: storage));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Market Habit Wall'), findsNothing);
    expect(find.text('Signal Counter Grid'), findsNothing);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Sign in'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'nova');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Continue').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('restores saved username session', (tester) async {
    final storage = TestTokenStorage(token: 'saved-token');
    final api = TestAuthApi();

    await tester.pumpWidget(AppNameDemo(authApi: api, tokenStorage: storage));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Welcome back'), findsNothing);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}

class TestAuthApi implements AuthApi {
  @override
  Future<AuthUser> register({
    required String username,
    required String password,
  }) async => _testUser;

  @override
  Future<AuthToken> login({
    required String username,
    required String password,
  }) async => const AuthToken(accessToken: 'token', tokenType: 'bearer');

  @override
  Future<AuthUser> getCurrentUser(String accessToken) async => _testUser;
}

class TestTokenStorage implements TokenStorage {
  TestTokenStorage({this.token});

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

final _testUser = AuthUser(
  id: 1,
  username: 'nova',
  role: 'user',
  status: 'active',
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);
