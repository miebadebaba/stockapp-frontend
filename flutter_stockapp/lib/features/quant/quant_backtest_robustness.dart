import 'quant_backtest_parameters.dart';
import 'quant_factor_backtest.dart';
import 'quant_factor_backtest_calculator.dart';
import 'stock_daily_bar.dart';

enum QuantBacktestRobustnessLevel { stable, mixed, insufficient }

class QuantBacktestWindowResult {
  const QuantBacktestWindowResult({required this.label, required this.result});

  final String label;
  final QuantFactorBacktestResult result;

  bool get isReferenceable =>
      result.tradeCount >= QuantBacktestRobustnessResult.minimumTradeCount;
}

class QuantBacktestRobustnessResult {
  const QuantBacktestRobustnessResult({required this.windows});

  static const minimumTradeCount = 5;
  static const minimumReferenceableWindows = 2;

  final List<QuantBacktestWindowResult> windows;

  List<QuantBacktestWindowResult> get referenceableWindows {
    return windows.where((window) => window.isReferenceable).toList();
  }

  QuantBacktestRobustnessLevel get level {
    final referenceable = referenceableWindows;
    if (referenceable.length < minimumReferenceableWindows) {
      return QuantBacktestRobustnessLevel.insufficient;
    }

    final positiveWindows = referenceable
        .where((window) => window.result.excessReturn > 0)
        .length;
    return positiveWindows == referenceable.length
        ? QuantBacktestRobustnessLevel.stable
        : QuantBacktestRobustnessLevel.mixed;
  }
}

QuantBacktestRobustnessResult calculateQuantBacktestRobustness({
  required String symbol,
  required List<StockDailyBar> bars,
  required QuantBacktestParameters parameters,
  int windowCount = 3,
}) {
  if (windowCount < 2) {
    throw ArgumentError.value(windowCount, 'windowCount', '至少需要两个时间窗口');
  }

  final orderedBars = [...bars]
    ..sort((left, right) => left.tradingDate.compareTo(right.tradingDate));
  final minimumBarsPerWindow =
      parameters.minimumLookback + parameters.holdingPeriod + 1;
  final usableWindowCount = orderedBars.length ~/ minimumBarsPerWindow;
  final count = usableWindowCount < windowCount
      ? usableWindowCount
      : windowCount;

  if (count == 0) {
    return const QuantBacktestRobustnessResult(windows: []);
  }

  final baseWindowSize = orderedBars.length ~/ count;
  final remainder = orderedBars.length % count;
  var start = 0;
  final windows = <QuantBacktestWindowResult>[];

  for (var index = 0; index < count; index++) {
    final size = baseWindowSize + (index < remainder ? 1 : 0);
    final windowBars = orderedBars.sublist(start, start + size);
    start += size;

    windows.add(
      QuantBacktestWindowResult(
        label: '阶段 ${index + 1}',
        result: calculateQuantFactorBacktest(
          symbol: symbol,
          bars: windowBars,
          parameters: parameters,
        ),
      ),
    );
  }

  return QuantBacktestRobustnessResult(windows: List.unmodifiable(windows));
}
