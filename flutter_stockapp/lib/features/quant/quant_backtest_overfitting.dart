import 'quant_backtest_comparison.dart';

enum QuantBacktestOverfitRisk { insufficientSample, low, moderate, high }

class QuantBacktestOverfitAssessment {
  const QuantBacktestOverfitAssessment({
    required this.risk,
    required this.referenceableCount,
    this.bestReturnItem,
    this.secondBestReturnItem,
    this.bestReturnAdvantage = 0,
    this.bestHasLimitedSample = false,
    this.hasDrawdownTradeoff = false,
  });

  static const minimumStableTradeCount = 10;
  static const meaningfulReturnAdvantage = 0.04;
  static const largeReturnAdvantage = 0.08;
  static const meaningfulDrawdownTradeoff = 0.05;

  final QuantBacktestOverfitRisk risk;
  final int referenceableCount;
  final QuantBacktestComparisonItem? bestReturnItem;
  final QuantBacktestComparisonItem? secondBestReturnItem;

  /// 最优收益组合相对第二名的累计收益差距。
  final double bestReturnAdvantage;

  /// 最优收益组合交易次数少于稳定参考门槛。
  final bool bestHasLimitedSample;

  /// 最优收益组合的最大回撤明显高于综合参考组合。
  final bool hasDrawdownTradeoff;

  bool get hasEnoughReferenceSamples => referenceableCount >= 2;
}

QuantBacktestOverfitAssessment assessQuantBacktestOverfitting(
  QuantBacktestComparisonResult result,
) {
  final referenceable = result.referenceableItems;
  if (referenceable.length < 2) {
    return QuantBacktestOverfitAssessment(
      risk: QuantBacktestOverfitRisk.insufficientSample,
      referenceableCount: referenceable.length,
    );
  }

  final sorted = [...referenceable]
    ..sort(
      (left, right) => right.cumulativeReturn.compareTo(left.cumulativeReturn),
    );
  final best = sorted.first;
  final second = sorted[1];
  final advantage = best.cumulativeReturn - second.cumulativeReturn;
  final balanced = result.balancedItem;
  final hasDrawdownTradeoff =
      balanced != null &&
      balanced != best &&
      best.maximumDrawdown - balanced.maximumDrawdown >=
          QuantBacktestOverfitAssessment.meaningfulDrawdownTradeoff;
  final bestHasLimitedSample =
      best.tradeCount < QuantBacktestOverfitAssessment.minimumStableTradeCount;
  final hasLargeGap =
      advantage >= QuantBacktestOverfitAssessment.largeReturnAdvantage;
  final hasMeaningfulGap =
      advantage >= QuantBacktestOverfitAssessment.meaningfulReturnAdvantage;

  final risk = hasLargeGap && (bestHasLimitedSample || hasDrawdownTradeoff)
      ? QuantBacktestOverfitRisk.high
      : hasMeaningfulGap || bestHasLimitedSample || hasDrawdownTradeoff
      ? QuantBacktestOverfitRisk.moderate
      : QuantBacktestOverfitRisk.low;

  return QuantBacktestOverfitAssessment(
    risk: risk,
    referenceableCount: referenceable.length,
    bestReturnItem: best,
    secondBestReturnItem: second,
    bestReturnAdvantage: advantage,
    bestHasLimitedSample: bestHasLimitedSample,
    hasDrawdownTradeoff: hasDrawdownTradeoff,
  );
}
