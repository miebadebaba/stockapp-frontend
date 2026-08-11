enum QuantFactorDirection { higherIsBetter, lowerIsBetter }

enum QuantFactorCategory { technical, fundamental, risk }

class QuantFactorDefinition {
  const QuantFactorDefinition({
    required this.id,
    required this.category,
    required this.direction,
  });

  final String id;
  final QuantFactorCategory category;
  final QuantFactorDirection direction;
}

const quantFactorDefinitions = <String, QuantFactorDefinition>{
  'trend': QuantFactorDefinition(
    id: 'trend',
    category: QuantFactorCategory.technical,
    direction: QuantFactorDirection.higherIsBetter,
  ),
  'momentum': QuantFactorDefinition(
    id: 'momentum',
    category: QuantFactorCategory.technical,
    direction: QuantFactorDirection.higherIsBetter,
  ),
  'volume': QuantFactorDefinition(
    id: 'volume',
    category: QuantFactorCategory.technical,
    direction: QuantFactorDirection.higherIsBetter,
  ),
};

Map<String, QuantFactorDirection> quantFactorDirectionsFor(
  Iterable<String> factorIds,
) {
  final directions = <String, QuantFactorDirection>{};

  for (final factorId in factorIds) {
    final definition = quantFactorDefinitions[factorId];

    if (definition == null) {
      throw ArgumentError.value(factorId, 'factorIds', 'Unknown quant factor.');
    }

    directions[factorId] = definition.direction;
  }

  return Map.unmodifiable(directions);
}
