import 'package:flutter_stockapp/features/quant/moving_average_series.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates a moving average value for every complete period', () {
    final bars = [1, 2, 3, 4, 5, 6].map(_bar).toList();

    final result = calculateMovingAverageSeries(bars: bars, period: 3);

    expect(result, [null, null, 2, 3, 4, 5]);
  });

  test('returns null values when history is shorter than the period', () {
    final bars = [10, 11].map(_bar).toList();

    final result = calculateMovingAverageSeries(bars: bars, period: 5);

    expect(result, [null, null]);
  });

  test('throws an error when the period is invalid', () {
    expect(
      () => calculateMovingAverageSeries(bars: const [], period: 0),
      throwsArgumentError,
    );
  });
}

StockDailyBar _bar(num close) {
  final value = close.toDouble();

  return StockDailyBar(
    tradingDate: DateTime(2026, 7, close.toInt()),
    open: value,
    high: value,
    low: value,
    close: value,
    volume: 1000,
  );
}
