import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_moving_average_overlay.dart';
import 'package:flutter_stockapp/features/quant/quant_price_chart.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('displays price range and dates from daily bars', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantPriceChart(
            bars: [
              StockDailyBar(
                tradingDate: DateTime(2026, 7, 28),
                open: 10.20,
                high: 10.80,
                low: 10.10,
                close: 10.60,
                volume: 1000,
              ),
              StockDailyBar(
                tradingDate: DateTime(2026, 7, 29),
                open: 10.60,
                high: 11.20,
                low: 10.50,
                close: 11.00,
                volume: 1200,
              ),
              StockDailyBar(
                tradingDate: DateTime(2026, 7, 30),
                open: 11.00,
                high: 11.50,
                low: 10.90,
                close: 11.30,
                volume: 1400,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('近60个交易日价格走势'), findsOneWidget);
    expect(find.text('基于真实日线收盘价绘制'), findsOneWidget);
    expect(find.text('区间最高'), findsOneWidget);
    expect(find.text('11.50'), findsOneWidget);
    expect(find.text('区间最低'), findsOneWidget);
    expect(find.text('10.10'), findsOneWidget);
    expect(find.text('最新收盘'), findsOneWidget);
    expect(find.text('11.30'), findsOneWidget);
    expect(find.text('2026-07-28'), findsOneWidget);
    expect(find.text('2026-07-30'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('switches chart to the latest 20 daily bars', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final bars = List.generate(60, (index) {
      final value = index.toDouble();

      return StockDailyBar(
        tradingDate: DateTime(2026, 1, 1).add(Duration(days: index)),
        open: 100 + value,
        high: 101 + value,
        low: 99 + value,
        close: 100.5 + value,
        volume: index == 0 ? 250000000 : 1000 + index,
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: QuantPriceChart(bars: bars)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('2026-01-01'), findsOneWidget);
    expect(find.text('近60个交易日价格走势'), findsOneWidget);
    expect(find.text('2.50 亿股'), findsOneWidget);

    await tester.tap(find.text('20日'));
    await tester.pumpAndSettle();
    expect(find.text('近20个交易日价格走势'), findsOneWidget);
    expect(find.text('近60个交易日价格走势'), findsNothing);
    expect(find.text('2.50 亿股'), findsNothing);
    expect(find.text('1059 股'), findsNWidgets(2));

    expect(find.text('2026-01-01'), findsNothing);
    expect(find.text('2026-02-10'), findsOneWidget);
    expect(find.text('2026-03-01'), findsOneWidget);
    expect(find.text('139.00'), findsOneWidget);
    expect(find.text('160.00'), findsOneWidget);
    expect(find.text('159.50'), findsOneWidget);
  });

  testWidgets('shows daily details after tapping the price chart', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantPriceChart(
            bars: [
              StockDailyBar(
                tradingDate: DateTime(2026, 7, 28),
                open: 10.20,
                high: 10.80,
                low: 10.10,
                close: 10.60,
                volume: 1000,
              ),
              StockDailyBar(
                tradingDate: DateTime(2026, 7, 29),
                open: 10.60,
                high: 11.20,
                low: 10.50,
                close: 11.00,
                volume: 1200,
              ),
              StockDailyBar(
                tradingDate: DateTime(2026, 7, 30),
                open: 11.00,
                high: 11.50,
                low: 10.90,
                close: 11.30,
                volume: 1400,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('quant-ohlc-details')), findsNothing);

    final chart = find.byKey(const ValueKey('quant-price-chart-gesture'));
    await tester.tapAt(tester.getCenter(chart));
    await tester.pump();

    expect(find.byKey(const ValueKey('quant-ohlc-details')), findsOneWidget);
    expect(find.text('2026-07-29'), findsOneWidget);
    expect(find.text('开盘价'), findsOneWidget);
    expect(find.text('最高价'), findsOneWidget);
    expect(find.text('最低价'), findsOneWidget);
    expect(find.text('收盘价'), findsOneWidget);
    expect(find.text('成交量'), findsOneWidget);
    expect(find.text('+0.40  +3.77%'), findsOneWidget);
  });

  testWidgets('switches from line chart to candlestick chart', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantPriceChart(
            bars: [
              StockDailyBar(
                tradingDate: DateTime(2026, 7, 29),
                open: 10.20,
                high: 10.90,
                low: 10.10,
                close: 10.70,
                volume: 1000,
              ),
              StockDailyBar(
                tradingDate: DateTime(2026, 7, 30),
                open: 10.80,
                high: 11.00,
                low: 10.30,
                close: 10.40,
                volume: 1200,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('quant-candlestick-chart')), findsNothing);

    await tester.tap(find.text('K线图'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('quant-candlestick-chart')),
      findsOneWidget,
    );
  });

  testWidgets('toggles moving average series independently', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final bars = List.generate(20, (index) {
      final value = 10.0 + index;

      return StockDailyBar(
        tradingDate: DateTime(2026, 7, 1).add(Duration(days: index)),
        open: value,
        high: value + 1,
        low: value - 1,
        close: value,
        volume: 1000,
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: QuantPriceChart(bars: bars)),
      ),
    );

    await tester.pumpAndSettle();

    var overlay = tester.widget<QuantMovingAverageOverlay>(
      find.byType(QuantMovingAverageOverlay),
    );

    expect(overlay.series.keys, containsAll([5, 10, 20]));

    await tester.tap(find.byKey(const ValueKey('quant-ma-5-checkbox')));
    await tester.pump();

    overlay = tester.widget<QuantMovingAverageOverlay>(
      find.byType(QuantMovingAverageOverlay),
    );

    expect(overlay.series.containsKey(5), isFalse);
    expect(overlay.series.keys, containsAll([10, 20]));
  });

  testWidgets('renders nothing when bars are empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: QuantPriceChart(bars: [])),
      ),
    );

    expect(find.text('近60个交易日价格走势'), findsNothing);
  });
}
