import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_backtest.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_backtest_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    required QuantFactorBacktestResult result,
    bool isSimulated = false,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: QuantFactorBacktestSection(
            result: result,
            isSimulated: isSimulated,
          ),
        ),
      ),
    );
  }

  testWidgets('显示回测规则和核心指标', (tester) async {
    final result = QuantFactorBacktestResult(
      trades: [
        QuantBacktestTrade(
          entryDate: DateTime(2026, 1, 1),
          exitDate: DateTime(2026, 1, 5),
          entryPrice: 100,
          exitPrice: 110,
          signalScore: 70,
        ),
        QuantBacktestTrade(
          entryDate: DateTime(2026, 1, 6),
          exitDate: DateTime(2026, 1, 10),
          entryPrice: 100,
          exitPrice: 95,
          signalScore: 65,
        ),
      ],
      signalThreshold: 60,
      holdingPeriod: 5,
      minimumLookback: 35,
    );

    await tester.pumpWidget(buildSubject(result: result));

    expect(find.text('多因子历史回测'), findsOneWidget);
    expect(
      find.text('风险调整分达到 60 后，于下一交易日开盘买入并持有 5 个交易日'),
      findsOneWidget,
    );
    expect(find.text('交易次数'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('胜率'), findsOneWidget);
    expect(find.text('50.00%'), findsOneWidget);
    expect(find.text('平均收益'), findsOneWidget);
    expect(find.text('+2.50%'), findsOneWidget);
    expect(find.text('累计收益'), findsOneWidget);
    expect(find.text('+4.50%'), findsOneWidget);
    expect(find.text('策略最大回撤'), findsOneWidget);
    expect(find.text('5.00%'), findsOneWidget);
  });

  testWidgets('没有交易时显示空状态和模拟数据提示', (tester) async {
    const result = QuantFactorBacktestResult(
      trades: [],
      signalThreshold: 60,
      holdingPeriod: 5,
      minimumLookback: 35,
    );

    await tester.pumpWidget(
      buildSubject(
        result: result,
        isSimulated: true,
      ),
    );

    expect(find.text('当前历史区间内没有满足条件的完整交易。'), findsOneWidget);
    expect(
      find.text('当前回测基于内置模拟数据，只用于验证功能流程，不能用于判断策略真实效果。'),
      findsOneWidget,
    );
    expect(find.text('交易次数'), findsNothing);
  });
}
