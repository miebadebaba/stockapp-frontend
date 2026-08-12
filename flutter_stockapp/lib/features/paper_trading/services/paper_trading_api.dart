import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/paper_portfolio.dart';

typedef JsonGet =
    Future<Map<String, dynamic>> Function({
      required String path,
      Map<String, dynamic>? queryParameters,
    });

typedef JsonListGet =
    Future<List<dynamic>> Function({
      required String path,
      Map<String, dynamic>? queryParameters,
    });

typedef JsonPost =
    Future<Map<String, dynamic>> Function({
      required String path,
      required Object body,
      Duration? receiveTimeout,
    });

abstract interface class PaperTradingApi {
  Future<PaperPortfolio> loadPortfolio();

  Future<List<HoldingPosition>> loadPositions();

  Future<List<PaperOrder>> loadOrders({
    String? side,
    String? status,
    int limit = 50,
  });

  Future<PaperOrderSubmission> submitOrder({
    required String symbol,
    required String side,
    required int quantity,
  });
}

class HttpPaperTradingApi implements PaperTradingApi {
  HttpPaperTradingApi({
    ApiClient? apiClient,
    JsonGet? getJson,
    JsonListGet? getJsonList,
    JsonPost? postJson,
  }) : _apiClient = apiClient ??
           (getJson == null || getJsonList == null || postJson == null
               ? ApiClient()
               : null),
       _ownsApiClient =
           apiClient == null &&
           (getJson == null || getJsonList == null || postJson == null),
       _getJson = getJson,
       _getJsonList = getJsonList,
       _postJson = postJson;

  static const portfolioPath = '/api/v1/paper-trading/portfolio';
  static const positionsPath = '/api/v1/paper-trading/positions';
  static const ordersPath = '/api/v1/paper-trading/orders';

  final ApiClient? _apiClient;
  final bool _ownsApiClient;
  final JsonGet? _getJson;
  final JsonListGet? _getJsonList;
  final JsonPost? _postJson;

  @override
  Future<PaperPortfolio> loadPortfolio() async {
    try {
      final response = await (_getJson ?? _apiClient!.getJson)(
        path: portfolioPath,
      );
      return PaperPortfolio.fromJson(response);
    } on ApiException catch (error) {
      throw PaperTradingApiException(_messageForApiError(error));
    } on FormatException {
      throw const PaperTradingApiException('后端返回的模拟交易数据格式不正确。');
    }
  }

  @override
  Future<List<HoldingPosition>> loadPositions() async {
    try {
      final response = await (_getJsonList ?? _apiClient!.getJsonList)(
        path: positionsPath,
      );
      return response
          .map((item) => HoldingPosition.fromJson(_asMap(item)))
          .toList(growable: false);
    } on ApiException catch (error) {
      throw PaperTradingApiException(_messageForApiError(error));
    } on FormatException {
      throw const PaperTradingApiException('后端返回的持仓数据格式不正确。');
    }
  }

  @override
  Future<List<PaperOrder>> loadOrders({
    String? side,
    String? status,
    int limit = 50,
  }) async {
    try {
      final query = <String, dynamic>{'limit': limit};
      if (side != null) {
        query['side'] = side;
      }
      if (status != null) {
        query['status'] = status;
      }
      final response = await (_getJsonList ?? _apiClient!.getJsonList)(
        path: ordersPath,
        queryParameters: query,
      );
      return response
          .map((item) => PaperOrder.fromJson(_asMap(item)))
          .toList(growable: false);
    } on ApiException catch (error) {
      throw PaperTradingApiException(_messageForApiError(error));
    } on FormatException {
      throw const PaperTradingApiException('后端返回的委托记录格式不正确。');
    }
  }

  @override
  Future<PaperOrderSubmission> submitOrder({
    required String symbol,
    required String side,
    required int quantity,
  }) async {
    try {
      final response = await (_postJson ?? _apiClient!.postJson)(
        path: ordersPath,
        body: {'symbol': symbol, 'side': side, 'quantity': quantity},
      );
      return PaperOrderSubmission.fromJson(response);
    } on ApiException catch (error) {
      throw PaperTradingApiException(_messageForOrderError(error, side));
    } on FormatException {
      throw const PaperTradingApiException('后端返回的成交数据格式不正确。');
    }
  }

  void close() {
    if (_ownsApiClient) {
      _apiClient?.close(force: true);
    }
  }
}

class PaperTradingApiException implements Exception {
  const PaperTradingApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  throw const FormatException('Expected a JSON object.');
}

String _messageForOrderError(ApiException error, String side) {
  if (error.statusCode == 404) {
    return side == 'sell' ? '未找到该股票或当前没有对应持仓。' : '未找到该股票代码。';
  }
  if (error.statusCode == 409) {
    return side == 'sell' ? '持仓数量不足，无法卖出。' : '可用资金不足，无法买入。';
  }
  if (error.statusCode == 422) {
    return '委托参数无效，可能是数量、股票代码或币种不符合要求。';
  }
  return _messageForApiError(error);
}

String _messageForApiError(ApiException error) {
  return switch (error.type) {
    ApiErrorType.timeout => '请求超时，请稍后重试。',
    ApiErrorType.connection => '无法连接后端，请确认本地服务已启动。',
    ApiErrorType.notFound => '请求的数据不存在。',
    ApiErrorType.server => '后端服务暂时不可用，请稍后重试。',
    ApiErrorType.invalidResponse => '后端返回的数据格式不正确。',
    _ => '模拟交易请求失败，请稍后重试。',
  };
}
