import 'package:flutter_stockapp/features/quant/macd_result.dart';
import 'package:flutter_stockapp/features/quant/quant_ai_analysis_section.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_analysis.dart';
import 'package:flutter_stockapp/features/quant/selected_stock.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_stockapp/features/quant/stock_quote.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_result.dart';
import 'package:flutter_stockapp/features/quant/volume_analysis_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('生成包含股票和主要指标的 AI 提问', () {
    final prompt = buildQuantAiPrompt(
      stock: const SelectedStock(code: '600519', name: '贵州茅台'),
      analysis: _analysis(),
    );

    expect(prompt, contains('贵州茅台'));
    expect(prompt, contains('600519'));
    expect(prompt, contains('MA5'));
    expect(prompt, contains('RSI14'));
    expect(prompt, contains('MACD'));
    expect(prompt, contains('年化波动率'));
    expect(prompt, contains('最大回撤'));
    expect(prompt, contains('分析仅用于解释历史数据'));
  });

  test('指标缺失时使用暂无，不会生成空值', () {
    final analysis = _analysis(
      ma5: null,
      ma10: null,
      ma20: null,
      rsi14: null,
      macd: null,
      volume: null,
      bars: const [],
    );

    final prompt = buildQuantAiPrompt(
      stock: const SelectedStock(code: '000001', name: '平安银行'),
      analysis: analysis,
    );

    expect(prompt, contains('MA5：暂无'));
    expect(prompt, contains('RSI14：暂无'));
    expect(prompt, contains('年化波动率：暂无'));
    expect(prompt, contains('最大回撤：暂无'));
  });
}

QuantStockAnalysis _analysis({
  List<StockDailyBar>? bars,
  double? ma5 = 105,
  double? ma10 = 103,
  double? ma20 = 100,
  double? rsi14 = 55,
  MacdResult? macd = const MacdResult(dif: 1.2, dea: 0.8, histogram: 0.4),
  VolumeAnalysisResult? volume = const VolumeAnalysisResult(
    latestVolume: 1500,
    averageVolume: 1233,
    volumeRatio: 1.22,
    priceDirection: PriceDirection.up,
  ),
}) {
  final testBars =
      bars ??
      [
        StockDailyBar(
          tradingDate: DateTime(2026, 7, 1),
          open: 100,
          high: 102,
          low: 99,
          close: 100,
          volume: 1000,
        ),
        StockDailyBar(
          tradingDate: DateTime(2026, 7, 2),
          open: 120,
          high: 122,
          low: 119,
          close: 120,
          volume: 1200,
        ),
        StockDailyBar(
          tradingDate: DateTime(2026, 7, 3),
          open: 90,
          high: 92,
          low: 89,
          close: 90,
          volume: 1500,
        ),
      ];

  return QuantStockAnalysis(
    symbol: '600519.SH',
    bars: testBars,
    latestBar: StockQuote(
      tradingDate: DateTime(2026, 7, 3),
      open: 90,
      high: 92,
      low: 89,
      close: 90,
      previousClose: 88,
      volume: 1500,
    ),
    ma5: ma5,
    ma10: ma10,
    ma20: ma20,
    macd: macd,
    rsi14: rsi14,
    volume: volume,
    technicalSummary: const TechnicalSummaryResult(
      trend: TrendState.upward,
      momentum: MomentumState.positive,
      strength: StrengthState.relativelyStrong,
      participation: ParticipationState.confirming,
      consistency: EvidenceConsistency.high,
      riskFlags: [],
    ),
  );
}
