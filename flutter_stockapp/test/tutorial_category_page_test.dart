import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/tutorial/tutorial_category_page.dart';

void main() {
  testWidgets('shows six stock tutorial modules in a two-column grid', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: TutorialCategoryPage.demo(topPadding: 16, bottomPadding: 16),
      ),
    );
    await tester.pumpAndSettle();

    const moduleNames = [
      '股票与行情基础',
      '交易入门',
      '公司与基本面分析',
      '技术指标与量化分析',
      '风险与投资组合',
      '模拟交易与 App 使用',
    ];
    for (final moduleName in moduleNames) {
      expect(find.text(moduleName), findsOneWidget);
    }

    expect(find.byType(TutorialCategoryTile), findsNWidgets(6));
    expect(find.text('Arts'), findsNothing);
    expect(find.text('Biology & Life Sciences'), findsNothing);

    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens a minimal placeholder for the tapped module', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: TutorialCategoryPage.demo(topPadding: 16, bottomPadding: 16),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('模拟交易与 App 使用'));
    await tester.pumpAndSettle();

    expect(find.byType(TutorialModulePlaceholderPage), findsOneWidget);
    expect(find.text('模拟交易与 App 使用'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });
}
