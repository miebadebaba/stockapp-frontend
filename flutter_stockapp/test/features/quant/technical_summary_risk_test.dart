import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_analyzer.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('identifyRiskFlags', () {
    test('RSI大于等于70时标记 rsiHigh', () {
      final flags = identifyRiskFlags(
        bars: _buildBars(List.generate(20, (index) => 10.0)),
        rsi: 70,
      );

      expect(flags, contains(TechnicalRiskFlag.rsiHigh));
      expect(flags, isNot(contains(TechnicalRiskFlag.rsiLow)));
    });

    test('RSI小于等于30时标记 rsiLow', () {
      final flags = identifyRiskFlags(
        bars: _buildBars(List.generate(20, (index) => 10.0)),
        rsi: 30,
      );

      expect(flags, contains(TechnicalRiskFlag.rsiLow));
      expect(flags, isNot(contains(TechnicalRiskFlag.rsiHigh)));
    });

    test('价格偏离MA20达到10%以上时标记 priceExtended', () {
      final closes = [...List.generate(19, (index) => 10.0), 20.0];

      final flags = identifyRiskFlags(bars: _buildBars(closes), rsi: 50);

      expect(flags, contains(TechnicalRiskFlag.priceExtended));
    });

    test('RSI或历史数据不足时标记 dataInsufficient', () {
      final invalidRsiFlags = identifyRiskFlags(
        bars: _buildBars(List.generate(20, (index) => 10.0)),
        rsi: null,
      );

      final insufficientBarsFlags = identifyRiskFlags(
        bars: _buildBars(List.generate(19, (index) => 10.0)),
        rsi: 50,
      );

      expect(invalidRsiFlags, contains(TechnicalRiskFlag.dataInsufficient));
      expect(
        insufficientBarsFlags,
        contains(TechnicalRiskFlag.dataInsufficient),
      );
    });

    test('RSI正常且价格未明显偏离时不返回风险标记', () {
      final flags = identifyRiskFlags(
        bars: _buildBars(List.generate(20, (index) => 10.0)),
        rsi: 50,
      );

      expect(flags, isEmpty);
    });
  });
}

List<StockDailyBar> _buildBars(List<double> closes) {
  return List.generate(closes.length, (index) {
    final close = closes[index];

    return StockDailyBar(
      tradingDate: DateTime(2026, 1, 1).add(Duration(days: index)),
      open: close,
      high: close,
      low: close,
      close: close,
      volume: 1000,
    );
  });
}
