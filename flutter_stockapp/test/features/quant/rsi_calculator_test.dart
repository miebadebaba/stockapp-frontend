import 'package:flutter_stockapp/features/quant/rsi_calculator.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('数据不足时返回 null', () {
    final bars = _barsFromCloses([10, 11, 12]);

    final result = calculateRsi(bars: bars, period: 3);

    expect(result, isNull);
  });

  test('只有上涨时返回 100', () {
    final bars = _barsFromCloses([10, 11, 12, 13]);

    final result = calculateRsi(bars: bars, period: 3);

    expect(result, 100);
  });

  test('只有下跌时返回 0', () {
    final bars = _barsFromCloses([13, 12, 11, 10]);

    final result = calculateRsi(bars: bars, period: 3);

    expect(result, 0);
  });

  test('价格完全不变时返回 50', () {
    final bars = _barsFromCloses([10, 10, 10, 10]);

    final result = calculateRsi(bars: bars, period: 3);

    expect(result, 50);
  });

  test('有涨有跌时正确计算 RSI', () {
    final bars = _barsFromCloses([10, 12, 11, 13]);

    final result = calculateRsi(bars: bars, period: 3);

    expect(result, closeTo(80, 0.0001));
  });

  test('周期不合法时抛出错误', () {
    expect(() => calculateRsi(bars: const [], period: 0), throwsArgumentError);
  });
}

List<StockDailyBar> _barsFromCloses(List<double> closes) {
  return List.generate(closes.length, (index) {
    final close = closes[index];

    return StockDailyBar(
      tradingDate: DateTime(2026, 7, index + 1),
      open: close,
      high: close,
      low: close,
      close: close,
      volume: 1000,
    );
  });
}
