import 'stock_daily_bar.dart';

double? calculateRsi({required List<StockDailyBar> bars, int period = 14}) {
  if (period <= 0) {
    throw ArgumentError.value(period, 'period', '周期必须大于 0');
  }

  if (bars.length < period + 1) {
    return null;
  }

  var totalGain = 0.0;
  var totalLoss = 0.0;
  final startIndex = bars.length - period;

  for (var index = startIndex; index < bars.length; index++) {
    final change = bars[index].close - bars[index - 1].close;

    if (change > 0) {
      totalGain += change;
    } else if (change < 0) {
      totalLoss += -change;
    }
  }

  if (totalGain == 0 && totalLoss == 0) {
    return 50;
  }

  if (totalLoss == 0) {
    return 100;
  }

  if (totalGain == 0) {
    return 0;
  }

  final averageGain = totalGain / period;
  final averageLoss = totalLoss / period;
  final relativeStrength = averageGain / averageLoss;

  return 100 - (100 / (1 + relativeStrength));
}
