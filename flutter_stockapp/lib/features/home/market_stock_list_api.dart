import '../../core/network/api_config.dart';
import '../market/market_stock_detail_transport.dart';
import 'home_stock_data.dart';
import 'widgets/stock_list_section.dart';

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
  } catch (_) {
    return homeStocks.map(_stockItemToJson).toList(growable: false);
  }
}

Map<String, dynamic> _stockItemToJson(StockListItemData item) {
  final ticker = _looksLikeAShareTicker(item.subtitle) ? item.subtitle : item.title;
  final companyName = _looksLikeAShareTicker(item.subtitle)
      ? item.title
      : item.subtitle;

  return {
    'id': item.id,
    'ticker': ticker,
    'company_name': companyName,
    'price_text': item.priceText,
    'change_percent': item.changePercent,
    'reference_value': item.referenceValue,
    'sparkline_values': item.sparklineValues,
  };
}

bool _looksLikeAShareTicker(String value) {
  return RegExp(r'^\d{6}\.(SH|SZ|BJ)$', caseSensitive: false).hasMatch(
    value.trim(),
  );
}
