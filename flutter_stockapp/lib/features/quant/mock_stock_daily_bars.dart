import 'dart:math';

import 'stock_daily_bar.dart';

final mockStockDailyBars = <String, List<StockDailyBar>>{
  '600519': _buildBars(
    latestClose: 1505.00,
    baseVolume: 3258400,
    variation: 1.0,
    profile: _steadyProfile,
  ),
  '000001': _buildBars(
    latestClose: 11.61,
    baseVolume: 58426100,
    variation: 0.8,
    profile: _weakProfile,
  ),
  '300750': _buildBars(
    latestClose: 217.45,
    baseVolume: 26317400,
    variation: 1.2,
    profile: _strongProfile,
  ),
  '601318': _buildBars(
    latestClose: 52.76,
    baseVolume: 41852600,
    variation: 0.7,
    profile: _rangeProfile,
  ),
  '000858': _buildBars(
    latestClose: 130.45,
    baseVolume: 15729400,
    variation: 0.9,
    profile: _recoveryProfile,
  ),
  '600036': _buildBars(
    latestClose: 42.62,
    baseVolume: 47381600,
    variation: 0.6,
    profile: _pullbackProfile,
  ),
  '002594': _buildBars(
    latestClose: 290.15,
    baseVolume: 22457300,
    variation: 1.1,
    profile: _volatileProfile,
  ),
  '600276': _buildBars(
    latestClose: 49.85,
    baseVolume: 19364800,
    variation: 0.75,
    profile: _downtrendProfile,
  ),
};

class _MockSeriesProfile {
  const _MockSeriesProfile({
    required this.trend,
    required this.waveAmplitude,
    required this.waveFrequency,
    required this.phase,
    required this.pullbackAmplitude,
    required this.pullbackFrequency,
    required this.volumeAmplitude,
    required this.volumeFrequency,
  });

  final double trend;
  final double waveAmplitude;
  final double waveFrequency;
  final double phase;
  final double pullbackAmplitude;
  final double pullbackFrequency;
  final double volumeAmplitude;
  final double volumeFrequency;
}

const _steadyProfile = _MockSeriesProfile(
  trend: 0.018,
  waveAmplitude: 0.014,
  waveFrequency: 4.3,
  phase: 0.2,
  pullbackAmplitude: 0.009,
  pullbackFrequency: 8.0,
  volumeAmplitude: 0.12,
  volumeFrequency: 3.8,
);

const _weakProfile = _MockSeriesProfile(
  trend: -0.032,
  waveAmplitude: 0.010,
  waveFrequency: 5.2,
  phase: 1.3,
  pullbackAmplitude: 0.015,
  pullbackFrequency: 7.0,
  volumeAmplitude: 0.20,
  volumeFrequency: 4.7,
);

const _strongProfile = _MockSeriesProfile(
  trend: 0.075,
  waveAmplitude: 0.024,
  waveFrequency: 4.0,
  phase: 2.1,
  pullbackAmplitude: 0.011,
  pullbackFrequency: 9.0,
  volumeAmplitude: 0.30,
  volumeFrequency: 3.2,
);

const _rangeProfile = _MockSeriesProfile(
  trend: 0.004,
  waveAmplitude: 0.030,
  waveFrequency: 6.0,
  phase: 0.8,
  pullbackAmplitude: 0.018,
  pullbackFrequency: 10.0,
  volumeAmplitude: 0.16,
  volumeFrequency: 5.5,
);

const _recoveryProfile = _MockSeriesProfile(
  trend: 0.045,
  waveAmplitude: 0.018,
  waveFrequency: 5.7,
  phase: 2.9,
  pullbackAmplitude: 0.023,
  pullbackFrequency: 8.5,
  volumeAmplitude: 0.26,
  volumeFrequency: 4.1,
);

const _pullbackProfile = _MockSeriesProfile(
  trend: -0.012,
  waveAmplitude: 0.022,
  waveFrequency: 4.8,
  phase: 3.6,
  pullbackAmplitude: 0.020,
  pullbackFrequency: 6.5,
  volumeAmplitude: 0.22,
  volumeFrequency: 3.5,
);

const _volatileProfile = _MockSeriesProfile(
  trend: 0.055,
  waveAmplitude: 0.040,
  waveFrequency: 3.6,
  phase: 1.7,
  pullbackAmplitude: 0.028,
  pullbackFrequency: 5.8,
  volumeAmplitude: 0.38,
  volumeFrequency: 2.9,
);

const _downtrendProfile = _MockSeriesProfile(
  trend: -0.058,
  waveAmplitude: 0.019,
  waveFrequency: 4.4,
  phase: 4.2,
  pullbackAmplitude: 0.012,
  pullbackFrequency: 7.8,
  volumeAmplitude: 0.28,
  volumeFrequency: 4.4,
);

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

List<StockDailyBar> _buildBars({
  required double latestClose,
  required int baseVolume,
  required double variation,
  required _MockSeriesProfile profile,
}) {
  return List.generate(_tradingDates.length, (index) {
    final closeOffset = _closeOffset(index, profile);
    final close = _roundPrice(latestClose * (1 + closeOffset * variation));

    final openMultiplier = index.isEven ? 0.996 : 1.004;
    final open = _roundPrice(close * openMultiplier);
    final high = _roundPrice(max(open, close) * 1.006);
    final low = _roundPrice(min(open, close) * 0.994);

    final volumeMultiplier =
        0.82 +
        (index % 5) * 0.06 +
        profile.volumeAmplitude *
            sin((index + profile.phase) / profile.volumeFrequency);

    final volume = (baseVolume * volumeMultiplier.clamp(0.45, 1.55)).round();

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

double _closeOffset(int index, _MockSeriesProfile profile) {
  final lastIndex = _tradingDates.length - 1;

  double rawValue(int value) {
    return profile.trend * (value / lastIndex - 1) +
        profile.waveAmplitude *
            sin((value + profile.phase) / profile.waveFrequency) +
        profile.pullbackAmplitude *
            cos((value + profile.phase) / profile.pullbackFrequency);
  }

  return rawValue(index) - rawValue(lastIndex);
}

double _roundPrice(double value) {
  return double.parse(value.toStringAsFixed(2));
}
