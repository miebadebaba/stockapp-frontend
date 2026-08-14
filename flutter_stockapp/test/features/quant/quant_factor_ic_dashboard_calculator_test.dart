import 'package:flutter_stockapp/features/quant/quant_factor_ic_dashboard.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_ic_dashboard_calculator.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_score_calculator.dart';
import 'package:flutter_stockapp/features/quant/quant_historical_analysis_builder.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_analysis.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_analysis_mock.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_ranking.dart';
import 'package:flutter_stockapp/features/quant/selected_stock.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateQuantFactorIcDashboard', () {
    test('calculates three factor results from real stock data', () {
      final rankingResult = _rankingResult([
        _realAnalysis('A', dailyChange: -0.6),
        _realAnalysis('B', dailyChange: 0.3),
        _realAnalysis('C', dailyChange: 0.9),
      ]);

      final result = calculateQuantFactorIcDashboard(
        rankingResult: rankingResult,
        holdingPeriod: 3,
        minimumLookback: 35,
        minimumSampleSize: 3,
      );

      expect(result.status, QuantFactorIcDashboardStatus.available);
      expect(result.realStockCount, 3);

      expect(
        result.factorResults.keys,
        unorderedEquals(['trend', 'momentum', 'volume']),
      );

      expect(result.resultFor('trend'), isNotNull);
      expect(result.resultFor('momentum'), isNotNull);
      expect(result.resultFor('volume'), isNotNull);
      expect(result.availableFactorCount, greaterThan(0));
    });

    test('excludes simulated stocks from the real stock count', () {
      final rankingResult = _rankingResult([
        _realAnalysis('REAL_A', dailyChange: 0.4),
        _realAnalysis('REAL_B', dailyChange: 0.8),
        buildMockQuantStockAnalysis('600519'),
        buildMockQuantStockAnalysis('300750'),
      ]);

      final result = calculateQuantFactorIcDashboard(
        rankingResult: rankingResult,
        minimumSampleSize: 3,
      );

      expect(
        result.status,
        QuantFactorIcDashboardStatus.insufficientRealStocks,
      );
      expect(result.realStockCount, 2);
      expect(result.factorResults, isEmpty);
      expect(result.isAvailable, isFalse);
    });

    test('reports insufficient history when future bars are unavailable', () {
      final rankingResult = _rankingResult([
        _realAnalysis('A', dailyChange: -0.6, barCount: 35),
        _realAnalysis('B', dailyChange: 0.3, barCount: 35),
        _realAnalysis('C', dailyChange: 0.9, barCount: 35),
      ]);

      final result = calculateQuantFactorIcDashboard(
        rankingResult: rankingResult,
        holdingPeriod: 3,
        minimumLookback: 35,
        minimumSampleSize: 3,
      );

      expect(result.status, QuantFactorIcDashboardStatus.insufficientHistory);
      expect(result.realStockCount, 3);
      expect(result.availableFactorCount, 0);

      for (final factorResult in result.factorResults.values) {
        expect(factorResult.availablePeriodCount, 0);
      }
    });

    test('rejects a minimum sample size smaller than two', () {
      expect(
        () => calculateQuantFactorIcDashboard(
          rankingResult: _rankingResult(const []),
          minimumSampleSize: 1,
        ),
        throwsArgumentError,
      );
    });
  });
}

QuantStockRankingResult _rankingResult(List<QuantStockAnalysis> analyses) {
  final items = <QuantStockRankingItem>[];

  for (var index = 0; index < analyses.length; index++) {
    final analysis = analyses[index];

    items.add(
      QuantStockRankingItem(
        rank: index + 1,
        stock: SelectedStock(code: analysis.symbol, name: analysis.symbol),
        analysis: analysis,
        score: calculateQuantFactorScore(analysis: analysis),
      ),
    );
  }

  return QuantStockRankingResult(
    items: List.unmodifiable(items),
    sortBy: QuantRankingSort.riskAdjustedScore,
  );
}

QuantStockAnalysis _realAnalysis(
  String symbol, {
  required double dailyChange,
  int barCount = 45,
}) {
  return buildHistoricalQuantStockAnalysis(
    symbol: symbol,
    bars: _buildBars(
      count: barCount,
      initialPrice: 100,
      dailyChange: dailyChange,
    ),
  );
}

List<StockDailyBar> _buildBars({
  required int count,
  required double initialPrice,
  required double dailyChange,
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
      volume: 1000 + index * 20,
    );
  });
}
