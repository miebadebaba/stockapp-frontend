import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_ohlc_details.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows OHLC volume and positive change', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantOhlcDetails(
            bar: StockDailyBar(
              tradingDate: DateTime(2026, 7, 30),
              open: 10.20,
              high: 11.30,
              low: 10.10,
              close: 11.00,
              volume: 120000,
            ),
            previousClose: 10.00,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('quant-ohlc-details')), findsOneWidget);
    expect(find.text('2026-07-30'), findsOneWidget);
    expect(find.text('开盘价'), findsOneWidget);
    expect(find.text('10.20'), findsOneWidget);
    expect(find.text('最高价'), findsOneWidget);
    expect(find.text('11.30'), findsOneWidget);
    expect(find.text('最低价'), findsOneWidget);
    expect(find.text('10.10'), findsOneWidget);
    expect(find.text('收盘价'), findsOneWidget);
    expect(find.text('11.00'), findsOneWidget);
    expect(find.text('成交量'), findsOneWidget);
    expect(find.text('12.00 万股'), findsOneWidget);
    expect(find.text('+1.00  +10.00%'), findsOneWidget);
    expect(find.text('+10.00%'), findsOneWidget);
  });

  testWidgets('shows placeholders without previous close', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantOhlcDetails(
            bar: StockDailyBar(
              tradingDate: DateTime(2026, 7, 30),
              open: 10.20,
              high: 11.30,
              low: 10.10,
              close: 11.00,
              volume: 120000,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('涨跌 --'), findsOneWidget);
    expect(find.text('涨跌幅'), findsOneWidget);
    expect(find.text('--'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
