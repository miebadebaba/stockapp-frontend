class StockQuote {
  const StockQuote({
    required this.tradingDate,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.previousClose,
    required this.volume,
  });

  final DateTime tradingDate;
  final double open;
  final double high;
  final double low;
  final double close;
  final double previousClose;
  final int volume;

  double get change => close - previousClose;

  double get changePercent {
    if (previousClose == 0) {
      return 0;
    }

    return change / previousClose * 100;
  }
}
