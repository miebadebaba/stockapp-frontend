import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_search_sheet.dart';
import 'package:flutter_stockapp/features/quant/selected_stock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/features/quant/quant_pool_controller.dart';

void main() {
  testWidgets('returns a custom six digit A-share code', (tester) async {
    final selectedStock = await _selectStock(tester, input: '000333');

    expect(selectedStock?.code, '000333');
    expect(selectedStock?.name, 'A股代码');
    expect(selectedStock?.market, QuantMarket.aShare);
  });

  testWidgets('rejects an incomplete A-share code', (tester) async {
    await _pumpSearchSheet(tester);

    await tester.enterText(find.byType(TextField), '12345');
    await tester.pumpAndSettle();

    expect(find.text('A股代码'), findsNothing);
    expect(find.text('未找到匹配的A股股票'), findsOneWidget);
  });

  testWidgets('normalizes and returns a custom Hong Kong code', (tester) async {
    final selectedStock = await _selectStock(
      tester,
      market: QuantMarket.hongKong,
      input: '123',
    );

    expect(selectedStock?.code, '00123.HK');
    expect(selectedStock?.name, '港股代码');
    expect(selectedStock?.market, QuantMarket.hongKong);
  });

  testWidgets('returns a custom United States stock code', (tester) async {
    final selectedStock = await _selectStock(
      tester,
      market: QuantMarket.unitedStates,
      input: 'AMD',
    );

    expect(selectedStock?.code, 'AMD');
    expect(selectedStock?.name, '美股代码');
    expect(selectedStock?.market, QuantMarket.unitedStates);
  });
  testWidgets('批量模式显示分析池中的自定义股票', (tester) async {
    final controller = QuantPoolController(
      initialStocks: const [
        SelectedStock(
          code: 'AMD',
          name: '美股代码',
          market: QuantMarket.unitedStates,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantStockSearchSheet(quantPoolController: controller),
        ),
      ),
    );

    await tester.tap(find.text('批量管理'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('美股').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'AMD');
    await tester.pumpAndSettle();

    expect(find.text('AMD · 美股 · 已在池中'), findsOneWidget);
  });
}

Future<void> _pumpSearchSheet(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: QuantStockSearchSheet()),
    ),
  );
}

Future<SelectedStock?> _selectStock(
  WidgetTester tester, {
  QuantMarket market = QuantMarket.aShare,
  required String input,
}) async {
  SelectedStock? selectedStock;

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: TextButton(
              key: const ValueKey('open-search'),
              onPressed: () async {
                selectedStock = await showModalBottomSheet<SelectedStock>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const FractionallySizedBox(
                    heightFactor: 0.75,
                    child: QuantStockSearchSheet(),
                  ),
                );
              },
              child: const Text('打开'),
            ),
          );
        },
      ),
    ),
  );

  await tester.tap(find.byKey(const ValueKey('open-search')));
  await tester.pumpAndSettle();

  if (market != QuantMarket.aShare) {
    await tester.tap(find.text(market.label).first);
    await tester.pumpAndSettle();
  }

  await tester.enterText(find.byType(TextField), input);
  await tester.pumpAndSettle();

  final normalizedCode = switch (market) {
    QuantMarket.aShare => input,
    QuantMarket.hongKong => '${input.padLeft(5, '0')}.HK',
    QuantMarket.unitedStates => input.toUpperCase(),
  };

  final stockTile = find.widgetWithText(
    ListTile,
    '$normalizedCode · ${market.label}',
  );
  expect(stockTile, findsOneWidget);

  await tester.tap(stockTile);
  await tester.pumpAndSettle();

  return selectedStock;
}
