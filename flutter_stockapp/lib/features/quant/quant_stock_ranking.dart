import 'quant_cross_sectional_calculator.dart';
import 'quant_factor_preset.dart';
import 'quant_factor_score.dart';
import 'quant_stock_analysis.dart';
import 'selected_stock.dart';

enum QuantRankingSort {
  poolCompositeScore,
  riskAdjustedScore,
  technicalScore,
  trend,
  momentum,
  volume,
}

extension QuantRankingSortLabel on QuantRankingSort {
  String get label {
    return switch (this) {
      QuantRankingSort.poolCompositeScore => '股票池综合分',
      QuantRankingSort.riskAdjustedScore => '风险调整分',
      QuantRankingSort.technicalScore => '综合评分',
      QuantRankingSort.trend => '趋势百分位',
      QuantRankingSort.momentum => '动量百分位',
      QuantRankingSort.volume => '量价百分位',
    };
  }

  bool get isCrossSectional {
    return switch (this) {
      QuantRankingSort.poolCompositeScore ||
      QuantRankingSort.trend ||
      QuantRankingSort.momentum ||
      QuantRankingSort.volume => true,
      QuantRankingSort.riskAdjustedScore ||
      QuantRankingSort.technicalScore => false,
    };
  }

  String get explanation {
    return switch (this) {
      QuantRankingSort.poolCompositeScore =>
        '综合趋势、动量和量价百分位计算，分数越高，表示在当前股票池中的整体相对表现越靠前。',
      QuantRankingSort.trend => '趋势百分位越高，表示该股票的趋势表现相对于当前股票池越强。',
      QuantRankingSort.momentum => '动量百分位越高，表示该股票的动量表现相对于当前股票池越强。',
      QuantRankingSort.volume => '量价百分位越高，表示该股票的量价表现相对于当前股票池越强。',
      QuantRankingSort.riskAdjustedScore => '在原始技术评分基础上，进一步考虑波动和回撤风险后的参考分数。',
      QuantRankingSort.technicalScore => '根据趋势、动量和量价因子计算的当前股票自身技术评分。',
    };
  }
}

class QuantStockRankingItem {
  const QuantStockRankingItem({
    required this.rank,
    required this.stock,
    required this.analysis,
    required this.score,
    this.crossSectionalScore,
  });

  final int rank;
  final SelectedStock stock;
  final QuantStockAnalysis analysis;
  final QuantFactorScore score;

  /// 该股票在当前股票池中的横向比较结果。
  final QuantCrossSectionalScore? crossSectionalScore;

  double get rankingScore => score.riskAdjustedScore ?? score.technicalScore;

  /// 股票池横向综合分，范围为 0 到 100。
  double? get poolCompositeScore => crossSectionalScore?.compositeScore;

  double? factorScore(String id) {
    for (final factor in score.factors) {
      if (factor.id == id) {
        return factor.score;
      }
    }

    return null;
  }

  /// 单项因子在股票池中的百分位，范围为 0 到 100。
  double? factorPercentile(String id) {
    return crossSectionalScore?.percentileFor(id);
  }

  /// Returns the standardized factor value within the current stock pool.
  double? factorZScore(String id) {
    return crossSectionalScore?.zScoreFor(id);
  }
}

class QuantStockRankingResult {
  const QuantStockRankingResult({
    required this.items,
    required this.sortBy,
    this.presetType = QuantFactorPresetType.balanced,
  });

  final List<QuantStockRankingItem> items;
  final QuantRankingSort sortBy;
  final QuantFactorPresetType presetType;
}
