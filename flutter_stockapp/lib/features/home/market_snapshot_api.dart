import '../../core/network/api_config.dart';
import '../market/market_stock_detail_transport.dart';
import 'market_snapshot_data.dart';
import 'market_snapshot_mock_data.dart';
import 'widgets/market_snapshot_section.dart';

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
  } catch (_) {
    return {
      'preview_items': mockMarketSnapshotOverview.previewItems
          .map(_marketItemToJson)
          .toList(growable: false),
      'groups': mockMarketSnapshotOverview.groups
          .map(
            (group) => {
              'id': group.id,
              'title': group.title,
              'items': group.items
                  .map(_marketItemToJson)
                  .toList(growable: false),
            },
          )
          .toList(growable: false),
    };
  }
}

Map<String, dynamic> _marketItemToJson(MarketSnapshotItemData item) {
  return {
    'id': item.id,
    'display_name': item.assetName,
    'value_text': item.valueText,
    'change_percent': item.changePercent,
    'sparkline_values': item.sparklineValues,
  };
}
