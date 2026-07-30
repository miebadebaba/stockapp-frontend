import 'package:flutter_stockapp/features/quant/technical_summary_insight.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_interpreter.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('interpretTechnicalSummary', () {
    test('偏强证据高度一致时生成相互印证的解释', () {
      const result = TechnicalSummaryResult(
        trend: TrendState.upward,
        momentum: MomentumState.positive,
        strength: StrengthState.relativelyStrong,
        participation: ParticipationState.confirming,
        consistency: EvidenceConsistency.high,
        riskFlags: [],
      );

      final insight = interpretTechnicalSummary(result);

      expect(insight.state, TechnicalSummaryInsightState.upwardAligned);
      expect(insight.title, '趋势、动能与量价方向相互印证');
      expect(insight.consistencyText, contains('一致性较高'));
      expect(insight.riskMessages, isEmpty);
    });

    test('偏弱证据一致时生成共同偏弱的解释', () {
      const result = TechnicalSummaryResult(
        trend: TrendState.downward,
        momentum: MomentumState.negative,
        strength: StrengthState.relativelyWeak,
        participation: ParticipationState.low,
        consistency: EvidenceConsistency.moderate,
        riskFlags: [],
      );

      final insight = interpretTechnicalSummary(result);

      expect(insight.state, TechnicalSummaryInsightState.downwardAligned);
      expect(insight.title, '趋势与动能共同偏弱');
      expect(insight.momentumText, contains('下跌动能相对占优'));
    });

    test('证据冲突时生成信号分化解释', () {
      const result = TechnicalSummaryResult(
        trend: TrendState.upward,
        momentum: MomentumState.negative,
        strength: StrengthState.balanced,
        participation: ParticipationState.contradicting,
        consistency: EvidenceConsistency.divergent,
        riskFlags: [],
      );

      final insight = interpretTechnicalSummary(result);

      expect(insight.state, TechnicalSummaryInsightState.divergent);
      expect(insight.title, '多项技术证据存在分化');
      expect(insight.overview, contains('不适合用单一指标作出结论'));
    });

    test('关键数据不足时生成不可用解释', () {
      const result = TechnicalSummaryResult(
        trend: TrendState.unavailable,
        momentum: MomentumState.unavailable,
        strength: StrengthState.unavailable,
        participation: ParticipationState.unavailable,
        consistency: EvidenceConsistency.unavailable,
        riskFlags: [TechnicalRiskFlag.dataInsufficient],
      );

      final insight = interpretTechnicalSummary(result);

      expect(insight.state, TechnicalSummaryInsightState.unavailable);
      expect(insight.title, '综合分析数据暂时不足');
      expect(insight.riskMessages, hasLength(1));
      expect(insight.riskMessages.first, contains('历史数据'));
    });

    test('风险标记被转换成对应的风险说明', () {
      const result = TechnicalSummaryResult(
        trend: TrendState.upward,
        momentum: MomentumState.positive,
        strength: StrengthState.overextendedHigh,
        participation: ParticipationState.confirming,
        consistency: EvidenceConsistency.high,
        riskFlags: [TechnicalRiskFlag.rsiHigh, TechnicalRiskFlag.priceExtended],
      );

      final insight = interpretTechnicalSummary(result);

      expect(insight.riskMessages, hasLength(2));
      expect(insight.riskMessages.first, contains('高位'));
      expect(insight.riskMessages.last, contains('MA20'));
      expect(insight.riskNotice, contains('不构成投资建议'));
    });
  });
}
