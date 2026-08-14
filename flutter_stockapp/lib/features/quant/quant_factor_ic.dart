import 'dart:math' as math;

enum QuantFactorIcReliability { insufficient, limited, adequate }

class QuantFactorIcCrossSection {
  const QuantFactorIcCrossSection({
    required this.date,
    required this.factorValuesByStock,
    required this.forwardReturnsByStock,
  });

  final DateTime date;
  final Map<String, double> factorValuesByStock;
  final Map<String, double> forwardReturnsByStock;
}

class QuantFactorIcPeriodResult {
  const QuantFactorIcPeriodResult({
    required this.date,
    required this.sampleSize,
    required this.informationCoefficient,
    required this.rankInformationCoefficient,
  });

  final DateTime date;
  final int sampleSize;

  /// Pearson correlation between factor values and forward returns.
  final double? informationCoefficient;

  /// Spearman rank correlation between factor values and forward returns.
  final double? rankInformationCoefficient;

  bool get isAvailable =>
      informationCoefficient != null && rankInformationCoefficient != null;
}

class QuantFactorIcResult {
  const QuantFactorIcResult({required this.factorId, required this.periods});

  final String factorId;
  final List<QuantFactorIcPeriodResult> periods;

  List<QuantFactorIcPeriodResult> get availablePeriods {
    return periods
        .where((period) => period.isAvailable)
        .toList(growable: false);
  }

  int get availablePeriodCount => availablePeriods.length;

  List<double> get informationCoefficients {
    return periods
        .map((period) => period.informationCoefficient)
        .whereType<double>()
        .toList(growable: false);
  }

  List<double> get rankInformationCoefficients {
    return periods
        .map((period) => period.rankInformationCoefficient)
        .whereType<double>()
        .toList(growable: false);
  }

  double? get averageInformationCoefficient {
    return _average(informationCoefficients);
  }

  double? get averageRankInformationCoefficient {
    return _average(rankInformationCoefficients);
  }

  double? get positiveInformationCoefficientRate {
    return _positiveRate(informationCoefficients);
  }

  double? get positiveRankInformationCoefficientRate {
    return _positiveRate(rankInformationCoefficients);
  }

  /// Mean IC divided by the sample standard deviation of period IC values.
  double? get icInformationRatio {
    return _informationRatio(informationCoefficients);
  }

  /// Mean Rank IC divided by its sample standard deviation.
  double? get rankIcInformationRatio {
    return _informationRatio(rankInformationCoefficients);
  }

  double get averageSampleSize {
    final available = availablePeriods;

    if (available.isEmpty) {
      return 0;
    }

    return available.fold<double>(
          0,
          (total, period) => total + period.sampleSize,
        ) /
        available.length;
  }

  QuantFactorIcReliability get reliability {
    if (availablePeriodCount < 5 || averageSampleSize < 5) {
      return QuantFactorIcReliability.insufficient;
    }

    if (availablePeriodCount < 20 || averageSampleSize < 20) {
      return QuantFactorIcReliability.limited;
    }

    return QuantFactorIcReliability.adequate;
  }
}

double? _average(List<double> values) {
  if (values.isEmpty) {
    return null;
  }

  return values.fold<double>(0, (sum, value) => sum + value) / values.length;
}

double? _positiveRate(List<double> values) {
  if (values.isEmpty) {
    return null;
  }

  return values.where((value) => value > 0).length / values.length;
}

double? _informationRatio(List<double> values) {
  if (values.length < 2) {
    return null;
  }

  final mean = _average(values)!;
  final squaredDeviationTotal = values.fold<double>(
    0,
    (total, value) => total + math.pow(value - mean, 2).toDouble(),
  );

  final sampleVariance = squaredDeviationTotal / (values.length - 1);

  if (sampleVariance <= 1e-12) {
    return null;
  }

  return mean / math.sqrt(sampleVariance);
}
