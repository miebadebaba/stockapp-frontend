import 'package:flutter_stockapp/features/quant/quant_factor_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registered technical factors use higher-is-better direction', () {
    final directions = quantFactorDirectionsFor([
      'trend',
      'momentum',
      'volume',
    ]);

    expect(directions, hasLength(3));
    expect(directions['trend'], QuantFactorDirection.higherIsBetter);
    expect(directions['momentum'], QuantFactorDirection.higherIsBetter);
    expect(directions['volume'], QuantFactorDirection.higherIsBetter);
  });

  test('factor definition id matches its registry key', () {
    for (final entry in quantFactorDefinitions.entries) {
      expect(entry.value.id, entry.key);
    }
  });

  test('unknown factor is rejected', () {
    expect(
      () => quantFactorDirectionsFor(['trend', 'unknown_factor']),
      throwsArgumentError,
    );
  });
}
