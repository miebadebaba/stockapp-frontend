import 'quant_factor_backtest.dart';
import 'selected_stock.dart';

class QuantMarketBacktestCostProfile {
  const QuantMarketBacktestCostProfile({
    required this.market,
    required this.costSettings,
    required this.buyCostLabel,
    required this.sellCostLabel,
    required this.description,
  });

  final QuantMarket market;
  final QuantBacktestCostSettings costSettings;
  final String buyCostLabel;
  final String sellCostLabel;
  final String description;

  String get marketLabel => market.label;

  String get rateSummary {
    return '佣金双向 ${_percent(costSettings.commissionRate)} · '
        '$buyCostLabel ${_percent(costSettings.buyTransactionCostRate)} · '
        '$sellCostLabel ${_percent(costSettings.sellTransactionCostRate)} · '
        '单边滑点 ${_percent(costSettings.slippageRate)}';
  }

  String get defaultAssumptionText => '$description 默认参数：$rateSummary';

  static QuantMarketBacktestCostProfile forMarket(QuantMarket market) {
    return switch (market) {
      QuantMarket.aShare => const QuantMarketBacktestCostProfile(
        market: QuantMarket.aShare,
        costSettings: QuantBacktestCostSettings(
          commissionRate: 0.0003,
          buyTransactionCostRate: 0,
          sellTransactionCostRate: 0.0005,
          slippageRate: 0.0005,
        ),
        buyCostLabel: '买入税费',
        sellCostLabel: '卖出印花税',
        description: 'A股估算：佣金双向收取，印花税仅卖出时收取。',
      ),
      QuantMarket.hongKong => const QuantMarketBacktestCostProfile(
        market: QuantMarket.hongKong,
        costSettings: QuantBacktestCostSettings(
          commissionRate: 0.0003,
          buyTransactionCostRate: 0.001085,
          sellTransactionCostRate: 0.001085,
          slippageRate: 0.0008,
        ),
        buyCostLabel: '买入交易税费',
        sellCostLabel: '卖出交易税费',
        description: '港股估算：佣金及印花税、交易费等费用均按双向计算。',
      ),
      QuantMarket.unitedStates => const QuantMarketBacktestCostProfile(
        market: QuantMarket.unitedStates,
        costSettings: QuantBacktestCostSettings(
          commissionRate: 0,
          buyTransactionCostRate: 0,
          sellTransactionCostRate: 0.0000278,
          slippageRate: 0.0003,
        ),
        buyCostLabel: '买入监管费',
        sellCostLabel: '卖出监管费',
        description: '美股估算：默认零佣金，并估算卖出监管费和成交滑点。',
      ),
    };
  }
}

String _percent(double rate) {
  final value = (rate * 100).toStringAsFixed(3);
  return '${value.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')}%';
}
