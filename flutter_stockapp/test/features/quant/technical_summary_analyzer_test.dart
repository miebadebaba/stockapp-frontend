import 'package:flutter_stockapp/features/quant/macd_result.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_analyzer.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_result.dart';
import 'package:flutter_stockapp/features/quant/volume_analysis_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('classifyStrength', () {
    test('RSI无效时返回 unavailable', () {
      expect(classifyStrength(null), StrengthState.unavailable);
      expect(classifyStrength(-1), StrengthState.unavailable);
      expect(classifyStrength(101), StrengthState.unavailable);
    });

    test('RSI大于等于70时返回高位状态', () {
      expect(classifyStrength(70), StrengthState.overextendedHigh);
      expect(classifyStrength(85), StrengthState.overextendedHigh);
    });

    test('RSI大于55且小于70时返回相对较强', () {
      expect(classifyStrength(56), StrengthState.relativelyStrong);
      expect(classifyStrength(69.9), StrengthState.relativelyStrong);
    });

    test('RSI位于45到55之间时返回相对均衡', () {
      expect(classifyStrength(45), StrengthState.balanced);
      expect(classifyStrength(50), StrengthState.balanced);
      expect(classifyStrength(55), StrengthState.balanced);
    });

    test('RSI大于30且小于45时返回相对较弱', () {
      expect(classifyStrength(30.1), StrengthState.relativelyWeak);
      expect(classifyStrength(44.9), StrengthState.relativelyWeak);
    });

    test('RSI小于等于30时返回低位状态', () {
      expect(classifyStrength(30), StrengthState.overextendedLow);
      expect(classifyStrength(10), StrengthState.overextendedLow);
    });
  });

  group('classifyTrend', () {
    test('历史数据不足时返回 unavailable', () {
      final bars = _buildBars(List.generate(24, (index) => 10 + index * 0.1));

      expect(classifyTrend(bars: bars), TrendState.unavailable);
    });

    test('价格和均线持续上升时返回 upward', () {
      final bars = _buildBars(List.generate(30, (index) => 10 + index * 0.2));

      expect(classifyTrend(bars: bars), TrendState.upward);
    });

    test('价格和均线持续下降时返回 downward', () {
      final bars = _buildBars(List.generate(30, (index) => 20 - index * 0.2));

      expect(classifyTrend(bars: bars), TrendState.downward);
    });

    test('价格横盘且MA20斜率不明显时返回 mixed', () {
      final bars = _buildBars(List.generate(30, (index) => 10.0));

      expect(classifyTrend(bars: bars), TrendState.mixed);
    });
  });

  group('classifyMomentum', () {
    test('MACD为空或数据无效时返回 unavailable', () {
      expect(classifyMomentum(null), MomentumState.unavailable);

      const invalidMacd = MacdResult(dif: double.nan, dea: 0, histogram: 0);

      expect(classifyMomentum(invalidMacd), MomentumState.unavailable);
    });

    test('DIF高于DEA且柱值为正时返回 positive', () {
      const macd = MacdResult(dif: 1.2, dea: 0.8, histogram: 0.8);

      expect(classifyMomentum(macd), MomentumState.positive);
    });

    test('DIF低于DEA且柱值为负时返回 negative', () {
      const macd = MacdResult(dif: -1.2, dea: -0.8, histogram: -0.8);

      expect(classifyMomentum(macd), MomentumState.negative);
    });

    test('DIF与柱值方向不一致或相等时返回 mixed', () {
      const inconsistentMacd = MacdResult(dif: 1.2, dea: 0.8, histogram: -0.2);

      const equalMacd = MacdResult(dif: 0, dea: 0, histogram: 0);

      expect(classifyMomentum(inconsistentMacd), MomentumState.mixed);
      expect(classifyMomentum(equalMacd), MomentumState.mixed);
    });
  });

  group('classifyParticipation', () {
    test('成交量为空或趋势不可用时返回 unavailable', () {
      expect(
        classifyParticipation(volume: null, trend: TrendState.upward),
        ParticipationState.unavailable,
      );

      expect(
        classifyParticipation(
          volume: _volumeResult(ratio: 1.5, direction: PriceDirection.up),
          trend: TrendState.unavailable,
        ),
        ParticipationState.unavailable,
      );
    });

    test('量比低于0.9时返回 low', () {
      final volume = _volumeResult(ratio: 0.8, direction: PriceDirection.up);

      expect(
        classifyParticipation(volume: volume, trend: TrendState.upward),
        ParticipationState.low,
      );
    });

    test('量比接近均量或趋势不明确时返回 inconclusive', () {
      final averageVolume = _volumeResult(
        ratio: 1.0,
        direction: PriceDirection.up,
      );

      final elevatedVolume = _volumeResult(
        ratio: 1.5,
        direction: PriceDirection.up,
      );

      expect(
        classifyParticipation(volume: averageVolume, trend: TrendState.upward),
        ParticipationState.inconclusive,
      );

      expect(
        classifyParticipation(volume: elevatedVolume, trend: TrendState.mixed),
        ParticipationState.inconclusive,
      );
    });

    test('放量方向与趋势一致时返回 confirming', () {
      final upwardVolume = _volumeResult(
        ratio: 1.5,
        direction: PriceDirection.up,
      );

      final downwardVolume = _volumeResult(
        ratio: 1.5,
        direction: PriceDirection.down,
      );

      expect(
        classifyParticipation(volume: upwardVolume, trend: TrendState.upward),
        ParticipationState.confirming,
      );

      expect(
        classifyParticipation(
          volume: downwardVolume,
          trend: TrendState.downward,
        ),
        ParticipationState.confirming,
      );
    });

    test('放量方向与趋势相反时返回 contradicting', () {
      final volume = _volumeResult(ratio: 1.5, direction: PriceDirection.down);

      expect(
        classifyParticipation(volume: volume, trend: TrendState.upward),
        ParticipationState.contradicting,
      );
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

VolumeAnalysisResult _volumeResult({
  required double ratio,
  required PriceDirection direction,
}) {
  return VolumeAnalysisResult(
    latestVolume: 1500,
    averageVolume: 1000,
    volumeRatio: ratio,
    priceDirection: direction,
  );
}
