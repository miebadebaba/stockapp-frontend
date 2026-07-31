import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_search_sheet.dart';
import 'package:flutter_stockapp/features/quant/selected_stock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('returns a custom six digit A-share code', (tester) async {
    SelectedStock? selectedStock;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  selectedStock = await showModalBottomSheet<SelectedStock>(
                    context: context,
                    builder: (_) => const QuantStockSearchSheet(),
                  );
                },
                child: const Text('打开'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '000333');
    await tester.pumpAndSettle();

    expect(find.text('A股代码'), findsOneWidget);
    final customCodeTile = find.widgetWithText(ListTile, '000333');
    expect(customCodeTile, findsOneWidget);

    await tester.tap(customCodeTile);
    await tester.pumpAndSettle();

    expect(selectedStock?.code, '000333');
    expect(selectedStock?.name, 'A股代码');
  });

  testWidgets('rejects an incomplete stock code', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: QuantStockSearchSheet()),
      ),
    );

    await tester.enterText(find.byType(TextField), '12345');
    await tester.pumpAndSettle();

    expect(find.text('A股代码'), findsNothing);
    expect(find.text('未找到匹配的 A 股'), findsOneWidget);
  });
}
