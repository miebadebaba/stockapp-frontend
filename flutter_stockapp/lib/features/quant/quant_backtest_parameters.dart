import 'quant_factor_backtest.dart';

class QuantBacktestParameters {
  const QuantBacktestParameters({
    this.signalThreshold = 60,
    this.holdingPeriod = 5,
    this.minimumLookback = 35,
    this.costSettings = const QuantBacktestCostSettings(),
  });

  /// 产生买入信号所需的最低因子分，范围为 0～100。
  final double signalThreshold;

  /// 信号产生后持有的交易日数量。
  final int holdingPeriod;

  /// 计算信号前至少需要的历史交易日数量。
  final int minimumLookback;

  /// 回测使用的佣金、印花税和滑点设置。
  final QuantBacktestCostSettings costSettings;

  QuantBacktestParameters copyWith({
    double? signalThreshold,
    int? holdingPeriod,
    int? minimumLookback,
    QuantBacktestCostSettings? costSettings,
  }) {
    return QuantBacktestParameters(
      signalThreshold: signalThreshold ?? this.signalThreshold,
      holdingPeriod: holdingPeriod ?? this.holdingPeriod,
      minimumLookback: minimumLookback ?? this.minimumLookback,
      costSettings: costSettings ?? this.costSettings,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QuantBacktestParameters &&
        other.signalThreshold == signalThreshold &&
        other.holdingPeriod == holdingPeriod &&
        other.minimumLookback == minimumLookback &&
        other.costSettings.commissionRate == costSettings.commissionRate &&
        other.costSettings.stampDutyRate == costSettings.stampDutyRate &&
        other.costSettings.slippageRate == costSettings.slippageRate;
  }

  @override
  int get hashCode {
    return Object.hash(
      signalThreshold,
      holdingPeriod,
      minimumLookback,
      costSettings.commissionRate,
      costSettings.stampDutyRate,
      costSettings.slippageRate,
    );
  }
}
