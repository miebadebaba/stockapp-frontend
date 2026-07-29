import 'macd_result.dart';
import 'moving_average_calculator.dart';
import 'stock_daily_bar.dart';
import 'technical_summary_result.dart';
import 'volume_analysis_result.dart';

StrengthState classifyStrength(double? rsi) {
  if (rsi == null || !rsi.isFinite || rsi < 0 || rsi > 100) {
    return StrengthState.unavailable;
  }

  if (rsi >= 70) {
    return StrengthState.overextendedHigh;
  }

  if (rsi > 55) {
    return StrengthState.relativelyStrong;
  }

  if (rsi >= 45) {
    return StrengthState.balanced;
  }

  if (rsi > 30) {
    return StrengthState.relativelyWeak;
  }

  return StrengthState.overextendedLow;
}

TrendState classifyTrend({required List<StockDailyBar> bars}) {
  const slopeLookback = 5;
  const slopeThreshold = 0.005;

  if (bars.length < 20 + slopeLookback) {
    return TrendState.unavailable;
  }

  final latestClose = bars.last.close;
  final ma5 = calculateMovingAverage(bars: bars, period: 5);
  final ma10 = calculateMovingAverage(bars: bars, period: 10);
  final ma20 = calculateMovingAverage(bars: bars, period: 20);

  final earlierBars = bars.sublist(0, bars.length - slopeLookback);
  final earlierMa20 = calculateMovingAverage(bars: earlierBars, period: 20);

  if (ma5 == null ||
      ma10 == null ||
      ma20 == null ||
      earlierMa20 == null ||
      !latestClose.isFinite ||
      !ma5.isFinite ||
      !ma10.isFinite ||
      !ma20.isFinite ||
      !earlierMa20.isFinite ||
      latestClose <= 0 ||
      ma20 <= 0 ||
      earlierMa20 <= 0) {
    return TrendState.unavailable;
  }

  final ma20Slope = (ma20 - earlierMa20) / earlierMa20;

  final isUpward =
      latestClose >= ma20 && ma5 >= ma10 && ma20Slope >= slopeThreshold;

  if (isUpward) {
    return TrendState.upward;
  }

  final isDownward =
      latestClose <= ma20 && ma5 <= ma10 && ma20Slope <= -slopeThreshold;

  if (isDownward) {
    return TrendState.downward;
  }

  return TrendState.mixed;
}

MomentumState classifyMomentum(MacdResult? macd) {
  if (macd == null ||
      !macd.dif.isFinite ||
      !macd.dea.isFinite ||
      !macd.histogram.isFinite) {
    return MomentumState.unavailable;
  }

  final isPositive = macd.dif > macd.dea && macd.histogram > 0;

  if (isPositive) {
    return MomentumState.positive;
  }

  final isNegative = macd.dif < macd.dea && macd.histogram < 0;

  if (isNegative) {
    return MomentumState.negative;
  }

  return MomentumState.mixed;
}

ParticipationState classifyParticipation({
  required VolumeAnalysisResult? volume,
  required TrendState trend,
}) {
  if (volume == null ||
      !volume.volumeRatio.isFinite ||
      volume.volumeRatio < 0 ||
      trend == TrendState.unavailable) {
    return ParticipationState.unavailable;
  }

  if (volume.volumeRatio < 0.9) {
    return ParticipationState.low;
  }

  if (volume.volumeRatio < 1.1 ||
      volume.priceDirection == PriceDirection.flat ||
      trend == TrendState.mixed) {
    return ParticipationState.inconclusive;
  }

  final confirmsUpwardTrend =
      trend == TrendState.upward && volume.priceDirection == PriceDirection.up;

  final confirmsDownwardTrend =
      trend == TrendState.downward &&
      volume.priceDirection == PriceDirection.down;

  if (confirmsUpwardTrend || confirmsDownwardTrend) {
    return ParticipationState.confirming;
  }

  return ParticipationState.contradicting;
}

EvidenceConsistency classifyConsistency({
  required TrendState trend,
  required MomentumState momentum,
  required ParticipationState participation,
}) {
  if (trend == TrendState.unavailable ||
      momentum == MomentumState.unavailable) {
    return EvidenceConsistency.unavailable;
  }

  final directionConflicts =
      (trend == TrendState.upward && momentum == MomentumState.negative) ||
      (trend == TrendState.downward && momentum == MomentumState.positive);

  if (directionConflicts || participation == ParticipationState.contradicting) {
    return EvidenceConsistency.divergent;
  }

  final directionAligns =
      (trend == TrendState.upward && momentum == MomentumState.positive) ||
      (trend == TrendState.downward && momentum == MomentumState.negative);

  if (directionAligns && participation == ParticipationState.confirming) {
    return EvidenceConsistency.high;
  }

  if (directionAligns) {
    return EvidenceConsistency.moderate;
  }

  return EvidenceConsistency.divergent;
}

List<TechnicalRiskFlag> identifyRiskFlags({
  required List<StockDailyBar> bars,
  required double? rsi,
}) {
  const priceDeviationThreshold = 0.10;
  final flags = <TechnicalRiskFlag>[];

  if (rsi == null || !rsi.isFinite || rsi < 0 || rsi > 100) {
    flags.add(TechnicalRiskFlag.dataInsufficient);
  } else if (rsi >= 70) {
    flags.add(TechnicalRiskFlag.rsiHigh);
  } else if (rsi <= 30) {
    flags.add(TechnicalRiskFlag.rsiLow);
  }

  final ma20 = calculateMovingAverage(bars: bars, period: 20);

  if (bars.isEmpty ||
      ma20 == null ||
      !bars.last.close.isFinite ||
      !ma20.isFinite ||
      bars.last.close <= 0 ||
      ma20 <= 0) {
    if (!flags.contains(TechnicalRiskFlag.dataInsufficient)) {
      flags.add(TechnicalRiskFlag.dataInsufficient);
    }

    return flags;
  }

  final priceDeviation = (bars.last.close - ma20).abs() / ma20;

  if (priceDeviation >= priceDeviationThreshold) {
    flags.add(TechnicalRiskFlag.priceExtended);
  }

  return flags;
}

TechnicalSummaryResult analyzeTechnicalSummary({
  required List<StockDailyBar> bars,
  required double? rsi,
  required MacdResult? macd,
  required VolumeAnalysisResult? volume,
}) {
  final trend = classifyTrend(bars: bars);
  final momentum = classifyMomentum(macd);
  final strength = classifyStrength(rsi);
  final participation = classifyParticipation(volume: volume, trend: trend);
  final consistency = classifyConsistency(
    trend: trend,
    momentum: momentum,
    participation: participation,
  );
  final riskFlags = identifyRiskFlags(bars: bars, rsi: rsi);

  return TechnicalSummaryResult(
    trend: trend,
    momentum: momentum,
    strength: strength,
    participation: participation,
    consistency: consistency,
    riskFlags: List.unmodifiable(riskFlags),
  );
}
