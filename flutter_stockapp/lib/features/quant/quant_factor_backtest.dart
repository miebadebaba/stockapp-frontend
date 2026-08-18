class QuantBacktestCostSettings {
  const QuantBacktestCostSettings({
    this.commissionRate = 0.0003,
    this.buyTransactionCostRate = 0,
    double? sellTransactionCostRate,
    double? stampDutyRate,
    this.slippageRate = 0.0005,
  }) : sellTransactionCostRate =
           sellTransactionCostRate ?? stampDutyRate ?? 0.0005;

  /// 单边佣金率，买入和卖出均收取。
  final double commissionRate;

  /// 买入时收取的税费或市场费用。
  final double buyTransactionCostRate;

  /// 卖出时收取的税费或市场费用。
  final double sellTransactionCostRate;

  /// 单边滑点率。
  final double slippageRate;

  /// 兼容原有“卖出印花税”参数。
  double get stampDutyRate => sellTransactionCostRate;

  double get roundTripCommissionRate => commissionRate * 2;
}

class QuantBacktestTrade {
  const QuantBacktestTrade({
    required this.entryDate,
    required this.exitDate,
    required this.entryPrice,
    required this.exitPrice,
    required this.signalScore,
    this.costSettings = const QuantBacktestCostSettings(),
  });

  final DateTime entryDate;
  final DateTime exitDate;

  /// 未计滑点的市场价格。
  final double entryPrice;
  final double exitPrice;

  final double signalScore;
  final QuantBacktestCostSettings costSettings;

  double get executedEntryPrice {
    return entryPrice * (1 + costSettings.slippageRate);
  }

  double get executedExitPrice {
    return exitPrice * (1 - costSettings.slippageRate);
  }

  /// 未扣除交易成本的毛收益率。
  double get grossReturnRate {
    return (exitPrice - entryPrice) / entryPrice;
  }

  /// 买入金额，包括买入佣金和买入滑点。
  double get totalEntryCost {
    return executedEntryPrice *
        (1 + costSettings.commissionRate + costSettings.buyTransactionCostRate);
  }

  /// 卖出所得，扣除卖出佣金、印花税和卖出滑点。
  double get netExitProceeds {
    return executedExitPrice *
        (1 -
            costSettings.commissionRate -
            costSettings.sellTransactionCostRate);
  }

  /// 扣除佣金、印花税和滑点后的净收益率。
  double get netReturnRate {
    return netExitProceeds / totalEntryCost - 1;
  }

  /// 为兼容现有统计逻辑，回测默认使用净收益率。
  double get returnRate => netReturnRate;

  double get estimatedCostRate {
    return grossReturnRate - netReturnRate;
  }

  bool get isWinning => netReturnRate > 0;
}

/// 净值曲线中的一个时间点。
///
/// strategyValue 和 benchmarkValue 都以 1.0 为初始净值。
class QuantBacktestEquityPoint {
  const QuantBacktestEquityPoint({
    required this.date,
    required this.strategyValue,
    required this.benchmarkValue,
  });

  final DateTime date;
  final double strategyValue;
  final double benchmarkValue;
}

/// 单个因子独立发出信号后的历史表现摘要。
///
/// 该结果用于观察因子过去的区分度，不代表未来收益承诺。
class QuantFactorHistoricalPerformance {
  const QuantFactorHistoricalPerformance({
    required this.factorId,
    required this.label,
    required this.trades,
  });

  final String factorId;
  final String label;
  final List<QuantBacktestTrade> trades;

  int get signalCount => trades.length;

  double get winRate {
    if (trades.isEmpty) {
      return 0;
    }

    return trades.where((trade) => trade.isWinning).length / trades.length;
  }

  double get averageReturn {
    if (trades.isEmpty) {
      return 0;
    }

    return trades.fold<double>(
          0,
          (total, trade) => total + trade.netReturnRate,
        ) /
        trades.length;
  }

  double get cumulativeReturn {
    var equity = 1.0;

    for (final trade in trades) {
      equity *= 1 + trade.netReturnRate;
    }

    return equity - 1;
  }

  double get maximumDrawdown {
    var equity = 1.0;
    var peak = equity;
    var maximumDrawdown = 0.0;

    for (final trade in trades) {
      equity *= 1 + trade.netReturnRate;
      if (equity > peak) {
        peak = equity;
      }

      final drawdown = (peak - equity) / peak;
      if (drawdown > maximumDrawdown) {
        maximumDrawdown = drawdown;
      }
    }

    return maximumDrawdown;
  }
}

enum QuantBacktestNoTradeReason {
  insufficientHistory,
  invalidPrices,
  noQualifiedSignal,
}

class QuantFactorBacktestResult {
  const QuantFactorBacktestResult({
    required this.trades,
    required this.signalThreshold,
    required this.holdingPeriod,
    required this.minimumLookback,
    this.costSettings = const QuantBacktestCostSettings(),
    this.equityCurve = const [],
    this.factorPerformances = const [],
    this.evaluatedSignalCount = 0,
    this.invalidPriceCandidateCount = 0,
    this.highestSignalScore,
  });

  final List<QuantBacktestTrade> trades;
  final double signalThreshold;
  final int holdingPeriod;
  final int minimumLookback;
  final QuantBacktestCostSettings costSettings;

  /// 策略净值与买入持有基准净值的对比数据。
  final List<QuantBacktestEquityPoint> equityCurve;

  /// 各单项因子独立发出信号时的历史表现。
  final List<QuantFactorHistoricalPerformance> factorPerformances;

  /// 实际完成因子评分的候选交易日数量。
  final int evaluatedSignalCount;

  /// 因开盘价或收盘价无效而被跳过的候选数量。
  final int invalidPriceCandidateCount;

  /// 回测期间观察到的最高风险调整分。
  final double? highestSignalScore;

  QuantBacktestNoTradeReason? get noTradeReason {
    if (trades.isNotEmpty) {
      return null;
    }

    if (evaluatedSignalCount > 0) {
      return QuantBacktestNoTradeReason.noQualifiedSignal;
    }

    if (invalidPriceCandidateCount > 0) {
      return QuantBacktestNoTradeReason.invalidPrices;
    }

    return QuantBacktestNoTradeReason.insufficientHistory;
  }

  int get tradeCount => trades.length;

  bool get hasEquityComparison => equityCurve.length >= 2;

  double get winRate {
    if (trades.isEmpty) {
      return 0;
    }

    final winningTrades = trades.where((trade) => trade.isWinning).length;
    return winningTrades / trades.length;
  }

  /// 平均净收益率。
  double get averageReturn {
    if (trades.isEmpty) {
      return 0;
    }

    final total = trades.fold<double>(
      0,
      (sum, trade) => sum + trade.netReturnRate,
    );

    return total / trades.length;
  }

  /// 平均毛收益率。
  double get averageGrossReturn {
    if (trades.isEmpty) {
      return 0;
    }

    final total = trades.fold<double>(
      0,
      (sum, trade) => sum + trade.grossReturnRate,
    );

    return total / trades.length;
  }

  /// 每笔交易平均受到的成本影响。
  double get averageCostRate {
    if (trades.isEmpty) {
      return 0;
    }

    final total = trades.fold<double>(
      0,
      (sum, trade) => sum + trade.estimatedCostRate,
    );

    return total / trades.length;
  }

  /// 扣除交易成本后的累计净收益。
  double get cumulativeReturn {
    var equity = 1.0;

    for (final trade in trades) {
      equity *= 1 + trade.netReturnRate;
    }

    return equity - 1;
  }

  /// 未扣除交易成本的累计毛收益。
  double get grossCumulativeReturn {
    var equity = 1.0;

    for (final trade in trades) {
      equity *= 1 + trade.grossReturnRate;
    }

    return equity - 1;
  }

  double get cumulativeCostImpact {
    return grossCumulativeReturn - cumulativeReturn;
  }

  /// 同一回测区间内，买入并持有股票的收益。
  double get benchmarkReturn {
    if (!hasEquityComparison) {
      return 0;
    }

    return equityCurve.last.benchmarkValue - 1;
  }

  /// 策略累计净收益减去基准收益。
  double get excessReturn {
    return cumulativeReturn - benchmarkReturn;
  }

  /// 基于净收益曲线计算最大回撤。
  double get maximumDrawdown {
    var equity = 1.0;
    var peak = equity;
    var maximumDrawdown = 0.0;

    for (final trade in trades) {
      equity *= 1 + trade.netReturnRate;

      if (equity > peak) {
        peak = equity;
      }

      final drawdown = (peak - equity) / peak;
      if (drawdown > maximumDrawdown) {
        maximumDrawdown = drawdown;
      }
    }

    return maximumDrawdown;
  }
}
