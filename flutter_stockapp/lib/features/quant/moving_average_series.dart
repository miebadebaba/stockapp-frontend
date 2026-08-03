import 'stock_daily_bar.dart';

List<double?> calculateMovingAverageSeries({
  required List<StockDailyBar> bars,
  required int period,
}) {
  if (period <= 0) {
    throw ArgumentError.value(
      period,
      'period',
      'Period must be greater than 0',
    );
  }

  final values = List<double?>.filled(bars.length, null);
  var rollingTotal = 0.0;

  for (var index = 0; index < bars.length; index++) {
    rollingTotal += bars[index].close;

    if (index >= period) {
      rollingTotal -= bars[index - period].close;
    }

    if (index >= period - 1) {
      values[index] = rollingTotal / period;
    }
  }

  return values;
}
