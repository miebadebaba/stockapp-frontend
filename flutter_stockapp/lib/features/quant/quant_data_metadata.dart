enum PriceAdjustment { none, forward, backward, unknown }

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
  });

  final DateTime latestTradingDate;
  final String sourceName;
  final PriceAdjustment priceAdjustment;
  final bool isSimulated;

  String get formattedTradingDate {
    final year = latestTradingDate.year;
    final month = latestTradingDate.month.toString().padLeft(2, '0');
    final day = latestTradingDate.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
