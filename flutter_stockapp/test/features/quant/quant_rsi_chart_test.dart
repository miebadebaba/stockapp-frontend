import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_rsi_chart.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('displays the latest RSI value and chart', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantRsiChart(
            bars: [
              _bar(DateTime(2026, 7, 28)),
              _bar(DateTime(2026, 7, 29)),
              _bar(DateTime(2026, 7, 30)),
            ],
            values: const [null, 45, 72.5],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('RSI相对强弱指标'), findsOneWidget);
    expect(find.text('最新RSI14'), findsOneWidget);
    expect(find.text('72.50'), findsOneWidget);
    expect(find.text('高位区间'), findsOneWidget);
    expect(find.byKey(const ValueKey('quant-rsi-chart')), findsOneWidget);
    expect(find.text('前 1 个交易日用于指标预热，对应区间保留为空白。'), findsOneWidget);
  });

  testWidgets('shows unavailable RSI for a selected warm-up date', (
    tester,
  ) async {
    final selectedDate = DateTime(2026, 7, 28);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantRsiChart(
            bars: [
              _bar(selectedDate),
              _bar(DateTime(2026, 7, 29)),
              _bar(DateTime(2026, 7, 30)),
            ],
            values: const [null, 45, 72.5],
            selectedTradingDate: selectedDate,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('所选日期RSI14'), findsOneWidget);
    expect(find.text('--'), findsOneWidget);
    expect(find.text('数据不足'), findsOneWidget);
    expect(find.text('72.50'), findsNothing);
    expect(find.text('高位区间'), findsNothing);
  });

  testWidgets('displays the selected date RSI value', (tester) async {
    final selectedDate = DateTime(2026, 7, 29);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantRsiChart(
            bars: [
              _bar(DateTime(2026, 7, 28)),
              _bar(selectedDate),
              _bar(DateTime(2026, 7, 30)),
            ],
            values: const [40, 28.5, 60],
            selectedTradingDate: selectedDate,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('所选日期RSI14'), findsOneWidget);
    expect(find.text('28.50'), findsOneWidget);
    expect(find.text('低位区间'), findsOneWidget);
  });

  testWidgets('renders nothing when bars are empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: QuantRsiChart(bars: [], values: []),
        ),
      ),
    );

    expect(find.text('RSI相对强弱指标'), findsNothing);
  });

  testWidgets('does not show warm-up notice when all values are available', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantRsiChart(
            bars: [_bar(DateTime(2026, 7, 28)), _bar(DateTime(2026, 7, 29))],
            values: const [45, 55],
          ),
        ),
      ),
    );

    expect(find.textContaining('用于指标预热'), findsNothing);
  });
}

StockDailyBar _bar(DateTime tradingDate) {
  return StockDailyBar(
    tradingDate: tradingDate,
    open: 10,
    high: 11,
    low: 9,
    close: 10.5,
    volume: 1000,
  );
}
