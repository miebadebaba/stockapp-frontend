import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/tutorial/trading_basics_page.dart';
import 'package:flutter_stockapp/features/tutorial/tutorial_category_page.dart';

void main() {
  const topicTitles = [
    '如何开始交易：开户、入金与账户选择',
    '买入前需要决定什么：股票、价格与数量',
    '市价单与限价单',
    '买一、卖一、盘口与买卖价差',
    '挂单、部分成交、撤单与滑点',
    '持仓、成本、市值与可用资金',
    '浮动盈亏、已实现盈亏与当日盈亏',
    '佣金、税费、平台费与换汇成本',
    '从买入到卖出：完成一笔交易',
  ];

  Future<void> pumpTradingBasicsPage(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
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

    await tester.tap(find.text('交易入门'));
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

  testWidgets(
    'opens trading basics from Tutorial home and renders nine topics',
    (tester) async {
      await pumpTradingBasicsPage(tester);

      expect(find.byType(TradingBasicsPage), findsOneWidget);
      expect(find.text('交易入门'), findsOneWidget);
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
    },
  );

  testWidgets('keeps the trading basics accordion controlled', (tester) async {
    await pumpTradingBasicsPage(tester);

    await tapTopic(tester, 'getting-started');
    expect(contentKey('getting-started'), findsOneWidget);

    await tapTopic(tester, 'decisions-before-buying');
    expect(contentKey('getting-started'), findsNothing);
    expect(contentKey('decisions-before-buying'), findsOneWidget);

    await tapTopic(tester, 'decisions-before-buying');
    expect(contentKey('decisions-before-buying'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders key trading education terms inside expected topics', (
    tester,
  ) async {
    await pumpTradingBasicsPage(tester);

    await tapTopic(tester, 'market-and-limit-orders');
    expect(find.text('市价单'), findsAtLeastNWidgets(1));
    expect(find.text('限价单'), findsAtLeastNWidgets(1));

    await tapTopic(tester, 'bid-ask-order-book');
    expect(find.textContaining('买一'), findsAtLeastNWidgets(1));
    expect(find.textContaining('卖一'), findsAtLeastNWidgets(1));
    expect(find.textContaining('买卖价差'), findsAtLeastNWidgets(1));

    await tapTopic(tester, 'profit-and-loss');
    expect(find.textContaining('浮动盈亏'), findsAtLeastNWidgets(1));
    expect(find.textContaining('已实现盈亏'), findsAtLeastNWidgets(1));
    expect(find.textContaining('当日盈亏'), findsAtLeastNWidgets(1));

    await tapTopic(tester, 'trading-costs');
    expect(find.textContaining('佣金'), findsAtLeastNWidgets(1));
    expect(find.textContaining('税费'), findsAtLeastNWidgets(1));
    expect(find.textContaining('换汇成本'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });
}
