import 'package:flutter_stockapp/features/quant/quant_factor_backtest.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_backtest_calculator.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateQuantFactorBacktest', () {
    test('信号产生后在下一交易日开盘买入并按持有周期卖出', () {
      final bars = _buildBars(50);

      final result = calculateQuantFactorBacktest(
        symbol: '600519',
        bars: bars,
        signalThreshold: 0,
        holdingPeriod: 5,
        minimumLookback: 35,
      );

      expect(result.tradeCount, 3);

      final firstTrade = result.trades.first;

      expect(firstTrade.entryDate, bars[35].tradingDate);
      expect(firstTrade.exitDate, bars[39].tradingDate);
      expect(firstTrade.entryPrice, bars[35].open);
      expect(firstTrade.exitPrice, bars[39].close);
      expect(firstTrade.signalScore, inInclusiveRange(0, 100));
      expect(
        firstTrade.netReturnRate,
        lessThan(firstTrade.grossReturnRate),
      );
    });

    test('连续信号不会生成时间重叠的交易', () {
      final result = calculateQuantFactorBacktest(
        symbol: '600519',
        bars: _buildBars(55),
        signalThreshold: 0,
        holdingPeriod: 5,
        minimumLookback: 35,
      );

      expect(result.tradeCount, greaterThan(1));

      for (var index = 1; index < result.trades.length; index++) {
        final previousTrade = result.trades[index - 1];
        final currentTrade = result.trades[index];

        expect(
          currentTrade.entryDate.isAfter(previousTrade.exitDate),
          isTrue,
        );
      }
    });

    test('将指定成本配置传给每笔交易和最终结果', () {
      const costs = QuantBacktestCostSettings(
        commissionRate: 0.001,
        stampDutyRate: 0.002,
        slippageRate: 0.003,
      );

      final result = calculateQuantFactorBacktest(
        symbol: '600519',
        bars: _buildBars(50),
        signalThreshold: 0,
        holdingPeriod: 5,
        minimumLookback: 35,
        costSettings: costs,
      );

      expect(result.tradeCount, greaterThan(0));
      expect(result.costSettings.commissionRate, 0.001);
      expect(result.costSettings.stampDutyRate, 0.002);
      expect(result.costSettings.slippageRate, 0.003);

      for (final trade in result.trades) {
        expect(trade.costSettings.commissionRate, 0.001);
        expect(trade.costSettings.stampDutyRate, 0.002);
        expect(trade.costSettings.slippageRate, 0.003);
      }
    });

    test('阈值过高时不生成交易', () {
      final result = calculateQuantFactorBacktest(
        symbol: '600519',
        bars: _buildBars(50),
        signalThreshold: 100,
        holdingPeriod: 5,
        minimumLookback: 35,
      );

      expect(result.tradeCount, 0);
      expect(result.winRate, 0);
      expect(result.averageReturn, 0);
      expect(result.averageGrossReturn, 0);
      expect(result.averageCostRate, 0);
      expect(result.cumulativeReturn, 0);
      expect(result.grossCumulativeReturn, 0);
      expect(result.cumulativeCostImpact, 0);
      expect(result.maximumDrawdown, 0);
    });

    test('拒绝无效的回测参数和交易成本', () {
      final bars = _buildBars(50);

      expect(
        () => calculateQuantFactorBacktest(
          symbol: '600519',
          bars: bars,
          signalThreshold: 101,
        ),
        throwsArgumentError,
      );

      expect(
        () => calculateQuantFactorBacktest(
          symbol: '600519',
          bars: bars,
          holdingPeriod: 0,
        ),
        throwsArgumentError,
      );

      expect(
        () => calculateQuantFactorBacktest(
          symbol: '600519',
          bars: bars,
          minimumLookback: 34,
        ),
        throwsArgumentError,
      );

      expect(
        () => calculateQuantFactorBacktest(
          symbol: '600519',
          bars: bars,
          costSettings: const QuantBacktestCostSettings(
            commissionRate: -0.001,
          ),
        ),
        throwsArgumentError,
      );

      expect(
        () => calculateQuantFactorBacktest(
          symbol: '600519',
          bars: bars,
          costSettings: const QuantBacktestCostSettings(
            slippageRate: 1,
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('QuantBacktestTrade', () {
    test('正确计算滑点、交易成本和净收益', () {
      const costs = QuantBacktestCostSettings(
        commissionRate: 0.001,
        stampDutyRate: 0.001,
        slippageRate: 0.001,
      );

      final trade = QuantBacktestTrade(
        entryDate: DateTime(2026, 1, 1),
        exitDate: DateTime(2026, 1, 5),
        entryPrice: 100,
        exitPrice: 110,
        signalScore: 70,
        costSettings: costs,
      );

      final expectedEntryCost = 100 * 1.001 * 1.001;
      final expectedExitProceeds = 110 * 0.999 * 0.998;
      final expectedNetReturn =
          expectedExitProceeds / expectedEntryCost - 1;

      expect(trade.executedEntryPrice, closeTo(100.1, 0.000001));
      expect(trade.executedExitPrice, closeTo(109.89, 0.000001));
      expect(trade.grossReturnRate, closeTo(0.10, 0.000001));
      expect(trade.totalEntryCost, closeTo(expectedEntryCost, 0.000001));
      expect(
        trade.netExitProceeds,
        closeTo(expectedExitProceeds, 0.000001),
      );
      expect(
        trade.netReturnRate,
        closeTo(expectedNetReturn, 0.000001),
      );
      expect(trade.netReturnRate, lessThan(trade.grossReturnRate));
      expect(
        trade.estimatedCostRate,
        closeTo(0.10 - expectedNetReturn, 0.000001),
      );
      expect(trade.returnRate, trade.netReturnRate);
      expect(trade.isWinning, isTrue);
    });
  });

  group('QuantFactorBacktestResult', () {
    test('零成本时保持原有收益统计结果', () {
      const zeroCosts = QuantBacktestCostSettings(
        commissionRate: 0,
        stampDutyRate: 0,
        slippageRate: 0,
      );

      final result = QuantFactorBacktestResult(
        trades: [
          QuantBacktestTrade(
            entryDate: DateTime(2026, 1, 1),
            exitDate: DateTime(2026, 1, 5),
            entryPrice: 100,
            exitPrice: 110,
            signalScore: 70,
            costSettings: zeroCosts,
          ),
          QuantBacktestTrade(
            entryDate: DateTime(2026, 1, 6),
            exitDate: DateTime(2026, 1, 10),
            entryPrice: 100,
            exitPrice: 95,
            signalScore: 65,
            costSettings: zeroCosts,
          ),
        ],
        signalThreshold: 60,
        holdingPeriod: 5,
        minimumLookback: 35,
        costSettings: zeroCosts,
      );

      expect(result.tradeCount, 2);
      expect(result.winRate, 0.5);
      expect(result.averageReturn, closeTo(0.025, 0.000001));
      expect(result.averageGrossReturn, closeTo(0.025, 0.000001));
      expect(result.averageCostRate, closeTo(0, 0.000001));
      expect(result.cumulativeReturn, closeTo(0.045, 0.000001));
      expect(result.grossCumulativeReturn, closeTo(0.045, 0.000001));
      expect(result.cumulativeCostImpact, closeTo(0, 0.000001));
      expect(result.maximumDrawdown, closeTo(0.05, 0.000001));
    });

    test('默认成本会降低平均收益和累计收益', () {
      final trades = [
        QuantBacktestTrade(
          entryDate: DateTime(2026, 1, 1),
          exitDate: DateTime(2026, 1, 5),
          entryPrice: 100,
          exitPrice: 110,
          signalScore: 70,
        ),
        QuantBacktestTrade(
          entryDate: DateTime(2026, 1, 6),
          exitDate: DateTime(2026, 1, 10),
          entryPrice: 100,
          exitPrice: 105,
          signalScore: 65,
        ),
      ];

      final result = QuantFactorBacktestResult(
        trades: trades,
        signalThreshold: 60,
        holdingPeriod: 5,
        minimumLookback: 35,
      );

      expect(
        result.averageReturn,
        lessThan(result.averageGrossReturn),
      );
      expect(
        result.cumulativeReturn,
        lessThan(result.grossCumulativeReturn),
      );
      expect(result.averageCostRate, greaterThan(0));
      expect(result.cumulativeCostImpact, greaterThan(0));
    });
  });
}

List<StockDailyBar> _buildBars(int count) {
  return List.generate(count, (index) {
    final close = 100.0 + index * 0.8;

    return StockDailyBar(
      tradingDate: DateTime(2026, 1, 1).add(Duration(days: index)),
      open: close - 0.2,
      high: close + 0.5,
      low: close - 0.5,
      close: close,
      volume: 1000 + index * 20,
    );
  });
}
