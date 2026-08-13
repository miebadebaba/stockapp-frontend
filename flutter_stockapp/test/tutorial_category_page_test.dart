import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/tutorial/simulation_app_guide_page.dart';
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

  testWidgets('opens simulation app guide and renders scrollable modules', (
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

    expect(find.byType(SimulationAppGuidePage), findsOneWidget);
    expect(find.byType(TutorialModulePlaceholderPage), findsNothing);
    expect(find.text('模拟交易与 App 使用'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    expect(find.text('认识主要功能'), findsOneWidget);
    expect(find.text('开始模拟交易'), findsOneWidget);
    expect(find.text('查看账户与重置'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('simulation-app-guide-scroll')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(find.text('使用提醒'), findsOneWidget);
    expect(find.textContaining('不涉及真实资金'), findsOneWidget);
  });
}
