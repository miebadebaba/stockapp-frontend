import 'package:flutter_stockapp/features/quant/quant_stock_analysis_mock.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_catalog.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_ranking.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_ranking_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_preset.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_preset_calculator.dart';

void main() {
  test('按风险调整分降序生成连续排名', () async {
    final stocks = quantStockCatalog.take(4).toList();

    final result = await calculateQuantStockRanking(
      stocks: stocks,
      analyze: (symbol) async => buildMockQuantStockAnalysis(symbol),
    );

    expect(result.sortBy, QuantRankingSort.riskAdjustedScore);
    expect(result.items, hasLength(4));
    expect(result.items.map((item) => item.rank), orderedEquals([1, 2, 3, 4]));

    for (var index = 1; index < result.items.length; index++) {
      expect(
        result.items[index - 1].rankingScore,
        greaterThanOrEqualTo(result.items[index].rankingScore),
      );
    }
  });

  test('支持按单项因子得分排序', () async {
    final stocks = quantStockCatalog.take(4).toList();

    for (final sortBy in [
      QuantRankingSort.trend,
      QuantRankingSort.momentum,
      QuantRankingSort.volume,
    ]) {
      final result = await calculateQuantStockRanking(
        stocks: stocks,
        analyze: (symbol) async => buildMockQuantStockAnalysis(symbol),
        sortBy: sortBy,
      );

      final factorId = switch (sortBy) {
        QuantRankingSort.trend => 'trend',
        QuantRankingSort.momentum => 'momentum',
        QuantRankingSort.volume => 'volume',
        _ => throw StateError('不是单项因子排序'),
      };

      for (var index = 1; index < result.items.length; index++) {
        expect(
          result.items[index - 1].factorScore(factorId),
          greaterThanOrEqualTo(result.items[index].factorScore(factorId) ?? 0),
        );
      }
    }
  });

  test('支持按策略风险调整分生成排名', () async {
    final stocks = quantStockCatalog.take(4).toList();
    final preset = quantFactorPresetByType(QuantFactorPresetType.aggressive);

    final result = await calculateQuantStockRanking(
      stocks: stocks,
      analyze: (symbol) async => buildMockQuantStockAnalysis(symbol),
      presetType: QuantFactorPresetType.aggressive,
    );

    expect(result.presetType, QuantFactorPresetType.aggressive);

    for (var index = 1; index < result.items.length; index++) {
      final previous = calculatePresetRiskAdjustedScore(
        score: result.items[index - 1].score,
        preset: preset,
      );
      final current = calculatePresetRiskAdjustedScore(
        score: result.items[index].score,
        preset: preset,
      );

      expect(previous, greaterThanOrEqualTo(current!));
    }
  });
}
