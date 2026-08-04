enum QuantFactorSignal { strong, positive, neutral, negative, unavailable }

enum QuantTechnicalRating {
  strong,
  positive,
  neutral,
  negative,
  weak,
  unavailable,
}

enum QuantRiskLevel { low, medium, high, unavailable }

class QuantFactorItem {
  const QuantFactorItem({
    required this.id,
    required this.label,
    required this.score,
    required this.weight,
    required this.signal,
    required this.summary,
    required this.evidence,
  });

  final String id;
  final String label;

  /// 单项因子标准分，范围为 0～100。
  final double score;

  /// 因子权重，范围为 0～1。
  final double weight;

  final QuantFactorSignal signal;
  final String summary;
  final List<String> evidence;

  double get weightedScore => score * weight;
}

class QuantRiskAssessment {
  const QuantRiskAssessment({
    required this.level,
    required this.summary,
    this.annualizedVolatility,
    this.maximumDrawdown,
  });

  final QuantRiskLevel level;
  final double? annualizedVolatility;
  final double? maximumDrawdown;
  final String summary;
}

class QuantFactorScore {
  const QuantFactorScore({
    required this.technicalScore,
    required this.rating,
    required this.factors,
    required this.risk,
    required this.summary,
    required this.hasSufficientData,
  });

  /// 技术状态综合分，范围为 0～100。
  final double technicalScore;

  final QuantTechnicalRating rating;
  final List<QuantFactorItem> factors;

  /// 风险独立展示，不直接作为上涨信号加入技术得分。
  final QuantRiskAssessment risk;

  final String summary;
  final bool hasSufficientData;
}
