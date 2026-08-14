import 'quant_factor_ic.dart';
import 'quant_statistics.dart';

QuantFactorIcResult calculateQuantFactorIc({
  required String factorId,
  required Iterable<QuantFactorIcCrossSection> crossSections,
  int minimumSampleSize = 3,
}) {
  final normalizedFactorId = factorId.trim();

  if (normalizedFactorId.isEmpty) {
    throw ArgumentError.value(
      factorId,
      'factorId',
      'Factor id cannot be empty.',
    );
  }

  if (minimumSampleSize < 2) {
    throw ArgumentError.value(
      minimumSampleSize,
      'minimumSampleSize',
      'Minimum sample size cannot be smaller than 2.',
    );
  }

  final periods = <QuantFactorIcPeriodResult>[];
  final observedDates = <DateTime>{};

  for (final crossSection in crossSections) {
    if (!observedDates.add(crossSection.date)) {
      throw ArgumentError.value(
        crossSection.date,
        'crossSections',
        'Cross-section dates cannot be duplicated.',
      );
    }

    final factorValues = <double>[];
    final forwardReturns = <double>[];

    for (final entry in crossSection.factorValuesByStock.entries) {
      final factorValue = entry.value;
      final forwardReturn = crossSection.forwardReturnsByStock[entry.key];

      if (forwardReturn != null &&
          factorValue.isFinite &&
          forwardReturn.isFinite) {
        factorValues.add(factorValue);
        forwardReturns.add(forwardReturn);
      }
    }

    final hasMinimumSample = factorValues.length >= minimumSampleSize;

    final informationCoefficient = hasMinimumSample
        ? calculatePearsonCorrelation(factorValues, forwardReturns)
        : null;

    final rankInformationCoefficient = hasMinimumSample
        ? calculatePearsonCorrelation(
            calculateAverageRanks(factorValues),
            calculateAverageRanks(forwardReturns),
          )
        : null;

    periods.add(
      QuantFactorIcPeriodResult(
        date: crossSection.date,
        sampleSize: factorValues.length,
        informationCoefficient: informationCoefficient,
        rankInformationCoefficient: rankInformationCoefficient,
      ),
    );
  }

  periods.sort((left, right) => left.date.compareTo(right.date));

  return QuantFactorIcResult(
    factorId: normalizedFactorId,
    periods: List.unmodifiable(periods),
  );
}
