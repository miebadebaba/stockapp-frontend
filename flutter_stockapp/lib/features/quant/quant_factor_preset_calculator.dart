import 'quant_factor_preset.dart';
import 'quant_factor_score.dart';

double calculatePresetTechnicalScore({
  required QuantFactorScore score,
  required QuantFactorPreset preset,
}) {
  if (!score.hasSufficientData) {
    return 0;
  }

  return score.factors
      .fold<double>(
        0,
        (total, factor) => total + factor.score * preset.weightFor(factor.id),
      )
      .clamp(0, 100)
      .toDouble();
}

double? calculatePresetRiskAdjustedScore({
  required QuantFactorScore score,
  required QuantFactorPreset preset,
}) {
  if (!score.hasSufficientData) {
    return null;
  }

  final riskPenalty = score.riskPenalty;

  if (riskPenalty == null) {
    return null;
  }

  final technicalScore = calculatePresetTechnicalScore(
    score: score,
    preset: preset,
  );

  return (technicalScore - riskPenalty * preset.riskPenaltyMultiplier)
      .clamp(0, 100)
      .toDouble();
}
