import 'package:flutter_stockapp/features/quant/technical_summary_analyzer.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('classifyConsistency', () {
    test('趋势或动能不可用时返回 unavailable', () {
      expect(
        classifyConsistency(
          trend: TrendState.unavailable,
          momentum: MomentumState.positive,
          participation: ParticipationState.confirming,
        ),
        EvidenceConsistency.unavailable,
      );

      expect(
        classifyConsistency(
          trend: TrendState.upward,
          momentum: MomentumState.unavailable,
          participation: ParticipationState.confirming,
        ),
        EvidenceConsistency.unavailable,
      );
    });

    test('趋势与动能方向相反时返回 divergent', () {
      expect(
        classifyConsistency(
          trend: TrendState.upward,
          momentum: MomentumState.negative,
          participation: ParticipationState.inconclusive,
        ),
        EvidenceConsistency.divergent,
      );

      expect(
        classifyConsistency(
          trend: TrendState.downward,
          momentum: MomentumState.positive,
          participation: ParticipationState.inconclusive,
        ),
        EvidenceConsistency.divergent,
      );
    });

    test('成交量与趋势冲突时返回 divergent', () {
      expect(
        classifyConsistency(
          trend: TrendState.upward,
          momentum: MomentumState.positive,
          participation: ParticipationState.contradicting,
        ),
        EvidenceConsistency.divergent,
      );
    });

    test('趋势动能一致且成交量确认时返回 high', () {
      expect(
        classifyConsistency(
          trend: TrendState.upward,
          momentum: MomentumState.positive,
          participation: ParticipationState.confirming,
        ),
        EvidenceConsistency.high,
      );

      expect(
        classifyConsistency(
          trend: TrendState.downward,
          momentum: MomentumState.negative,
          participation: ParticipationState.confirming,
        ),
        EvidenceConsistency.high,
      );
    });

    test('趋势动能一致但成交量未确认时返回 moderate', () {
      expect(
        classifyConsistency(
          trend: TrendState.upward,
          momentum: MomentumState.positive,
          participation: ParticipationState.inconclusive,
        ),
        EvidenceConsistency.moderate,
      );

      expect(
        classifyConsistency(
          trend: TrendState.downward,
          momentum: MomentumState.negative,
          participation: ParticipationState.low,
        ),
        EvidenceConsistency.moderate,
      );
    });

    test('趋势或动能不明确时返回 divergent', () {
      expect(
        classifyConsistency(
          trend: TrendState.mixed,
          momentum: MomentumState.mixed,
          participation: ParticipationState.inconclusive,
        ),
        EvidenceConsistency.divergent,
      );
    });
  });
}
