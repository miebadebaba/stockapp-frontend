import 'quant_factor_ic_dashboard.dart';
import 'quant_factor_ic_response_mapper.dart';
import 'selected_stock.dart';

typedef JsonPost =
    Future<Map<String, dynamic>> Function({
      required String path,
      required Object body,
    });

class QuantFactorIcApi {
  const QuantFactorIcApi({required this.postJson});

  static const path = '/api/v1/quant/factor-ic-analysis';
  static const historyLimit = 120;
  static const holdingPeriod = 5;
  static const minimumLookback = 35;
  static const minimumSampleSize = 3;

  final JsonPost postJson;

  Future<QuantFactorIcDashboardResult> analyze({
    required QuantMarket market,
    required Iterable<String> symbols,
  }) async {
    final normalizedSymbols = symbols
        .map((symbol) => symbol.trim().toUpperCase())
        .where((symbol) => symbol.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (normalizedSymbols.length < minimumSampleSize) {
      return QuantFactorIcDashboardResult(
        status: QuantFactorIcDashboardStatus.insufficientRealStocks,
        realStockCount: normalizedSymbols.length,
      );
    }

    final response = await postJson(
      path: path,
      body: {
        'market': _marketValue(market),
        'symbols': normalizedSymbols,
        'history_limit': historyLimit,
        'holding_period': holdingPeriod,
        'minimum_lookback': minimumLookback,
        'minimum_sample_size': minimumSampleSize,
      },
    );

    return mapQuantFactorIcAnalysisResponse(response);
  }
}

String _marketValue(QuantMarket market) {
  return switch (market) {
    QuantMarket.aShare => 'a_share',
    QuantMarket.hongKong => 'hong_kong',
    QuantMarket.unitedStates => 'united_states',
  };
}
