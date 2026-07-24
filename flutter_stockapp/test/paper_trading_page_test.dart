import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/navigation/root_shell.dart';
import 'package:flutter_stockapp/features/paper_trading/models/paper_portfolio.dart';
import 'package:flutter_stockapp/features/paper_trading/paper_trading_page.dart';

void main() {
  testWidgets('Simulation opens the paper trading page and returns', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(820, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: RootShell(themeMode: ThemeMode.light, onThemeModeChanged: (_) {}),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(find.text('News'), findsOneWidget);
    expect(find.text('Tutorial'), findsOneWidget);
    expect(find.text('Forum'), findsOneWidget);
    expect(find.text('Simulation'), findsOneWidget);

    await tester.tap(find.text('Simulation'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PaperTradingPage), findsOneWidget);
    expect(find.text('模拟交易'), findsOneWidget);
    expect(find.text('腾讯控股'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PaperTradingPage), findsNothing);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });

  testWidgets('paper trading content renders on a narrow dark viewport', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const PaperTradingPage(),
      ),
    );
    await tester.pump();

    expect(find.text('199885.01'), findsOneWidget);
    expect(find.text('-114.99'), findsNWidgets(2));
    expect(find.text('-0.01%'), findsOneWidget);
    expect(find.text('18.8%'), findsOneWidget);
    expect(find.text('436.332'), findsOneWidget);
    expect(find.text('435.000'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('买入'));
    await tester.pump();
    expect(find.text('功能待接入'), findsOneWidget);
  });

  testWidgets('paper trading page supports an empty portfolio', (tester) async {
    final emptyPortfolio = PaperPortfolio(
      summary: PaperPortfolio.mock.summary,
      holdings: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: PaperTradingPage(portfolio: emptyPortfolio),
      ),
    );

    expect(find.text('暂无持仓'), findsOneWidget);
    expect(find.text('腾讯控股'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
