import 'package:flutter/material.dart';
import 'package:flutter_stockapp/features/quant/quant_candlestick_chart.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders candlesticks from daily bars', (tester) async {
    final bars = [
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
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 220,
            child: QuantCandlestickChart(bars: bars, selectedIndex: 1),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(
      find.byKey(const ValueKey('quant-candlestick-chart')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders safely when bars are empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 220,
            child: QuantCandlestickChart(bars: []),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(
      find.byKey(const ValueKey('quant-candlestick-chart')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
