import 'quant_factor_ic_analysis_calculator.dart';
import 'quant_factor_ic_dashboard.dart';
import 'quant_stock_ranking.dart';
import 'stock_daily_bar.dart';

const quantFactorIcDashboardFactorIds = ['trend', 'momentum', 'volume'];

QuantFactorIcDashboardResult calculateQuantFactorIcDashboard({
  required QuantStockRankingResult rankingResult,
  int holdingPeriod = 5,
  int minimumLookback = 35,
  int minimumSampleSize = 3,
}) {
  if (minimumSampleSize < 2) {
    throw ArgumentError.value(
      minimumSampleSize,
      'minimumSampleSize',
      'Minimum sample size cannot be smaller than 2.',
    );
  }

  final barsByStock = <String, List<StockDailyBar>>{};

  for (final item in rankingResult.items) {
    final analysis = item.analysis;
    final symbol = analysis.symbol.trim();

    if (analysis.isSimulated || symbol.isEmpty || analysis.bars.isEmpty) {
      continue;
    }

    barsByStock[symbol] = analysis.bars;
  }

  final realStockCount = barsByStock.length;

  if (realStockCount < minimumSampleSize) {
    return QuantFactorIcDashboardResult(
      status: QuantFactorIcDashboardStatus.insufficientRealStocks,
      realStockCount: realStockCount,
    );
  }

  final factorResults = {
    for (final factorId in quantFactorIcDashboardFactorIds)
      factorId: calculateQuantFactorIcAnalysis(
        factorId: factorId,
        barsByStock: barsByStock,
        holdingPeriod: holdingPeriod,
        minimumLookback: minimumLookback,
        minimumSampleSize: minimumSampleSize,
      ),
  };

  final hasAvailableResult = factorResults.values.any(
    (result) => result.availablePeriodCount > 0,
  );

  return QuantFactorIcDashboardResult(
    status: hasAvailableResult
        ? QuantFactorIcDashboardStatus.available
        : QuantFactorIcDashboardStatus.insufficientHistory,
    realStockCount: realStockCount,
    factorResults: Map.unmodifiable(factorResults),
  );
}
