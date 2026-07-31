import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/tutorial/stock_market_basics_page.dart';
import 'package:flutter_stockapp/features/tutorial/tutorial_category_page.dart';

void main() {
  const topicTitles = [
    '股票到底是什么',
    '股票是怎样被买卖的',
    '为什么股票价格会变化',
    '股票详情页上的数字怎么看',
    '涨跌额与涨跌幅',
    '开盘价、收盘价、最高价与最低价',
    'K线是什么',
    '分时图与K线图的区别',
    '市值、PE与PB',
  ];

  Future<void> pumpStockBasicsPage(WidgetTester tester) async {
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

    await tester.tap(find.text('股票与行情基础'));
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

  testWidgets('renders the final nine stock basics topics', (tester) async {
    await pumpStockBasicsPage(tester);

    expect(find.byType(StockMarketBasicsPage), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    for (final title in topicTitles) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.text('成交量与成交额'), findsNothing);

    final topicRows = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey<String> &&
          key.value.startsWith('tutorial-topic-') &&
          !key.value.startsWith('tutorial-topic-content-');
    });
    expect(topicRows, findsNWidgets(9));
    expect(tester.takeException(), isNull);
  });

  testWidgets('expands every topic, keeps one open, and toggles open topic', (
    tester,
  ) async {
    await pumpStockBasicsPage(tester);

    for (final topic in StockMarketBasicsPage.topics) {
      await tapTopic(tester, topic.id);
      expect(contentKey(topic.id), findsOneWidget);
    }

    await tapTopic(tester, 'what-is-a-stock');
    expect(contentKey('what-is-a-stock'), findsOneWidget);

    await tapTopic(tester, 'how-stocks-are-traded');
    expect(contentKey('what-is-a-stock'), findsNothing);
    expect(contentKey('how-stocks-are-traded'), findsOneWidget);

    await tapTopic(tester, 'how-stocks-are-traded');
    expect(contentKey('how-stocks-are-traded'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('moves volume and turnover explanation into topic 04', (
    tester,
  ) async {
    await pumpStockBasicsPage(tester);

    await tapTopic(tester, 'reading-stock-details');

    expect(find.textContaining('成交量表示'), findsOneWidget);
    expect(find.textContaining('成交额表示'), findsOneWidget);
    expect(find.text('今日涨跌'), findsOneWidget);
    expect(find.text('个人盈亏'), findsOneWidget);
    expect(find.text('股票贵不贵'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders educational diagrams and key valuation terms', (
    tester,
  ) async {
    await pumpStockBasicsPage(tester);

    await tapTopic(tester, 'candlestick-basics');
    expect(
      find.byKey(const ValueKey('k-line-educational-diagram')),
      findsOneWidget,
    );

    await tapTopic(tester, 'intraday-vs-candlestick');
    expect(contentKey('candlestick-basics'), findsNothing);
    expect(
      find.byKey(const ValueKey('intraday-kline-comparison-diagram')),
      findsOneWidget,
    );

    await tapTopic(tester, 'market-cap-pe-pb');
    expect(contentKey('intraday-vs-candlestick'), findsNothing);
    expect(find.text('市值'), findsAtLeastNWidgets(1));
    expect(find.text('PE'), findsAtLeastNWidgets(1));
    expect(find.text('PB'), findsAtLeastNWidgets(1));
    expect(find.textContaining('市值：整家公司当前在市场上值多少钱'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
