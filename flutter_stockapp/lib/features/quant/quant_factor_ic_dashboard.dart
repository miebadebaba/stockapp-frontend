import 'quant_factor_ic.dart';

enum QuantFactorIcDashboardStatus {
  available,
  insufficientRealStocks,
  insufficientHistory,
}

class QuantFactorIcDashboardResult {
  const QuantFactorIcDashboardResult({
    required this.status,
    required this.realStockCount,
    this.factorResults = const {},
  });

  final QuantFactorIcDashboardStatus status;

  /// 实际参与 IC 分析的真实数据股票数量。
  final int realStockCount;

  /// key 为 trend、momentum 或 volume。
  final Map<String, QuantFactorIcResult> factorResults;

  bool get isAvailable {
    return status == QuantFactorIcDashboardStatus.available;
  }

  int get availableFactorCount {
    return factorResults.values
        .where((result) => result.availablePeriodCount > 0)
        .length;
  }

  QuantFactorIcResult? resultFor(String factorId) {
    return factorResults[factorId.trim()];
  }
}
