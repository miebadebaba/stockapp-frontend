import 'package:flutter_stockapp/features/quant/quant_market_backtest_costs.dart';
import 'package:flutter_stockapp/features/quant/selected_stock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('A股默认成本仅在卖出时收取印花税', () {
    final profile = QuantMarketBacktestCostProfile.forMarket(
      QuantMarket.aShare,
    );

    expect(profile.costSettings.commissionRate, 0.0003);
    expect(profile.costSettings.buyTransactionCostRate, 0);
    expect(profile.costSettings.sellTransactionCostRate, 0.0005);
    expect(profile.costSettings.slippageRate, 0.0005);
  });

  test('港股默认成本在买卖两侧收取市场税费', () {
    final profile = QuantMarketBacktestCostProfile.forMarket(
      QuantMarket.hongKong,
    );

    expect(profile.costSettings.commissionRate, 0.0003);
    expect(profile.costSettings.buyTransactionCostRate, 0.001085);
    expect(profile.costSettings.sellTransactionCostRate, 0.001085);
    expect(profile.costSettings.slippageRate, 0.0008);
  });

  test('美股默认零佣金并在卖出侧估算监管费', () {
    final profile = QuantMarketBacktestCostProfile.forMarket(
      QuantMarket.unitedStates,
    );

    expect(profile.costSettings.commissionRate, 0);
    expect(profile.costSettings.buyTransactionCostRate, 0);
    expect(profile.costSettings.sellTransactionCostRate, 0.0000278);
    expect(profile.costSettings.slippageRate, 0.0003);
  });
}
