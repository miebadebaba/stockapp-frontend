import 'stock_daily_bar.dart';

List<Map<String, dynamic>> mapTechnicalSummaryRequest(
  List<StockDailyBar> bars,
) {
  return bars.map(_mapDailyBar).toList(growable: false);
}

Map<String, dynamic> _mapDailyBar(StockDailyBar bar) {
  return {
    'trade_date': _formatDate(bar.tradingDate),
    'open': bar.open,
    'high': bar.high,
    'low': bar.low,
    'close': bar.close,
    'volume': bar.volume,
  };
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}
