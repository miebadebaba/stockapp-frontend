import 'package:flutter_stockapp/features/quant/rsi_series.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns null until there are enough price changes', () {
    final bars = [10, 11, 12].map(_bar).toList();

    final result = calculateRsiSeries(bars: bars, period: 3);

    expect(result, [null, null, null]);
  });

  test('returns 100 when all price changes are gains', () {
    final bars = [10, 11, 12, 13, 14].map(_bar).toList();

    final result = calculateRsiSeries(bars: bars, period: 3);

    expect(result, [null, null, null, 100, 100]);
  });

  test('returns 0 when all price changes are losses', () {
    final bars = [14, 13, 12, 11].map(_bar).toList();

    final result = calculateRsiSeries(bars: bars, period: 3);

    expect(result, [null, null, null, 0]);
  });

  test('returns 50 when prices do not change', () {
    final bars = [10, 10, 10, 10].map(_bar).toList();

    final result = calculateRsiSeries(bars: bars, period: 3);

    expect(result, [null, null, null, 50]);
  });

  test('calculates each rolling RSI value', () {
    final bars = [10, 12, 11, 13, 12].map(_bar).toList();

    final result = calculateRsiSeries(bars: bars, period: 3);

    expect(result[3], closeTo(80, 0.0001));
    expect(result[4], closeTo(50, 0.0001));
  });

  test('throws an error when the period is invalid', () {
    expect(
      () => calculateRsiSeries(bars: const [], period: 0),
      throwsArgumentError,
    );
  });
}

StockDailyBar _bar(num close) {
  final value = close.toDouble();

  return StockDailyBar(
    tradingDate: DateTime(2026, 7, 1),
    open: value,
    high: value,
    low: value,
    close: value,
    volume: 1000,
  );
}
