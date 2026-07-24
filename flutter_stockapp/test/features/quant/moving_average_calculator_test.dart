import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/features/quant/moving_average_calculator.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';

void main() {
  test('使用最近5个收盘价计算MA5', () {
    final bars = [_bar(10), _bar(11), _bar(12), _bar(13), _bar(14)];

    final result = calculateMovingAverage(bars: bars, period: 5);

    expect(result, 12);
  });

  test('历史数据不足时返回null', () {
    final bars = [_bar(10), _bar(11)];

    final result = calculateMovingAverage(bars: bars, period: 5);

    expect(result, isNull);
  });

  test('周期不合法时抛出错误', () {
    expect(
      () => calculateMovingAverage(bars: const [], period: 0),
      throwsArgumentError,
    );
  });
  test('MA5 only uses the latest 5 closing prices', () {
    final bars = [_bar(1), _bar(10), _bar(11), _bar(12), _bar(13), _bar(14)];

    final result = calculateMovingAverage(bars: bars, period: 5);

    expect(result, 12);
  });
}

StockDailyBar _bar(double close) {
  return StockDailyBar(
    tradingDate: DateTime(2026, 7, 1),
    open: close,
    high: close,
    low: close,
    close: close,
    volume: 1000,
  );
}
