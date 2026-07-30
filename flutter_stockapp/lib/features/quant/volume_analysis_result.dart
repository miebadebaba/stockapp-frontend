enum PriceDirection { up, flat, down }

class VolumeAnalysisResult {
  const VolumeAnalysisResult({
    required this.latestVolume,
    required this.averageVolume,
    required this.volumeRatio,
    required this.priceDirection,
  });

  final int latestVolume;
  final double averageVolume;
  final double volumeRatio;
  final PriceDirection priceDirection;
}
