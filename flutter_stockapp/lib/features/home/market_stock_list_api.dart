import '../../core/network/api_config.dart';
import 'widgets/stock_list_section.dart';
import '../market/market_stock_detail_transport.dart';

class MarketStockListApi {
  const MarketStockListApi({this.apiBaseUrl});

  final String? apiBaseUrl;

  Future<List<StockListItemData>> fetchStocks() async {
    final baseUrl = (apiBaseUrl ?? ApiConfig.baseUri.toString()).trim();
    final url = '$baseUrl/api/v1/market/stocks';
    final json = await _fetchStockListJson(url, baseUrl);
    if (json is! List) {
      throw const MarketStockListApiException(
        'The stock list response was not a JSON array.',
      );
    }

    return json
        .whereType<Map<String, dynamic>>()
        .map(StockListItemData.fromBackendJson)
        .toList();
  }
}

class MarketStockListApiException implements Exception {
  const MarketStockListApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<Object?> _fetchStockListJson(String url, String baseUrl) async {
  try {
    return await fetchJson(url);
  } catch (error) {
    final message = error.toString();

    if (message.contains('SocketException') ||
        message.contains('Connection refused')) {
      throw MarketStockListApiException(
        'The StockApp backend is not reachable at $baseUrl. Start the backend and try again.',
      );
    }

    if (message.contains('status 502') ||
        message.contains('Unable to load market data for')) {
      throw const MarketStockListApiException(
        'The backend is running, but live stock data is currently unavailable from PandaAI.',
      );
    }

    throw MarketStockListApiException(
      'Unable to load live stocks right now. $message',
    );
  }
}
