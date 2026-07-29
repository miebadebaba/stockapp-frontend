import 'package:flutter_stockapp/features/quant/macd_insight.dart';
import 'package:flutter_stockapp/features/quant/macd_interpreter.dart';
import 'package:flutter_stockapp/features/quant/macd_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MACD为空时返回 unavailable', () {
    final result = interpretMacd(null);

    expect(result.state, MacdInsightState.unavailable);
    expect(result.title, '暂时无法解读MACD');
  });

  test('DIF与DEA非常接近时返回 neutral', () {
    final result = interpretMacd(
      const MacdResult(dif: 10, dea: 9.95, histogram: 0.1),
    );

    expect(result.state, MacdInsightState.neutral);
    expect(result.title, '短期与长期趋势动量较为接近');
  });

  test('DIF高于DEA且都在零轴上方时返回 positive', () {
    final result = interpretMacd(
      const MacdResult(dif: 2, dea: 1, histogram: 2),
    );

    expect(result.state, MacdInsightState.positive);
    expect(result.title, '趋势动量相对偏强');
  });

  test('DIF低于DEA且都在零轴下方时返回 cautious', () {
    final result = interpretMacd(
      const MacdResult(dif: -2, dea: -1, histogram: -2),
    );

    expect(result.state, MacdInsightState.cautious);
    expect(result.title, '趋势动量相对偏弱');
  });

  test('DIF高于DEA但都在零轴下方时返回动量改善', () {
    final result = interpretMacd(
      const MacdResult(dif: -1, dea: -2, histogram: 2),
    );

    expect(result.state, MacdInsightState.neutral);
    expect(result.title, '短期动量正在改善');
  });

  test('DIF低于DEA但都在零轴上方时返回动量减弱', () {
    final result = interpretMacd(
      const MacdResult(dif: 1, dea: 2, histogram: -2),
    );

    expect(result.state, MacdInsightState.neutral);
    expect(result.title, '短期动量正在减弱');
  });

  test('DIF从零轴下方超过零轴上方的DEA时返回由弱转强', () {
    final result = interpretMacd(
      const MacdResult(dif: 1, dea: -1, histogram: 4),
    );

    expect(result.state, MacdInsightState.neutral);
    expect(result.title, '趋势动量正在由弱转强');
  });

  test('DIF从零轴上方跌到零轴下方时返回由强转弱', () {
    final result = interpretMacd(
      const MacdResult(dif: -1, dea: 1, histogram: -4),
    );

    expect(result.state, MacdInsightState.neutral);
    expect(result.title, '趋势动量正在由强转弱');
  });
}
