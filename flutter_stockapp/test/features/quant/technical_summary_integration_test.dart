import 'package:flutter_stockapp/features/quant/macd_result.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_analyzer.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_result.dart';
import 'package:flutter_stockapp/features/quant/volume_analysis_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('analyzeTechnicalSummary', () {
    test('多项证据共同偏强且成交量确认时返回完整结果', () {
      final bars = _buildBars(List.generate(30, (index) => 10 + index * 0.05));

      const macd = MacdResult(dif: 1.2, dea: 0.8, histogram: 0.8);

      const volume = VolumeAnalysisResult(
        latestVolume: 1500,
        averageVolume: 1000,
        volumeRatio: 1.5,
        priceDirection: PriceDirection.up,
      );

      final result = analyzeTechnicalSummary(
        bars: bars,
        rsi: 60,
        macd: macd,
        volume: volume,
      );

      expect(result.trend, TrendState.upward);
      expect(result.momentum, MomentumState.positive);
      expect(result.strength, StrengthState.relativelyStrong);
      expect(result.participation, ParticipationState.confirming);
      expect(result.consistency, EvidenceConsistency.high);
      expect(result.riskFlags, isEmpty);
    });

    test('关键数据不足时返回不可用状态和风险提醒', () {
      final bars = _buildBars(List.generate(10, (index) => 10.0));

      final result = analyzeTechnicalSummary(
        bars: bars,
        rsi: null,
        macd: null,
        volume: null,
      );

      expect(result.trend, TrendState.unavailable);
      expect(result.momentum, MomentumState.unavailable);
      expect(result.strength, StrengthState.unavailable);
      expect(result.participation, ParticipationState.unavailable);
      expect(result.consistency, EvidenceConsistency.unavailable);
      expect(result.riskFlags, contains(TechnicalRiskFlag.dataInsufficient));
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
