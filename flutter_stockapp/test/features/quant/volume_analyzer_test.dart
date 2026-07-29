import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_stockapp/features/quant/volume_analysis_result.dart';
import 'package:flutter_stockapp/features/quant/volume_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('历史数据不足时返回 null', () {
    final bars = _buildBars(
      closes: [10, 10, 10, 10, 10],
      volumes: [100, 100, 100, 100, 100],
    );

    final result = analyzeVolume(bars: bars);

    expect(result, isNull);
  });

  test('正确计算前5日平均成交量和量比', () {
    final bars = _buildBars(
      closes: [10, 10, 10, 10, 10, 11],
      volumes: [100, 200, 300, 400, 500, 600],
    );

    final result = analyzeVolume(bars: bars);

    expect(result, isNotNull);
    expect(result!.latestVolume, 600);
    expect(result.averageVolume, 300);
    expect(result.volumeRatio, 2);
  });

  test('最新收盘价上涨时返回 up', () {
    final bars = _buildBars(
      closes: [10, 10, 10, 10, 10, 11],
      volumes: [100, 100, 100, 100, 100, 100],
    );

    final result = analyzeVolume(bars: bars);

    expect(result!.priceDirection, PriceDirection.up);
  });

  test('最新收盘价下跌时返回 down', () {
    final bars = _buildBars(
      closes: [10, 10, 10, 10, 11, 10],
      volumes: [100, 100, 100, 100, 100, 100],
    );

    final result = analyzeVolume(bars: bars);

    expect(result!.priceDirection, PriceDirection.down);
  });

  test('最新收盘价不变时返回 flat', () {
    final bars = _buildBars(
      closes: [10, 10, 10, 10, 10, 10],
      volumes: [100, 100, 100, 100, 100, 100],
    );

    final result = analyzeVolume(bars: bars);

    expect(result!.priceDirection, PriceDirection.flat);
  });

  test('最新成交量不计入基准平均值', () {
    final bars = _buildBars(
      closes: [10, 10, 10, 10, 10, 11],
      volumes: [100, 100, 100, 100, 100, 1000],
    );

    final result = analyzeVolume(bars: bars);

    expect(result!.averageVolume, 100);
    expect(result.volumeRatio, 10);
  });

  test('周期小于等于0时抛出错误', () {
    expect(
      () => analyzeVolume(bars: const [], baselinePeriod: 0),
      throwsArgumentError,
    );
  });

  test('成交量为负数时返回 null', () {
    final bars = _buildBars(
      closes: [10, 10, 10, 10, 10, 11],
      volumes: [100, 100, -1, 100, 100, 200],
    );

    final result = analyzeVolume(bars: bars);

    expect(result, isNull);
  });

  test('基准平均成交量为0时返回 null', () {
    final bars = _buildBars(
      closes: [10, 10, 10, 10, 10, 11],
      volumes: [0, 0, 0, 0, 0, 200],
    );

    final result = analyzeVolume(bars: bars);

    expect(result, isNull);
  });
}

List<StockDailyBar> _buildBars({
  required List<double> closes,
  required List<int> volumes,
}) {
  return List.generate(closes.length, (index) {
    final close = closes[index];

    return StockDailyBar(
      tradingDate: DateTime(2026, 7, 1).add(Duration(days: index)),
      open: close,
      high: close,
      low: close,
      close: close,
      volume: volumes[index],
    );
  });
}
