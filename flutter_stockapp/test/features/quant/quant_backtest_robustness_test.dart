import 'package:flutter_stockapp/features/quant/quant_backtest_parameters.dart';
import 'package:flutter_stockapp/features/quant/quant_backtest_robustness.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_backtest.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateQuantBacktestRobustness', () {
    test('按时间顺序拆分连续阶段，并保留相同参数', () {
      final bars = _buildBars(150);
      const parameters = QuantBacktestParameters(
        signalThreshold: 0,
        holdingPeriod: 5,
        minimumLookback: 35,
      );

      final result = calculateQuantBacktestRobustness(
        symbol: '600519',
        bars: bars,
        parameters: parameters,
      );

      expect(result.windows, hasLength(3));
      expect(result.windows.map((window) => window.label), [
        '阶段 1',
        '阶段 2',
        '阶段 3',
      ]);
      expect(result.windows.first.result.backtestStartDate, isNotNull);
      expect(
        result.windows.first.result.backtestEndDate!.isBefore(
          result.windows[1].result.backtestStartDate!,
        ),
        isTrue,
      );
      expect(
        result.windows.every(
          (window) =>
              window.result.signalThreshold == parameters.signalThreshold,
        ),
        isTrue,
      );
    });

    test('历史数据不足时不生成验证阶段', () {
      const parameters = QuantBacktestParameters(
        holdingPeriod: 5,
        minimumLookback: 35,
      );

      final result = calculateQuantBacktestRobustness(
        symbol: '600519',
        bars: _buildBars(40),
        parameters: parameters,
      );

      expect(result.windows, isEmpty);
      expect(result.level, QuantBacktestRobustnessLevel.insufficient);
    });

    test('样本充足且均跑赢基准时标记为稳定', () {
      final result = QuantBacktestRobustnessResult(
        windows: [
          _window('阶段 1', exitPrice: 110, benchmarkValue: 1.05),
          _window('阶段 2', exitPrice: 108, benchmarkValue: 1.03),
        ],
      );

      expect(result.level, QuantBacktestRobustnessLevel.stable);
    });

    test('样本充足但部分阶段落后基准时标记为阶段差异较大', () {
      final result = QuantBacktestRobustnessResult(
        windows: [
          _window('阶段 1', exitPrice: 110, benchmarkValue: 1.05),
          _window('阶段 2', exitPrice: 101, benchmarkValue: 1.1),
        ],
      );

      expect(result.level, QuantBacktestRobustnessLevel.mixed);
    });
  });
}

QuantBacktestWindowResult _window(
  String label, {
  required double exitPrice,
  required double benchmarkValue,
}) {
  final trades = List.generate(
    QuantBacktestRobustnessResult.minimumTradeCount,
    (index) => QuantBacktestTrade(
      entryDate: DateTime(2026, 1, index * 2 + 1),
      exitDate: DateTime(2026, 1, index * 2 + 2),
      entryPrice: 100,
      exitPrice: exitPrice,
      signalScore: 70,
      costSettings: const QuantBacktestCostSettings(
        commissionRate: 0,
        stampDutyRate: 0,
        slippageRate: 0,
      ),
    ),
  );

  return QuantBacktestWindowResult(
    label: label,
    result: QuantFactorBacktestResult(
      trades: trades,
      signalThreshold: 60,
      holdingPeriod: 5,
      minimumLookback: 35,
      equityCurve: [
        QuantBacktestEquityPoint(
          date: DateTime(2026, 1, 1),
          strategyValue: 1,
          benchmarkValue: 1,
        ),
        QuantBacktestEquityPoint(
          date: DateTime(2026, 1, 10),
          strategyValue: 1,
          benchmarkValue: benchmarkValue,
        ),
      ],
    ),
  );
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
