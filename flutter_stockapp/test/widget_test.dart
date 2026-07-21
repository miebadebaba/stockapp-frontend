import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/app.dart';
import 'package:flutter_stockapp/features/auth/auth_database_stub.dart';
import 'package:flutter_stockapp/features/auth/auth_session.dart';

void main() {
  testWidgets('signs in with username and opens shell', (tester) async {
    AuthSession.debugDatabase = MemoryAuthDatabase();
    addTearDown(() => AuthSession.debugDatabase = null);

    await tester.pumpWidget(const AppNameDemo());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Welcome to AppName.'), findsOneWidget);
    expect(find.text('Market Habit Wall'), findsNothing);
    expect(find.text('Signal Counter Grid'), findsNothing);

    await tester.enterText(find.byType(TextField), 'nova');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('restores saved username session', (tester) async {
    AuthSession.debugDatabase = MemoryAuthDatabase(currentUsername: 'nova');
    addTearDown(() => AuthSession.debugDatabase = null);

    await tester.pumpWidget(const AppNameDemo());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Welcome to AppName.'), findsNothing);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
