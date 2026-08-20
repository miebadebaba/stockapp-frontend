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

  static const minimumReferenceTradeCount = 5;

  final List<QuantBacktestComparisonItem> items;

  List<QuantBacktestComparisonItem> get referenceableItems {
    return items
        .where((item) => item.tradeCount >= minimumReferenceTradeCount)
        .toList();
  }

  QuantBacktestComparisonItem? get bestReturnItem {
    final comparableItems = referenceableItems;

    if (comparableItems.isEmpty) {
      return null;
    }

    return comparableItems.reduce(
      (current, next) =>
          next.cumulativeReturn > current.cumulativeReturn ? next : current,
    );
  }

  QuantBacktestComparisonItem? get lowestDrawdownItem {
    final comparableItems = referenceableItems;

    if (comparableItems.isEmpty) {
      return null;
    }

    return comparableItems.reduce(
      (current, next) =>
          next.maximumDrawdown < current.maximumDrawdown ? next : current,
    );
  }

  /// 根据收益、回撤和交易覆盖度选出相对均衡的历史组合。
  QuantBacktestComparisonItem? get balancedItem {
    final comparableItems = referenceableItems;

    if (comparableItems.length < 2) {
      return null;
    }

    final maxReturn = comparableItems
        .map((item) => item.cumulativeReturn)
        .reduce((left, right) => left > right ? left : right);
    final minReturn = comparableItems
        .map((item) => item.cumulativeReturn)
        .reduce((left, right) => left < right ? left : right);
    final maxDrawdown = comparableItems
        .map((item) => item.maximumDrawdown)
        .reduce((left, right) => left > right ? left : right);
    final minDrawdown = comparableItems
        .map((item) => item.maximumDrawdown)
        .reduce((left, right) => left < right ? left : right);
    final maxTrades = comparableItems
        .map((item) => item.tradeCount)
        .reduce((left, right) => left > right ? left : right);
    final minTrades = comparableItems
        .map((item) => item.tradeCount)
        .reduce((left, right) => left < right ? left : right);

    double normalizeHigher(double value, double minimum, double maximum) {
      if (maximum == minimum) {
        return 1;
      }

      return (value - minimum) / (maximum - minimum);
    }

    double normalizeLower(double value, double minimum, double maximum) {
      return 1 - normalizeHigher(value, minimum, maximum);
    }

    return comparableItems.reduce((current, next) {
      double score(QuantBacktestComparisonItem item) {
        final returnScore = normalizeHigher(
          item.cumulativeReturn,
          minReturn,
          maxReturn,
        );
        final drawdownScore = normalizeLower(
          item.maximumDrawdown,
          minDrawdown,
          maxDrawdown,
        );
        final coverageScore = normalizeHigher(
          item.tradeCount.toDouble(),
          minTrades.toDouble(),
          maxTrades.toDouble(),
        );

        return returnScore * 0.5 + drawdownScore * 0.3 + coverageScore * 0.2;
      }

      return score(next) > score(current) ? next : current;
    });
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
