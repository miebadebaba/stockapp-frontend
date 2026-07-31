import 'package:flutter_stockapp/features/quant/quant_stock_analysis_api.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_result.dart';
import 'package:flutter_stockapp/features/quant/volume_analysis_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('requests and maps the complete stock analysis', () async {
    var callCount = 0;
    String? receivedPath;
    Map<String, dynamic>? receivedQuery;

    final api = QuantStockAnalysisApi(
      getJson:
          ({
            required String path,
            Map<String, dynamic>? queryParameters,
          }) async {
            callCount += 1;
            receivedPath = path;
            receivedQuery = queryParameters;

            return {
              'symbol': '000001',
              'bars': [
                {
                  'trade_date': '2026-07-29',
                  'open': 11.20,
                  'high': 11.35,
                  'low': 11.10,
                  'close': 11.28,
                  'previous_close': 11.18,
                  'volume': 151105407,
                },
                {
                  'trade_date': '2026-07-30',
                  'open': 11.28,
                  'high': 11.45,
                  'low': 11.18,
                  'close': 11.43,
                  'previous_close': 11.28,
                  'volume': 63912219,
                },
              ],
              'latest_bar': {
                'trade_date': '2026-07-30',
                'open': 11.28,
                'high': 11.45,
                'low': 11.18,
                'close': 11.43,
                'previous_close': 11.28,
                'volume': 63912219,
              },
              'ma5': 11.224,
              'ma10': 11.078,
              'ma20': 10.821,
              'macd': {'dif': 0.1647, 'dea': 0.0854, 'histogram': 0.1586},
              'rsi14': 85.0,
              'volume': {
                'latest_volume': 63912219,
                'average_volume': 115317930.4,
                'volume_ratio': 0.5542,
                'price_direction': 'up',
              },
              'technical_summary': {
                'trend': 'upward',
                'momentum': 'positive',
                'strength': 'high',
                'participation': 'low',
                'consistency': 'moderate',
                'risk_flags': ['rsi_high'],
              },
            };
          },
    );

    final result = await api.analyze('000001');

    expect(callCount, 1);
    expect(receivedPath, '/api/v1/quant/stocks/000001/analysis');
    expect(receivedQuery, {'limit': 60});

    expect(result.symbol, '000001');
    expect(result.bars, hasLength(2));
    expect(result.latestBar.close, 11.43);
    expect(result.latestBar.previousClose, 11.28);
    expect(result.ma5, 11.224);
    expect(result.ma10, 11.078);
    expect(result.ma20, 10.821);
    expect(result.macd?.dif, 0.1647);
    expect(result.rsi14, 85.0);
    expect(result.volume?.priceDirection, PriceDirection.up);
    expect(result.technicalSummary.trend, TrendState.upward);
    expect(result.technicalSummary.riskFlags, [TechnicalRiskFlag.rsiHigh]);
  });
}
