class QuantCrossSectionalScore {
  const QuantCrossSectionalScore({
    required this.stockId,
    required this.factorPercentiles,
    required this.compositeScore,
  });

  final String stockId;

  /// Each factor's relative position in the stock pool, from 0 to 100.
  final Map<String, double> factorPercentiles;

  /// Weighted composite score calculated from factor percentiles.
  final double compositeScore;

  double? percentileFor(String factorId) {
    return factorPercentiles[factorId];
  }
}

Map<String, QuantCrossSectionalScore> calculateCrossSectionalScores({
  required Map<String, Map<String, double>> factorScoresByStock,
  required Map<String, double> factorWeights,
}) {
  if (factorScoresByStock.isEmpty) {
    return const {};
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

  for (final factorId in factorWeights.keys) {
    final availableValues = <MapEntry<String, double>>[];

    for (final stockEntry in factorScoresByStock.entries) {
      final value = stockEntry.value[factorId];

      if (value != null && value.isFinite) {
        availableValues.add(MapEntry(stockEntry.key, value));
      }
    }

    final factorPercentiles = _calculatePercentiles(availableValues);

    for (final entry in factorPercentiles.entries) {
      percentilesByStock[entry.key]![factorId] = entry.value;
    }
  }

  return Map.unmodifiable({
    for (final stockEntry in percentilesByStock.entries)
      stockEntry.key: QuantCrossSectionalScore(
        stockId: stockEntry.key,
        factorPercentiles: Map.unmodifiable(stockEntry.value),
        compositeScore: _calculateCompositeScore(
          percentiles: stockEntry.value,
          factorWeights: factorWeights,
        ),
      ),
  });
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
