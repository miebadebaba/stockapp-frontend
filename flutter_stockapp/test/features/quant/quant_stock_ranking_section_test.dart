import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_score_calculator.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_analysis_mock.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_catalog.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_ranking.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_ranking_section.dart';
import 'package:flutter_stockapp/features/quant/selected_stock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_preset.dart';

void main() {
  testWidgets('显示市场、排序方式和股票排名', (tester) async {
    final firstStock = quantStockCatalog[0];
    final secondStock = quantStockCatalog[1];
    final firstAnalysis = buildMockQuantStockAnalysis(firstStock.code);
    final secondAnalysis = buildMockQuantStockAnalysis(secondStock.code);

    final result = QuantStockRankingResult(
      sortBy: QuantRankingSort.riskAdjustedScore,
      items: [
        QuantStockRankingItem(
          rank: 1,
          stock: firstStock,
          analysis: firstAnalysis,
          score: calculateQuantFactorScore(analysis: firstAnalysis),
        ),
        QuantStockRankingItem(
          rank: 2,
          stock: secondStock,
          analysis: secondAnalysis,
          score: calculateQuantFactorScore(analysis: secondAnalysis),
        ),
      ],
    );

    SelectedStock? selectedStock;
    QuantFactorPresetType? selectedPresetType;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuantStockRankingSection(
              result: result,
              market: QuantMarket.aShare,
              presetType: QuantFactorPresetType.balanced,
              isLoading: false,
              onMarketChanged: (_) {},
              onPresetChanged: (presetType) {
                selectedPresetType = presetType;
              },
              onSortChanged: (_) {},
              onRefresh: () {},
              onStockSelected: (stock) {
                selectedStock = stock;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('股票池筛选'), findsOneWidget);
    expect(find.text('排序方式'), findsOneWidget);
    expect(find.text('风险调整分'), findsWidgets);
    expect(find.text(firstStock.name), findsOneWidget);
    expect(find.text(secondStock.name), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('策略偏好'), findsOneWidget);
    expect(find.text('稳健型'), findsOneWidget);
    expect(find.text('均衡型'), findsOneWidget);
    expect(find.text('进取型'), findsOneWidget);

    await tester.tap(find.text('进取型'));
    await tester.pump();

    expect(selectedPresetType, QuantFactorPresetType.aggressive);

    await tester.tap(find.text(firstStock.name));
    await tester.pump();

    expect(selectedStock?.code, firstStock.code);
  });

  testWidgets('加载时显示排名进度', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantStockRankingSection(
            result: null,
            market: QuantMarket.aShare,
            presetType: QuantFactorPresetType.balanced,
            isLoading: true,
            onMarketChanged: (_) {},
            onPresetChanged: (_) {},
            onSortChanged: (_) {},
            onRefresh: () {},
            onStockSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('正在计算股票池排名...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
