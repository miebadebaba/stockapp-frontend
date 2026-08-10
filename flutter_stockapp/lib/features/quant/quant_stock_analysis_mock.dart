import 'dart:math' as math;

import 'macd_calculator.dart';
import 'mock_stock_daily_bars.dart';
import 'mock_stock_quotes.dart';
import 'moving_average_calculator.dart';
import 'quant_stock_analysis.dart';
import 'rsi_calculator.dart';
import 'stock_daily_bar.dart';
import 'stock_quote.dart';
import 'technical_summary_analyzer.dart';
import 'volume_analyzer.dart';

QuantStockAnalysis buildMockQuantStockAnalysis(String symbol) {
  final normalizedSymbol = _normalizeSymbol(symbol);
  final bars = List<StockDailyBar>.unmodifiable(_resolveBars(normalizedSymbol));
  final latestBar =
      mockStockQuotes[normalizedSymbol] ?? _quoteFromBars(bars);
  final ma5 = calculateMovingAverage(bars: bars, period: 5);
  final ma10 = calculateMovingAverage(bars: bars, period: 10);
  final ma20 = calculateMovingAverage(bars: bars, period: 20);
  final macd = calculateMacd(bars: bars);
  final rsi14 = calculateRsi(bars: bars);
  final volume = analyzeVolume(bars: bars);
  final technicalSummary = analyzeTechnicalSummary(
    bars: bars,
    rsi: rsi14,
    macd: macd,
    volume: volume,
  );

  return QuantStockAnalysis(
    symbol: normalizedSymbol,
    bars: bars,
    latestBar: latestBar,
    ma5: ma5,
    ma10: ma10,
    ma20: ma20,
    macd: macd,
    rsi14: rsi14,
    volume: volume,
    technicalSummary: technicalSummary,
    dataSourceName: 'Built-in mock data',
    isSimulated: true,
  );
}

List<StockDailyBar> _resolveBars(String symbol) {
  final predefined = mockStockDailyBars[symbol];
  if (predefined != null && predefined.isNotEmpty) {
    return predefined;
  }

  return _generateBars(symbol);
}

List<StockDailyBar> _generateBars(String symbol) {
  final seed = symbol.runes.fold<int>(0, (sum, rune) => sum + rune);
  final random = math.Random(seed);
  final templateBars = mockStockDailyBars.values.first;
  final latestClose = 18 + (seed % 240) + random.nextDouble() * 12;
  final baseVolume = 1200000 + (seed % 9000000);
  var previousClose = latestClose * (0.92 + random.nextDouble() * 0.06);

  return List<StockDailyBar>.generate(templateBars.length, (index) {
    final drift = (index / templateBars.length) * (0.06 + random.nextDouble() * 0.04);
    final wave = math.sin((index + seed % 7) / 4) * 0.018;
    final close = _roundPrice(latestClose * (0.9 + drift + wave));
    final open = _roundPrice(previousClose * (0.995 + random.nextDouble() * 0.01));
    final high = _roundPrice(
      math.max(open, close) * (1.002 + random.nextDouble() * 0.02),
    );
    final low = _roundPrice(
      math.min(open, close) * (0.98 + random.nextDouble() * 0.015),
    );
    final volume = (baseVolume * (0.82 + random.nextDouble() * 0.4)).round();

    previousClose = close;

    return StockDailyBar(
      tradingDate: templateBars[index].tradingDate,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  });
}

StockQuote _quoteFromBars(List<StockDailyBar> bars) {
  final latest = bars.last;
  final previous = bars.length > 1 ? bars[bars.length - 2] : latest;

  return StockQuote(
    tradingDate: latest.tradingDate,
    open: latest.open,
    high: latest.high,
    low: latest.low,
    close: latest.close,
    previousClose: previous.close,
    volume: latest.volume,
  );
}

String _normalizeSymbol(String symbol) {
  return symbol.trim().toUpperCase().split('.').first;
}

double _roundPrice(double value) {
  return double.parse(value.toStringAsFixed(2));
}
