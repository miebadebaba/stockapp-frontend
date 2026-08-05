import 'quant_factor_score_calculator.dart';
import 'quant_stock_analysis.dart';
import 'quant_stock_ranking.dart';
import 'selected_stock.dart';

Future<QuantStockRankingResult> calculateQuantStockRanking({
  required List<SelectedStock> stocks,
  required Future<QuantStockAnalysis> Function(String symbol) analyze,
  QuantRankingSort sortBy = QuantRankingSort.riskAdjustedScore,
}) async {
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
    (left, right) =>
        _sortValue(right, sortBy).compareTo(_sortValue(left, sortBy)),
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
  );
}

double _sortValue(QuantStockRankingItem item, QuantRankingSort sortBy) {
  return switch (sortBy) {
    QuantRankingSort.riskAdjustedScore =>
      item.score.riskAdjustedScore ?? item.score.technicalScore,
    QuantRankingSort.technicalScore => item.score.technicalScore,
    QuantRankingSort.trend => item.factorScore('trend') ?? 0,
    QuantRankingSort.momentum => item.factorScore('momentum') ?? 0,
    QuantRankingSort.volume => item.factorScore('volume') ?? 0,
  };
}
