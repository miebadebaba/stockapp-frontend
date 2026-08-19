import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_volume_chart.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('displays volume metrics and chart', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantVolumeChart(
            bars: [
              StockDailyBar(
                tradingDate: DateTime(2026, 7, 28),
                open: 10,
                high: 11,
                low: 9,
                close: 10.50,
                volume: 250000000,
              ),
              StockDailyBar(
                tradingDate: DateTime(2026, 7, 29),
                open: 10.50,
                high: 11,
                low: 10,
                close: 10.20,
                volume: 180000000,
              ),
              StockDailyBar(
                tradingDate: DateTime(2026, 7, 30),
                open: 10.20,
                high: 11,
                low: 10,
                close: 10.80,
                volume: 12000,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('成交量趋势'), findsOneWidget);
    expect(find.text('区间最大'), findsOneWidget);
    expect(find.text('2.50 亿股'), findsOneWidget);
    expect(find.text('最新成交量'), findsOneWidget);
    expect(find.text('1.20 万股'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('displays volume for the selected trading date', (tester) async {
    final selectedDate = DateTime(2026, 7, 29);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantVolumeChart(
            bars: [
              StockDailyBar(
                tradingDate: DateTime(2026, 7, 28),
                open: 10,
                high: 11,
                low: 9,
                close: 10.50,
                volume: 250000000,
              ),
              StockDailyBar(
                tradingDate: selectedDate,
                open: 10.50,
                high: 11,
                low: 10,
                close: 10.20,
                volume: 180000000,
              ),
              StockDailyBar(
                tradingDate: DateTime(2026, 7, 30),
                open: 10.20,
                high: 11,
                low: 10,
                close: 10.80,
                volume: 12000,
              ),
            ],
            selectedTradingDate: selectedDate,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('所选日期成交量'), findsOneWidget);
    expect(find.text('1.80 亿股'), findsOneWidget);
    expect(find.text('最新成交量'), findsNothing);
    expect(find.text('1.20 万股'), findsNothing);
  });

  testWidgets('renders nothing when bars are empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: QuantVolumeChart(bars: [])),
      ),
    );

    expect(find.text('成交量趋势'), findsNothing);
  });
}
