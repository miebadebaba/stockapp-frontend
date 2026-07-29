import 'package:flutter_stockapp/features/quant/moving_average_insight.dart';
import 'package:flutter_stockapp/features/quant/moving_average_interpreter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('数据不足时返回 unavailable', () {
    final result = interpretMovingAverages(
      close: 10,
      ma5: 9,
      ma10: null,
      ma20: null,
    );

    expect(result.state, MovingAverageInsightState.unavailable);
    expect(result.title, '历史数据不足');
  });

  test('收盘价和均线由高到低排列时返回 positive', () {
    final result = interpretMovingAverages(
      close: 12,
      ma5: 11,
      ma10: 10,
      ma20: 9,
    );

    expect(result.state, MovingAverageInsightState.positive);
    expect(result.title, '短中期价格状态相对偏强');
  });

  test('收盘价和均线由低到高排列时返回 cautious', () {
    final result = interpretMovingAverages(
      close: 8,
      ma5: 9,
      ma10: 10,
      ma20: 11,
    );

    expect(result.state, MovingAverageInsightState.cautious);
    expect(result.title, '短中期价格状态相对偏弱');
  });

  test('均线没有形成一致排列时返回 neutral', () {
    final result = interpretMovingAverages(
      close: 12,
      ma5: 11,
      ma10: 9,
      ma20: 10,
    );

    expect(result.state, MovingAverageInsightState.neutral);
    expect(result.title, '均线方向暂不一致');
  });
  test('均线偏强排列但收盘价低于MA5时返回回落解释', () {
    final result = interpretMovingAverages(
      close: 10.5,
      ma5: 11,
      ma10: 10,
      ma20: 9,
    );

    expect(result.state, MovingAverageInsightState.neutral);
    expect(result.title, '均线排列偏强，但短期价格有所回落');
  });

  test('均线偏弱排列但收盘价高于MA5时返回反弹解释', () {
    final result = interpretMovingAverages(
      close: 11.5,
      ma5: 11,
      ma10: 12,
      ma20: 13,
    );

    expect(result.state, MovingAverageInsightState.neutral);
    expect(result.title, '均线排列偏弱，但短期价格有所反弹');
  });
}
