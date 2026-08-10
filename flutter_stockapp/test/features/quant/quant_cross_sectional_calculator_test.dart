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
}
