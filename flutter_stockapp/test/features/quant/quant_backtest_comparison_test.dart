import 'package:flutter_stockapp/features/quant/quant_backtest_comparison.dart';
import 'package:flutter_stockapp/features/quant/quant_backtest_parameters.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_backtest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuantBacktestComparisonResult', () {
    test('零交易策略不参与最佳收益和最低回撤评选', () {
      final noTradeItem = _buildItem(id: 'conservative', label: '稳健策略');

      final balancedItem = _buildItem(
        id: 'balanced',
        label: '均衡策略',
        exitPrice: 90,
      );

      final activeItem = _buildItem(id: 'active', label: '积极策略', exitPrice: 95);

      final result = QuantBacktestComparisonResult(
        items: [noTradeItem, balancedItem, activeItem],
      );

      expect(result.bestReturnItem, same(activeItem));
      expect(result.lowestDrawdownItem, same(activeItem));
    });

    test('所有策略都没有交易时不生成最佳结果', () {
      final result = QuantBacktestComparisonResult(
        items: [
          _buildItem(id: 'conservative', label: '稳健策略'),
          _buildItem(id: 'balanced', label: '均衡策略'),
        ],
      );

      expect(result.bestReturnItem, isNull);
      expect(result.lowestDrawdownItem, isNull);
    });

    test('默认提供稳健、均衡和积极三种策略', () {
      final cases = defaultQuantBacktestComparisonCases();

      expect(cases, hasLength(3));
      expect(cases.map((item) => item.id), [
        'conservative',
        'balanced',
        'active',
      ]);
      expect(cases[0].parameters.signalThreshold, 70);
      expect(cases[1].parameters.signalThreshold, 60);
      expect(cases[2].parameters.signalThreshold, 50);
    });
  });
}

QuantBacktestComparisonItem _buildItem({
  required String id,
  required String label,
  double? exitPrice,
}) {
  const costs = QuantBacktestCostSettings(
    commissionRate: 0,
    stampDutyRate: 0,
    slippageRate: 0,
  );

  final trades = exitPrice == null
      ? const <QuantBacktestTrade>[]
      : [
          QuantBacktestTrade(
            entryDate: DateTime(2026, 1, 1),
            exitDate: DateTime(2026, 1, 2),
            entryPrice: 100,
            exitPrice: exitPrice,
            signalScore: 70,
            costSettings: costs,
          ),
        ];

  return QuantBacktestComparisonItem(
    caseDefinition: QuantBacktestComparisonCase(
      id: id,
      label: label,
      description: '测试策略',
      parameters: const QuantBacktestParameters(costSettings: costs),
    ),
    result: QuantFactorBacktestResult(
      trades: trades,
      signalThreshold: 60,
      holdingPeriod: 5,
      minimumLookback: 35,
      costSettings: costs,
    ),
  );
}
