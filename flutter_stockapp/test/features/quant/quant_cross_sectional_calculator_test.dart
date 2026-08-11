import 'package:flutter_stockapp/features/quant/quant_cross_sectional_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('将股票因子分转换为股票池百分位', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {
        'A': {'trend': 40.0, 'momentum': 30.0, 'volume': 20.0},
        'B': {'trend': 70.0, 'momentum': 60.0, 'volume': 50.0},
        'C': {'trend': 90.0, 'momentum': 80.0, 'volume': 75.0},
      },
      factorWeights: const {'trend': 0.40, 'momentum': 0.35, 'volume': 0.25},
    );

    expect(result['A']!.percentileFor('trend'), 0);
    expect(result['B']!.percentileFor('trend'), 50);
    expect(result['C']!.percentileFor('trend'), 100);

    expect(result['A']!.compositeScore, 0);
    expect(result['B']!.compositeScore, closeTo(50, 0.001));
    expect(result['C']!.compositeScore, closeTo(100, 0.001));

    expect(result['A']!.availableFactorCount, 3);
    expect(result['A']!.totalFactorCount, 3);
    expect(result['A']!.coverageRatio, 1);
  });

  test('相同因子分获得相同百分位', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {
        'A': {'trend': 80.0},
        'B': {'trend': 80.0},
        'C': {'trend': 40.0},
      },
      factorWeights: const {'trend': 1.0},
    );

    expect(
      result['A']!.percentileFor('trend'),
      result['B']!.percentileFor('trend'),
    );
    expect(result['C']!.percentileFor('trend'), 0);
  });

  test('股票池只有一只股票时使用中性百分位', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {
        'A': {'trend': 80.0},
      },
      factorWeights: const {'trend': 1.0},
    );

    expect(result['A']!.percentileFor('trend'), 50);
    expect(result['A']!.compositeScore, 50);
    expect(result['A']!.availableFactorCount, 1);
    expect(result['A']!.totalFactorCount, 1);
    expect(result['A']!.coverageRatio, 1);
  });

  test('缺少某项因子时按可用因子重新计算权重', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {
        'A': {'trend': 80.0, 'momentum': 60.0},
        'B': {'trend': 40.0},
      },
      factorWeights: const {'trend': 0.50, 'momentum': 0.50},
    );

    expect(result['A']!.compositeScore, 75);
    expect(result['B']!.compositeScore, 0);
  });

  test('空股票池返回空结果', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {},
      factorWeights: const {'trend': 0.40, 'momentum': 0.35, 'volume': 0.25},
    );

    expect(result, isEmpty);
  });

  test('reports factor coverage when some factors are missing', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {
        'A': {'trend': 80.0, 'momentum': 60.0},
        'B': {'trend': 40.0},
      },
      factorWeights: const {'trend': 0.40, 'momentum': 0.35, 'volume': 0.25},
    );

    expect(result['A']!.availableFactorCount, 2);
    expect(result['A']!.totalFactorCount, 3);
    expect(result['A']!.coverageRatio, closeTo(2 / 3, 0.001));

    expect(result['B']!.availableFactorCount, 1);
    expect(result['B']!.totalFactorCount, 3);
    expect(result['B']!.coverageRatio, closeTo(1 / 3, 0.001));
  });

  test('reports zero coverage when a stock has no valid factors', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {'A': {}},
      factorWeights: const {'trend': 0.40, 'momentum': 0.35, 'volume': 0.25},
    );

    expect(result['A']!.availableFactorCount, 0);
    expect(result['A']!.totalFactorCount, 3);
    expect(result['A']!.coverageRatio, 0);
    expect(result['A']!.compositeScore, 0);
  });

  test('supports factors where lower values are better', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {
        'A': {'volatility': 10.0},
        'B': {'volatility': 20.0},
        'C': {'volatility': 30.0},
      },
      factorWeights: const {'volatility': 1.0},
      factorDirections: const {
        'volatility': QuantFactorDirection.lowerIsBetter,
      },
    );

    expect(result['A']!.percentileFor('volatility'), 100);
    expect(result['B']!.percentileFor('volatility'), 50);
    expect(result['C']!.percentileFor('volatility'), 0);

    expect(result['A']!.compositeScore, 100);
    expect(result['C']!.compositeScore, 0);
  });

  test('winsorizes extreme factor values when configured', () {
    const factorScores = {
      'A': {'trend': 0.0},
      'B': {'trend': 10.0},
      'C': {'trend': 20.0},
      'D': {'trend': 30.0},
      'E': {'trend': 40.0},
      'F': {'trend': 50.0},
      'G': {'trend': 60.0},
      'H': {'trend': 70.0},
      'I': {'trend': 80.0},
      'J': {'trend': 1000.0},
    };

    final result = calculateCrossSectionalScores(
      factorScoresByStock: factorScores,
      factorWeights: const {'trend': 1.0},
      winsorizationQuantile: 0.2,
    );

    final withoutWinsorization = calculateCrossSectionalScores(
      factorScoresByStock: factorScores,
      factorWeights: const {'trend': 1.0},
    );

    expect(
      result['J']!.compositeScore,
      lessThan(withoutWinsorization['J']!.compositeScore),
    );

    expect(
      result['I']!.percentileFor('trend'),
      result['J']!.percentileFor('trend'),
    );

    expect(
      result['A']!.percentileFor('trend'),
      result['B']!.percentileFor('trend'),
    );

    expect(result['J']!.availableFactorCount, 1);
    expect(result['J']!.totalFactorCount, 1);
  });

  test('keeps small stock pools unchanged by winsorization', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {
        'A': {'trend': 0.0},
        'B': {'trend': 10.0},
        'C': {'trend': 1000.0},
      },
      factorWeights: const {'trend': 1.0},
      winsorizationQuantile: 0.2,
    );

    expect(result['A']!.percentileFor('trend'), 0);
    expect(result['B']!.percentileFor('trend'), 50);
    expect(result['C']!.percentileFor('trend'), 100);
  });

  test('rejects invalid winsorization quantiles', () {
    expect(
      () => calculateCrossSectionalScores(
        factorScoresByStock: const {
          'A': {'trend': 80.0},
        },
        factorWeights: const {'trend': 1.0},
        winsorizationQuantile: 0.5,
      ),
      throwsArgumentError,
    );
  });

  test('因子权重不能为负数', () {
    expect(
      () => calculateCrossSectionalScores(
        factorScoresByStock: const {
          'A': {'trend': 80.0},
        },
        factorWeights: const {'trend': -1.0},
      ),
      throwsArgumentError,
    );
  });
  test('Z-Score uses population standard deviation', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {
        'A': {'trend': 40.0},
        'B': {'trend': 50.0},
        'C': {'trend': 60.0},
      },
      factorWeights: const {'trend': 1.0},
    );

    expect(result['A']!.zScoreFor('trend'), closeTo(-1.224745, 0.000001));
    expect(result['B']!.zScoreFor('trend'), closeTo(0, 0.000001));
    expect(result['C']!.zScoreFor('trend'), closeTo(1.224745, 0.000001));
  });

  test('single stock receives neutral Z-Score', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {
        'A': {'trend': 80.0},
      },
      factorWeights: const {'trend': 1.0},
    );

    expect(result['A']!.zScoreFor('trend'), 0);
  });

  test('equal factor values receive neutral Z-Scores', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {
        'A': {'trend': 80.0},
        'B': {'trend': 80.0},
        'C': {'trend': 80.0},
      },
      factorWeights: const {'trend': 1.0},
    );

    expect(result['A']!.zScoreFor('trend'), 0);
    expect(result['B']!.zScoreFor('trend'), 0);
    expect(result['C']!.zScoreFor('trend'), 0);
  });

  test('lower-is-better direction reverses Z-Score signs', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {
        'A': {'volatility': 10.0},
        'B': {'volatility': 20.0},
        'C': {'volatility': 30.0},
      },
      factorWeights: const {'volatility': 1.0},
      factorDirections: const {
        'volatility': QuantFactorDirection.lowerIsBetter,
      },
    );

    expect(result['A']!.zScoreFor('volatility'), greaterThan(0));
    expect(result['B']!.zScoreFor('volatility'), closeTo(0, 0.000001));
    expect(result['C']!.zScoreFor('volatility'), lessThan(0));
  });

  test('Winsorization is applied before Z-Score calculation', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {
        'A': {'trend': 0.0},
        'B': {'trend': 10.0},
        'C': {'trend': 20.0},
        'D': {'trend': 30.0},
        'E': {'trend': 100.0},
      },
      factorWeights: const {'trend': 1.0},
      winsorizationQuantile: 0.20,
    );

    expect(result['A']!.zScoreFor('trend'), closeTo(-1.078599, 0.00001));
    expect(result['E']!.zScoreFor('trend'), closeTo(1.617898, 0.00001));
  });
  test('factor sample size only counts valid values', () {
    final result = calculateCrossSectionalScores(
      factorScoresByStock: const {
        'A': {'trend': 80.0},
        'B': {'trend': 60.0},
        'C': {},
        'D': {'trend': double.nan},
      },
      factorWeights: const {'trend': 1.0},
    );

    expect(result['A']!.sampleSizeFor('trend'), 2);
    expect(result['B']!.sampleSizeFor('trend'), 2);
    expect(result['C']!.sampleSizeFor('trend'), 2);
    expect(result['D']!.sampleSizeFor('trend'), 2);

    expect(
      result['A']!.reliabilityFor('trend'),
      QuantFactorSampleReliability.insufficient,
    );
  });

  test('factor reliability follows sample-size thresholds', () {
    Map<String, Map<String, double>> buildPool(int count) {
      return {
        for (var index = 0; index < count; index++)
          'S$index': {'trend': index.toDouble()},
      };
    }

    final insufficient = calculateCrossSectionalScores(
      factorScoresByStock: buildPool(4),
      factorWeights: const {'trend': 1.0},
    );

    final limited = calculateCrossSectionalScores(
      factorScoresByStock: buildPool(5),
      factorWeights: const {'trend': 1.0},
    );

    final adequate = calculateCrossSectionalScores(
      factorScoresByStock: buildPool(20),
      factorWeights: const {'trend': 1.0},
    );

    expect(
      insufficient['S0']!.reliabilityFor('trend'),
      QuantFactorSampleReliability.insufficient,
    );
    expect(
      limited['S0']!.reliabilityFor('trend'),
      QuantFactorSampleReliability.limited,
    );
    expect(
      adequate['S0']!.reliabilityFor('trend'),
      QuantFactorSampleReliability.adequate,
    );
  });
}
