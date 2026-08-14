import 'package:flutter_stockapp/features/quant/quant_factor_ic.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_ic_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates Pearson IC and Rank IC for a cross-section', () {
    final result = calculateQuantFactorIc(
      factorId: 'trend',
      crossSections: [
        _section(
          DateTime(2026, 1, 2),
          const {'A': 1.0, 'B': 2.0, 'C': 3.0, 'D': 4.0},
          const {'A': 0.01, 'B': 0.04, 'C': 0.09, 'D': 0.16},
        ),
      ],
    );

    final period = result.periods.single;

    expect(result.factorId, 'trend');
    expect(period.sampleSize, 4);
    expect(period.informationCoefficient, greaterThan(0.95));
    expect(period.rankInformationCoefficient, closeTo(1, 0.000001));
    expect(period.isAvailable, isTrue);
  });

  test('uses only stocks with both finite values', () {
    final result = calculateQuantFactorIc(
      factorId: 'momentum',
      minimumSampleSize: 2,
      crossSections: [
        _section(
          DateTime(2026, 1, 2),
          const {'A': 1.0, 'B': 2.0, 'C': double.nan, 'D': 4.0},
          const {'A': 0.01, 'C': 0.03, 'D': 0.04, 'E': 0.05},
        ),
      ],
    );

    final period = result.periods.single;

    expect(period.sampleSize, 2);
    expect(period.informationCoefficient, closeTo(1, 0.000001));
    expect(period.rankInformationCoefficient, closeTo(1, 0.000001));
  });

  test('insufficient samples produce unavailable coefficients', () {
    final result = calculateQuantFactorIc(
      factorId: 'volume',
      minimumSampleSize: 3,
      crossSections: [
        _section(
          DateTime(2026, 1, 2),
          const {'A': 1.0, 'B': 2.0},
          const {'A': 0.01, 'B': 0.02},
        ),
      ],
    );

    final period = result.periods.single;

    expect(period.sampleSize, 2);
    expect(period.informationCoefficient, isNull);
    expect(period.rankInformationCoefficient, isNull);
    expect(period.isAvailable, isFalse);
  });
  test('calculates multi-period IC summary metrics', () {
    final result = calculateQuantFactorIc(
      factorId: 'trend',
      crossSections: [
        _section(
          DateTime(2026, 1, 2),
          const {'A': 1.0, 'B': 2.0, 'C': 3.0},
          const {'A': 0.01, 'B': 0.02, 'C': 0.03},
        ),
        _section(
          DateTime(2026, 1, 3),
          const {'A': 1.0, 'B': 2.0, 'C': 3.0},
          const {'A': 0.02, 'B': 0.04, 'C': 0.06},
        ),
        _section(
          DateTime(2026, 1, 4),
          const {'A': 1.0, 'B': 2.0, 'C': 3.0},
          const {'A': 0.03, 'B': 0.02, 'C': 0.01},
        ),
      ],
    );

    expect(result.informationCoefficients.length, 3);
    expect(result.rankInformationCoefficients.length, 3);

    expect(result.averageInformationCoefficient, closeTo(1 / 3, 0.000001));
    expect(result.averageRankInformationCoefficient, closeTo(1 / 3, 0.000001));

    expect(result.positiveInformationCoefficientRate, closeTo(2 / 3, 0.000001));
    expect(
      result.positiveRankInformationCoefficientRate,
      closeTo(2 / 3, 0.000001),
    );

    expect(result.icInformationRatio, greaterThan(0));
    expect(result.rankIcInformationRatio, greaterThan(0));
  });
  test('reports insufficient reliability with too few periods', () {
    final result = QuantFactorIcResult(
      factorId: 'trend',
      periods: List.generate(
        4,
        (index) => QuantFactorIcPeriodResult(
          date: DateTime(2026, 1, index + 1),
          sampleSize: 10,
          informationCoefficient: 0.2,
          rankInformationCoefficient: 0.2,
        ),
      ),
    );

    expect(result.reliability, QuantFactorIcReliability.insufficient);
  });

  test('reports limited reliability with a moderate sample', () {
    final result = QuantFactorIcResult(
      factorId: 'trend',
      periods: List.generate(
        5,
        (index) => QuantFactorIcPeriodResult(
          date: DateTime(2026, 1, index + 1),
          sampleSize: 10,
          informationCoefficient: 0.2,
          rankInformationCoefficient: 0.2,
        ),
      ),
    );

    expect(result.reliability, QuantFactorIcReliability.limited);
  });

  test('reports adequate reliability with enough periods and samples', () {
    final result = QuantFactorIcResult(
      factorId: 'trend',
      periods: List.generate(
        20,
        (index) => QuantFactorIcPeriodResult(
          date: DateTime(2026, 1, index + 1),
          sampleSize: 20,
          informationCoefficient: 0.2,
          rankInformationCoefficient: 0.2,
        ),
      ),
    );

    expect(result.reliability, QuantFactorIcReliability.adequate);
  });
}

QuantFactorIcCrossSection _section(
  DateTime date,
  Map<String, double> factors,
  Map<String, double> returns,
) {
  return QuantFactorIcCrossSection(
    date: date,
    factorValuesByStock: factors,
    forwardReturnsByStock: returns,
  );
}
