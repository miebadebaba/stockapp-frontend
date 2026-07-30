import 'dart:math';

import 'macd_insight.dart';
import 'macd_result.dart';

MacdInsight interpretMacd(MacdResult? macd) {
  const riskNotice = 'MACD只描述历史价格的趋势和动量，不能预测未来走势，也不构成投资建议。';

  if (macd == null ||
      !macd.dif.isFinite ||
      !macd.dea.isFinite ||
      !macd.histogram.isFinite) {
    return const MacdInsight(
      state: MacdInsightState.unavailable,
      title: '暂时无法解读MACD',
      explanation: '当前没有足够或有效的历史数据，暂时无法判断MACD状态。',
      riskNotice: riskNotice,
    );
  }

  final referenceMagnitude = max(macd.dif.abs(), macd.dea.abs());
  final neutralThreshold = max(0.000001, referenceMagnitude * 0.01);
  final difference = macd.dif - macd.dea;

  if (difference.abs() <= neutralThreshold) {
    return const MacdInsight(
      state: MacdInsightState.neutral,
      title: '短期与长期趋势动量较为接近',
      explanation:
          'DIF与DEA之间的差距较小，说明当前短期和较长期趋势动量较为接近，'
          '暂时没有表现出明显方向。',
      riskNotice: riskNotice,
    );
  }

  if (difference > 0) {
    if (macd.dif > 0 && macd.dea > 0) {
      return const MacdInsight(
        state: MacdInsightState.positive,
        title: '趋势动量相对偏强',
        explanation:
            'DIF高于DEA，并且两者都位于零轴上方，'
            '说明短期趋势动量强于较长期趋势动量，整体价格趋势相对偏强。',
        riskNotice: riskNotice,
      );
    }

    if (macd.dif < 0 && macd.dea < 0) {
      return const MacdInsight(
        state: MacdInsightState.neutral,
        title: '短期动量正在改善',
        explanation:
            'DIF已经高于DEA，但两者仍位于零轴下方，'
            '说明短期趋势动量有所改善，但整体趋势位置仍相对偏弱。',
        riskNotice: riskNotice,
      );
    }

    return const MacdInsight(
      state: MacdInsightState.neutral,
      title: '趋势动量正在由弱转强',
      explanation:
          'DIF已经高于DEA，但两条线分布在零轴两侧，'
          '说明短期趋势动量正在改善，整体方向仍需要继续观察。',
      riskNotice: riskNotice,
    );
  }

  if (macd.dif < 0 && macd.dea < 0) {
    return const MacdInsight(
      state: MacdInsightState.cautious,
      title: '趋势动量相对偏弱',
      explanation:
          'DIF低于DEA，并且两者都位于零轴下方，'
          '说明短期趋势动量弱于较长期趋势动量，整体价格趋势相对偏弱。',
      riskNotice: riskNotice,
    );
  }

  if (macd.dif > 0 && macd.dea > 0) {
    return const MacdInsight(
      state: MacdInsightState.neutral,
      title: '短期动量正在减弱',
      explanation:
          'DIF已经低于DEA，但两者仍位于零轴上方，'
          '说明短期趋势动量有所减弱，但整体趋势位置仍相对偏强。',
      riskNotice: riskNotice,
    );
  }

  return const MacdInsight(
    state: MacdInsightState.neutral,
    title: '趋势动量正在由强转弱',
    explanation:
        'DIF已经低于DEA，但两条线分布在零轴两侧，'
        '说明短期趋势动量正在减弱，整体方向仍需要继续观察。',
    riskNotice: riskNotice,
  );
}
