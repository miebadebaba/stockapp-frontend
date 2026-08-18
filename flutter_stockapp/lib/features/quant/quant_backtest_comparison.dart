import 'quant_backtest_parameters.dart';
import 'quant_factor_backtest.dart';
import 'quant_factor_backtest_calculator.dart';
import 'stock_daily_bar.dart';

class QuantBacktestComparisonCase {
  const QuantBacktestComparisonCase({
    required this.id,
    required this.label,
    required this.description,
    required this.parameters,
  });

  final String id;
  final String label;
  final String description;
  final QuantBacktestParameters parameters;
}

class QuantBacktestComparisonItem {
  const QuantBacktestComparisonItem({
    required this.caseDefinition,
    required this.result,
  });

  final QuantBacktestComparisonCase caseDefinition;
  final QuantFactorBacktestResult result;

  int get tradeCount => result.tradeCount;

  double get cumulativeReturn => result.cumulativeReturn;

  double get winRate => result.winRate;

  double get maximumDrawdown => result.maximumDrawdown;

  double get benchmarkReturn => result.benchmarkReturn;

  double get excessReturn => result.excessReturn;
}

class QuantBacktestComparisonResult {
  const QuantBacktestComparisonResult({required this.items});

  final List<QuantBacktestComparisonItem> items;

  QuantBacktestComparisonItem? get bestReturnItem {
    final comparableItems = items.where((item) => item.tradeCount > 0).toList();

    if (comparableItems.isEmpty) {
      return null;
    }

    return comparableItems.reduce(
      (current, next) =>
          next.cumulativeReturn > current.cumulativeReturn ? next : current,
    );
  }

  QuantBacktestComparisonItem? get lowestDrawdownItem {
    final comparableItems = items.where((item) => item.tradeCount > 0).toList();

    if (comparableItems.isEmpty) {
      return null;
    }

    return comparableItems.reduce(
      (current, next) =>
          next.maximumDrawdown < current.maximumDrawdown ? next : current,
    );
  }
}

QuantBacktestComparisonResult calculateQuantBacktestComparison({
  required String symbol,
  required List<StockDailyBar> bars,
  required List<QuantBacktestComparisonCase> cases,
}) {
  if (cases.isEmpty) {
    throw ArgumentError.value(cases, 'cases', '至少需要一个回测参数组合');
  }

  final ids = <String>{};
  for (final item in cases) {
    if (item.id.trim().isEmpty) {
      throw ArgumentError.value(item.id, 'id', '参数组合 ID 不能为空');
    }

    if (!ids.add(item.id)) {
      throw ArgumentError.value(item.id, 'id', '参数组合 ID 不能重复');
    }
  }

  final items = cases.map((caseDefinition) {
    final result = calculateQuantFactorBacktest(
      symbol: symbol,
      bars: bars,
      parameters: caseDefinition.parameters,
    );

    return QuantBacktestComparisonItem(
      caseDefinition: caseDefinition,
      result: result,
    );
  }).toList();

  return QuantBacktestComparisonResult(items: List.unmodifiable(items));
}

List<QuantBacktestComparisonCase> defaultQuantBacktestComparisonCases({
  QuantBacktestCostSettings costSettings = const QuantBacktestCostSettings(),
}) {
  return [
    QuantBacktestComparisonCase(
      id: 'conservative',
      label: '稳健策略',
      description: '较高信号阈值，减少交易次数',
      parameters: QuantBacktestParameters(
        signalThreshold: 70,
        holdingPeriod: 10,
        costSettings: costSettings,
      ),
    ),
    QuantBacktestComparisonCase(
      id: 'balanced',
      label: '均衡策略',
      description: '在信号质量和交易频率之间平衡',
      parameters: QuantBacktestParameters(
        signalThreshold: 60,
        holdingPeriod: 5,
        costSettings: costSettings,
      ),
    ),
    QuantBacktestComparisonCase(
      id: 'active',
      label: '积极策略',
      description: '较低信号阈值，提高信号覆盖率',
      parameters: QuantBacktestParameters(
        signalThreshold: 50,
        holdingPeriod: 3,
        costSettings: costSettings,
      ),
    ),
  ];
}
