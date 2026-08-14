import 'package:flutter_stockapp/features/quant/quant_factor_ic.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_ic_analysis_calculator.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateQuantFactorIcAnalysis', () {
    test('builds historical samples and calculates IC results', () {
      const dailyChanges = [-0.8, -0.4, -0.15, 0.2, 0.6, 1.0];

      final barsByStock = <String, List<StockDailyBar>>{
        for (var index = 0; index < dailyChanges.length; index++)
          'STOCK_$index': _buildBars(
            count: 45,
            initialPrice: 100,
            dailyChange: dailyChanges[index],
            initialVolume: 1000 + index * 100,
          ),
      };

      final result = calculateQuantFactorIcAnalysis(
        factorId: 'trend',
        barsByStock: barsByStock,
        holdingPeriod: 3,
        minimumLookback: 35,
        minimumSampleSize: 3,
      );

      expect(result.factorId, 'trend');

      // 45 个交易日，前 35 日作为观察期，最后 3 日留给未来收益。
      expect(result.periods, hasLength(8));
      expect(result.availablePeriodCount, 8);
      expect(result.averageSampleSize, 6);

      for (final period in result.periods) {
        expect(period.sampleSize, 6);
        expect(period.isAvailable, isTrue);
        expect(period.informationCoefficient, isNotNull);
        expect(period.rankInformationCoefficient, isNotNull);
      }

      expect(result.averageInformationCoefficient, greaterThan(0));
      expect(result.averageRankInformationCoefficient, greaterThan(0));

      expect(result.positiveInformationCoefficientRate, closeTo(1, 0.000001));
      expect(
        result.positiveRankInformationCoefficientRate,
        closeTo(1, 0.000001),
      );

      // 有效周期和平均股票数量均已达到 5，但尚未达到 20。
      expect(result.reliability, QuantFactorIcReliability.limited);
    });

    test('returns an empty insufficient result without stock data', () {
      final result = calculateQuantFactorIcAnalysis(
        factorId: 'trend',
        barsByStock: const {},
      );

      expect(result.factorId, 'trend');
      expect(result.periods, isEmpty);
      expect(result.availablePeriodCount, 0);
      expect(result.averageSampleSize, 0);

      expect(result.averageInformationCoefficient, isNull);
      expect(result.averageRankInformationCoefficient, isNull);
      expect(result.positiveInformationCoefficientRate, isNull);
      expect(result.positiveRankInformationCoefficientRate, isNull);
      expect(result.icInformationRatio, isNull);
      expect(result.rankIcInformationRatio, isNull);

      expect(result.reliability, QuantFactorIcReliability.insufficient);
    });
  });
}

List<StockDailyBar> _buildBars({
  required int count,
  required double initialPrice,
  required double dailyChange,
  required int initialVolume,
}) {
  return List.generate(count, (index) {
    final close = initialPrice + index * dailyChange;
    final previousClose = index == 0
        ? initialPrice
        : initialPrice + (index - 1) * dailyChange;
    final open = previousClose + dailyChange * 0.25;

    return StockDailyBar(
      tradingDate: DateTime(2026, 1, 1).add(Duration(days: index)),
      open: open,
      high: (open > close ? open : close) + 0.5,
      low: (open < close ? open : close) - 0.5,
      close: close,
      volume: initialVolume + index * 20,
    );
  });
}
