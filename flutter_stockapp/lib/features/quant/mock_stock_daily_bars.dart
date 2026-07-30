import 'dart:math';

import 'stock_daily_bar.dart';

final mockStockDailyBars = <String, List<StockDailyBar>>{
  '600519': _buildBars(
    latestClose: 1505.00,
    baseVolume: 3258400,
    variation: 1.0,
  ),
  '000001': _buildBars(
    latestClose: 11.61,
    baseVolume: 58426100,
    variation: 0.8,
  ),
  '300750': _buildBars(
    latestClose: 217.45,
    baseVolume: 26317400,
    variation: 1.2,
  ),
  '601318': _buildBars(
    latestClose: 52.76,
    baseVolume: 41852600,
    variation: 0.7,
  ),
  '000858': _buildBars(
    latestClose: 130.45,
    baseVolume: 15729400,
    variation: 0.9,
  ),
  '600036': _buildBars(
    latestClose: 42.62,
    baseVolume: 47381600,
    variation: 0.6,
  ),
  '002594': _buildBars(
    latestClose: 290.15,
    baseVolume: 22457300,
    variation: 1.1,
  ),
  '600276': _buildBars(
    latestClose: 49.85,
    baseVolume: 19364800,
    variation: 0.75,
  ),
};

final _tradingDates = <DateTime>[
  DateTime(2026, 5, 28),
  DateTime(2026, 5, 29),
  DateTime(2026, 6, 1),
  DateTime(2026, 6, 2),
  DateTime(2026, 6, 3),
  DateTime(2026, 6, 4),
  DateTime(2026, 6, 5),
  DateTime(2026, 6, 8),
  DateTime(2026, 6, 9),
  DateTime(2026, 6, 10),
  DateTime(2026, 6, 11),
  DateTime(2026, 6, 12),
  DateTime(2026, 6, 15),
  DateTime(2026, 6, 16),
  DateTime(2026, 6, 17),
  DateTime(2026, 6, 18),
  DateTime(2026, 6, 19),
  DateTime(2026, 6, 22),
  DateTime(2026, 6, 23),
  DateTime(2026, 6, 24),
  DateTime(2026, 6, 25),
  DateTime(2026, 6, 26),
  DateTime(2026, 6, 29),
  DateTime(2026, 6, 30),
  DateTime(2026, 7, 1),
  DateTime(2026, 7, 2),
  DateTime(2026, 7, 3),
  DateTime(2026, 7, 6),
  DateTime(2026, 7, 7),
  DateTime(2026, 7, 8),
  DateTime(2026, 7, 9),
  DateTime(2026, 7, 10),
  DateTime(2026, 7, 13),
  DateTime(2026, 7, 14),
  DateTime(2026, 7, 15),
  DateTime(2026, 7, 16),
  DateTime(2026, 7, 17),
  DateTime(2026, 7, 20),
  DateTime(2026, 7, 21),
  DateTime(2026, 7, 22),
];

const _closeOffsets = <double>[
  -0.060,
  -0.057,
  -0.059,
  -0.055,
  -0.052,
  -0.054,
  -0.049,
  -0.046,
  -0.048,
  -0.043,
  -0.040,
  -0.042,
  -0.038,
  -0.035,
  -0.037,
  -0.033,
  -0.030,
  -0.034,
  -0.031,
  -0.035,
  -0.032,
  -0.027,
  -0.029,
  -0.022,
  -0.018,
  -0.021,
  -0.014,
  -0.010,
  -0.013,
  -0.006,
  -0.002,
  -0.005,
  0.003,
  0.007,
  0.004,
  0.012,
  0.016,
  0.013,
  0.021,
  0.000,
];

List<StockDailyBar> _buildBars({
  required double latestClose,
  required int baseVolume,
  required double variation,
}) {
  return List.generate(_tradingDates.length, (index) {
    final close = _roundPrice(
      latestClose * (1 + _closeOffsets[index] * variation),
    );
    final open = _roundPrice(close * (index.isEven ? 0.996 : 1.004));
    final high = _roundPrice(max(open, close) * 1.006);
    final low = _roundPrice(min(open, close) * 0.994);
    final volume = (baseVolume * (0.82 + (index % 5) * 0.06)).round();

    return StockDailyBar(
      tradingDate: _tradingDates[index],
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  });
}

double _roundPrice(double value) {
  return double.parse(value.toStringAsFixed(2));
}
