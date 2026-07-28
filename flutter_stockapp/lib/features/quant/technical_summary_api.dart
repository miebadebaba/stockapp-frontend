import 'stock_daily_bar.dart';
import 'technical_summary_request_mapper.dart';
import 'technical_summary_response_mapper.dart';
import 'technical_summary_result.dart';

typedef JsonPost =
    Future<Map<String, dynamic>> Function({
      required String path,
      required Object body,
    });

class TechnicalSummaryApi {
  const TechnicalSummaryApi({required JsonPost postJson})
    : _postJson = postJson;

  static const endpointPath = '/api/v1/quant/technical-summary';

  final JsonPost _postJson;

  Future<TechnicalSummaryResult> analyze(List<StockDailyBar> bars) async {
    final response = await _postJson(
      path: endpointPath,
      body: mapTechnicalSummaryRequest(bars),
    );

    return mapTechnicalSummaryResponse(response);
  }
}
