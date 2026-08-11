import 'package:flutter_stockapp/features/quant/quant_factor_correlation_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates positive and negative Pearson correlations', () {
    final results = calculateFactorCorrelations(
      factorValuesByStock: const {
        'A': {'trend': 1.0, 'momentum': 10.0, 'volume': 3.0},
        'B': {'trend': 2.0, 'momentum': 20.0, 'volume': 2.0},
        'C': {'trend': 3.0, 'momentum': 30.0, 'volume': 1.0},
      },
      factorIds: const ['trend', 'momentum', 'volume'],
    );

    expect(results, hasLength(3));

    final trendMomentum = results.firstWhere(
      (result) =>
          result.leftFactorId == 'trend' && result.rightFactorId == 'momentum',
    );

    final trendVolume = results.firstWhere(
      (result) =>
          result.leftFactorId == 'trend' && result.rightFactorId == 'volume',
    );

    expect(trendMomentum.coefficient, closeTo(1, 0.000001));
    expect(trendMomentum.sampleSize, 3);
    expect(trendMomentum.strength, QuantFactorCorrelationStrength.strong);

    expect(trendVolume.coefficient, closeTo(-1, 0.000001));
    expect(trendVolume.sampleSize, 3);
    expect(trendVolume.strength, QuantFactorCorrelationStrength.strong);
  });

  test('uncorrelated values produce a weak correlation', () {
    final results = calculateFactorCorrelations(
      factorValuesByStock: const {
        'A': {'trend': -1.0, 'momentum': 1.0},
        'B': {'trend': 0.0, 'momentum': -2.0},
        'C': {'trend': 1.0, 'momentum': 1.0},
      },
      factorIds: const ['trend', 'momentum'],
    );

    expect(results.single.coefficient, closeTo(0, 0.000001));
    expect(results.single.strength, QuantFactorCorrelationStrength.weak);
  });

  test('only stocks with both valid factor values are used', () {
    final results = calculateFactorCorrelations(
      factorValuesByStock: const {
        'A': {'trend': 1.0, 'momentum': 10.0},
        'B': {'trend': 2.0},
        'C': {'momentum': 30.0},
        'D': {'trend': 4.0, 'momentum': 40.0},
        'E': {'trend': double.nan, 'momentum': 50.0},
      },
      factorIds: const ['trend', 'momentum'],
    );

    expect(results.single.sampleSize, 2);
    expect(results.single.coefficient, closeTo(1, 0.000001));
  });

  test('constant factor produces an unavailable correlation', () {
    final results = calculateFactorCorrelations(
      factorValuesByStock: const {
        'A': {'trend': 1.0, 'momentum': 5.0},
        'B': {'trend': 2.0, 'momentum': 5.0},
        'C': {'trend': 3.0, 'momentum': 5.0},
      },
      factorIds: const ['trend', 'momentum'],
    );

    expect(results.single.coefficient, isNull);
    expect(results.single.isAvailable, isFalse);
    expect(results.single.strength, QuantFactorCorrelationStrength.unavailable);
  });

  test('duplicate factor ids do not create duplicate pairs', () {
    final results = calculateFactorCorrelations(
      factorValuesByStock: const {
        'A': {'trend': 1.0, 'momentum': 2.0},
        'B': {'trend': 2.0, 'momentum': 3.0},
      },
      factorIds: const ['trend', 'momentum', 'trend'],
    );

    expect(results, hasLength(1));
    expect(results.single.leftFactorId, 'trend');
    expect(results.single.rightFactorId, 'momentum');
  });

  test('correlation strength follows absolute-value thresholds', () {
    const unavailable = QuantFactorCorrelation(
      leftFactorId: 'A',
      rightFactorId: 'B',
      sampleSize: 0,
      coefficient: null,
    );

    const weak = QuantFactorCorrelation(
      leftFactorId: 'A',
      rightFactorId: 'B',
      sampleSize: 10,
      coefficient: -0.29,
    );

    const moderate = QuantFactorCorrelation(
      leftFactorId: 'A',
      rightFactorId: 'B',
      sampleSize: 10,
      coefficient: -0.50,
    );

    const strong = QuantFactorCorrelation(
      leftFactorId: 'A',
      rightFactorId: 'B',
      sampleSize: 10,
      coefficient: -0.80,
    );

    expect(unavailable.strength, QuantFactorCorrelationStrength.unavailable);
    expect(weak.strength, QuantFactorCorrelationStrength.weak);
    expect(moderate.strength, QuantFactorCorrelationStrength.moderate);
    expect(strong.strength, QuantFactorCorrelationStrength.strong);
  });
  test('redundancy warning requires adequate sample and high correlation', () {
    const insufficient = QuantFactorCorrelation(
      leftFactorId: 'trend',
      rightFactorId: 'momentum',
      sampleSize: 4,
      coefficient: 0.95,
    );

    const limited = QuantFactorCorrelation(
      leftFactorId: 'trend',
      rightFactorId: 'momentum',
      sampleSize: 10,
      coefficient: 0.95,
    );

    const adequateButNotRedundant = QuantFactorCorrelation(
      leftFactorId: 'trend',
      rightFactorId: 'momentum',
      sampleSize: 20,
      coefficient: 0.79,
    );

    const adequateAndRedundant = QuantFactorCorrelation(
      leftFactorId: 'trend',
      rightFactorId: 'momentum',
      sampleSize: 20,
      coefficient: -0.80,
    );

    expect(
      insufficient.reliability,
      QuantFactorCorrelationReliability.insufficient,
    );
    expect(insufficient.isPotentiallyRedundant, isFalse);

    expect(limited.reliability, QuantFactorCorrelationReliability.limited);
    expect(limited.isPotentiallyRedundant, isFalse);

    expect(
      adequateButNotRedundant.reliability,
      QuantFactorCorrelationReliability.adequate,
    );
    expect(adequateButNotRedundant.isPotentiallyRedundant, isFalse);

    expect(
      adequateAndRedundant.reliability,
      QuantFactorCorrelationReliability.adequate,
    );
    expect(adequateAndRedundant.isPotentiallyRedundant, isTrue);
  });
}
