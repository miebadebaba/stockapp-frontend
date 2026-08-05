import 'package:flutter_stockapp/features/quant/quant_factor_preset.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_preset_calculator.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final score = QuantFactorScore(
    technicalScore: 63,
    riskAdjustedScore: 55,
    riskPenalty: 8,
    riskAdjustedRating: QuantTechnicalRating.neutral,
    rating: QuantTechnicalRating.neutral,
    factors: const [
      QuantFactorItem(
        id: 'trend',
        label: '趋势',
        score: 80,
        weight: 0.40,
        signal: QuantFactorSignal.strong,
        summary: '趋势较强',
        evidence: [],
      ),
      QuantFactorItem(
        id: 'momentum',
        label: '动量',
        score: 60,
        weight: 0.35,
        signal: QuantFactorSignal.neutral,
        summary: '动量中性',
        evidence: [],
      ),
      QuantFactorItem(
        id: 'volume',
        label: '量价',
        score: 40,
        weight: 0.25,
        signal: QuantFactorSignal.negative,
        summary: '量价偏弱',
        evidence: [],
      ),
    ],
    risk: const QuantRiskAssessment(
      level: QuantRiskLevel.medium,
      summary: '风险中等',
    ),
    summary: '测试评分',
    hasSufficientData: true,
  );

  test('根据策略权重计算不同的技术评分', () {
    final conservative = calculatePresetTechnicalScore(
      score: score,
      preset: quantFactorPresetByType(QuantFactorPresetType.conservative),
    );
    final balanced = calculatePresetTechnicalScore(
      score: score,
      preset: quantFactorPresetByType(QuantFactorPresetType.balanced),
    );
    final aggressive = calculatePresetTechnicalScore(
      score: score,
      preset: quantFactorPresetByType(QuantFactorPresetType.aggressive),
    );

    expect(conservative, 64);
    expect(balanced, 63);
    expect(aggressive, 62);
  });

  test('风险扣分强度随策略风险偏好变化', () {
    final conservative = calculatePresetRiskAdjustedScore(
      score: score,
      preset: quantFactorPresetByType(QuantFactorPresetType.conservative),
    );
    final balanced = calculatePresetRiskAdjustedScore(
      score: score,
      preset: quantFactorPresetByType(QuantFactorPresetType.balanced),
    );
    final aggressive = calculatePresetRiskAdjustedScore(
      score: score,
      preset: quantFactorPresetByType(QuantFactorPresetType.aggressive),
    );

    expect(conservative, 54);
    expect(balanced, 55);
    expect(aggressive, 56);
  });

  test('数据不足时不生成策略风险调整分', () {
    const unavailableScore = QuantFactorScore(
      technicalScore: 0,
      rating: QuantTechnicalRating.unavailable,
      factors: [],
      risk: QuantRiskAssessment(
        level: QuantRiskLevel.unavailable,
        summary: '数据不足',
      ),
      summary: '数据不足',
      hasSufficientData: false,
    );

    final preset = quantFactorPresetByType(QuantFactorPresetType.balanced);

    expect(
      calculatePresetTechnicalScore(score: unavailableScore, preset: preset),
      0,
    );
    expect(
      calculatePresetRiskAdjustedScore(score: unavailableScore, preset: preset),
      isNull,
    );
  });
}
