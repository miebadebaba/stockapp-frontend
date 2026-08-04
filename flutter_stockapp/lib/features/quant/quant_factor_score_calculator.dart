import 'quant_factor_score.dart';
import 'quant_stock_analysis.dart';
import 'risk_metrics_calculator.dart';
import 'volume_analysis_result.dart';

QuantFactorScore calculateQuantFactorScore({
  required QuantStockAnalysis analysis,
}) {
  final trend = _calculateTrendFactor(analysis);
  final momentum = _calculateMomentumFactor(analysis);
  final volume = _calculateVolumeFactor(analysis);
  final factors = [trend, momentum, volume];

  final hasSufficientData = factors.every(
    (factor) => factor.signal != QuantFactorSignal.unavailable,
  );

  final technicalScore = hasSufficientData
      ? factors
            .fold<double>(0, (total, factor) => total + factor.weightedScore)
            .clamp(0, 100)
            .toDouble()
      : 0.0;

  final rating = hasSufficientData
      ? _classifyTechnicalRating(technicalScore)
      : QuantTechnicalRating.unavailable;

  final riskMetrics = calculateRiskMetrics(bars: analysis.bars);
  final risk = _assessRisk(riskMetrics);

  return QuantFactorScore(
    technicalScore: technicalScore,
    rating: rating,
    factors: List.unmodifiable(factors),
    risk: risk,
    summary: _buildTechnicalSummary(
      rating: rating,
      trend: trend,
      momentum: momentum,
      volume: volume,
    ),
    hasSufficientData: hasSufficientData,
  );
}

QuantFactorItem _calculateTrendFactor(QuantStockAnalysis analysis) {
  final close = analysis.latestBar.close;
  final ma5 = analysis.ma5;
  final ma10 = analysis.ma10;
  final ma20 = analysis.ma20;

  if (!_isValidPositive(close) ||
      !_isValidPositive(ma5) ||
      !_isValidPositive(ma10) ||
      !_isValidPositive(ma20)) {
    return _unavailableFactor(
      id: 'trend',
      label: '趋势',
      weight: 0.40,
      summary: '均线数据不足，暂时无法评价趋势。',
    );
  }

  final validMa5 = ma5!;
  final validMa10 = ma10!;
  final validMa20 = ma20!;

  var score = 50.0;
  final evidence = <String>[];

  score += close > validMa5 ? 8 : -8;
  score += close > validMa10 ? 8 : -8;
  score += close > validMa20 ? 10 : -10;
  score += validMa5 > validMa10 ? 7 : -7;
  score += validMa10 > validMa20 ? 7 : -7;

  if (validMa5 > validMa10 && validMa10 > validMa20) {
    score += 10;
    evidence.add('MA5、MA10、MA20呈多头排列');
  } else if (validMa5 < validMa10 && validMa10 < validMa20) {
    score -= 10;
    evidence.add('MA5、MA10、MA20呈空头排列');
  } else {
    evidence.add('均线排列暂未形成一致方向');
  }

  if (close > validMa20) {
    evidence.add('当前价格位于MA20上方');
  } else {
    evidence.add('当前价格位于MA20下方');
  }

  score = score.clamp(0, 100).toDouble();

  return QuantFactorItem(
    id: 'trend',
    label: '趋势',
    score: score,
    weight: 0.40,
    signal: _classifyFactorSignal(score),
    summary: score >= 65
        ? '短中期趋势偏强。'
        : score < 45
        ? '短中期趋势偏弱。'
        : '短中期趋势暂不明确。',
    evidence: List.unmodifiable(evidence),
  );
}

QuantFactorItem _calculateMomentumFactor(QuantStockAnalysis analysis) {
  final rsi = analysis.rsi14;
  final macd = analysis.macd;

  if (rsi == null ||
      !rsi.isFinite ||
      rsi < 0 ||
      rsi > 100 ||
      macd == null ||
      !macd.dif.isFinite ||
      !macd.dea.isFinite ||
      !macd.histogram.isFinite) {
    return _unavailableFactor(
      id: 'momentum',
      label: '动量',
      weight: 0.35,
      summary: 'RSI或MACD数据不足，暂时无法评价动量。',
    );
  }

  final double rsiScore;
  final String rsiEvidence;

  if (rsi >= 70) {
    rsiScore = 65;
    rsiEvidence = 'RSI为${rsi.toStringAsFixed(1)}，动量较强但存在过热迹象';
  } else if (rsi > 55) {
    rsiScore = 85;
    rsiEvidence = 'RSI为${rsi.toStringAsFixed(1)}，处于相对强势区间';
  } else if (rsi >= 45) {
    rsiScore = 55;
    rsiEvidence = 'RSI为${rsi.toStringAsFixed(1)}，处于相对均衡区间';
  } else if (rsi > 30) {
    rsiScore = 35;
    rsiEvidence = 'RSI为${rsi.toStringAsFixed(1)}，动量相对偏弱';
  } else {
    rsiScore = 25;
    rsiEvidence = 'RSI为${rsi.toStringAsFixed(1)}，处于超卖区间';
  }

  final double macdScore;
  final String macdEvidence;

  if (macd.dif > macd.dea && macd.histogram > 0) {
    macdScore = 85;
    macdEvidence = 'MACD位于正向状态，上涨动量占优';
  } else if (macd.dif < macd.dea && macd.histogram < 0) {
    macdScore = 15;
    macdEvidence = 'MACD位于负向状态，下跌动量占优';
  } else {
    macdScore = 50;
    macdEvidence = 'MACD方向尚不明确';
  }

  final score = (rsiScore * 0.45 + macdScore * 0.55).clamp(0, 100).toDouble();

  return QuantFactorItem(
    id: 'momentum',
    label: '动量',
    score: score,
    weight: 0.35,
    signal: _classifyFactorSignal(score),
    summary: score >= 65
        ? '当前上涨动量相对较强。'
        : score < 45
        ? '当前上涨动量相对不足。'
        : '当前动量表现相对中性。',
    evidence: [rsiEvidence, macdEvidence],
  );
}

QuantFactorItem _calculateVolumeFactor(QuantStockAnalysis analysis) {
  final volume = analysis.volume;

  if (volume == null ||
      !volume.volumeRatio.isFinite ||
      volume.volumeRatio < 0) {
    return _unavailableFactor(
      id: 'volume',
      label: '量价',
      weight: 0.25,
      summary: '成交量数据不足，暂时无法评价量价关系。',
    );
  }

  final ratio = volume.volumeRatio;
  final double score;
  final String directionText;

  switch (volume.priceDirection) {
    case PriceDirection.up:
      directionText = '价格上涨';
      if (ratio >= 1.2) {
        score = 90;
      } else if (ratio >= 1.0) {
        score = 75;
      } else {
        score = 60;
      }

    case PriceDirection.flat:
      directionText = '价格基本持平';
      score = ratio >= 1.2 ? 50 : 45;

    case PriceDirection.down:
      directionText = '价格下跌';
      if (ratio >= 1.2) {
        score = 15;
      } else if (ratio >= 1.0) {
        score = 30;
      } else {
        score = 40;
      }
  }

  final ratioText = ratio >= 1.2
      ? '成交量明显放大'
      : ratio >= 1.0
      ? '成交量略有放大'
      : '成交量相对缩小';

  return QuantFactorItem(
    id: 'volume',
    label: '量价',
    score: score,
    weight: 0.25,
    signal: _classifyFactorSignal(score),
    summary: score >= 65
        ? '量价关系对当前走势形成一定支持。'
        : score < 45
        ? '量价关系对当前走势支持不足。'
        : '量价关系暂时没有明显方向。',
    evidence: [
      '$directionText，$ratioText',
      '当前成交量约为近期平均水平的${ratio.toStringAsFixed(2)}倍',
    ],
  );
}

QuantRiskAssessment _assessRisk(RiskMetrics? metrics) {
  if (metrics == null ||
      !metrics.annualizedVolatility.isFinite ||
      !metrics.maximumDrawdown.isFinite) {
    return const QuantRiskAssessment(
      level: QuantRiskLevel.unavailable,
      summary: '历史数据不足，暂时无法评价风险。',
    );
  }

  final volatility = metrics.annualizedVolatility;
  final drawdown = metrics.maximumDrawdown;

  final QuantRiskLevel level;
  final String summary;

  if (volatility >= 0.40 || drawdown >= 0.25) {
    level = QuantRiskLevel.high;
    summary = '近期价格波动或阶段性回撤较大，风险水平较高。';
  } else if (volatility < 0.20 && drawdown < 0.10) {
    level = QuantRiskLevel.low;
    summary = '近期价格波动和阶段性回撤相对较小。';
  } else {
    level = QuantRiskLevel.medium;
    summary = '近期价格波动和阶段性回撤处于中等水平。';
  }

  return QuantRiskAssessment(
    level: level,
    annualizedVolatility: volatility,
    maximumDrawdown: drawdown,
    summary: summary,
  );
}

QuantFactorItem _unavailableFactor({
  required String id,
  required String label,
  required double weight,
  required String summary,
}) {
  return QuantFactorItem(
    id: id,
    label: label,
    score: 0,
    weight: weight,
    signal: QuantFactorSignal.unavailable,
    summary: summary,
    evidence: const ['有效数据不足'],
  );
}

QuantFactorSignal _classifyFactorSignal(double score) {
  if (score >= 80) {
    return QuantFactorSignal.strong;
  }

  if (score >= 65) {
    return QuantFactorSignal.positive;
  }

  if (score >= 45) {
    return QuantFactorSignal.neutral;
  }

  return QuantFactorSignal.negative;
}

QuantTechnicalRating _classifyTechnicalRating(double score) {
  if (score >= 85) {
    return QuantTechnicalRating.strong;
  }

  if (score >= 70) {
    return QuantTechnicalRating.positive;
  }

  if (score >= 55) {
    return QuantTechnicalRating.neutral;
  }

  if (score >= 40) {
    return QuantTechnicalRating.negative;
  }

  return QuantTechnicalRating.weak;
}

String _buildTechnicalSummary({
  required QuantTechnicalRating rating,
  required QuantFactorItem trend,
  required QuantFactorItem momentum,
  required QuantFactorItem volume,
}) {
  if (rating == QuantTechnicalRating.unavailable) {
    return '部分技术指标数据不足，暂时无法生成完整评分。';
  }

  final strongest = [trend, momentum, volume]
    ..sort((left, right) => right.score.compareTo(left.score));

  final weakest = strongest.last;

  final ratingText = switch (rating) {
    QuantTechnicalRating.strong => '技术状态强势',
    QuantTechnicalRating.positive => '技术状态偏强',
    QuantTechnicalRating.neutral => '技术状态中性',
    QuantTechnicalRating.negative => '技术状态偏弱',
    QuantTechnicalRating.weak => '技术状态弱势',
    QuantTechnicalRating.unavailable => '技术状态暂不可用',
  };

  return '$ratingText，${strongest.first.label}表现相对较好，'
      '${weakest.label}仍需关注。';
}

bool _isValidPositive(double? value) {
  return value != null && value.isFinite && value > 0;
}
