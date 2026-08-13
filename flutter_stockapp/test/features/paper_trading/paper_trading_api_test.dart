import 'package:flutter_stockapp/core/network/api_exception.dart';
import 'package:flutter_stockapp/features/paper_trading/services/paper_trading_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HttpPaperTradingApi', () {
    test('loads portfolio from the backend portfolio path', () async {
      String? capturedPath;
      final api = HttpPaperTradingApi(
        getJson:
            ({required String path, Map<String, dynamic>? queryParameters}) {
              capturedPath = path;
              return Future.value(_portfolioJson());
            },
        getJsonList:
            ({required String path, Map<String, dynamic>? queryParameters}) {
              return Future.value(const []);
            },
        postJson:
            ({
              required String path,
              required Object body,
              Duration? receiveTimeout,
            }) {
              return Future.value(const {});
            },
      );

      final portfolio = await api.loadPortfolio();

      expect(capturedPath, HttpPaperTradingApi.portfolioPath);
      expect(portfolio.account.accountKey, 'demo');
      expect(portfolio.holdings.single.symbol, '00700.HK');
    });

    test('loads orders with the existing query parameters', () async {
      String? capturedPath;
      Map<String, dynamic>? capturedQuery;
      final api = HttpPaperTradingApi(
        getJson:
            ({required String path, Map<String, dynamic>? queryParameters}) {
              return Future.value(_portfolioJson());
            },
        getJsonList:
            ({required String path, Map<String, dynamic>? queryParameters}) {
              capturedPath = path;
              capturedQuery = queryParameters;
              return Future.value([_orderJson()]);
            },
        postJson:
            ({
              required String path,
              required Object body,
              Duration? receiveTimeout,
            }) {
              return Future.value(const {});
            },
      );

      final orders = await api.loadOrders(
        side: 'buy',
        status: 'filled',
        limit: 25,
      );

      expect(capturedPath, HttpPaperTradingApi.ordersPath);
      expect(capturedQuery, {'limit': 25, 'side': 'buy', 'status': 'filled'});
      expect(orders.single.symbol, '00700.HK');
    });

    test('submits market orders with the existing request body', () async {
      String? capturedPath;
      Object? capturedBody;
      final api = HttpPaperTradingApi(
        getJson:
            ({required String path, Map<String, dynamic>? queryParameters}) {
              return Future.value(_portfolioJson());
            },
        getJsonList:
            ({required String path, Map<String, dynamic>? queryParameters}) {
              return Future.value(const []);
            },
        postJson:
            ({
              required String path,
              required Object body,
              Duration? receiveTimeout,
            }) {
              capturedPath = path;
              capturedBody = body;
              return Future.value(_submissionJson());
            },
      );

      final result = await api.submitOrder(
        symbol: '00700.HK',
        side: 'buy',
        quantity: 100,
      );

      expect(capturedPath, HttpPaperTradingApi.ordersPath);
      expect(capturedBody, {'symbol': '00700.HK', 'side': 'buy', 'quantity': 100});
      expect(result.execution.price, 380);
    });

    test('preserves order error handling', () async {
      final api = HttpPaperTradingApi(
        getJson:
            ({required String path, Map<String, dynamic>? queryParameters}) {
              return Future.value(_portfolioJson());
            },
        getJsonList:
            ({required String path, Map<String, dynamic>? queryParameters}) {
              return Future.value(const []);
            },
        postJson:
            ({
              required String path,
              required Object body,
              Duration? receiveTimeout,
            }) {
              throw const ApiException(
                type: ApiErrorType.unknown,
                message: 'conflict',
                statusCode: 409,
              );
            },
      );

      await expectLater(
        api.submitOrder(symbol: '00700.HK', side: 'sell', quantity: 999),
        throwsA(
          isA<PaperTradingApiException>().having(
            (error) => error.message,
            'message',
            '持仓数量不足，无法卖出。',
          ),
        ),
      );
    });

    test('resets the account through the reset path', () async {
      String? capturedPath;
      Object? capturedBody;
      final api = HttpPaperTradingApi(
        getJson:
            ({required String path, Map<String, dynamic>? queryParameters}) {
              return Future.value(_portfolioJson());
            },
        getJsonList:
            ({required String path, Map<String, dynamic>? queryParameters}) {
              return Future.value(const []);
            },
        postJson:
            ({
              required String path,
              required Object body,
              Duration? receiveTimeout,
            }) {
              capturedPath = path;
              capturedBody = body;
              return Future.value(_portfolioJson());
            },
      );

      final portfolio = await api.resetAccount();

      expect(capturedPath, HttpPaperTradingApi.resetPath);
      expect(capturedBody, const {});
      expect(portfolio.summary.availableCash, 162000);
    });
  });
}

Map<String, dynamic> _portfolioJson() {
  return {
    'account': {
      'id': 1,
      'account_key': 'demo',
      'currency': 'HKD',
      'initial_cash': 200000,
      'available_cash': 162000,
    },
    'summary': _summaryJson(),
    'positions': [
      {
        'symbol': '00700.HK',
        'name': 'Tencent Holdings',
        'currency': 'HKD',
        'quantity': 100,
        'average_cost': 380,
        'current_price': 400,
        'market_value': 40000,
        'unrealized_profit_loss': 2000,
        'unrealized_profit_loss_percent': 5.26,
      },
    ],
  };
}

Map<String, dynamic> _orderJson() {
  return {
    'id': 1,
    'symbol': '00700.HK',
    'side': 'buy',
    'order_type': 'market',
    'quantity': 100,
    'status': 'filled',
    'submitted_at': '2026-08-03T09:30:00Z',
    'filled_at': '2026-08-03T09:30:01Z',
    'execution_price': 380,
  };
}

Map<String, dynamic> _submissionJson() {
  return {
    'order': _orderJson(),
    'execution': {
      'id': 1,
      'order_id': 1,
      'symbol': '00700.HK',
      'side': 'buy',
      'quantity': 100,
      'price': 380,
      'executed_at': '2026-08-03T09:30:01Z',
    },
    'summary': _summaryJson(),
  };
}

Map<String, dynamic> _summaryJson() {
  return {
    'initial_cash': 200000,
    'total_assets': 202000,
    'total_profit_loss': 2000,
    'total_profit_loss_percent': 1,
    'market_value': 40000,
    'available_cash': 162000,
    'position_ratio': 19.8,
  };
}
