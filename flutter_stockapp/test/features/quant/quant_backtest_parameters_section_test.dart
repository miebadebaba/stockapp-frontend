import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_backtest_parameters.dart';
import 'package:flutter_stockapp/features/quant/quant_backtest_parameters_section.dart';
import 'package:flutter_stockapp/features/quant/selected_stock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('显示回测参数对交易频率和成本的说明', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuantBacktestParametersSection(
              parameters: const QuantBacktestParameters(),
              market: QuantMarket.aShare,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('回测参数'), findsOneWidget);
    expect(find.text('参数说明'), findsOneWidget);
    expect(find.text('提高信号阈值：交易通常更少，筛选条件更严格；降低阈值则会增加信号覆盖。'), findsOneWidget);
    expect(
      find.text('延长持有周期：单笔持仓时间更长，可能减少交易频率，也会承受更长时间的价格波动。'),
      findsOneWidget,
    );
    expect(find.text('提高交易成本假设：会直接降低回测净收益，更接近实际成交时的保守估计。'), findsOneWidget);
    expect(find.text('信号阈值：60 分'), findsOneWidget);
    expect(find.text('持有周期'), findsOneWidget);
    expect(find.text('交易成本设置'), findsOneWidget);
    expect(find.text('当前市场：A股'), findsOneWidget);
    expect(find.textContaining('A股估算'), findsNWidgets(2));
    expect(find.textContaining('佣金双向 0.03%'), findsOneWidget);
    expect(find.text('默认值仅用于回测估算，实际费率可能因券商、账户和成交金额不同而变化。'), findsOneWidget);

    await tester.ensureVisible(find.text('交易成本设置'));
    await tester.tap(find.text('交易成本设置'));
    await tester.pumpAndSettle();
    expect(find.text('当前默认假设'), findsOneWidget);
    expect(find.textContaining('卖出印花税 0.05%'), findsNWidgets(2));
  });

  testWidgets('应用过高成本假设时提醒谨慎解读', (tester) async {
    var changedParameters = <QuantBacktestParameters>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuantBacktestParametersSection(
              parameters: const QuantBacktestParameters(),
              market: QuantMarket.aShare,
              onChanged: changedParameters.add,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('交易成本设置'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '2');
    await tester.enterText(fields.at(1), '1');
    await tester.enterText(fields.at(2), '1');
    await tester.enterText(fields.at(3), '1');
    await tester.ensureVisible(find.text('应用参数'));
    await tester.tap(find.text('应用参数'));
    await tester.pumpAndSettle();

    expect(changedParameters, hasLength(1));
    expect(find.textContaining('成本假设偏高，请谨慎解读收益'), findsOneWidget);
  });
}
