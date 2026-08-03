import '../../core/network/api_config.dart';
import '../market/market_stock_detail_transport.dart';
import 'market_snapshot_data.dart';

class MarketSnapshotApi {
  const MarketSnapshotApi({this.apiBaseUrl});

  final String? apiBaseUrl;

  Future<MarketSnapshotOverviewData> fetchOverview() async {
    final baseUrl = (apiBaseUrl ?? ApiConfig.baseUri.toString()).trim();
    final url = '$baseUrl/api/v1/market/indexes/overview';
    final json = await _fetchMarketOverviewJson(url, baseUrl);
    if (json is! Map<String, dynamic>) {
      throw const MarketSnapshotApiException(
        'The markets response was not a JSON object.',
      );
    }

    return MarketSnapshotOverviewData.fromBackendJson(json);
  }
}

class MarketSnapshotApiException implements Exception {
  const MarketSnapshotApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<Object?> _fetchMarketOverviewJson(String url, String baseUrl) async {
  try {
    return await fetchJson(url);
  } catch (error) {
    final message = error.toString();

    if (message.contains('SocketException') ||
        message.contains('Connection refused')) {
      throw MarketSnapshotApiException(
        'The StockApp backend is not reachable at $baseUrl. Start the backend and try again.',
      );
    }

    if (message.contains('status 502') ||
        message.contains('Unable to load live market indexes')) {
      throw const MarketSnapshotApiException(
        'The backend is running, but live market indexes are currently unavailable from PandaAI.',
      );
    }

    throw MarketSnapshotApiException(
      'Unable to load live markets right now. $message',
    );
  }
}
