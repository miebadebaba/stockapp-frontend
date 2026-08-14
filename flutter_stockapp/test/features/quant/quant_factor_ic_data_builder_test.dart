import 'package:flutter_stockapp/features/quant/quant_factor_ic_data_builder.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildQuantFactorIcCrossSections', () {
    test('groups multiple stocks by date and calculates forward returns', () {
      final stockA = _buildBars(
        count: 40,
        initialPrice: 100,
        dailyChange: 0.8,
        initialVolume: 1000,
      );
      final stockB = _buildBars(
        count: 40,
        initialPrice: 200,
        dailyChange: 0.4,
        initialVolume: 2000,
      );

      final sections = buildQuantFactorIcCrossSections(
        factorId: 'trend',
        barsByStock: {'A': stockA, 'B': stockB},
        holdingPeriod: 3,
        minimumLookback: 35,
      );

      expect(sections, hasLength(3));

      final firstSection = sections.first;

      expect(firstSection.date, stockA[34].tradingDate);
      expect(
        firstSection.factorValuesByStock.keys,
        unorderedEquals(['A', 'B']),
      );
      expect(
        firstSection.forwardReturnsByStock.keys,
        unorderedEquals(['A', 'B']),
      );

      final expectedReturnA = stockA[37].close / stockA[35].open - 1;
      final expectedReturnB = stockB[37].close / stockB[35].open - 1;

      expect(
        firstSection.forwardReturnsByStock['A'],
        closeTo(expectedReturnA, 0.000001),
      );
      expect(
        firstSection.forwardReturnsByStock['B'],
        closeTo(expectedReturnB, 0.000001),
      );

      expect(firstSection.factorValuesByStock['A']!.isFinite, isTrue);
      expect(firstSection.factorValuesByStock['B']!.isFinite, isTrue);
    });

    test('sorts input bars and output cross-sections by date', () {
      final reversedBars = _buildBars(
        count: 40,
        initialPrice: 100,
        dailyChange: 0.8,
        initialVolume: 1000,
      ).reversed.toList();

      final sections = buildQuantFactorIcCrossSections(
        factorId: 'trend',
        barsByStock: {'A': reversedBars},
        holdingPeriod: 3,
        minimumLookback: 35,
      );

      expect(sections, hasLength(3));

      for (var index = 1; index < sections.length; index++) {
        expect(sections[index].date.isAfter(sections[index - 1].date), isTrue);
      }

      expect(sections.first.date, DateTime(2026, 2, 4));
      expect(sections.last.date, DateTime(2026, 2, 6));
    });

    test('does not create sections without enough future bars', () {
      final bars = _buildBars(
        count: 40,
        initialPrice: 100,
        dailyChange: 0.8,
        initialVolume: 1000,
      );

      final sections = buildQuantFactorIcCrossSections(
        factorId: 'trend',
        barsByStock: {'A': bars},
        holdingPeriod: 3,
        minimumLookback: 35,
      );

      expect(sections.last.date, bars[36].tradingDate);

      expect(
        sections.any(
          (section) =>
              section.date.isAtSameMomentAs(bars[37].tradingDate) ||
              section.date.isAtSameMomentAs(bars[38].tradingDate) ||
              section.date.isAtSameMomentAs(bars[39].tradingDate),
        ),
        isFalse,
      );
    });

    test('future price changes return but not historical factor score', () {
      final originalBars = _buildBars(
        count: 40,
        initialPrice: 100,
        dailyChange: 0.8,
        initialVolume: 1000,
      );

      final changedBars = [...originalBars];
      final futureBar = changedBars[37];

      changedBars[37] = StockDailyBar(
        tradingDate: futureBar.tradingDate,
        open: futureBar.open,
        high: 251,
        low: futureBar.low,
        close: 250,
        volume: futureBar.volume,
      );

      final originalSections = buildQuantFactorIcCrossSections(
        factorId: 'trend',
        barsByStock: {'A': originalBars},
        holdingPeriod: 3,
        minimumLookback: 35,
      );

      final changedSections = buildQuantFactorIcCrossSections(
        factorId: 'trend',
        barsByStock: {'A': changedBars},
        holdingPeriod: 3,
        minimumLookback: 35,
      );

      final originalFirst = originalSections.first;
      final changedFirst = changedSections.first;

      expect(
        changedFirst.factorValuesByStock['A'],
        closeTo(originalFirst.factorValuesByStock['A']!, 0.000001),
      );

      expect(
        changedFirst.forwardReturnsByStock['A'],
        isNot(closeTo(originalFirst.forwardReturnsByStock['A']!, 0.000001)),
      );
    });

    test('rejects invalid parameters', () {
      expect(
        () => buildQuantFactorIcCrossSections(
          factorId: ' ',
          barsByStock: const {},
        ),
        throwsArgumentError,
      );

      expect(
        () => buildQuantFactorIcCrossSections(
          factorId: 'trend',
          barsByStock: const {},
          holdingPeriod: 0,
        ),
        throwsArgumentError,
      );

      expect(
        () => buildQuantFactorIcCrossSections(
          factorId: 'trend',
          barsByStock: const {},
          minimumLookback: 34,
        ),
        throwsArgumentError,
      );
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

    return StockDailyBar(
      tradingDate: DateTime(2026, 1, 1).add(Duration(days: index)),
      open: close - 0.2,
      high: close + 0.5,
      low: close - 0.5,
      close: close,
      volume: initialVolume + index * 20,
    );
  });
}
