enum ChartDisplayMode {
  line,
  candles,
}

class ChartCandleData {
  const ChartCandleData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  final double open;
  final double high;
  final double low;
  final double close;
}
