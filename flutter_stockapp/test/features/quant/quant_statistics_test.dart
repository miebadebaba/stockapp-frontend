import 'package:flutter_stockapp/features/quant/quant_statistics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates positive and negative Pearson correlations', () {
    final positive = calculatePearsonCorrelation(
      const [1, 2, 3, 4],
      const [10, 20, 30, 40],
    );

    final negative = calculatePearsonCorrelation(
      const [1, 2, 3, 4],
      const [40, 30, 20, 10],
    );

    expect(positive, closeTo(1, 0.000001));
    expect(negative, closeTo(-1, 0.000001));
  });

  test('Pearson correlation rejects unusable samples', () {
    expect(calculatePearsonCorrelation(const [1], const [2]), isNull);

    expect(calculatePearsonCorrelation(const [1, 2], const [3]), isNull);

    expect(
      calculatePearsonCorrelation(const [1, 1, 1], const [2, 3, 4]),
      isNull,
    );

    expect(
      calculatePearsonCorrelation(const [1, double.nan], const [2, 3]),
      isNull,
    );
  });

  test('average ranks preserve order and share ranks for ties', () {
    final ranks = calculateAverageRanks(const [30, 10, 20, 20, 40]);

    expect(ranks, const [4, 1, 2.5, 2.5, 5]);
  });

  test('average ranks reject non-finite values', () {
    expect(
      () => calculateAverageRanks(const [1, double.infinity]),
      throwsArgumentError,
    );
  });
}
