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

  analyzedItems.sort(
    (left, right) => _sortValue(
      right,
      sortBy,
      preset,
    ).compareTo(_sortValue(left, sortBy, preset)),
  );

  final rankedItems = <QuantStockRankingItem>[
    for (var index = 0; index < analyzedItems.length; index++)
      QuantStockRankingItem(
        rank: index + 1,
        stock: analyzedItems[index].stock,
        analysis: analyzedItems[index].analysis,
        score: analyzedItems[index].score,
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
    QuantRankingSort.riskAdjustedScore =>
      calculatePresetRiskAdjustedScore(score: item.score, preset: preset) ??
          calculatePresetTechnicalScore(score: item.score, preset: preset),
    QuantRankingSort.technicalScore => calculatePresetTechnicalScore(
      score: item.score,
      preset: preset,
    ),
    QuantRankingSort.trend => item.factorScore('trend') ?? 0,
    QuantRankingSort.momentum => item.factorScore('momentum') ?? 0,
    QuantRankingSort.volume => item.factorScore('volume') ?? 0,
  };
}
