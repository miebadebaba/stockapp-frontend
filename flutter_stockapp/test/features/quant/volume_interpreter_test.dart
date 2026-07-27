import 'package:flutter_stockapp/features/quant/volume_analysis_result.dart';
import 'package:flutter_stockapp/features/quant/volume_insight.dart';
import 'package:flutter_stockapp/features/quant/volume_interpreter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('成交量分析结果为空时返回 unavailable', () {
    final insight = interpretVolume(null);

    expect(insight.state, VolumeInsightState.unavailable);
    expect(insight.title, '暂时无法解读成交量');
  });

  test('量比等于1.50且价格上涨时返回明显放量上涨', () {
    final insight = interpretVolume(
      _result(volumeRatio: 1.50, priceDirection: PriceDirection.up),
    );

    expect(insight.state, VolumeInsightState.elevated);
    expect(insight.title, '明显放量上涨');
  });

  test('量比等于1.10且价格下跌时返回温和放量下跌', () {
    final insight = interpretVolume(
      _result(volumeRatio: 1.10, priceDirection: PriceDirection.down),
    );

    expect(insight.state, VolumeInsightState.elevated);
    expect(insight.title, '温和放量下跌');
  });

  test('放量但价格持平时返回对应解释', () {
    final insight = interpretVolume(
      _result(volumeRatio: 1.20, priceDirection: PriceDirection.flat),
    );

    expect(insight.state, VolumeInsightState.elevated);
    expect(insight.title, '温和放量但价格基本持平');
  });

  test('量比等于0.90时返回接近近期平均水平', () {
    final insight = interpretVolume(
      _result(volumeRatio: 0.90, priceDirection: PriceDirection.up),
    );

    expect(insight.state, VolumeInsightState.normal);
    expect(insight.title, '成交量接近近期平均水平');
  });

  test('量比等于0.60且价格上涨时返回温和缩量上涨', () {
    final insight = interpretVolume(
      _result(volumeRatio: 0.60, priceDirection: PriceDirection.up),
    );

    expect(insight.state, VolumeInsightState.reduced);
    expect(insight.title, '温和缩量上涨');
  });

  test('量比低于0.60且价格下跌时返回明显缩量下跌', () {
    final insight = interpretVolume(
      _result(volumeRatio: 0.59, priceDirection: PriceDirection.down),
    );

    expect(insight.state, VolumeInsightState.reduced);
    expect(insight.title, '明显缩量下跌');
  });

  test('缩量但价格持平时返回对应解释', () {
    final insight = interpretVolume(
      _result(volumeRatio: 0.80, priceDirection: PriceDirection.flat),
    );

    expect(insight.state, VolumeInsightState.reduced);
    expect(insight.title, '温和缩量且价格基本持平');
  });
}

VolumeAnalysisResult _result({
  required double volumeRatio,
  required PriceDirection priceDirection,
}) {
  return VolumeAnalysisResult(
    latestVolume: 100,
    averageVolume: 100,
    volumeRatio: volumeRatio,
    priceDirection: priceDirection,
  );
}
