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
  QuantBacktestCostSettings costSettings = const QuantBacktestCostSettings(),
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

  if (costSettings.commissionRate < 0 ||
      costSettings.stampDutyRate < 0 ||
      costSettings.slippageRate < 0 ||
      costSettings.commissionRate >= 1 ||
      costSettings.stampDutyRate >= 1 ||
      costSettings.slippageRate >= 1) {
    throw ArgumentError.value(costSettings, 'costSettings', '交易成本率必须在 0～1 之间');
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
        costSettings: costSettings,
      ),
    );

    // 当前交易结束前不再产生新交易，避免持仓重叠。
    signalIndex = exitIndex;
  }

  final equityCurve = _buildEquityCurve(
    bars: orderedBars,
    trades: trades,
    minimumLookback: minimumLookback,
  );

  return QuantFactorBacktestResult(
    trades: List.unmodifiable(trades),
    signalThreshold: signalThreshold,
    holdingPeriod: holdingPeriod,
    minimumLookback: minimumLookback,
    costSettings: costSettings,
    equityCurve: List.unmodifiable(equityCurve),
  );
}

List<QuantBacktestEquityPoint> _buildEquityCurve({
  required List<StockDailyBar> bars,
  required List<QuantBacktestTrade> trades,
  required int minimumLookback,
}) {
  if (bars.length <= minimumLookback) {
    return const [];
  }

  final backtestBars = bars.sublist(minimumLookback);
  final benchmarkStartPrice = backtestBars.first.close;

  if (!_isValidPrice(benchmarkStartPrice)) {
    return const [];
  }

  final points = <QuantBacktestEquityPoint>[];
  var settledEquity = 1.0;
  var tradeIndex = 0;

  for (final bar in backtestBars) {
    var strategyValue = settledEquity;

    if (tradeIndex < trades.length) {
      final trade = trades[tradeIndex];
      final isEntryOrLater = !bar.tradingDate.isBefore(trade.entryDate);
      final isBeforeExit = bar.tradingDate.isBefore(trade.exitDate);
      final isExitDate = bar.tradingDate.isAtSameMomentAs(trade.exitDate);

      if (isEntryOrLater && isBeforeExit) {
        final units = settledEquity / trade.totalEntryCost;
        strategyValue = _isValidPrice(bar.close)
            ? units * bar.close
            : settledEquity;
      } else if (isExitDate) {
        settledEquity *= 1 + trade.netReturnRate;
        strategyValue = settledEquity;
        tradeIndex++;
      }
    }

    final benchmarkValue = _isValidPrice(bar.close)
        ? bar.close / benchmarkStartPrice
        : points.isEmpty
        ? 1.0
        : points.last.benchmarkValue;

    points.add(
      QuantBacktestEquityPoint(
        date: bar.tradingDate,
        strategyValue: strategyValue,
        benchmarkValue: benchmarkValue,
      ),
    );
  }

  return points;
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
