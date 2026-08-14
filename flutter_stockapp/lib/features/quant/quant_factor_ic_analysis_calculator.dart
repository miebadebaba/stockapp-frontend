import 'quant_factor_ic.dart';
import 'quant_factor_ic_calculator.dart';
import 'quant_factor_ic_data_builder.dart';
import 'stock_daily_bar.dart';

QuantFactorIcResult calculateQuantFactorIcAnalysis({
  required String factorId,
  required Map<String, List<StockDailyBar>> barsByStock,
  int holdingPeriod = 5,
  int minimumLookback = 35,
  int minimumSampleSize = 3,
}) {
  final crossSections = buildQuantFactorIcCrossSections(
    factorId: factorId,
    barsByStock: barsByStock,
    holdingPeriod: holdingPeriod,
    minimumLookback: minimumLookback,
  );

  return calculateQuantFactorIc(
    factorId: factorId,
    crossSections: crossSections,
    minimumSampleSize: minimumSampleSize,
  );
}
