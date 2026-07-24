import 'rsi_insight.dart';

RsiInsight interpretRsi(double? rsi) {
  const riskNotice = 'RSI只描述近期历史价格的相对动量，不能预测未来走势，也不构成投资建议。';

  if (rsi == null || !rsi.isFinite || rsi < 0 || rsi > 100) {
    return const RsiInsight(
      state: RsiInsightState.unavailable,
      title: '暂时无法解读RSI',
      explanation: '当前没有有效的RSI数据，请等待更多历史行情数据。',
      riskNotice: riskNotice,
    );
  }

  if (rsi >= 70) {
    return const RsiInsight(
      state: RsiInsightState.high,
      title: '近期上涨动量处于较高水平',
      explanation:
          'RSI已进入常用的70以上高位参考区，说明最近一段时间上涨幅度相对更强。'
          '高位不代表价格一定会立即下跌，强势行情中RSI可能持续处于较高水平。',
      riskNotice: riskNotice,
    );
  }

  if (rsi <= 30) {
    return const RsiInsight(
      state: RsiInsightState.low,
      title: '近期下跌动量处于较高水平',
      explanation:
          'RSI已进入常用的30以下低位参考区，说明最近一段时间下跌幅度相对更强。'
          '低位不代表价格一定会立即反弹，弱势行情中RSI可能持续处于较低水平。',
      riskNotice: riskNotice,
    );
  }

  if (rsi > 50) {
    return const RsiInsight(
      state: RsiInsightState.neutral,
      title: '近期上涨动量相对占优',
      explanation:
          'RSI位于50到70之间，说明近期上涨力量相对更强，'
          '但尚未进入常用的70以上高位参考区。',
      riskNotice: riskNotice,
    );
  }

  if (rsi < 50) {
    return const RsiInsight(
      state: RsiInsightState.neutral,
      title: '近期下跌动量相对占优',
      explanation:
          'RSI位于30到50之间，说明近期下跌力量相对更强，'
          '但尚未进入常用的30以下低位参考区。',
      riskNotice: riskNotice,
    );
  }

  return const RsiInsight(
    state: RsiInsightState.neutral,
    title: '近期涨跌动量相对均衡',
    explanation: 'RSI接近50，表示最近一段时间的上涨和下跌力量大致相当。',
    riskNotice: riskNotice,
  );
}
