import 'quant_factor_score.dart';
import 'quant_stock_analysis.dart';
import 'selected_stock.dart';

enum QuantRankingSort {
  riskAdjustedScore,
  technicalScore,
  trend,
  momentum,
  volume,
}

extension QuantRankingSortLabel on QuantRankingSort {
  String get label {
    return switch (this) {
      QuantRankingSort.riskAdjustedScore => '风险调整分',
      QuantRankingSort.technicalScore => '综合评分',
      QuantRankingSort.trend => '趋势因子',
      QuantRankingSort.momentum => '动量因子',
      QuantRankingSort.volume => '量价因子',
    };
  }
}

class QuantStockRankingItem {
  const QuantStockRankingItem({
    required this.rank,
    required this.stock,
    required this.analysis,
    required this.score,
  });

  final int rank;
  final SelectedStock stock;
  final QuantStockAnalysis analysis;
  final QuantFactorScore score;

  double get rankingScore => score.riskAdjustedScore ?? score.technicalScore;

  double? factorScore(String id) {
    for (final factor in score.factors) {
      if (factor.id == id) {
        return factor.score;
      }
    }
    return null;
  }
}

class QuantStockRankingResult {
  const QuantStockRankingResult({required this.items, required this.sortBy});

  final List<QuantStockRankingItem> items;
  final QuantRankingSort sortBy;
}
