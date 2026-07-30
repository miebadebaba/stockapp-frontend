import 'quant_stock_analysis.dart';
import 'quant_stock_analysis_response_mapper.dart';

typedef JsonGet =
    Future<Map<String, dynamic>> Function({
      required String path,
      Map<String, dynamic>? queryParameters,
    });

class QuantStockAnalysisApi {
  const QuantStockAnalysisApi({required this.getJson});

  static const defaultLimit = 60;

  final JsonGet getJson;

  Future<QuantStockAnalysis> analyze(String symbol) async {
    final response = await getJson(
      path: '/api/v1/quant/stocks/$symbol/analysis',
      queryParameters: const {'limit': defaultLimit},
    );

    return mapQuantStockAnalysisResponse(response);
  }
}
