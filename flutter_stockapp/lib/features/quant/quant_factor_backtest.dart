class QuantBacktestTrade {
  const QuantBacktestTrade({
    required this.entryDate,
    required this.exitDate,
    required this.entryPrice,
    required this.exitPrice,
    required this.signalScore,
  });

  final DateTime entryDate;
  final DateTime exitDate;
  final double entryPrice;
  final double exitPrice;
  final double signalScore;

  /// 单笔收益率，例如 0.05 表示盈利 5%。
  double get returnRate => (exitPrice - entryPrice) / entryPrice;

  bool get isWinning => returnRate > 0;
}

class QuantFactorBacktestResult {
  const QuantFactorBacktestResult({
    required this.trades,
    required this.signalThreshold,
    required this.holdingPeriod,
    required this.minimumLookback,
  });

  final List<QuantBacktestTrade> trades;
  final double signalThreshold;
  final int holdingPeriod;
  final int minimumLookback;

  int get tradeCount => trades.length;

  double get winRate {
    if (trades.isEmpty) {
      return 0;
    }

    final winningTrades = trades.where((trade) => trade.isWinning).length;
    return winningTrades / trades.length;
  }

  double get averageReturn {
    if (trades.isEmpty) {
      return 0;
    }

    final total = trades.fold<double>(
      0,
      (sum, trade) => sum + trade.returnRate,
    );

    return total / trades.length;
  }

  double get cumulativeReturn {
    var equity = 1.0;

    for (final trade in trades) {
      equity *= 1 + trade.returnRate;
    }

    return equity - 1;
  }

  double get maximumDrawdown {
    var equity = 1.0;
    var peak = equity;
    var maximumDrawdown = 0.0;

    for (final trade in trades) {
      equity *= 1 + trade.returnRate;

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
