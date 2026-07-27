import 'stock_daily_bar.dart';
import 'volume_analysis_result.dart';

VolumeAnalysisResult? analyzeVolume({
  required List<StockDailyBar> bars,
  int baselinePeriod = 5,
}) {
  if (baselinePeriod <= 0) {
    throw ArgumentError.value(baselinePeriod, 'baselinePeriod', '比较周期必须大于0');
  }

  if (bars.length < baselinePeriod + 1) {
    return null;
  }

  final latestBar = bars.last;
  final previousBar = bars[bars.length - 2];
  final baselineStartIndex = bars.length - baselinePeriod - 1;

  var totalVolume = 0.0;

  for (var index = baselineStartIndex; index < bars.length - 1; index++) {
    final volume = bars[index].volume;

    if (volume < 0) {
      return null;
    }

    totalVolume += volume;
  }

  if (latestBar.volume < 0) {
    return null;
  }

  final averageVolume = totalVolume / baselinePeriod;

  if (averageVolume <= 0) {
    return null;
  }

  final priceDirection = switch (latestBar.close.compareTo(previousBar.close)) {
    > 0 => PriceDirection.up,
    < 0 => PriceDirection.down,
    _ => PriceDirection.flat,
  };

  return VolumeAnalysisResult(
    latestVolume: latestBar.volume,
    averageVolume: averageVolume,
    volumeRatio: latestBar.volume / averageVolume,
    priceDirection: priceDirection,
  );
}
