import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/macd_result.dart';
import 'package:flutter_stockapp/features/quant/quant_macd_chart.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('displays latest MACD values and chart', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantMacdChart(
            bars: [
              _bar(DateTime(2026, 7, 28)),
              _bar(DateTime(2026, 7, 29)),
              _bar(DateTime(2026, 7, 30)),
            ],
            values: const [
              null,
              MacdResult(dif: 0.12, dea: 0.08, histogram: 0.08),
              MacdResult(dif: 0.25, dea: 0.15, histogram: 0.20),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('MACD趋势指标'), findsOneWidget);
    expect(find.text('DIF和DEA展示趋势变化，柱状图展示两者差异；0轴用于区分正负动能'), findsOneWidget);
    expect(find.text('0.25'), findsOneWidget);
    expect(find.text('0.15'), findsOneWidget);
    expect(find.text('0.20'), findsOneWidget);
    expect(find.byKey(const ValueKey('quant-macd-chart')), findsOneWidget);
    expect(find.text('前 1 个交易日用于指标预热，对应区间保留为空白。'), findsOneWidget);
    expect(find.text('最新DIF'), findsOneWidget);
    expect(find.text('最新DEA'), findsOneWidget);
    expect(find.text('最新MACD柱'), findsOneWidget);
  });

  testWidgets('displays dates for the full visible price range', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantMacdChart(
            bars: [
              _bar(DateTime(2026, 7, 28)),
              _bar(DateTime(2026, 7, 29)),
              _bar(DateTime(2026, 7, 30)),
              _bar(DateTime(2026, 7, 31)),
              _bar(DateTime(2026, 8, 1)),
            ],
            values: const [
              null,
              null,
              MacdResult(dif: 0.10, dea: 0.08, histogram: 0.04),
              MacdResult(dif: 0.15, dea: 0.10, histogram: 0.10),
              MacdResult(dif: 0.20, dea: 0.12, histogram: 0.16),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final dateAxis = find.byKey(const ValueKey('quant-macd-date-axis'));
    expect(
      find.descendant(of: dateAxis, matching: find.text('2026-07-28')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dateAxis, matching: find.text('2026-07-30')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dateAxis, matching: find.text('2026-08-01')),
      findsOneWidget,
    );
  });

  testWidgets('displays selected date MACD values', (tester) async {
    final selectedDate = DateTime(2026, 7, 29);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantMacdChart(
            bars: [
              _bar(DateTime(2026, 7, 28)),
              _bar(selectedDate),
              _bar(DateTime(2026, 7, 30)),
            ],
            values: const [
              null,
              MacdResult(dif: -0.30, dea: -0.20, histogram: -0.20),
              MacdResult(dif: 0.25, dea: 0.15, histogram: 0.20),
            ],
            selectedTradingDate: selectedDate,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('-0.30'), findsOneWidget);
    expect(find.text('-0.20'), findsNWidgets(2));
    expect(find.text('所选日期DIF'), findsOneWidget);
    expect(find.text('所选日期DEA'), findsOneWidget);
    expect(find.text('所选日期MACD柱'), findsOneWidget);
  });

  testWidgets('shows unavailable values for a selected warm-up date', (
    tester,
  ) async {
    final selectedDate = DateTime(2026, 7, 28);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantMacdChart(
            bars: [
              _bar(selectedDate),
              _bar(DateTime(2026, 7, 29)),
              _bar(DateTime(2026, 7, 30)),
            ],
            values: const [
              null,
              MacdResult(dif: 0.12, dea: 0.08, histogram: 0.08),
              MacdResult(dif: 0.25, dea: 0.15, histogram: 0.20),
            ],
            selectedTradingDate: selectedDate,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('所选日期DIF'), findsOneWidget);
    expect(find.text('所选日期DEA'), findsOneWidget);
    expect(find.text('所选日期MACD柱'), findsOneWidget);
    expect(find.text('--'), findsNWidgets(3));
    expect(find.text('0.25'), findsNothing);
    expect(find.text('0.15'), findsNothing);
    expect(find.text('0.20'), findsNothing);
  });

  testWidgets('renders nothing when bars are empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: QuantMacdChart(bars: [], values: []),
        ),
      ),
    );

    expect(find.text('MACD趋势指标'), findsNothing);
  });

  testWidgets('does not show warm-up notice when all values are available', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantMacdChart(
            bars: [_bar(DateTime(2026, 7, 28)), _bar(DateTime(2026, 7, 29))],
            values: const [
              MacdResult(dif: 0.10, dea: 0.08, histogram: 0.04),
              MacdResult(dif: 0.15, dea: 0.10, histogram: 0.10),
            ],
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
