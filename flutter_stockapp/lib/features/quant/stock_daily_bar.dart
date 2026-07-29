class StockDailyBar {
  const StockDailyBar({
    required this.tradingDate,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final DateTime tradingDate;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;
}
