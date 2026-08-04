import 'macd_calculator.dart';
import 'moving_average_calculator.dart';
import 'quant_factor_backtest.dart';
import 'quant_factor_score_calculator.dart';
import 'quant_stock_analysis.dart';
import 'rsi_calculator.dart';
import 'stock_daily_bar.dart';
import 'stock_quote.dart';
import 'technical_summary_analyzer.dart';
import 'volume_analyzer.dart';

QuantFactorBacktestResult calculateQuantFactorBacktest({
  required String symbol,
  required List<StockDailyBar> bars,
  double signalThreshold = 60,
  int holdingPeriod = 5,
  int minimumLookback = 35,
}) {
  if (signalThreshold < 0 || signalThreshold > 100) {
    throw ArgumentError.value(
      signalThreshold,
      'signalThreshold',
      '信号阈值必须在 0～100 之间',
    );
  }

  if (holdingPeriod <= 0) {
    throw ArgumentError.value(holdingPeriod, 'holdingPeriod', '持有周期必须大于 0');
  }

  if (minimumLookback < 35) {
    throw ArgumentError.value(
      minimumLookback,
      'minimumLookback',
      '观察窗口不能少于 35 个交易日',
    );
  }

  final orderedBars = [...bars]
    ..sort((left, right) => left.tradingDate.compareTo(right.tradingDate));

  final trades = <QuantBacktestTrade>[];

  var signalIndex = minimumLookback - 1;

  while (signalIndex < orderedBars.length) {
    final entryIndex = signalIndex + 1;
    final exitIndex = entryIndex + holdingPeriod - 1;

    if (exitIndex >= orderedBars.length) {
      break;
    }

    final historicalBars = List<StockDailyBar>.unmodifiable(
      orderedBars.sublist(0, signalIndex + 1),
    );

    final analysis = _buildHistoricalAnalysis(
      symbol: symbol,
      bars: historicalBars,
    );

    final factorScore = calculateQuantFactorScore(analysis: analysis);
    final signalScore = factorScore.riskAdjustedScore;

    if (signalScore == null || signalScore < signalThreshold) {
      signalIndex++;
      continue;
    }

    final entryBar = orderedBars[entryIndex];
    final exitBar = orderedBars[exitIndex];

    if (!_isValidPrice(entryBar.open) || !_isValidPrice(exitBar.close)) {
      signalIndex++;
      continue;
    }

    trades.add(
      QuantBacktestTrade(
        entryDate: entryBar.tradingDate,
        exitDate: exitBar.tradingDate,
        entryPrice: entryBar.open,
        exitPrice: exitBar.close,
        signalScore: signalScore,
      ),
    );

    // 当前交易结束前不再产生新交易，避免持仓重叠。
    signalIndex = exitIndex;
  }

  return QuantFactorBacktestResult(
    trades: List.unmodifiable(trades),
    signalThreshold: signalThreshold,
    holdingPeriod: holdingPeriod,
    minimumLookback: minimumLookback,
  );
}

QuantStockAnalysis _buildHistoricalAnalysis({
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
    dataSourceName: '历史回测',
  );
}

bool _isValidPrice(double value) {
  return value.isFinite && value > 0;
}
