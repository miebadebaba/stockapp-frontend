import 'macd_result.dart';
import 'stock_daily_bar.dart';

MacdResult? calculateMacd({
  required List<StockDailyBar> bars,
  int fastPeriod = 12,
  int slowPeriod = 26,
  int signalPeriod = 9,
}) {
  if (fastPeriod <= 0 || slowPeriod <= 0 || signalPeriod <= 0) {
    throw ArgumentError('MACD周期必须大于0');
  }

  if (fastPeriod >= slowPeriod) {
    throw ArgumentError('快速周期必须小于慢速周期');
  }

  final minimumBarCount = slowPeriod + signalPeriod - 1;

  if (bars.length < minimumBarCount) {
    return null;
  }

  final fastAlpha = 2 / (fastPeriod + 1);
  final slowAlpha = 2 / (slowPeriod + 1);
  final signalAlpha = 2 / (signalPeriod + 1);

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
  }

  return MacdResult(dif: dif, dea: dea, histogram: 2 * (dif - dea));
}
