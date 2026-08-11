import 'dart:math' as math;

import 'quant_factor_definition.dart';

export 'quant_factor_definition.dart' show QuantFactorDirection;

enum QuantFactorSampleReliability { insufficient, limited, adequate }

class QuantCrossSectionalScore {
  const QuantCrossSectionalScore({
    required this.stockId,
    required this.factorPercentiles,
    required this.compositeScore,
    this.factorZScores = const {},
    this.factorSampleSizes = const {},
    this.totalFactorCount,
  });

  final String stockId;

  /// Each factor's relative position in the stock pool, from 0 to 100.
  final Map<String, double> factorPercentiles;

  final Map<String, double> factorZScores;

  /// Number of valid stocks used to normalize each factor.
  final Map<String, int> factorSampleSizes;

  int? sampleSizeFor(String factorId) {
    return factorSampleSizes[factorId];
  }

  QuantFactorSampleReliability reliabilityFor(String factorId) {
    final sampleSize = factorSampleSizes[factorId] ?? 0;

    if (sampleSize < 5) {
      return QuantFactorSampleReliability.insufficient;
    }

    if (sampleSize < 20) {
      return QuantFactorSampleReliability.limited;
    }

    return QuantFactorSampleReliability.adequate;
  }

  double? zScoreFor(String factorId) {
    return factorZScores[factorId];
  }

  /// Weighted composite score calculated from factor percentiles.
  final double compositeScore;

  /// Number of factors included in the current cross-sectional calculation.
  final int? totalFactorCount;

  int get availableFactorCount => factorPercentiles.length;

  double? get coverageRatio {
    final total = totalFactorCount;
    if (total == null || total <= 0) {
      return null;
    }

    return (availableFactorCount / total).clamp(0, 1).toDouble();
  }

  double? percentileFor(String factorId) {
    return factorPercentiles[factorId];
  }
}

Map<String, QuantCrossSectionalScore> calculateCrossSectionalScores({
  required Map<String, Map<String, double>> factorScoresByStock,
  required Map<String, double> factorWeights,
  Map<String, QuantFactorDirection> factorDirections = const {},
  double? winsorizationQuantile,
}) {
  if (factorScoresByStock.isEmpty) {
    return const {};
  }

  if (winsorizationQuantile != null &&
      (winsorizationQuantile <= 0 || winsorizationQuantile >= 0.5)) {
    throw ArgumentError.value(
      winsorizationQuantile,
      'winsorizationQuantile',
      'Winsorization quantile must be greater than 0 and less than 0.5.',
    );
  }

  if (factorWeights.values.any((weight) => weight < 0)) {
    throw ArgumentError.value(
      factorWeights,
      'factorWeights',
      'Factor weights cannot be negative.',
    );
  }

  final percentilesByStock = <String, Map<String, double>>{
    for (final stockId in factorScoresByStock.keys) stockId: <String, double>{},
  };

  final zScoresByStock = <String, Map<String, double>>{
    for (final stockId in factorScoresByStock.keys) stockId: <String, double>{},
  };

  final factorSampleSizes = <String, int>{};

  for (final factorId in factorWeights.keys) {
    final availableValues = <MapEntry<String, double>>[];

    for (final stockEntry in factorScoresByStock.entries) {
      final value = stockEntry.value[factorId];

      if (value != null && value.isFinite) {
        final direction =
            factorDirections[factorId] ?? QuantFactorDirection.higherIsBetter;

        final comparableValue = direction == QuantFactorDirection.lowerIsBetter
            ? -value
            : value;

        availableValues.add(MapEntry(stockEntry.key, comparableValue));
      }
    }

    final preparedValues = winsorizationQuantile == null
        ? availableValues
        : _winsorizeValues(availableValues, quantile: winsorizationQuantile);
    factorSampleSizes[factorId] = preparedValues.length;

    final factorZScores = _calculateZScores(preparedValues);
    final factorPercentiles = _calculatePercentiles(preparedValues);

    for (final entry in factorPercentiles.entries) {
      percentilesByStock[entry.key]![factorId] = entry.value;
    }

    for (final entry in factorZScores.entries) {
      zScoresByStock[entry.key]![factorId] = entry.value;
    }
  }

  return Map.unmodifiable({
    for (final stockEntry in percentilesByStock.entries)
      stockEntry.key: QuantCrossSectionalScore(
        stockId: stockEntry.key,
        factorPercentiles: Map.unmodifiable(stockEntry.value),
        factorZScores: Map.unmodifiable(zScoresByStock[stockEntry.key]!),
        factorSampleSizes: Map.unmodifiable(factorSampleSizes),
        compositeScore: _calculateCompositeScore(
          percentiles: stockEntry.value,
          factorWeights: factorWeights,
        ),
        totalFactorCount: factorWeights.length,
      ),
  });
}

List<MapEntry<String, double>> _winsorizeValues(
  List<MapEntry<String, double>> values, {
  required double quantile,
}) {
  if (values.length < 5) {
    return values;
  }

  final sortedValues = [...values]
    ..sort((left, right) => left.value.compareTo(right.value));

  final numericValues = [for (final entry in sortedValues) entry.value];

  final lowerBound = _interpolatedValue(
    numericValues,
    (numericValues.length - 1) * quantile,
  );

  final upperBound = _interpolatedValue(
    numericValues,
    (numericValues.length - 1) * (1 - quantile),
  );

  return [
    for (final entry in values)
      MapEntry(entry.key, entry.value.clamp(lowerBound, upperBound).toDouble()),
  ];
}

double _interpolatedValue(List<double> sortedValues, double index) {
  final lowerIndex = index.floor();
  final upperIndex = index.ceil();

  if (lowerIndex == upperIndex) {
    return sortedValues[lowerIndex];
  }

  final fraction = index - lowerIndex;

  return sortedValues[lowerIndex] +
      (sortedValues[upperIndex] - sortedValues[lowerIndex]) * fraction;
}

Map<String, double> _calculateZScores(List<MapEntry<String, double>> values) {
  if (values.isEmpty) {
    return const {};
  }

  if (values.length == 1) {
    return {values.single.key: 0};
  }

  final mean =
      values.fold<double>(0, (sum, entry) => sum + entry.value) / values.length;

  final variance =
      values.fold<double>(
        0,
        (sum, entry) => sum + math.pow(entry.value - mean, 2),
      ) /
      values.length;

  if (variance <= 1e-12) {
    return {for (final entry in values) entry.key: 0};
  }

  final standardDeviation = math.sqrt(variance);

  return {
    for (final entry in values)
      entry.key: (entry.value - mean) / standardDeviation,
  };
}

Map<String, double> _calculatePercentiles(
  List<MapEntry<String, double>> values,
) {
  if (values.isEmpty) {
    return const {};
  }

  if (values.length == 1) {
    return {values.single.key: 50};
  }

  final sortedValues = [...values]
    ..sort((left, right) => left.value.compareTo(right.value));

  final result = <String, double>{};
  var start = 0;

  while (start < sortedValues.length) {
    var end = start;

    while (end + 1 < sortedValues.length &&
        sortedValues[end + 1].value == sortedValues[start].value) {
      end++;
    }

    final averageRank = (start + end) / 2;
    final percentile = averageRank / (sortedValues.length - 1) * 100;

    for (var index = start; index <= end; index++) {
      result[sortedValues[index].key] = percentile;
    }

    start = end + 1;
  }

  return result;
}

double _calculateCompositeScore({
  required Map<String, double> percentiles,
  required Map<String, double> factorWeights,
}) {
  var weightedTotal = 0.0;
  var availableWeight = 0.0;

  for (final entry in percentiles.entries) {
    final weight = factorWeights[entry.key] ?? 0;

    if (weight <= 0) {
      continue;
    }

    weightedTotal += entry.value * weight;
    availableWeight += weight;
  }

  if (availableWeight == 0) {
    return 0;
  }

  return (weightedTotal / availableWeight).clamp(0, 100).toDouble();
}
