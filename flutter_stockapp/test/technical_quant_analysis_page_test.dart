import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/tutorial/technical_quant_analysis_page.dart';
import 'package:flutter_stockapp/features/tutorial/tutorial_category_page.dart';

void main() {
  const topicTitles = [
    '技术分析、技术指标、因子与策略有什么区别',
    '移动平均线 MA 与趋势',
    'MACD 是什么',
    'RSI 与超买、超卖',
    '成交量与量价关系',
    'VWAP 是什么',
    '趋势、震荡与指标冲突',
    '回测是什么，怎样判断策略是否有效',
    '过拟合、未来函数与量化分析的局限',
  ];

  Future<void> pumpTechnicalQuantPage(
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

    await tester.tap(find.text('技术指标与量化分析'));
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

  testWidgets('opens technical quant analysis and renders nine topics', (
    tester,
  ) async {
    await pumpTechnicalQuantPage(tester);

    expect(find.byType(TechnicalQuantAnalysisPage), findsOneWidget);
    expect(find.text('技术指标与量化分析'), findsOneWidget);
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

  testWidgets('keeps the technical quant accordion controlled', (tester) async {
    await pumpTechnicalQuantPage(tester);

    await tapTopic(tester, 'indicator-factor-signal-strategy');
    expect(contentKey('indicator-factor-signal-strategy'), findsOneWidget);

    await tapTopic(tester, 'ma-trend');
    expect(contentKey('indicator-factor-signal-strategy'), findsNothing);
    expect(contentKey('ma-trend'), findsOneWidget);

    await tapTopic(tester, 'ma-trend');
    expect(contentKey('ma-trend'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders key concepts and all educational diagrams', (
    tester,
  ) async {
    await pumpTechnicalQuantPage(tester);

    await tapTopic(tester, 'indicator-factor-signal-strategy');
    expect(find.textContaining('技术指标'), findsAtLeastNWidgets(1));
    expect(find.textContaining('因子'), findsAtLeastNWidgets(1));
    expect(find.textContaining('信号'), findsAtLeastNWidgets(1));
    expect(find.textContaining('策略'), findsAtLeastNWidgets(1));

    await tapTopic(tester, 'ma-trend');
    expect(find.textContaining('MA'), findsAtLeastNWidgets(1));
    expect(find.textContaining('金叉'), findsAtLeastNWidgets(1));
    expect(find.textContaining('死叉'), findsAtLeastNWidgets(1));
    expect(find.byKey(const ValueKey('ma-teaching-diagram')), findsOneWidget);

    await tapTopic(tester, 'macd');
    expect(find.textContaining('MACD'), findsAtLeastNWidgets(1));
    expect(find.textContaining('DIF'), findsAtLeastNWidgets(1));
    expect(find.textContaining('DEA'), findsAtLeastNWidgets(1));
    expect(find.byKey(const ValueKey('macd-teaching-diagram')), findsOneWidget);

    await tapTopic(tester, 'rsi');
    expect(find.textContaining('RSI'), findsAtLeastNWidgets(1));
    expect(find.textContaining('超买'), findsAtLeastNWidgets(1));
    expect(find.textContaining('超卖'), findsAtLeastNWidgets(1));
    expect(find.textContaining('70'), findsAtLeastNWidgets(1));
    expect(find.textContaining('30'), findsAtLeastNWidgets(1));
    expect(find.byKey(const ValueKey('rsi-teaching-diagram')), findsOneWidget);

    await tapTopic(tester, 'volume-price');
    expect(find.textContaining('放量'), findsAtLeastNWidgets(1));
    expect(find.textContaining('缩量'), findsAtLeastNWidgets(1));
    expect(find.textContaining('量比'), findsAtLeastNWidgets(1));
    expect(find.textContaining('近期平均成交量'), findsAtLeastNWidgets(1));
    expect(find.textContaining('盘中不能直接与完整交易日比较'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('volume-teaching-diagram')),
      findsOneWidget,
    );

    await tapTopic(tester, 'vwap');
    expect(find.textContaining('VWAP'), findsAtLeastNWidgets(1));
    expect(find.textContaining('成交量加权平均价格'), findsAtLeastNWidgets(1));
    expect(find.byKey(const ValueKey('vwap-teaching-diagram')), findsOneWidget);

    await tapTopic(tester, 'regime-conflict');
    expect(find.textContaining('趋势行情'), findsAtLeastNWidgets(1));
    expect(find.textContaining('震荡行情'), findsAtLeastNWidgets(1));
    expect(find.textContaining('指标冲突'), findsAtLeastNWidgets(1));
    expect(
      find.byKey(const ValueKey('market-regime-teaching-diagram')),
      findsOneWidget,
    );

    await tapTopic(tester, 'backtest');
    expect(find.textContaining('回测'), findsAtLeastNWidgets(1));
    expect(find.textContaining('最大回撤'), findsAtLeastNWidgets(1));
    expect(find.textContaining('胜率'), findsAtLeastNWidgets(1));
    expect(find.textContaining('交易成本'), findsAtLeastNWidgets(1));
    expect(
      find.byKey(const ValueKey('backtest-drawdown-teaching-diagram')),
      findsOneWidget,
    );

    await tapTopic(tester, 'quant-limitations');
    expect(find.textContaining('过拟合'), findsAtLeastNWidgets(1));
    expect(find.textContaining('未来函数'), findsAtLeastNWidgets(1));
    expect(find.textContaining('幸存者偏差'), findsAtLeastNWidgets(1));
    expect(find.textContaining('数据质量'), findsAtLeastNWidgets(1));
    expect(
      find.byKey(const ValueKey('quant-bias-teaching-diagram')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders overfitting and future data diagram on small screens', (
    tester,
  ) async {
    await pumpTechnicalQuantPage(tester, viewSize: const Size(360, 640));

    await tapTopic(tester, 'quant-limitations');

    final diagram = find.byKey(const ValueKey('quant-bias-teaching-diagram'));
    expect(diagram, findsOneWidget);
    expect(tester.getSize(diagram).width, lessThanOrEqualTo(360));
    expect(tester.takeException(), isNull);
  });
}
