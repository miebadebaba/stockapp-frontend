import 'package:flutter_stockapp/features/quant/mock_stock_daily_bars.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_score_calculator.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_analysis_mock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('不同股票使用不同的模拟走势和成交量节奏', () {
    final maotai = buildMockQuantStockAnalysis('600519');
    final ningde = buildMockQuantStockAnalysis('300750');

    expect(maotai.bars, hasLength(mockStockDailyBars['600519']!.length));
    expect(ningde.bars, hasLength(mockStockDailyBars['300750']!.length));

    final maotaiCloses = maotai.bars.map((bar) => bar.close).toList();
    final ningdeCloses = ningde.bars.map((bar) => bar.close).toList();

    expect(maotaiCloses, isNot(equals(ningdeCloses)));
    expect(
      maotai.bars.map((bar) => bar.volume).toList(),
      isNot(equals(ningde.bars.map((bar) => bar.volume).toList())),
    );

    expect(maotai.rsi14, isNot(equals(ningde.rsi14)));
    expect(maotai.macd?.histogram, isNot(equals(ningde.macd?.histogram)));
    expect(
      maotai.volume?.volumeRatio,
      isNot(equals(ningde.volume?.volumeRatio)),
    );
  });

  test('不同股票的多因子评分会基于各自的模拟行情计算', () {
    final maotaiScore = calculateQuantFactorScore(
      analysis: buildMockQuantStockAnalysis('600519'),
    );
    final ningdeScore = calculateQuantFactorScore(
      analysis: buildMockQuantStockAnalysis('300750'),
    );

    expect(
      maotaiScore.technicalScore,
      isNot(equals(ningdeScore.technicalScore)),
    );
    expect(
      maotaiScore.riskAdjustedScore,
      isNot(equals(ningdeScore.riskAdjustedScore)),
    );

    final maotaiFactors = maotaiScore.factors
        .map((factor) => factor.score)
        .toList();
    final ningdeFactors = ningdeScore.factors
        .map((factor) => factor.score)
        .toList();

    expect(maotaiFactors, isNot(equals(ningdeFactors)));
  });

  test('同一股票重复分析仍然保持稳定', () {
    final first = buildMockQuantStockAnalysis('600519');
    final second = buildMockQuantStockAnalysis('600519');

    expect(
      first.bars.map((bar) => bar.close).toList(),
      equals(second.bars.map((bar) => bar.close).toList()),
    );
    expect(first.rsi14, second.rsi14);
    expect(first.macd?.histogram, second.macd?.histogram);
    expect(first.volume?.volumeRatio, second.volume?.volumeRatio);
  });
}
