import 'package:flutter_stockapp/features/quant/macd_calculator.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('历史数据不足时返回 null', () {
    final bars = _barsFromCloses(List<double>.generate(33, (index) => 10));

    final result = calculateMacd(bars: bars);

    expect(result, isNull);
  });

  test('价格完全不变时三个结果都为 0', () {
    final bars = _barsFromCloses(List<double>.generate(34, (index) => 10));

    final result = calculateMacd(bars: bars);

    expect(result, isNotNull);
    expect(result!.dif, closeTo(0, 0.000001));
    expect(result.dea, closeTo(0, 0.000001));
    expect(result.histogram, closeTo(0, 0.000001));
  });

  test('价格持续上涨时 DIF 和 DEA 为正数', () {
    final bars = _barsFromCloses(
      List<double>.generate(40, (index) => 10 + index.toDouble()),
    );

    final result = calculateMacd(bars: bars);

    expect(result, isNotNull);
    expect(result!.dif, greaterThan(0));
    expect(result.dea, greaterThan(0));
  });

  test('柱值等于 2 乘以 DIF 与 DEA 的差', () {
    final bars = _barsFromCloses(
      List<double>.generate(
        40,
        (index) => 10 + index * 0.5 + (index.isEven ? 0.2 : -0.1),
      ),
    );

    final result = calculateMacd(bars: bars);

    expect(result, isNotNull);
    expect(result!.histogram, closeTo(2 * (result.dif - result.dea), 0.000001));
  });

  test('周期小于等于 0 时抛出错误', () {
    expect(
      () => calculateMacd(bars: const [], fastPeriod: 0),
      throwsArgumentError,
    );
  });

  test('快速周期不小于慢速周期时抛出错误', () {
    expect(
      () => calculateMacd(bars: const [], fastPeriod: 26, slowPeriod: 26),
      throwsArgumentError,
    );
  });
}

List<StockDailyBar> _barsFromCloses(List<double> closes) {
  return List.generate(closes.length, (index) {
    final close = closes[index];

    return StockDailyBar(
      tradingDate: DateTime(2026, 1, 1).add(Duration(days: index)),
      open: close,
      high: close,
      low: close,
      close: close,
      volume: 1000,
    );
  });
}
