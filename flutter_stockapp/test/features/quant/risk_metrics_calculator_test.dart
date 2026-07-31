import 'package:flutter_stockapp/features/quant/risk_metrics_calculator.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('计算年化波动率和最大回撤', () {
    final bars = _barsFromCloses([100, 120, 90, 108]);

    final result = calculateRiskMetrics(bars: bars);

    expect(result, isNotNull);
    expect(result!.annualizedVolatility, greaterThan(0));
    expect(result.maximumDrawdown, closeTo(0.25, 0.000001));
  });

  test('计算前按照交易日期排序', () {
    final bars = [
      _bar(date: DateTime(2026, 7, 3), close: 90),
      _bar(date: DateTime(2026, 7, 1), close: 100),
      _bar(date: DateTime(2026, 7, 2), close: 120),
    ];

    final result = calculateRiskMetrics(bars: bars);

    expect(result, isNotNull);
    expect(result!.maximumDrawdown, closeTo(0.25, 0.000001));
  });

  test('历史数据不足时返回 null', () {
    final bars = _barsFromCloses([100, 110]);

    final result = calculateRiskMetrics(bars: bars);

    expect(result, isNull);
  });

  test('每年交易日数量必须大于 0', () {
    final bars = _barsFromCloses([100, 110, 105]);

    expect(
      () => calculateRiskMetrics(bars: bars, tradingDaysPerYear: 0),
      throwsArgumentError,
    );
  });
}

List<StockDailyBar> _barsFromCloses(List<double> closes) {
  return List.generate(
    closes.length,
    (index) => _bar(date: DateTime(2026, 7, index + 1), close: closes[index]),
  );
}

StockDailyBar _bar({required DateTime date, required double close}) {
  return StockDailyBar(
    tradingDate: date,
    open: close,
    high: close,
    low: close,
    close: close,
    volume: 1000,
  );
}
