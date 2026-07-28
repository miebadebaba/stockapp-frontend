import 'package:flutter/foundation.dart';

import 'market_stock_detail_data.dart';
import 'market_stock_detail_transport.dart';

class MarketStockDetailApi {
  const MarketStockDetailApi({this.apiBaseUrl});

  final String? apiBaseUrl;

  Future<MarketStockDetailData> fetchStockDetail(String stockId) async {
    final normalizedId = stockId.trim().toLowerCase();
    final symbol = normalizedId.toUpperCase();
    final baseUrl = (apiBaseUrl ?? _defaultBaseUrl()).trim();
    final url =
        '$baseUrl/api/v1/market/stocks/${Uri.encodeComponent(symbol)}/detail';

    final json = await _fetchJsonWithFriendlyErrors(url, baseUrl, symbol);
    if (json is! Map<String, dynamic>) {
      throw const MarketStockDetailApiException(
        'The stock detail response was not a JSON object.',
      );
    }

    final stock = MarketStockDetailData.fromBackendJson(
      json,
      fallbackNews: marketStockNewsArticlesById(normalizedId),
    );
    if (stock.chartSeries.isEmpty || stock.candleSeries.isEmpty) {
      throw const MarketStockDetailApiException(
        'The stock detail response did not include usable chart data.',
      );
    }
    return stock;
  }
}

class MarketStockDetailApiException implements Exception {
  const MarketStockDetailApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<Object?> _fetchJsonWithFriendlyErrors(
  String url,
  String baseUrl,
  String symbol,
) async {
  try {
    return await fetchJson(url);
  } catch (error) {
    final message = error.toString();

    if (message.contains('SocketException') ||
        message.contains('Connection refused')) {
      throw MarketStockDetailApiException(
        'The StockApp backend is not reachable at $baseUrl. Start backend-main and try again.',
      );
    }

    if (message.contains('status 502') ||
        message.contains('Unable to load market data for')) {
      throw MarketStockDetailApiException(
        'The backend is running, but live market data for $symbol is currently unavailable. Check the PandaAI credentials in backend-main/.env and confirm the backend can reach the provider network.',
      );
    }

    if (message.contains('status 404')) {
      throw MarketStockDetailApiException(
        'No stock detail data was found for $symbol.',
      );
    }

    if (message.contains('UnsupportedError')) {
      throw const MarketStockDetailApiException(
        'This build does not include stock-detail network loading.',
      );
    }

    throw MarketStockDetailApiException(
      'Unable to load stock detail right now. $message',
    );
  }
}

String _defaultBaseUrl() {
  const configured = String.fromEnvironment('STOCKAPP_API_BASE_URL');
  if (configured.isNotEmpty) {
    return configured;
  }

  if (kIsWeb) {
    return 'http://127.0.0.1:8010';
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'http://10.0.2.2:8010',
    _ => 'http://127.0.0.1:8010',
  };
}
