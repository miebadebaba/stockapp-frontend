import 'package:flutter_stockapp/features/quant/macd_series.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns one value for every bar', () {
    final bars = _barsFromCloses([10, 11, 12, 13, 14, 15]);

    final result = calculateMacdSeries(
      bars: bars,
      fastPeriod: 2,
      slowPeriod: 3,
      signalPeriod: 2,
    );

    expect(result, hasLength(bars.length));
    expect(result.take(3), everyElement(isNull));
    expect(result[3], isNotNull);
  });

  test('returns zero values when prices do not change', () {
    final bars = _barsFromCloses([10, 10, 10, 10, 10]);

    final result = calculateMacdSeries(
      bars: bars,
      fastPeriod: 2,
      slowPeriod: 3,
      signalPeriod: 2,
    );

    final latest = result.last;

    expect(latest, isNotNull);
    expect(latest!.dif, closeTo(0, 0.000001));
    expect(latest.dea, closeTo(0, 0.000001));
    expect(latest.histogram, closeTo(0, 0.000001));
  });

  test('returns positive DIF and DEA during a rising trend', () {
    final bars = _barsFromCloses([10, 11, 12, 13, 14, 15]);

    final result = calculateMacdSeries(
      bars: bars,
      fastPeriod: 2,
      slowPeriod: 3,
      signalPeriod: 2,
    );

    final latest = result.last;

    expect(latest, isNotNull);
    expect(latest!.dif, greaterThan(0));
    expect(latest.dea, greaterThan(0));
    expect(latest.histogram, closeTo(2 * (latest.dif - latest.dea), 0.000001));
  });

  test('returns an empty series for empty bars', () {
    final result = calculateMacdSeries(bars: const []);

    expect(result, isEmpty);
  });

  test('throws an error when a period is invalid', () {
    expect(
      () => calculateMacdSeries(bars: const [], fastPeriod: 0),
      throwsArgumentError,
    );
  });

  test('throws when fast period is not shorter than slow period', () {
    expect(
      () => calculateMacdSeries(bars: const [], fastPeriod: 3, slowPeriod: 3),
      throwsArgumentError,
    );
  });
}

List<StockDailyBar> _barsFromCloses(List<double> closes) {
  return List.generate(closes.length, (index) {
    final close = closes[index];

    return StockDailyBar(
      tradingDate: DateTime(2026, 7, 1).add(Duration(days: index)),
      open: close,
      high: close,
      low: close,
      close: close,
      volume: 1000,
    );
  });
}
