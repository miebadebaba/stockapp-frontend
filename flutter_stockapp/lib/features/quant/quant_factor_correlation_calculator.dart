import 'dart:math' as math;

enum QuantFactorCorrelationStrength { unavailable, weak, moderate, strong }

enum QuantFactorCorrelationReliability { insufficient, limited, adequate }

class QuantFactorCorrelation {
  const QuantFactorCorrelation({
    required this.leftFactorId,
    required this.rightFactorId,
    required this.sampleSize,
    required this.coefficient,
  });

  final String leftFactorId;
  final String rightFactorId;

  /// Number of stocks with valid values for both factors.
  final int sampleSize;

  /// Pearson correlation coefficient, ranging from -1 to 1.
  ///
  /// Null means the coefficient cannot be calculated because the sample
  /// is too small or one of the factors has no variation.
  final double? coefficient;

  bool get isAvailable => coefficient != null;

  double? get absoluteCoefficient => coefficient?.abs();

  QuantFactorCorrelationStrength get strength {
    final value = absoluteCoefficient;

    if (value == null) {
      return QuantFactorCorrelationStrength.unavailable;
    }

    if (value < 0.30) {
      return QuantFactorCorrelationStrength.weak;
    }

    if (value < 0.70) {
      return QuantFactorCorrelationStrength.moderate;
    }

    return QuantFactorCorrelationStrength.strong;
  }

  QuantFactorCorrelationReliability get reliability {
    if (sampleSize < 5) {
      return QuantFactorCorrelationReliability.insufficient;
    }

    if (sampleSize < 20) {
      return QuantFactorCorrelationReliability.limited;
    }

    return QuantFactorCorrelationReliability.adequate;
  }

  /// Whether the two factors may contain substantially duplicated information.
  ///
  /// A warning is only produced when the sample is adequate and the absolute
  /// correlation reaches 0.80.
  bool get isPotentiallyRedundant {
    final value = absoluteCoefficient;

    return reliability == QuantFactorCorrelationReliability.adequate &&
        value != null &&
        value >= 0.80;
  }
}

List<QuantFactorCorrelation> calculateFactorCorrelations({
  required Map<String, Map<String, double>> factorValuesByStock,
  required Iterable<String> factorIds,
}) {
  final uniqueFactorIds = <String>[];

  for (final factorId in factorIds) {
    if (!uniqueFactorIds.contains(factorId)) {
      uniqueFactorIds.add(factorId);
    }
  }

  final results = <QuantFactorCorrelation>[];

  for (var leftIndex = 0; leftIndex < uniqueFactorIds.length; leftIndex++) {
    for (
      var rightIndex = leftIndex + 1;
      rightIndex < uniqueFactorIds.length;
      rightIndex++
    ) {
      final leftFactorId = uniqueFactorIds[leftIndex];
      final rightFactorId = uniqueFactorIds[rightIndex];
      final leftValues = <double>[];
      final rightValues = <double>[];

      for (final stockValues in factorValuesByStock.values) {
        final leftValue = stockValues[leftFactorId];
        final rightValue = stockValues[rightFactorId];

        if (leftValue != null &&
            rightValue != null &&
            leftValue.isFinite &&
            rightValue.isFinite) {
          leftValues.add(leftValue);
          rightValues.add(rightValue);
        }
      }

      results.add(
        QuantFactorCorrelation(
          leftFactorId: leftFactorId,
          rightFactorId: rightFactorId,
          sampleSize: leftValues.length,
          coefficient: _calculatePearsonCorrelation(leftValues, rightValues),
        ),
      );
    }
  }

  return List.unmodifiable(results);
}

double? _calculatePearsonCorrelation(
  List<double> leftValues,
  List<double> rightValues,
) {
  if (leftValues.length != rightValues.length || leftValues.length < 2) {
    return null;
  }

  final sampleSize = leftValues.length;

  final leftMean =
      leftValues.fold<double>(0, (sum, value) => sum + value) / sampleSize;

  final rightMean =
      rightValues.fold<double>(0, (sum, value) => sum + value) / sampleSize;

  var covarianceTotal = 0.0;
  var leftSquaredDeviationTotal = 0.0;
  var rightSquaredDeviationTotal = 0.0;

  for (var index = 0; index < sampleSize; index++) {
    final leftDeviation = leftValues[index] - leftMean;
    final rightDeviation = rightValues[index] - rightMean;

    covarianceTotal += leftDeviation * rightDeviation;
    leftSquaredDeviationTotal += leftDeviation * leftDeviation;
    rightSquaredDeviationTotal += rightDeviation * rightDeviation;
  }

  if (leftSquaredDeviationTotal <= 1e-12 ||
      rightSquaredDeviationTotal <= 1e-12) {
    return null;
  }

  final denominator = math.sqrt(
    leftSquaredDeviationTotal * rightSquaredDeviationTotal,
  );

  return (covarianceTotal / denominator).clamp(-1.0, 1.0).toDouble();
}
