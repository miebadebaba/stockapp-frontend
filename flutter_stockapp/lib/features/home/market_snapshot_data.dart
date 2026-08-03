import 'widgets/market_snapshot_section.dart';

class MarketSnapshotGroupData {
  const MarketSnapshotGroupData({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<MarketSnapshotItemData> items;

  factory MarketSnapshotGroupData.fromBackendJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final items = itemsJson is List
        ? itemsJson
              .whereType<Map<String, dynamic>>()
              .map(MarketSnapshotItemData.fromBackendJson)
              .toList()
        : const <MarketSnapshotItemData>[];

    return MarketSnapshotGroupData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      items: items,
    );
  }
}

class MarketSnapshotOverviewData {
  const MarketSnapshotOverviewData({
    required this.previewItems,
    required this.groups,
  });

  final List<MarketSnapshotItemData> previewItems;
  final List<MarketSnapshotGroupData> groups;

  factory MarketSnapshotOverviewData.fromBackendJson(
    Map<String, dynamic> json,
  ) {
    final previewJson = json['preview_items'];
    final groupsJson = json['groups'];

    final previewItems = previewJson is List
        ? previewJson
              .whereType<Map<String, dynamic>>()
              .map(MarketSnapshotItemData.fromBackendJson)
              .toList()
        : const <MarketSnapshotItemData>[];

    final groups = groupsJson is List
        ? groupsJson
              .whereType<Map<String, dynamic>>()
              .map(MarketSnapshotGroupData.fromBackendJson)
              .toList()
        : const <MarketSnapshotGroupData>[];

    return MarketSnapshotOverviewData(
      previewItems: previewItems,
      groups: groups,
    );
  }
}
