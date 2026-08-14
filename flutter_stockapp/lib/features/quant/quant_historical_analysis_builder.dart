import 'macd_calculator.dart';
import 'moving_average_calculator.dart';
import 'quant_stock_analysis.dart';
import 'rsi_calculator.dart';
import 'stock_daily_bar.dart';
import 'stock_quote.dart';
import 'technical_summary_analyzer.dart';
import 'volume_analyzer.dart';

QuantStockAnalysis buildHistoricalQuantStockAnalysis({
  required String symbol,
  required List<StockDailyBar> bars,
}) {
  final latestBar = bars.last;
  final previousBar = bars[bars.length - 2];

  final macd = calculateMacd(bars: bars);
  final rsi = calculateRsi(bars: bars);
  final volume = analyzeVolume(bars: bars);

  return QuantStockAnalysis(
    symbol: symbol,
    bars: bars,
    latestBar: StockQuote(
      tradingDate: latestBar.tradingDate,
      open: latestBar.open,
      high: latestBar.high,
      low: latestBar.low,
      close: latestBar.close,
      previousClose: previousBar.close,
      volume: latestBar.volume,
    ),
    ma5: calculateMovingAverage(bars: bars, period: 5),
    ma10: calculateMovingAverage(bars: bars, period: 10),
    ma20: calculateMovingAverage(bars: bars, period: 20),
    macd: macd,
    rsi14: rsi,
    volume: volume,
    technicalSummary: analyzeTechnicalSummary(
      bars: bars,
      rsi: rsi,
      macd: macd,
      volume: volume,
    ),
    dataSourceName: 'historical',
  );
}
