import 'package:flutter_stockapp/features/quant/quant_factor_ic_api.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_ic_dashboard.dart';
import 'package:flutter_stockapp/features/quant/selected_stock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('posts normalized symbols to the real IC endpoint', () async {
    String? receivedPath;
    Object? receivedBody;

    final api = QuantFactorIcApi(
      postJson: ({required String path, required Object body}) async {
        receivedPath = path;
        receivedBody = body;

        return {
          'market': 'united_states',
          'symbols': ['AAPL', 'MSFT', 'NVDA'],
          'history_limit': 120,
          'holding_period': 5,
          'minimum_lookback': 35,
          'minimum_sample_size': 3,
          'factor_results': [
            {
              'factor_id': 'trend',
              'periods': [
                {
                  'date': '2026-01-05',
                  'sample_size': 3,
                  'information_coefficient': 0.4,
                  'rank_information_coefficient': 0.5,
                },
              ],
            },
          ],
        };
      },
    );

    final result = await api.analyze(
      market: QuantMarket.unitedStates,
      symbols: const [' aapl ', 'MSFT', 'nvda', 'AAPL'],
    );

    expect(receivedPath, '/api/v1/quant/factor-ic-analysis');
    expect(receivedBody, {
      'market': 'united_states',
      'symbols': ['AAPL', 'MSFT', 'NVDA'],
      'history_limit': 120,
      'holding_period': 5,
      'minimum_lookback': 35,
      'minimum_sample_size': 3,
    });
    expect(result.status, QuantFactorIcDashboardStatus.available);
    expect(result.realStockCount, 3);
  });

  test(
    'does not request backend when fewer than three stocks remain',
    () async {
      var requestCount = 0;

      final api = QuantFactorIcApi(
        postJson: ({required String path, required Object body}) async {
          requestCount += 1;
          return {};
        },
      );

      final result = await api.analyze(
        market: QuantMarket.aShare,
        symbols: const [' 600519 ', '600519', ''],
      );

      expect(requestCount, 0);
      expect(
        result.status,
        QuantFactorIcDashboardStatus.insufficientRealStocks,
      );
      expect(result.realStockCount, 1);
    },
  );
}
