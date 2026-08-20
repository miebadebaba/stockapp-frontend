import 'stock_daily_bar.dart';

enum PriceAdjustment { none, forward, backward, unknown }

enum QuantDataQuality { simulated, limitedHistory, issuesDetected, usable }

extension PriceAdjustmentLabel on PriceAdjustment {
  String get label {
    switch (this) {
      case PriceAdjustment.none:
        return '不复权';
      case PriceAdjustment.forward:
        return '前复权';
      case PriceAdjustment.backward:
        return '后复权';
      case PriceAdjustment.unknown:
        return '暂未提供';
    }
  }
}

class QuantDataMetadata {
  const QuantDataMetadata({
    required this.latestTradingDate,
    required this.sourceName,
    required this.priceAdjustment,
    required this.isSimulated,
    this.historyStartDate,
    this.historyBarCount = 0,
    this.invalidBarCount = 0,
    this.duplicateDateCount = 0,
  });

  static const minimumRecommendedHistoryCount = 60;

  final DateTime latestTradingDate;
  final String sourceName;
  final PriceAdjustment priceAdjustment;
  final bool isSimulated;
  final DateTime? historyStartDate;
  final int historyBarCount;
  final int invalidBarCount;
  final int duplicateDateCount;

  factory QuantDataMetadata.fromBars({
    required List<StockDailyBar> bars,
    DateTime? latestTradingDate,
    required String sourceName,
    required PriceAdjustment priceAdjustment,
    required bool isSimulated,
  }) {
    final orderedBars = [...bars]
      ..sort((left, right) => left.tradingDate.compareTo(right.tradingDate));
    final latestDate = orderedBars.isEmpty
        ? latestTradingDate ?? DateTime.fromMillisecondsSinceEpoch(0)
        : orderedBars.last.tradingDate;
    final dates = <DateTime>{};
    var invalidBarCount = 0;

    for (final bar in orderedBars) {
      dates.add(_dateOnly(bar.tradingDate));
      if (!_isValidBar(bar)) {
        invalidBarCount++;
      }
    }

    return QuantDataMetadata(
      latestTradingDate: latestDate,
      sourceName: sourceName,
      priceAdjustment: priceAdjustment,
      isSimulated: isSimulated,
      historyStartDate: orderedBars.isEmpty
          ? null
          : orderedBars.first.tradingDate,
      historyBarCount: orderedBars.length,
      invalidBarCount: invalidBarCount,
      duplicateDateCount: orderedBars.length - dates.length,
    );
  }

  QuantDataQuality get quality {
    if (isSimulated) {
      return QuantDataQuality.simulated;
    }
    if (invalidBarCount > 0 || duplicateDateCount > 0) {
      return QuantDataQuality.issuesDetected;
    }
    if (historyBarCount < minimumRecommendedHistoryCount) {
      return QuantDataQuality.limitedHistory;
    }
    return QuantDataQuality.usable;
  }

  bool get hasRecommendedHistory =>
      historyBarCount >= minimumRecommendedHistoryCount;

  bool get hasDataIssues => invalidBarCount > 0 || duplicateDateCount > 0;

  String get formattedTradingDate {
    return _formatDate(latestTradingDate);
  }

  String? get formattedHistoryRange {
    final startDate = historyStartDate;
    if (startDate == null || historyBarCount == 0) {
      return null;
    }

    return '${_formatDate(startDate)} 至 $formattedTradingDate';
  }
}

extension QuantDataQualityLabel on QuantDataQuality {
  String get label {
    return switch (this) {
      QuantDataQuality.simulated => '模拟数据',
      QuantDataQuality.limitedHistory => '历史区间较短',
      QuantDataQuality.issuesDetected => '发现数据异常',
      QuantDataQuality.usable => '可用于初步分析',
    };
  }
}

bool _isValidBar(StockDailyBar bar) {
  final prices = [bar.open, bar.high, bar.low, bar.close];
  if (prices.any((price) => !price.isFinite || price <= 0) || bar.volume < 0) {
    return false;
  }

  return bar.high >= bar.open &&
      bar.high >= bar.close &&
      bar.low <= bar.open &&
      bar.low <= bar.close &&
      bar.high >= bar.low;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _formatDate(DateTime value) {
  final year = value.year;
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
