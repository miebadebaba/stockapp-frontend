import 'quant_backtest_parameters.dart';
import 'quant_factor_backtest.dart';
import 'quant_factor_score.dart';
import 'quant_factor_score_calculator.dart';
import 'quant_historical_analysis_builder.dart';
import 'stock_daily_bar.dart';

QuantFactorBacktestResult calculateQuantFactorBacktest({
  required String symbol,
  required List<StockDailyBar> bars,
  double? signalThreshold,
  int? holdingPeriod,
  int? minimumLookback,
  QuantBacktestCostSettings? costSettings,
  QuantBacktestParameters? parameters,
}) {
  final effectiveParameters =
      parameters ??
      QuantBacktestParameters(
        signalThreshold: signalThreshold ?? 60,
        holdingPeriod: holdingPeriod ?? 5,
        minimumLookback: minimumLookback ?? 35,
        costSettings: costSettings ?? const QuantBacktestCostSettings(),
      );

  final effectiveSignalThreshold = effectiveParameters.signalThreshold;
  final effectiveHoldingPeriod = effectiveParameters.holdingPeriod;
  final effectiveMinimumLookback = effectiveParameters.minimumLookback;
  final effectiveCostSettings = effectiveParameters.costSettings;

  if (effectiveSignalThreshold < 0 || effectiveSignalThreshold > 100) {
    throw ArgumentError.value(
      effectiveSignalThreshold,
      'signalThreshold',
      '信号阈值必须在 0～100 之间',
    );
  }

  if (effectiveHoldingPeriod <= 0) {
    throw ArgumentError.value(
      effectiveHoldingPeriod,
      'holdingPeriod',
      '持有周期必须大于 0',
    );
  }

  if (effectiveMinimumLookback < 35) {
    throw ArgumentError.value(
      effectiveMinimumLookback,
      'minimumLookback',
      '观察窗口不能少于 35 个交易日',
    );
  }

  if (effectiveCostSettings.commissionRate < 0 ||
      effectiveCostSettings.stampDutyRate < 0 ||
      effectiveCostSettings.slippageRate < 0 ||
      effectiveCostSettings.commissionRate >= 1 ||
      effectiveCostSettings.stampDutyRate >= 1 ||
      effectiveCostSettings.slippageRate >= 1) {
    throw ArgumentError.value(
      effectiveCostSettings,
      'costSettings',
      '交易成本率必须在 0～1 之间',
    );
  }

  final orderedBars = [...bars]
    ..sort((left, right) => left.tradingDate.compareTo(right.tradingDate));

  final trades = <QuantBacktestTrade>[];

  final factorTrades = <String, List<QuantBacktestTrade>>{
    'trend': [],
    'momentum': [],
    'volume': [],
  };

  final factorNextAvailableIndex = <String, int>{
    'trend': effectiveMinimumLookback - 1,
    'momentum': effectiveMinimumLookback - 1,
    'volume': effectiveMinimumLookback - 1,
  };

  var signalIndex = effectiveMinimumLookback - 1;

  while (signalIndex < orderedBars.length) {
    final entryIndex = signalIndex + 1;
    final exitIndex = entryIndex + effectiveHoldingPeriod - 1;

    if (exitIndex >= orderedBars.length) {
      break;
    }

    final historicalBars = List<StockDailyBar>.unmodifiable(
      orderedBars.sublist(0, signalIndex + 1),
    );

    final analysis = buildHistoricalQuantStockAnalysis(
      symbol: symbol,
      bars: historicalBars,
    );

    final factorScore = calculateQuantFactorScore(analysis: analysis);

    final signalScore = factorScore.riskAdjustedScore;

    final entryBar = orderedBars[entryIndex];
    final exitBar = orderedBars[exitIndex];

    if (!_isValidPrice(entryBar.open) || !_isValidPrice(exitBar.close)) {
      signalIndex++;
      continue;
    }

    for (final factor in factorScore.factors) {
      final factorId = factor.id;
      final nextAvailableIndex = factorNextAvailableIndex[factorId];
      final factorTradeList = factorTrades[factorId];

      if (nextAvailableIndex == null ||
          factorTradeList == null ||
          factor.signal == QuantFactorSignal.unavailable ||
          factor.score < effectiveSignalThreshold ||
          signalIndex < nextAvailableIndex) {
        continue;
      }

      factorTradeList.add(
        QuantBacktestTrade(
          entryDate: entryBar.tradingDate,
          exitDate: exitBar.tradingDate,
          entryPrice: entryBar.open,
          exitPrice: exitBar.close,
          signalScore: factor.score,
          costSettings: effectiveCostSettings,
        ),
      );

      factorNextAvailableIndex[factorId] = exitIndex;
    }

    if (signalScore == null || signalScore < effectiveSignalThreshold) {
      signalIndex++;
      continue;
    }

    final trade = QuantBacktestTrade(
      entryDate: entryBar.tradingDate,
      exitDate: exitBar.tradingDate,
      entryPrice: entryBar.open,
      exitPrice: exitBar.close,
      signalScore: signalScore,
      costSettings: effectiveCostSettings,
    );

    trades.add(trade);

    // 当前交易结束前不再产生新交易，避免持仓时间重叠。
    signalIndex = exitIndex;
  }

  final equityCurve = _buildEquityCurve(
    bars: orderedBars,
    trades: trades,
    minimumLookback: effectiveMinimumLookback,
  );

  return QuantFactorBacktestResult(
    trades: List.unmodifiable(trades),
    signalThreshold: effectiveSignalThreshold,
    holdingPeriod: effectiveHoldingPeriod,
    minimumLookback: effectiveMinimumLookback,
    costSettings: effectiveCostSettings,
    equityCurve: List.unmodifiable(equityCurve),
    factorPerformances: List.unmodifiable([
      QuantFactorHistoricalPerformance(
        factorId: 'trend',
        label: '趋势因子',
        trades: List.unmodifiable(factorTrades['trend']!),
      ),
      QuantFactorHistoricalPerformance(
        factorId: 'momentum',
        label: '动量因子',
        trades: List.unmodifiable(factorTrades['momentum']!),
      ),
      QuantFactorHistoricalPerformance(
        factorId: 'volume',
        label: '量价因子',
        trades: List.unmodifiable(factorTrades['volume']!),
      ),
    ]),
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

bool _isValidPrice(double value) {
  return value.isFinite && value > 0;
}
