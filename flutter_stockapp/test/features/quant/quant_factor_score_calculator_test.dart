import 'package:flutter_stockapp/features/quant/macd_result.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_score.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_score_calculator.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_analysis.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_stockapp/features/quant/stock_quote.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_result.dart';
import 'package:flutter_stockapp/features/quant/volume_analysis_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateQuantFactorScore', () {
    test('趋势动量和量价均较强时返回强势评分', () {
      final analysis = _buildAnalysis(
        close: 120,
        ma5: 115,
        ma10: 110,
        ma20: 105,
        rsi: 60,
        macd: const MacdResult(dif: 1.2, dea: 0.8, histogram: 0.8),
        volume: _volume(ratio: 1.3, direction: PriceDirection.up),
        bars: _bars(List.generate(30, (index) => 100.0 + index)),
      );

      final result = calculateQuantFactorScore(analysis: analysis);

      expect(result.hasSufficientData, isTrue);
      expect(result.technicalScore, closeTo(92.25, 0.001));
      expect(result.rating, QuantTechnicalRating.strong);
      expect(result.factors, hasLength(3));
      expect(result.risk.level, QuantRiskLevel.low);
    });

    test('趋势动量和量价均较弱时返回弱势评分', () {
      final analysis = _buildAnalysis(
        close: 80,
        ma5: 85,
        ma10: 90,
        ma20: 95,
        rsi: 40,
        macd: const MacdResult(dif: -1.2, dea: -0.8, histogram: -0.8),
        volume: _volume(ratio: 1.3, direction: PriceDirection.down),
        bars: _bars(List.generate(30, (index) => 120.0 - index)),
      );

      final result = calculateQuantFactorScore(analysis: analysis);

      expect(result.hasSufficientData, isTrue);
      expect(result.technicalScore, closeTo(12.15, 0.001));
      expect(result.rating, QuantTechnicalRating.weak);
      expect(result.technicalScore, inInclusiveRange(0, 100));
    });

    test('关键指标缺失时不强行生成技术评分', () {
      final analysis = _buildAnalysis(
        close: 100,
        ma5: null,
        ma10: null,
        ma20: null,
        rsi: null,
        macd: null,
        volume: null,
        bars: _bars([100, 101, 102]),
      );

      final result = calculateQuantFactorScore(analysis: analysis);

      expect(result.hasSufficientData, isFalse);
      expect(result.technicalScore, 0);
      expect(result.rating, QuantTechnicalRating.unavailable);
      expect(
        result.factors.every(
          (factor) => factor.signal == QuantFactorSignal.unavailable,
        ),
        isTrue,
      );
    });

    test('风险等级独立于技术状态评分', () {
      final lowRiskAnalysis = _buildStrongAnalysis(
        bars: _bars([100, 100.5, 101, 101.5]),
      );

      final highRiskAnalysis = _buildStrongAnalysis(
        bars: _bars([100, 150, 90, 95]),
      );

      final lowRiskResult = calculateQuantFactorScore(
        analysis: lowRiskAnalysis,
      );
      final highRiskResult = calculateQuantFactorScore(
        analysis: highRiskAnalysis,
      );

      expect(lowRiskResult.technicalScore, highRiskResult.technicalScore);
      expect(lowRiskResult.risk.level, QuantRiskLevel.low);
      expect(highRiskResult.risk.level, QuantRiskLevel.high);
    });
  });
}

QuantStockAnalysis _buildStrongAnalysis({required List<StockDailyBar> bars}) {
  return _buildAnalysis(
    close: 120,
    ma5: 115,
    ma10: 110,
    ma20: 105,
    rsi: 60,
    macd: const MacdResult(dif: 1.2, dea: 0.8, histogram: 0.8),
    volume: _volume(ratio: 1.3, direction: PriceDirection.up),
    bars: bars,
  );
}

QuantStockAnalysis _buildAnalysis({
  required double close,
  required double? ma5,
  required double? ma10,
  required double? ma20,
  required double? rsi,
  required MacdResult? macd,
  required VolumeAnalysisResult? volume,
  required List<StockDailyBar> bars,
}) {
  return QuantStockAnalysis(
    symbol: '600519',
    bars: bars,
    latestBar: StockQuote(
      tradingDate: DateTime(2026, 8, 1),
      open: close,
      high: close,
      low: close,
      close: close,
      previousClose: close,
      volume: 1000,
    ),
    ma5: ma5,
    ma10: ma10,
    ma20: ma20,
    macd: macd,
    rsi14: rsi,
    volume: volume,
    technicalSummary: const TechnicalSummaryResult(
      trend: TrendState.mixed,
      momentum: MomentumState.mixed,
      strength: StrengthState.balanced,
      participation: ParticipationState.inconclusive,
      consistency: EvidenceConsistency.moderate,
      riskFlags: [],
    ),
  );
}

List<StockDailyBar> _bars(List<double> closes) {
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

VolumeAnalysisResult _volume({
  required double ratio,
  required PriceDirection direction,
}) {
  return VolumeAnalysisResult(
    latestVolume: 1300,
    averageVolume: 1000,
    volumeRatio: ratio,
    priceDirection: direction,
  );
}
