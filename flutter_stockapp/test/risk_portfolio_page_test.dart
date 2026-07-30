import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/tutorial/risk_portfolio_page.dart';
import 'package:flutter_stockapp/features/tutorial/tutorial_category_page.dart';

void main() {
  const topicTitles = [
    '风险是什么：亏损、波动与不确定性',
    '仓位是什么，为什么不能满仓一只股票',
    '分散投资与集中投资',
    '相关性与真正的分散',
    '波动率与最大回撤',
    '风险收益比、盈亏比与胜率',
    '止损的作用与局限',
    '杠杆、保证金与强制平仓',
    '如何为一笔交易设置风险上限',
  ];

  Future<void> pumpRiskPortfolioPage(
    WidgetTester tester, {
    Size viewSize = const Size(390, 844),
  }) async {
    tester.view
      ..physicalSize = viewSize
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

    await tester.tap(find.text('风险与投资组合'));
    await tester.pumpAndSettle();
  }

  Finder topicKey(String id) => find.byKey(ValueKey('tutorial-topic-$id'));

  Finder contentKey(String id) =>
      find.byKey(ValueKey('tutorial-topic-content-$id'));

  Future<void> tapTopic(WidgetTester tester, String id) async {
    await tester.ensureVisible(topicKey(id));
    await tester.pumpAndSettle();
    await tester.tap(topicKey(id));
    await tester.pumpAndSettle();
  }

  testWidgets('opens risk portfolio and renders nine topics', (tester) async {
    await pumpRiskPortfolioPage(tester);

    expect(find.byType(RiskPortfolioPage), findsOneWidget);
    expect(find.text('风险与投资组合'), findsOneWidget);
    for (final title in topicTitles) {
      expect(find.text(title), findsOneWidget);
    }

    final topicRows = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey<String> &&
          key.value.startsWith('tutorial-topic-') &&
          !key.value.startsWith('tutorial-topic-content-');
    });
    expect(topicRows, findsNWidgets(9));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the risk portfolio accordion controlled', (tester) async {
    await pumpRiskPortfolioPage(tester);

    await tapTopic(tester, 'risk-basics');
    expect(contentKey('risk-basics'), findsOneWidget);

    await tapTopic(tester, 'position-sizing');
    expect(contentKey('risk-basics'), findsNothing);
    expect(contentKey('position-sizing'), findsOneWidget);

    await tapTopic(tester, 'position-sizing');
    expect(contentKey('position-sizing'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders key risk concepts and five educational diagrams', (
    tester,
  ) async {
    await pumpRiskPortfolioPage(tester);

    await tapTopic(tester, 'risk-basics');
    expect(find.textContaining('市场风险'), findsAtLeastNWidgets(1));
    expect(find.textContaining('公司风险'), findsAtLeastNWidgets(1));
    expect(find.textContaining('流动性风险'), findsAtLeastNWidgets(1));
    expect(find.textContaining('杠杆风险'), findsAtLeastNWidgets(1));

    await tapTopic(tester, 'position-sizing');
    expect(find.textContaining('仓位'), findsAtLeastNWidgets(1));
    expect(find.textContaining('满仓'), findsAtLeastNWidgets(1));
    expect(find.textContaining('账户影响'), findsAtLeastNWidgets(1));
    expect(
      find.byKey(const ValueKey('position-impact-teaching-diagram')),
      findsOneWidget,
    );

    await tapTopic(tester, 'diversification-concentration');
    expect(find.textContaining('分散投资'), findsAtLeastNWidgets(1));
    expect(find.textContaining('集中投资'), findsAtLeastNWidgets(1));
    expect(find.textContaining('市场整体风险'), findsAtLeastNWidgets(1));

    await tapTopic(tester, 'correlation');
    expect(find.textContaining('相关性'), findsAtLeastNWidgets(1));
    expect(find.textContaining('高相关'), findsAtLeastNWidgets(1));
    expect(find.textContaining('低相关'), findsAtLeastNWidgets(1));
    expect(find.textContaining('银行 A'), findsAtLeastNWidgets(1));
    expect(
      find.byKey(const ValueKey('correlation-teaching-diagram')),
      findsOneWidget,
    );

    await tapTopic(tester, 'volatility-drawdown');
    expect(find.textContaining('波动率'), findsAtLeastNWidgets(1));
    expect(find.textContaining('最大回撤'), findsAtLeastNWidgets(1));
    expect(find.textContaining('历史高点'), findsAtLeastNWidgets(1));
    expect(find.textContaining('后续低点'), findsAtLeastNWidgets(1));
    expect(
      find.byKey(const ValueKey('volatility-drawdown-teaching-diagram')),
      findsOneWidget,
    );

    await tapTopic(tester, 'risk-reward-win-rate');
    expect(find.textContaining('风险收益比'), findsAtLeastNWidgets(1));
    expect(find.textContaining('盈亏比'), findsAtLeastNWidgets(1));
    expect(find.textContaining('胜率'), findsAtLeastNWidgets(1));
    expect(find.textContaining('交易期望'), findsAtLeastNWidgets(1));
    expect(find.textContaining('最终仍亏损'), findsAtLeastNWidgets(1));

    await tapTopic(tester, 'stop-loss');
    expect(find.textContaining('止损'), findsAtLeastNWidgets(1));
    expect(find.textContaining('跳空'), findsAtLeastNWidgets(1));
    expect(find.textContaining('止损价格不等于保证成交价格'), findsOneWidget);

    await tapTopic(tester, 'leverage-margin');
    expect(find.textContaining('杠杆'), findsAtLeastNWidgets(1));
    expect(find.textContaining('保证金'), findsAtLeastNWidgets(1));
    expect(find.textContaining('强制平仓'), findsAtLeastNWidgets(1));
    expect(find.textContaining('融资利息'), findsAtLeastNWidgets(1));
    expect(
      find.byKey(const ValueKey('leverage-margin-teaching-diagram')),
      findsOneWidget,
    );

    await tapTopic(tester, 'trade-risk-limit');
    expect(find.textContaining('单笔风险上限'), findsAtLeastNWidgets(1));
    expect(find.textContaining('每股潜在损失'), findsAtLeastNWidgets(1));
    expect(find.textContaining('可买数量'), findsAtLeastNWidgets(1));
    expect(find.textContaining('滑点'), findsAtLeastNWidgets(1));
    expect(find.textContaining('组合整体风险'), findsAtLeastNWidgets(1));
    expect(
      find.byKey(const ValueKey('trade-risk-flow-teaching-diagram')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders leverage and margin flow diagram on small screens', (
    tester,
  ) async {
    await pumpRiskPortfolioPage(tester, viewSize: const Size(360, 640));

    await tapTopic(tester, 'leverage-margin');

    final diagram = find.byKey(
      const ValueKey('leverage-margin-teaching-diagram'),
    );
    expect(diagram, findsOneWidget);
    expect(tester.getSize(diagram).width, lessThanOrEqualTo(360));
    expect(tester.takeException(), isNull);
  });
}
