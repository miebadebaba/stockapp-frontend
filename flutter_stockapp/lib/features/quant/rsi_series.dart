import 'stock_daily_bar.dart';

List<double?> calculateRsiSeries({
  required List<StockDailyBar> bars,
  int period = 14,
}) {
  if (period <= 0) {
    throw ArgumentError.value(
      period,
      'period',
      'Period must be greater than 0',
    );
  }

  final values = List<double?>.filled(bars.length, null);

  for (var index = period; index < bars.length; index++) {
    var totalGain = 0.0;
    var totalLoss = 0.0;

    for (
      var changeIndex = index - period + 1;
      changeIndex <= index;
      changeIndex++
    ) {
      final change = bars[changeIndex].close - bars[changeIndex - 1].close;

      if (change > 0) {
        totalGain += change;
      } else if (change < 0) {
        totalLoss += -change;
      }
    }

    if (totalGain == 0 && totalLoss == 0) {
      values[index] = 50;
    } else if (totalLoss == 0) {
      values[index] = 100;
    } else if (totalGain == 0) {
      values[index] = 0;
    } else {
      final relativeStrength = totalGain / totalLoss;
      values[index] = 100 - (100 / (1 + relativeStrength));
    }
  }

  return values;
}
