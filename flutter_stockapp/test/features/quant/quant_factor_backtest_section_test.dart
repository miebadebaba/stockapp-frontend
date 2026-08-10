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

  testWidgets('显示成本假设和扣除成本后的回测指标', (tester) async {
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
    expect(find.text('风险调整分达到 60 后，于下一交易日开盘买入并持有 5 个交易日'), findsOneWidget);
    expect(find.text('成本假设：佣金双向 0.03%，卖出印花税 0.05%，单边滑点 0.05%'), findsOneWidget);

    expect(find.text('交易次数'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    expect(find.text('净胜率'), findsOneWidget);
    expect(find.text('50.00%'), findsOneWidget);

    expect(find.text('平均毛收益'), findsOneWidget);
    expect(find.text('+2.50%'), findsOneWidget);

    expect(find.text('平均净收益'), findsOneWidget);
    expect(find.text('+2.28%'), findsOneWidget);

    expect(find.text('累计毛收益'), findsOneWidget);
    expect(find.text('+4.50%'), findsOneWidget);

    expect(find.text('累计净收益'), findsOneWidget);
    expect(find.text('+4.06%'), findsOneWidget);

    expect(find.text('平均成本影响'), findsOneWidget);
    expect(find.text('0.22%'), findsOneWidget);

    expect(find.text('累计成本影响'), findsOneWidget);
    expect(find.text('0.44%'), findsOneWidget);

    expect(find.text('策略最大回撤'), findsOneWidget);
    expect(find.text('5.20%'), findsOneWidget);

    expect(
      find.text('回测已估算佣金、印花税和滑点，不代表未来收益；暂未考虑最低佣金、涨跌停及停牌限制。'),
      findsOneWidget,
    );
  });

  testWidgets('显示策略与基准收益对比曲线', (tester) async {
    final result = QuantFactorBacktestResult(
      trades: [
        QuantBacktestTrade(
          entryDate: DateTime(2026, 1, 2),
          exitDate: DateTime(2026, 1, 5),
          entryPrice: 100,
          exitPrice: 110,
          signalScore: 70,
        ),
      ],
      signalThreshold: 60,
      holdingPeriod: 5,
      minimumLookback: 35,
      equityCurve: [
        QuantBacktestEquityPoint(
          date: DateTime(2026, 1, 1),
          strategyValue: 1,
          benchmarkValue: 1,
        ),
        QuantBacktestEquityPoint(
          date: DateTime(2026, 1, 5),
          strategyValue: 1.0978,
          benchmarkValue: 1.05,
        ),
      ],
    );

    await tester.pumpWidget(buildSubject(result: result));

    expect(find.text('策略与基准对比'), findsOneWidget);
    expect(find.text('比较多因子策略净值与同期买入并持有的表现'), findsOneWidget);

    expect(find.text('基准收益'), findsOneWidget);
    expect(find.text('+5.00%'), findsOneWidget);

    expect(find.text('超额收益'), findsOneWidget);
    expect(find.text('+4.77%'), findsOneWidget);

    expect(find.text('多因子策略'), findsOneWidget);
    expect(find.text('买入持有基准'), findsOneWidget);

    expect(
      find.byKey(const ValueKey('quant-backtest-equity-chart')),
      findsOneWidget,
    );

    expect(find.text('2026-01-01'), findsOneWidget);
    expect(find.text('2026-01-05'), findsOneWidget);
  });

  testWidgets('没有交易时显示空状态和模拟数据提示', (tester) async {
    const result = QuantFactorBacktestResult(
      trades: [],
      signalThreshold: 60,
      holdingPeriod: 5,
      minimumLookback: 35,
    );

    await tester.pumpWidget(buildSubject(result: result, isSimulated: true));

    expect(find.text('当前历史区间内没有满足条件的完整交易。'), findsOneWidget);
    expect(find.text('当前回测基于内置模拟数据，只用于验证功能流程，不能用于判断策略真实效果。'), findsOneWidget);

    expect(find.text('交易次数'), findsNothing);
    expect(find.text('策略与基准对比'), findsNothing);
    expect(
      find.byKey(const ValueKey('quant-backtest-equity-chart')),
      findsNothing,
    );
  });

  testWidgets('显示三个因子的历史表现摘要', (tester) async {
    const result = QuantFactorBacktestResult(
      trades: [],
      signalThreshold: 60,
      holdingPeriod: 5,
      minimumLookback: 35,
      factorPerformances: [
        QuantFactorHistoricalPerformance(
          factorId: 'trend',
          label: '趋势因子',
          trades: [],
        ),
        QuantFactorHistoricalPerformance(
          factorId: 'momentum',
          label: '动量因子',
          trades: [],
        ),
        QuantFactorHistoricalPerformance(
          factorId: 'volume',
          label: '量价因子',
          trades: [],
        ),
      ],
    );

    await tester.pumpWidget(buildSubject(result: result));

    expect(find.text('因子历史表现'), findsOneWidget);
    expect(find.text('趋势因子'), findsOneWidget);
    expect(find.text('动量因子'), findsOneWidget);
    expect(find.text('量价因子'), findsOneWidget);

    expect(find.byType(ExpansionTile), findsNWidgets(3));
    expect(
      find.byKey(const ValueKey('quant-factor-performance-trend')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('quant-factor-performance-momentum')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('quant-factor-performance-volume')),
      findsOneWidget,
    );

    // 默认折叠，只显示摘要。
    expect(find.text('暂无满足条件的历史信号'), findsNWidgets(3));
    expect(find.text('信号次数'), findsNothing);

    // 展开趋势因子后显示完整统计。
    await tester.ensureVisible(
      find.byKey(const ValueKey('quant-factor-performance-trend')),
    );
    await tester.tap(
      find.byKey(const ValueKey('quant-factor-performance-trend')),
    );
    await tester.pumpAndSettle();

    expect(find.text('信号次数'), findsOneWidget);
    expect(find.text('胜率'), findsOneWidget);
    expect(find.text('平均净收益'), findsOneWidget);
    expect(find.text('累计净收益'), findsOneWidget);
    expect(find.text('最大回撤'), findsOneWidget);
  });
}
