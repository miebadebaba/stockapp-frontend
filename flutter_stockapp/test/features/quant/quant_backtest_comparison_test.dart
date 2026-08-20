import 'package:flutter_stockapp/features/quant/quant_backtest_comparison.dart';
import 'package:flutter_stockapp/features/quant/quant_backtest_overfitting.dart';
import 'package:flutter_stockapp/features/quant/quant_backtest_parameters.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_backtest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuantBacktestComparisonResult', () {
    test('样本不足的策略不参与参数比较评选', () {
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

      expect(result.bestReturnItem, isNull);
      expect(result.lowestDrawdownItem, isNull);
      expect(result.balancedItem, isNull);
    });

    test('样本充足的策略参与收益、回撤和综合参考评选', () {
      final returnFirst = _buildItem(
        id: 'return-first',
        label: '收益优先策略',
        exitPrices: [120, 90, 120, 100, 100],
      );
      final lowDrawdown = _buildItem(
        id: 'low-drawdown',
        label: '低回撤策略',
        exitPrices: [104, 104, 104, 104, 104],
      );
      final weaker = _buildItem(
        id: 'weaker',
        label: '低效策略',
        exitPrices: [95, 95, 95, 95, 95],
      );
      final result = QuantBacktestComparisonResult(
        items: [returnFirst, lowDrawdown, weaker],
      );

      expect(result.bestReturnItem, same(returnFirst));
      expect(result.lowestDrawdownItem, same(lowDrawdown));
      expect(result.balancedItem, same(lowDrawdown));
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

    test('三种策略继承传入的市场成本', () {
      const marketCosts = QuantBacktestCostSettings(
        commissionRate: 0,
        buyTransactionCostRate: 0.001,
        sellTransactionCostRate: 0.001,
        slippageRate: 0.0008,
      );

      final cases = defaultQuantBacktestComparisonCases(
        costSettings: marketCosts,
      );

      for (final item in cases) {
        expect(item.parameters.costSettings, same(marketCosts));
      }
    });

    test('参数样本不足时不判断过拟合风险', () {
      final assessment = assessQuantBacktestOverfitting(
        QuantBacktestComparisonResult(
          items: [
            _buildItem(
              id: 'first',
              label: '第一组',
              exitPrices: [110, 110, 110, 110, 110],
            ),
            _buildItem(id: 'limited', label: '样本有限组', exitPrices: [95]),
          ],
        ),
      );

      expect(assessment.risk, QuantBacktestOverfitRisk.insufficientSample);
      expect(assessment.referenceableCount, 1);
    });

    test('收益差距大且最优组合样本偏少时提示较高过拟合风险', () {
      final highReturn = _buildItem(
        id: 'high-return',
        label: '高收益策略',
        exitPrices: [120, 120, 120, 120, 120],
      );
      final steady = _buildItem(
        id: 'steady',
        label: '稳定策略',
        exitPrices: [102, 102, 102, 102, 102, 102, 102, 102, 102, 102],
      );
      final assessment = assessQuantBacktestOverfitting(
        QuantBacktestComparisonResult(items: [highReturn, steady]),
      );

      expect(assessment.risk, QuantBacktestOverfitRisk.high);
      expect(assessment.bestReturnItem, same(highReturn));
      expect(assessment.secondBestReturnItem, same(steady));
      expect(assessment.bestHasLimitedSample, isTrue);
      expect(assessment.bestReturnAdvantage, greaterThan(0.08));
    });

    test('参数表现接近且样本充足时不提示明显过拟合风险', () {
      final first = _buildItem(
        id: 'first',
        label: '第一组',
        exitPrices: [104, 104, 104, 104, 104, 104, 104, 104, 104, 104],
      );
      final second = _buildItem(
        id: 'second',
        label: '第二组',
        exitPrices: [
          103.9,
          103.9,
          103.9,
          103.9,
          103.9,
          103.9,
          103.9,
          103.9,
          103.9,
          103.9,
        ],
      );
      final assessment = assessQuantBacktestOverfitting(
        QuantBacktestComparisonResult(items: [first, second]),
      );

      expect(assessment.risk, QuantBacktestOverfitRisk.low);
      expect(assessment.bestHasLimitedSample, isFalse);
      expect(assessment.bestReturnAdvantage, lessThan(0.04));
    });
  });
}

QuantBacktestComparisonItem _buildItem({
  required String id,
  required String label,
  double? exitPrice,
  List<double>? exitPrices,
}) {
  const costs = QuantBacktestCostSettings(
    commissionRate: 0,
    stampDutyRate: 0,
    slippageRate: 0,
  );

  final prices = exitPrices ?? (exitPrice == null ? const [] : [exitPrice]);
  final trades = List.generate(
    prices.length,
    (index) => QuantBacktestTrade(
      entryDate: DateTime(2026, 1, index * 2 + 1),
      exitDate: DateTime(2026, 1, index * 2 + 2),
      entryPrice: 100,
      exitPrice: prices[index],
      signalScore: 70,
      costSettings: costs,
    ),
  );

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
