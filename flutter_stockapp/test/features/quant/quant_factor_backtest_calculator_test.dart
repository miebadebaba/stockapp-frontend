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

        expect(currentTrade.entryDate.isAfter(previousTrade.exitDate), isTrue);
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
      expect(result.cumulativeReturn, 0);
      expect(result.maximumDrawdown, 0);
    });

    test('拒绝无效的回测参数', () {
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
    });
  });

  group('QuantFactorBacktestResult', () {
    test('正确统计胜率、平均收益、累计收益和最大回撤', () {
      final result = QuantFactorBacktestResult(
        trades: [
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
            exitPrice: 95,
            signalScore: 65,
          ),
        ],
        signalThreshold: 60,
        holdingPeriod: 5,
        minimumLookback: 35,
      );

      expect(result.tradeCount, 2);
      expect(result.winRate, 0.5);
      expect(result.averageReturn, closeTo(0.025, 0.000001));
      expect(result.cumulativeReturn, closeTo(0.045, 0.000001));
      expect(result.maximumDrawdown, closeTo(0.05, 0.000001));
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
