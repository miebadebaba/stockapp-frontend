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
          result.items[index - 1].factorPercentile(factorId),
          greaterThanOrEqualTo(
            result.items[index].factorPercentile(factorId) ?? 0,
          ),
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
  test('为每只股票生成股票池横向百分位', () async {
    final stocks = quantStockCatalog.take(4).toList();

    final result = await calculateQuantStockRanking(
      stocks: stocks,
      analyze: (symbol) async => buildMockQuantStockAnalysis(symbol),
    );

    expect(result.items, hasLength(4));

    for (final item in result.items) {
      expect(item.crossSectionalScore, isNotNull);
      expect(item.poolCompositeScore, inInclusiveRange(0, 100));
      expect(item.factorPercentile('trend'), inInclusiveRange(0, 100));
      expect(item.factorPercentile('momentum'), inInclusiveRange(0, 100));
      expect(item.factorPercentile('volume'), inInclusiveRange(0, 100));
    }
  });

  test('横向综合分使用当前策略的因子权重', () async {
    final stocks = quantStockCatalog.take(4).toList();

    final balancedResult = await calculateQuantStockRanking(
      stocks: stocks,
      analyze: (symbol) async => buildMockQuantStockAnalysis(symbol),
      presetType: QuantFactorPresetType.balanced,
    );

    final aggressiveResult = await calculateQuantStockRanking(
      stocks: stocks,
      analyze: (symbol) async => buildMockQuantStockAnalysis(symbol),
      presetType: QuantFactorPresetType.aggressive,
    );

    expect(
      balancedResult.items.every((item) => item.crossSectionalScore != null),
      isTrue,
    );
    expect(
      aggressiveResult.items.every((item) => item.crossSectionalScore != null),
      isTrue,
    );
  });
  test('支持按股票池综合分降序排名', () async {
    final stocks = quantStockCatalog.take(4).toList();

    final result = await calculateQuantStockRanking(
      stocks: stocks,
      analyze: (symbol) async => buildMockQuantStockAnalysis(symbol),
      sortBy: QuantRankingSort.poolCompositeScore,
    );

    expect(result.sortBy, QuantRankingSort.poolCompositeScore);

    for (var index = 1; index < result.items.length; index++) {
      expect(
        result.items[index - 1].poolCompositeScore,
        greaterThanOrEqualTo(result.items[index].poolCompositeScore ?? 0),
      );
    }
  });
  test('ranking items expose finite factor Z-Scores', () async {
    final stocks = quantStockCatalog.take(4).toList();

    final result = await calculateQuantStockRanking(
      stocks: stocks,
      analyze: (symbol) async => buildMockQuantStockAnalysis(symbol),
    );

    expect(result.items, hasLength(4));

    for (final item in result.items) {
      final trendZScore = item.factorZScore('trend');
      final momentumZScore = item.factorZScore('momentum');
      final volumeZScore = item.factorZScore('volume');

      expect(trendZScore, isNotNull);
      expect(momentumZScore, isNotNull);
      expect(volumeZScore, isNotNull);

      expect(trendZScore!.isFinite, isTrue);
      expect(momentumZScore!.isFinite, isTrue);
      expect(volumeZScore!.isFinite, isTrue);
    }
  });
}
