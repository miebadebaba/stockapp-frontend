import 'quant_factor_ic.dart';
import 'quant_factor_score.dart';
import 'quant_factor_score_calculator.dart';
import 'quant_historical_analysis_builder.dart';
import 'stock_daily_bar.dart';

List<QuantFactorIcCrossSection> buildQuantFactorIcCrossSections({
  required String factorId,
  required Map<String, List<StockDailyBar>> barsByStock,
  int holdingPeriod = 5,
  int minimumLookback = 35,
}) {
  final normalizedFactorId = factorId.trim();

  if (normalizedFactorId.isEmpty) {
    throw ArgumentError.value(
      factorId,
      'factorId',
      'Factor id cannot be empty.',
    );
  }

  if (holdingPeriod <= 0) {
    throw ArgumentError.value(
      holdingPeriod,
      'holdingPeriod',
      'Holding period must be greater than zero.',
    );
  }

  if (minimumLookback < 35) {
    throw ArgumentError.value(
      minimumLookback,
      'minimumLookback',
      'Minimum lookback cannot be smaller than 35.',
    );
  }

  final sectionsByDate = <DateTime, _MutableIcCrossSection>{};

  for (final stockEntry in barsByStock.entries) {
    final symbol = stockEntry.key.trim();

    if (symbol.isEmpty) {
      continue;
    }

    final orderedBars = [...stockEntry.value]
      ..sort((left, right) => left.tradingDate.compareTo(right.tradingDate));

    var signalIndex = minimumLookback - 1;

    while (signalIndex < orderedBars.length) {
      final entryIndex = signalIndex + 1;
      final exitIndex = entryIndex + holdingPeriod - 1;

      if (exitIndex >= orderedBars.length) {
        break;
      }

      final entryBar = orderedBars[entryIndex];
      final exitBar = orderedBars[exitIndex];

      if (!_isValidPrice(entryBar.open) || !_isValidPrice(exitBar.close)) {
        signalIndex++;
        continue;
      }

      final historicalBars = List<StockDailyBar>.unmodifiable(
        orderedBars.sublist(0, signalIndex + 1),
      );

      final analysis = buildHistoricalQuantStockAnalysis(
        symbol: symbol,
        bars: historicalBars,
      );

      final factorScore = calculateQuantFactorScore(analysis: analysis);

      if (!factorScore.hasSufficientData) {
        signalIndex++;
        continue;
      }

      final factor = _findFactor(
        score: factorScore,
        factorId: normalizedFactorId,
      );

      if (factor == null ||
          factor.signal == QuantFactorSignal.unavailable ||
          !factor.score.isFinite) {
        signalIndex++;
        continue;
      }

      final forwardReturn = exitBar.close / entryBar.open - 1;

      if (!forwardReturn.isFinite) {
        signalIndex++;
        continue;
      }

      final date = DateTime(
        orderedBars[signalIndex].tradingDate.year,
        orderedBars[signalIndex].tradingDate.month,
        orderedBars[signalIndex].tradingDate.day,
      );

      final section = sectionsByDate.putIfAbsent(
        date,
        _MutableIcCrossSection.new,
      );

      section.factorValuesByStock[symbol] = factor.score;
      section.forwardReturnsByStock[symbol] = forwardReturn;

      signalIndex++;
    }
  }

  final dates = sectionsByDate.keys.toList()..sort();

  return List.unmodifiable([
    for (final date in dates)
      QuantFactorIcCrossSection(
        date: date,
        factorValuesByStock: Map.unmodifiable(
          sectionsByDate[date]!.factorValuesByStock,
        ),
        forwardReturnsByStock: Map.unmodifiable(
          sectionsByDate[date]!.forwardReturnsByStock,
        ),
      ),
  ]);
}

QuantFactorItem? _findFactor({
  required QuantFactorScore score,
  required String factorId,
}) {
  for (final factor in score.factors) {
    if (factor.id == factorId) {
      return factor;
    }
  }

  return null;
}

bool _isValidPrice(double value) {
  return value.isFinite && value > 0;
}

class _MutableIcCrossSection {
  final factorValuesByStock = <String, double>{};
  final forwardReturnsByStock = <String, double>{};
}
