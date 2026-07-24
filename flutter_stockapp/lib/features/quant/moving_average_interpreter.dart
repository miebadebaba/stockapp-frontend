import 'moving_average_insight.dart';

MovingAverageInsight interpretMovingAverages({
  required double? close,
  required double? ma5,
  required double? ma10,
  required double? ma20,
}) {
  const riskNotice = '技术指标只描述历史价格状态，不能预测未来走势，也不构成投资建议。';

  if (close == null || ma5 == null || ma10 == null || ma20 == null) {
    return const MovingAverageInsight(
      state: MovingAverageInsightState.unavailable,
      title: '历史数据不足',
      explanation: '目前没有足够的收盘价数据，暂时无法判断均线状态。',
      riskNotice: riskNotice,
    );
  }

  if (close > ma5 && ma5 > ma10 && ma10 > ma20) {
    return const MovingAverageInsight(
      state: MovingAverageInsightState.positive,
      title: '短中期价格状态相对偏强',
      explanation:
          '当前收盘价位于5日均线上方，并且MA5高于MA10、MA10高于MA20。'
          '这表示近期平均价格高于较长期平均价格。',
      riskNotice: riskNotice,
    );
  }

  if (close < ma5 && ma5 < ma10 && ma10 < ma20) {
    return const MovingAverageInsight(
      state: MovingAverageInsightState.cautious,
      title: '短中期价格状态相对偏弱',
      explanation:
          '当前收盘价位于5日均线下方，并且MA5低于MA10、MA10低于MA20。'
          '这表示近期平均价格低于较长期平均价格。',
      riskNotice: riskNotice,
    );
  }

  if (ma5 > ma10 && ma10 > ma20) {
    return const MovingAverageInsight(
      state: MovingAverageInsightState.neutral,
      title: '均线排列偏强，但短期价格有所回落',
      explanation:
          'MA5高于MA10、MA10高于MA20，说明近期平均价格仍高于较长期平均价格。'
          '但当前收盘价低于MA5，表示最新价格已经回落到5日平均价格下方，需要继续观察。',
      riskNotice: riskNotice,
    );
  }

  if (ma5 < ma10 && ma10 < ma20) {
    return const MovingAverageInsight(
      state: MovingAverageInsightState.neutral,
      title: '均线排列偏弱，但短期价格有所反弹',
      explanation:
          'MA5低于MA10、MA10低于MA20，说明近期平均价格仍低于较长期平均价格。'
          '但当前收盘价已经回到MA5上方，表示短期价格出现反弹，需要继续观察。',
      riskNotice: riskNotice,
    );
  }

  return MovingAverageInsight(
    state: MovingAverageInsightState.neutral,
    title: '均线方向暂不一致',
    explanation: close >= ma5
        ? '当前收盘价位于5日均线上方，但MA5、MA10和MA20没有形成一致排列，暂时不能仅凭均线判断明确方向。'
        : '当前收盘价位于5日均线下方，但MA5、MA10和MA20没有形成一致排列，暂时不能仅凭均线判断明确方向。',
    riskNotice: riskNotice,
  );
}
