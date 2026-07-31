import 'dart:math' as math;

import 'stock_daily_bar.dart';

class RiskMetrics {
  const RiskMetrics({
    required this.annualizedVolatility,
    required this.maximumDrawdown,
  });

  final double annualizedVolatility;
  final double maximumDrawdown;
}

RiskMetrics? calculateRiskMetrics({
  required List<StockDailyBar> bars,
  int tradingDaysPerYear = 252,
}) {
  if (tradingDaysPerYear <= 0) {
    throw ArgumentError.value(
      tradingDaysPerYear,
      'tradingDaysPerYear',
      'Must be greater than 0',
    );
  }

  if (bars.length < 3) {
    return null;
  }

  final orderedBars = [...bars]
    ..sort((left, right) => left.tradingDate.compareTo(right.tradingDate));

  if (orderedBars.any((bar) => !bar.close.isFinite || bar.close <= 0)) {
    return null;
  }

  final returns = <double>[];
  var peak = orderedBars.first.close;
  var maximumDrawdown = 0.0;

  for (var index = 1; index < orderedBars.length; index++) {
    final previousClose = orderedBars[index - 1].close;
    final currentClose = orderedBars[index].close;

    returns.add(math.log(currentClose / previousClose));

    if (currentClose > peak) {
      peak = currentClose;
    }

    final drawdown = (peak - currentClose) / peak;
    if (drawdown > maximumDrawdown) {
      maximumDrawdown = drawdown;
    }
  }

  final mean = returns.reduce((left, right) => left + right) / returns.length;

  var squaredDeviationTotal = 0.0;
  for (final value in returns) {
    final deviation = value - mean;
    squaredDeviationTotal += deviation * deviation;
  }

  final dailyVolatility = math.sqrt(
    squaredDeviationTotal / (returns.length - 1),
  );

  return RiskMetrics(
    annualizedVolatility:
        dailyVolatility * math.sqrt(tradingDaysPerYear.toDouble()),
    maximumDrawdown: maximumDrawdown,
  );
}
