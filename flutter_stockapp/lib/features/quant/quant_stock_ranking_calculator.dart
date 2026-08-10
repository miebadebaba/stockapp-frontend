import 'quant_cross_sectional_calculator.dart';
import 'quant_factor_preset.dart';
import 'quant_factor_preset_calculator.dart';
import 'quant_factor_score_calculator.dart';
import 'quant_stock_analysis.dart';
import 'quant_stock_ranking.dart';
import 'selected_stock.dart';

Future<QuantStockRankingResult> calculateQuantStockRanking({
  required List<SelectedStock> stocks,
  required Future<QuantStockAnalysis> Function(String symbol) analyze,
  QuantRankingSort sortBy = QuantRankingSort.riskAdjustedScore,
  QuantFactorPresetType presetType = QuantFactorPresetType.balanced,
}) async {
  final preset = quantFactorPresetByType(presetType);

  final analyzedItems = await Future.wait(
    stocks.map((stock) async {
      final analysis = await analyze(stock.code);
      final score = calculateQuantFactorScore(analysis: analysis);

      if (!score.hasSufficientData) {
        return null;
      }

      return QuantStockRankingItem(
        rank: 0,
        stock: stock,
        analysis: analysis,
        score: score,
      );
    }),
  ).then((items) => items.whereType<QuantStockRankingItem>().toList());

  final crossSectionalScores = calculateCrossSectionalScores(
    factorScoresByStock: {
      for (final item in analyzedItems)
        item.stock.code: {
          for (final factor in item.score.factors) factor.id: factor.score,
        },
    },
    factorWeights: {
      'trend': preset.trendWeight,
      'momentum': preset.momentumWeight,
      'volume': preset.volumeWeight,
    },
  );

  final itemsWithCrossSectionalScores = analyzedItems
      .map(
        (item) => QuantStockRankingItem(
          rank: 0,
          stock: item.stock,
          analysis: item.analysis,
          score: item.score,
          crossSectionalScore: crossSectionalScores[item.stock.code],
        ),
      )
      .toList();

  itemsWithCrossSectionalScores.sort(
    (left, right) => _sortValue(
      right,
      sortBy,
      preset,
    ).compareTo(_sortValue(left, sortBy, preset)),
  );

  final rankedItems = <QuantStockRankingItem>[
    for (var index = 0; index < itemsWithCrossSectionalScores.length; index++)
      QuantStockRankingItem(
        rank: index + 1,
        stock: itemsWithCrossSectionalScores[index].stock,
        analysis: itemsWithCrossSectionalScores[index].analysis,
        score: itemsWithCrossSectionalScores[index].score,
        crossSectionalScore:
            itemsWithCrossSectionalScores[index].crossSectionalScore,
      ),
  ];

  return QuantStockRankingResult(
    items: List.unmodifiable(rankedItems),
    sortBy: sortBy,
    presetType: presetType,
  );
}

double _sortValue(
  QuantStockRankingItem item,
  QuantRankingSort sortBy,
  QuantFactorPreset preset,
) {
  return switch (sortBy) {
    QuantRankingSort.poolCompositeScore => item.poolCompositeScore ?? 0,
    QuantRankingSort.riskAdjustedScore =>
      calculatePresetRiskAdjustedScore(score: item.score, preset: preset) ??
          calculatePresetTechnicalScore(score: item.score, preset: preset),
    QuantRankingSort.technicalScore => calculatePresetTechnicalScore(
      score: item.score,
      preset: preset,
    ),
    QuantRankingSort.trend => item.factorPercentile('trend') ?? 0,
    QuantRankingSort.momentum => item.factorPercentile('momentum') ?? 0,
    QuantRankingSort.volume => item.factorPercentile('volume') ?? 0,
  };
}
