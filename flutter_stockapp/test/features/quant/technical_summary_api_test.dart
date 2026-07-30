import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_api.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TechnicalSummaryApi', () {
    test('sends one correctly shaped request and maps the response', () async {
      var callCount = 0;
      String? receivedPath;
      Object? receivedBody;

      final api = TechnicalSummaryApi(
        postJson: ({required String path, required Object body}) async {
          callCount += 1;
          receivedPath = path;
          receivedBody = body;

          return {
            'trend': 'upward',
            'momentum': 'positive',
            'strength': 'relatively_strong',
            'participation': 'confirming',
            'consistency': 'high',
            'risk_flags': <String>[],
          };
        },
      );

      final result = await api.analyze([
        StockDailyBar(
          tradingDate: DateTime(2026, 1, 2),
          open: 10.1,
          high: 10.8,
          low: 9.9,
          close: 10.5,
          volume: 1200,
        ),
      ]);

      expect(callCount, 1);
      expect(receivedPath, '/api/v1/quant/technical-summary');
      expect(receivedBody, [
        {
          'trade_date': '2026-01-02',
          'open': 10.1,
          'high': 10.8,
          'low': 9.9,
          'close': 10.5,
          'volume': 1200,
        },
      ]);
      expect(result.trend, TrendState.upward);
      expect(result.momentum, MomentumState.positive);
      expect(result.strength, StrengthState.relativelyStrong);
      expect(result.participation, ParticipationState.confirming);
      expect(result.consistency, EvidenceConsistency.high);
      expect(result.riskFlags, isEmpty);
    });

    test('maps an insufficient-data response', () async {
      final api = TechnicalSummaryApi(
        postJson: ({required String path, required Object body}) async {
          return {
            'trend': 'insufficient_data',
            'momentum': 'insufficient_data',
            'strength': 'insufficient_data',
            'participation': 'insufficient_data',
            'consistency': 'unavailable',
            'risk_flags': ['data_insufficient'],
          };
        },
      );

      final result = await api.analyze(const []);

      expect(result.trend, TrendState.unavailable);
      expect(result.momentum, MomentumState.unavailable);
      expect(result.strength, StrengthState.unavailable);
      expect(result.participation, ParticipationState.unavailable);
      expect(result.consistency, EvidenceConsistency.unavailable);
      expect(result.riskFlags, [TechnicalRiskFlag.dataInsufficient]);
    });

    test('does not hide a transport error', () async {
      final api = TechnicalSummaryApi(
        postJson: ({required String path, required Object body}) async {
          throw StateError('network unavailable');
        },
      );

      await expectLater(
        api.analyze(const []),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'network unavailable',
          ),
        ),
      );
    });
  });
}
