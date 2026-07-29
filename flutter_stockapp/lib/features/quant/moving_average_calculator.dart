import 'stock_daily_bar.dart';

double? calculateMovingAverage({
  required List<StockDailyBar> bars,
  required int period,
}) {
  if (period <= 0) {
    throw ArgumentError.value(period, 'period', '周期必须大于 0');
  }

  if (bars.length < period) {
    return null;
  }

  var total = 0.0;
  final startIndex = bars.length - period;

  for (var index = startIndex; index < bars.length; index++) {
    total += bars[index].close;
  }

  return total / period;
}
