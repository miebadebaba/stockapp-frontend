import 'macd_result.dart';
import 'stock_daily_bar.dart';
import 'stock_quote.dart';
import 'technical_summary_result.dart';
import 'volume_analysis_result.dart';

class QuantStockAnalysis {
  const QuantStockAnalysis({
    required this.symbol,
    required this.bars,
    required this.latestBar,
    required this.ma5,
    required this.ma10,
    required this.ma20,
    required this.macd,
    required this.rsi14,
    required this.volume,
    required this.technicalSummary,
    this.dataSourceName = 'Market 行情服务',
    this.isSimulated = false,
  });

  final String symbol;
  final List<StockDailyBar> bars;
  final StockQuote latestBar;
  final double? ma5;
  final double? ma10;
  final double? ma20;
  final MacdResult? macd;
  final double? rsi14;
  final VolumeAnalysisResult? volume;
  final TechnicalSummaryResult technicalSummary;
  final String dataSourceName;
  final bool isSimulated;
}
