import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/tutorial/fundamental_analysis_page.dart';
import 'package:flutter_stockapp/features/tutorial/tutorial_category_page.dart';

void main() {
  const topicTitles = [
    '公司靠什么赚钱：商业模式',
    '营业收入、成本与利润',
    '毛利率、净利率与盈利能力',
    '资产、负债与股东权益',
    '现金流为什么重要',
    '三张财务报表怎么看',
    '增长是否健康、利润是否真实',
    '好公司为什么不一定是好股票',
    '阅读财报时要警惕什么',
  ];

  Future<void> pumpFundamentalAnalysisPage(WidgetTester tester) async {
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

    await tester.tap(find.text('公司与基本面分析'));
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

  testWidgets('opens fundamental analysis and renders nine topics', (
    tester,
  ) async {
    await pumpFundamentalAnalysisPage(tester);

    expect(find.byType(FundamentalAnalysisPage), findsOneWidget);
    expect(find.text('公司与基本面分析'), findsOneWidget);
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

  testWidgets('keeps the fundamental analysis accordion controlled', (
    tester,
  ) async {
    await pumpFundamentalAnalysisPage(tester);

    await tapTopic(tester, 'business-model');
    expect(contentKey('business-model'), findsOneWidget);

    await tapTopic(tester, 'revenue-cost-profit');
    expect(contentKey('business-model'), findsNothing);
    expect(contentKey('revenue-cost-profit'), findsOneWidget);

    await tapTopic(tester, 'revenue-cost-profit');
    expect(contentKey('revenue-cost-profit'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders key fundamental analysis content in expected topics', (
    tester,
  ) async {
    await pumpFundamentalAnalysisPage(tester);

    await tapTopic(tester, 'business-model');
    expect(find.textContaining('商业模式'), findsAtLeastNWidgets(1));

    await tapTopic(tester, 'margins-and-profitability');
    expect(find.textContaining('毛利率'), findsAtLeastNWidgets(1));
    expect(find.textContaining('净利率'), findsAtLeastNWidgets(1));
    expect(find.textContaining('ROE'), findsAtLeastNWidgets(1));

    await tapTopic(tester, 'assets-liabilities-equity');
    expect(find.textContaining('资产'), findsAtLeastNWidgets(1));
    expect(find.textContaining('负债'), findsAtLeastNWidgets(1));
    expect(find.textContaining('股东权益'), findsAtLeastNWidgets(1));

    await tapTopic(tester, 'cash-flow');
    expect(find.textContaining('经营现金流'), findsAtLeastNWidgets(1));
    expect(find.textContaining('自由现金流'), findsAtLeastNWidgets(1));

    await tapTopic(tester, 'financial-statements');
    expect(find.text('利润表'), findsOneWidget);
    expect(find.text('资产负债表'), findsOneWidget);
    expect(find.text('现金流量表'), findsOneWidget);

    await tapTopic(tester, 'good-company-good-stock');
    expect(find.textContaining('好公司不一定是好投资'), findsAtLeastNWidgets(1));

    await tapTopic(tester, 'financial-report-warning-signs');
    expect(find.text('常见风险信号'), findsOneWidget);
    expect(find.textContaining('应收账款增长快于收入'), findsAtLeastNWidgets(1));
    expect(find.textContaining('存货增长快于销售'), findsAtLeastNWidgets(1));
    expect(find.textContaining('净利润增长但经营现金流恶化'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });
}
