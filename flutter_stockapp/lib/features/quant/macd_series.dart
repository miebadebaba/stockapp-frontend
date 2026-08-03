import 'macd_result.dart';
import 'stock_daily_bar.dart';

List<MacdResult?> calculateMacdSeries({
  required List<StockDailyBar> bars,
  int fastPeriod = 12,
  int slowPeriod = 26,
  int signalPeriod = 9,
}) {
  if (fastPeriod <= 0 || slowPeriod <= 0 || signalPeriod <= 0) {
    throw ArgumentError('MACD periods must be greater than 0');
  }

  if (fastPeriod >= slowPeriod) {
    throw ArgumentError('Fast period must be shorter than slow period');
  }

  final values = List<MacdResult?>.filled(bars.length, null);
  if (bars.isEmpty) {
    return values;
  }

  final fastAlpha = 2 / (fastPeriod + 1);
  final slowAlpha = 2 / (slowPeriod + 1);
  final signalAlpha = 2 / (signalPeriod + 1);
  final firstVisibleIndex = slowPeriod + signalPeriod - 2;

  var fastEma = bars.first.close;
  var slowEma = bars.first.close;
  var dif = fastEma - slowEma;
  var dea = dif;

  for (var index = 1; index < bars.length; index++) {
    final close = bars[index].close;

    fastEma = close * fastAlpha + fastEma * (1 - fastAlpha);
    slowEma = close * slowAlpha + slowEma * (1 - slowAlpha);

    dif = fastEma - slowEma;
    dea = dif * signalAlpha + dea * (1 - signalAlpha);

    if (index >= firstVisibleIndex) {
      values[index] = MacdResult(
        dif: dif,
        dea: dea,
        histogram: 2 * (dif - dea),
      );
    }
  }

  return values;
}
