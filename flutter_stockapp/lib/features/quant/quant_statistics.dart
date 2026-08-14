import 'dart:math' as math;

double? calculatePearsonCorrelation(
  Iterable<double> leftValues,
  Iterable<double> rightValues,
) {
  final left = leftValues.toList(growable: false);
  final right = rightValues.toList(growable: false);

  if (left.length != right.length ||
      left.length < 2 ||
      left.any((value) => !value.isFinite) ||
      right.any((value) => !value.isFinite)) {
    return null;
  }

  final sampleSize = left.length;
  final leftMean =
      left.fold<double>(0, (sum, value) => sum + value) / sampleSize;
  final rightMean =
      right.fold<double>(0, (sum, value) => sum + value) / sampleSize;

  var covarianceTotal = 0.0;
  var leftVarianceTotal = 0.0;
  var rightVarianceTotal = 0.0;

  for (var index = 0; index < sampleSize; index++) {
    final leftDeviation = left[index] - leftMean;
    final rightDeviation = right[index] - rightMean;

    covarianceTotal += leftDeviation * rightDeviation;
    leftVarianceTotal += leftDeviation * leftDeviation;
    rightVarianceTotal += rightDeviation * rightDeviation;
  }

  if (leftVarianceTotal <= 1e-12 || rightVarianceTotal <= 1e-12) {
    return null;
  }

  final denominator = math.sqrt(leftVarianceTotal * rightVarianceTotal);

  return (covarianceTotal / denominator).clamp(-1.0, 1.0).toDouble();
}

List<double> calculateAverageRanks(Iterable<double> sourceValues) {
  final values = sourceValues.toList(growable: false);

  if (values.any((value) => !value.isFinite)) {
    throw ArgumentError.value(
      sourceValues,
      'sourceValues',
      'Rank values must be finite.',
    );
  }

  final orderedIndices = List<int>.generate(values.length, (index) => index)
    ..sort((left, right) => values[left].compareTo(values[right]));

  final ranks = List<double>.filled(values.length, 0);
  var start = 0;

  while (start < orderedIndices.length) {
    var end = start;

    while (end + 1 < orderedIndices.length &&
        values[orderedIndices[end + 1]] == values[orderedIndices[start]]) {
      end++;
    }

    final averageRank = (start + end + 2) / 2;

    for (var index = start; index <= end; index++) {
      ranks[orderedIndices[index]] = averageRank;
    }

    start = end + 1;
  }

  return List.unmodifiable(ranks);
}
