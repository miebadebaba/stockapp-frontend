import 'package:flutter_stockapp/features/quant/rsi_insight.dart';
import 'package:flutter_stockapp/features/quant/rsi_interpreter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RSI为空时返回 unavailable', () {
    final result = interpretRsi(null);

    expect(result.state, RsiInsightState.unavailable);
    expect(result.title, '暂时无法解读RSI');
  });

  test('RSI超出有效范围时返回 unavailable', () {
    final result = interpretRsi(101);

    expect(result.state, RsiInsightState.unavailable);
  });

  test('RSI等于70时返回 high', () {
    final result = interpretRsi(70);

    expect(result.state, RsiInsightState.high);
    expect(result.title, '近期上涨动量处于较高水平');
  });

  test('RSI等于30时返回 low', () {
    final result = interpretRsi(30);

    expect(result.state, RsiInsightState.low);
    expect(result.title, '近期下跌动量处于较高水平');
  });

  test('RSI位于50到70之间时返回上涨动量占优', () {
    final result = interpretRsi(62.07);

    expect(result.state, RsiInsightState.neutral);
    expect(result.title, '近期上涨动量相对占优');
  });

  test('RSI位于30到50之间时返回下跌动量占优', () {
    final result = interpretRsi(42);

    expect(result.state, RsiInsightState.neutral);
    expect(result.title, '近期下跌动量相对占优');
  });

  test('RSI等于50时返回涨跌动量均衡', () {
    final result = interpretRsi(50);

    expect(result.state, RsiInsightState.neutral);
    expect(result.title, '近期涨跌动量相对均衡');
  });
}
