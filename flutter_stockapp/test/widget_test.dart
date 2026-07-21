import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/app.dart';

void main() {
  testWidgets('renders AppName UI shell', (tester) async {
    await tester.pumpWidget(const AppNameDemo());

    expect(find.text('Market Habit Wall'), findsNothing);
    expect(find.text('Signal Counter Grid'), findsNothing);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}
