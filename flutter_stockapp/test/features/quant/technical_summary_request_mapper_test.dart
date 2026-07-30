import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_request_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapTechnicalSummaryRequest', () {
    test('maps daily bars to the backend request shape', () {
      final bars = [
        StockDailyBar(
          tradingDate: DateTime(2026, 1, 2),
          open: 10.1,
          high: 10.8,
          low: 9.9,
          close: 10.5,
          volume: 1200,
        ),
        StockDailyBar(
          tradingDate: DateTime(2026, 1, 3),
          open: 10.5,
          high: 11.0,
          low: 10.2,
          close: 10.9,
          volume: 1500,
        ),
      ];

      final result = mapTechnicalSummaryRequest(bars);

      expect(result, [
        {
          'trade_date': '2026-01-02',
          'open': 10.1,
          'high': 10.8,
          'low': 9.9,
          'close': 10.5,
          'volume': 1200,
        },
        {
          'trade_date': '2026-01-03',
          'open': 10.5,
          'high': 11.0,
          'low': 10.2,
          'close': 10.9,
          'volume': 1500,
        },
      ]);
    });

    test('returns an empty request for empty bars', () {
      final result = mapTechnicalSummaryRequest(const []);

      expect(result, isEmpty);
    });

    test('does not modify the original bars', () {
      final bars = [
        StockDailyBar(
          tradingDate: DateTime(2026, 1, 2),
          open: 10,
          high: 10,
          low: 10,
          close: 10,
          volume: 1000,
        ),
      ];
      final originalBars = List<StockDailyBar>.of(bars);

      mapTechnicalSummaryRequest(bars);

      expect(bars, originalBars);
    });
  });
}
