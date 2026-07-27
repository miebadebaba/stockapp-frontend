import 'technical_summary_insight.dart';
import 'technical_summary_result.dart';

TechnicalSummaryInsight interpretTechnicalSummary(
  TechnicalSummaryResult result,
) {
  const riskNotice =
      '综合分析仅描述历史价格和成交量呈现的技术状态，'
      '不能预测未来走势，也不构成投资建议。';

  final state = _classifyInsightState(result);
  final title = _buildTitle(state, result.consistency);
  final overview = _buildOverview(state, result.consistency);

  return TechnicalSummaryInsight(
    state: state,
    title: title,
    overview: overview,
    trendText: _describeTrend(result.trend),
    momentumText: _describeMomentum(result.momentum),
    strengthText: _describeStrength(result.strength),
    participationText: _describeParticipation(result.participation),
    consistencyText: _describeConsistency(result.consistency),
    riskMessages: List.unmodifiable(result.riskFlags.map(_describeRiskFlag)),
    riskNotice: riskNotice,
  );
}

TechnicalSummaryInsightState _classifyInsightState(
  TechnicalSummaryResult result,
) {
  if (result.consistency == EvidenceConsistency.unavailable) {
    return TechnicalSummaryInsightState.unavailable;
  }

  final upwardAligned =
      result.trend == TrendState.upward &&
      result.momentum == MomentumState.positive &&
      result.consistency != EvidenceConsistency.divergent;

  if (upwardAligned) {
    return TechnicalSummaryInsightState.upwardAligned;
  }

  final downwardAligned =
      result.trend == TrendState.downward &&
      result.momentum == MomentumState.negative &&
      result.consistency != EvidenceConsistency.divergent;

  if (downwardAligned) {
    return TechnicalSummaryInsightState.downwardAligned;
  }

  return TechnicalSummaryInsightState.divergent;
}

String _buildTitle(
  TechnicalSummaryInsightState state,
  EvidenceConsistency consistency,
) {
  return switch (state) {
    TechnicalSummaryInsightState.upwardAligned =>
      consistency == EvidenceConsistency.high ? '趋势、动能与量价方向相互印证' : '趋势与动能共同偏强',
    TechnicalSummaryInsightState.downwardAligned =>
      consistency == EvidenceConsistency.high ? '偏弱趋势得到多项证据确认' : '趋势与动能共同偏弱',
    TechnicalSummaryInsightState.divergent => '多项技术证据存在分化',
    TechnicalSummaryInsightState.unavailable => '综合分析数据暂时不足',
  };
}

String _buildOverview(
  TechnicalSummaryInsightState state,
  EvidenceConsistency consistency,
) {
  return switch (state) {
    TechnicalSummaryInsightState.upwardAligned =>
      consistency == EvidenceConsistency.high
          ? '均线趋势和MACD动能方向一致，成交量也提供了一定确认，'
                '说明当前历史数据中的偏强特征较为一致。'
          : '均线趋势和MACD动能方向一致，但成交量暂未提供充分确认，'
                '需要继续观察量价关系。',
    TechnicalSummaryInsightState.downwardAligned =>
      consistency == EvidenceConsistency.high
          ? '均线趋势和MACD动能共同偏弱，成交量也提供了一定确认，'
                '说明当前历史数据中的偏弱特征较为一致。'
          : '均线趋势和MACD动能共同偏弱，但成交量确认程度有限，'
                '需要结合后续价格和成交量变化继续观察。',
    TechnicalSummaryInsightState.divergent =>
      '均线、MACD或成交量之间没有形成一致方向，'
          '当前技术状态存在分化，不适合用单一指标作出结论。',
    TechnicalSummaryInsightState.unavailable => '当前历史数据不足以完成综合判断，请等待更多有效日线数据。',
  };
}

String _describeTrend(TrendState trend) {
  return switch (trend) {
    TrendState.upward => '价格位于MA20上方，短期均线排列和MA20斜率显示趋势相对向上。',
    TrendState.downward => '价格位于MA20下方，短期均线排列和MA20斜率显示趋势相对向下。',
    TrendState.mixed => '价格、短期均线和MA20斜率没有形成明确一致的趋势。',
    TrendState.unavailable => '历史日线数量不足，暂时无法判断均线趋势。',
  };
}

String _describeMomentum(MomentumState momentum) {
  return switch (momentum) {
    MomentumState.positive => 'DIF高于DEA且MACD柱为正，当前上涨动能相对占优。',
    MomentumState.negative => 'DIF低于DEA且MACD柱为负，当前下跌动能相对占优。',
    MomentumState.mixed => 'DIF、DEA与MACD柱没有形成一致方向，动能信号存在分化。',
    MomentumState.unavailable => 'MACD数据不足或无效，暂时无法判断动能。',
  };
}

String _describeStrength(StrengthState strength) {
  return switch (strength) {
    StrengthState.overextendedHigh => 'RSI处于70以上高位区间，近期上涨力量较强，同时需要注意过热风险。',
    StrengthState.relativelyStrong => 'RSI位于55到70之间，近期上涨力量相对较强。',
    StrengthState.balanced => 'RSI位于45到55之间，近期上涨和下跌力量相对均衡。',
    StrengthState.relativelyWeak => 'RSI位于30到45之间，近期下跌力量相对较强。',
    StrengthState.overextendedLow => 'RSI处于30以下低位区间，近期下跌力量较强，同时可能处于超卖状态。',
    StrengthState.unavailable => 'RSI数据不足或无效，暂时无法判断相对强弱。',
  };
}

String _describeParticipation(ParticipationState participation) {
  return switch (participation) {
    ParticipationState.confirming => '成交量高于近期平均水平，且最新价格方向与主要趋势一致。',
    ParticipationState.contradicting => '成交量高于近期平均水平，但最新价格方向与主要趋势相反。',
    ParticipationState.inconclusive => '成交量接近近期平均水平，或当前趋势方向不明确，确认作用有限。',
    ParticipationState.low => '成交量低于近期平均水平，市场参与度相对有限。',
    ParticipationState.unavailable => '成交量或趋势数据不足，暂时无法判断市场参与度。',
  };
}

String _describeConsistency(EvidenceConsistency consistency) {
  return switch (consistency) {
    EvidenceConsistency.high => '证据一致性较高：趋势、动能和成交量方向相互印证。',
    EvidenceConsistency.moderate => '证据一致性一般：趋势和动能方向一致，但成交量确认有限。',
    EvidenceConsistency.divergent => '信号分化：趋势、动能或量价关系之间存在差异。',
    EvidenceConsistency.unavailable => '关键数据不足，暂时无法评估各项证据的一致程度。',
  };
}

String _describeRiskFlag(TechnicalRiskFlag flag) {
  return switch (flag) {
    TechnicalRiskFlag.rsiHigh => 'RSI处于高位并不代表价格一定下跌，强势行情中高位状态可能持续。',
    TechnicalRiskFlag.rsiLow => 'RSI处于低位并不代表价格一定反弹，弱势行情中低位状态可能持续。',
    TechnicalRiskFlag.priceExtended => '最新价格与MA20偏离较大，短期波动和回撤风险可能有所提高。',
    TechnicalRiskFlag.dataInsufficient => '部分指标缺少足够历史数据，当前综合结果的完整性有限。',
  };
}
