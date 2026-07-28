import 'package:flutter_stockapp/features/quant/technical_summary_response_mapper.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapTechnicalSummaryResponse', () {
    test('maps a complete backend response', () {
      final result = mapTechnicalSummaryResponse({
        'trend': 'upward',
        'momentum': 'positive',
        'strength': 'relatively_strong',
        'participation': 'confirming',
        'consistency': 'high',
        'risk_flags': ['price_extended'],
      });

      expect(result.trend, TrendState.upward);
      expect(result.momentum, MomentumState.positive);
      expect(result.strength, StrengthState.relativelyStrong);
      expect(result.participation, ParticipationState.confirming);
      expect(result.consistency, EvidenceConsistency.high);
      expect(result.riskFlags, [TechnicalRiskFlag.priceExtended]);
    });

    test('maps backend insufficient data states', () {
      final result = mapTechnicalSummaryResponse({
        'trend': 'insufficient_data',
        'momentum': 'insufficient_data',
        'strength': 'insufficient_data',
        'participation': 'insufficient_data',
        'consistency': 'unavailable',
        'risk_flags': ['data_insufficient'],
      });

      expect(result.trend, TrendState.unavailable);
      expect(result.momentum, MomentumState.unavailable);
      expect(result.strength, StrengthState.unavailable);
      expect(result.participation, ParticipationState.unavailable);
      expect(result.consistency, EvidenceConsistency.unavailable);
      expect(result.riskFlags, [TechnicalRiskFlag.dataInsufficient]);
    });

    test('rejects an unknown backend state', () {
      expect(
        () => mapTechnicalSummaryResponse({
          'trend': 'unexpected',
          'momentum': 'positive',
          'strength': 'balanced',
          'participation': 'confirming',
          'consistency': 'high',
          'risk_flags': <String>[],
        }),
        throwsFormatException,
      );
    });
  });
}
