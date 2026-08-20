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
      backtestStartDate: DateTime(2026, 1, 1),
      backtestEndDate: DateTime(2026, 1, 10),
    );

    await tester.pumpWidget(buildSubject(result: result));

    expect(find.text('多因子历史回测'), findsOneWidget);
    expect(find.text('风险调整分达到 60 后，于下一交易日开盘买入并持有 5 个交易日'), findsOneWidget);
    expect(
      find.text(
        '成本假设：单边佣金 0.03%，买入税费 0.00%，'
        '卖出税费 0.05%，单边滑点 0.05%',
      ),
      findsOneWidget,
    );

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

    expect(find.text('专业回测指标'), findsOneWidget);
    expect(find.text('盈亏比'), findsOneWidget);
    expect(find.text('盈利因子'), findsOneWidget);
    expect(find.text('年化收益率'), findsOneWidget);
    expect(find.text('夏普比率'), findsOneWidget);
    expect(find.text('样本不足'), findsNWidgets(4));
    expect(find.textContaining('当前只有 2 笔交易，少于最低 5 笔样本'), findsOneWidget);

    expect(find.text('回测结论'), findsOneWidget);
    expect(find.text('回测区间：2026-01-01 至 2026-01-10'), findsOneWidget);
    expect(
      find.text(
        '本次回测共完成 2 笔交易，净胜率 50.00%。交易样本较少，结论仅作初步观察。'
        '未提供同期基准曲线，暂不比较超额收益。',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('需要留意回撤风险。'), findsOneWidget);
    expect(find.textContaining('历史回测不能推断未来表现。'), findsOneWidget);

    expect(find.text('逐笔交易明细'), findsOneWidget);
    expect(find.text('共 2 笔，按买入日期排序'), findsOneWidget);
    expect(find.text('买入成交价'), findsNothing);

    final details = find.byKey(const ValueKey('quant-backtest-trade-details'));
    await tester.ensureVisible(details);
    await tester.tap(details);
    await tester.pumpAndSettle();

    expect(find.text('第 1 笔'), findsOneWidget);
    expect(find.text('第 2 笔'), findsOneWidget);
    expect(find.text('买入 2026-01-01 · 卖出 2026-01-05'), findsOneWidget);
    expect(find.text('买入成交价'), findsNWidgets(2));
    expect(find.text('卖出成交价'), findsNWidgets(2));
    expect(find.text('毛收益'), findsNWidgets(2));
    expect(find.text('成本影响'), findsNWidgets(2));
    expect(find.text('信号分'), findsNWidgets(2));
    expect(find.text('100.05'), findsNWidgets(2));
    expect(find.text('109.95'), findsOneWidget);
    expect(find.text('+10.00%'), findsOneWidget);
    expect(find.text('70'), findsOneWidget);

    expect(
      find.text(
        '回测已估算佣金、市场税费和滑点，不代表未来收益；'
        '实际费用因市场、券商和成交金额而异。',
      ),
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

    expect(find.text('基准收益'), findsNWidgets(2));
    expect(find.text('+5.00%'), findsNWidgets(2));

    expect(find.text('超额收益'), findsOneWidget);
    expect(find.text('+4.77%'), findsOneWidget);
    expect(
      find.text(
        '本次回测共完成 1 笔交易，净胜率 100.00%。交易样本较少，结论仅作初步观察。'
        '策略在该历史区间跑赢买入持有基准 +4.77%。',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('历史回撤相对较小。'), findsOneWidget);
    expect(find.textContaining('历史回测不能推断未来表现。'), findsOneWidget);

    expect(find.text('多因子策略'), findsOneWidget);
    expect(find.text('买入持有基准'), findsOneWidget);

    expect(
      find.byKey(const ValueKey('quant-backtest-equity-chart')),
      findsOneWidget,
    );

    expect(find.text('2026-01-01'), findsOneWidget);
    expect(find.text('2026-01-05'), findsOneWidget);
    expect(find.text('已选 2026-01-05'), findsOneWidget);
    expect(find.text('策略收益'), findsOneWidget);
    expect(find.text('基准收益'), findsNWidgets(2));
    expect(find.text('当日超额'), findsOneWidget);
    expect(find.text('+9.78%'), findsOneWidget);
    expect(find.text('+4.78%'), findsOneWidget);

    final chart = find.byKey(const ValueKey('quant-backtest-equity-chart'));
    await tester.ensureVisible(chart);
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getTopLeft(chart) + const Offset(45, 100));
    await tester.pump();

    expect(find.text('已选 2026-01-01'), findsOneWidget);
    expect(find.text('+0.00%'), findsNWidgets(3));
  });

  testWidgets('没有交易时显示空状态和模拟数据提示', (tester) async {
    const result = QuantFactorBacktestResult(
      trades: [],
      signalThreshold: 60,
      holdingPeriod: 5,
      minimumLookback: 35,
    );

    await tester.pumpWidget(buildSubject(result: result, isSimulated: true));

    expect(find.text('历史数据不足，暂时无法形成完整交易。请增加回测数据区间，或缩短持有周期。'), findsOneWidget);
    expect(find.text('当前回测基于内置模拟数据，只用于验证功能流程，不能用于判断策略真实效果。'), findsOneWidget);

    expect(find.text('交易次数'), findsNothing);
    expect(find.text('逐笔交易明细'), findsNothing);
    expect(find.text('策略与基准对比'), findsNothing);
    expect(
      find.byKey(const ValueKey('quant-backtest-equity-chart')),
      findsNothing,
    );
  });

  testWidgets('没有信号时显示最高分和调整建议', (tester) async {
    const result = QuantFactorBacktestResult(
      trades: [],
      signalThreshold: 60,
      holdingPeriod: 5,
      minimumLookback: 35,
      evaluatedSignalCount: 18,
      highestSignalScore: 54.4,
    );

    await tester.pumpWidget(buildSubject(result: result));

    expect(
      find.text(
        '已评估 18 个候选交易日，最高风险调整分为 54 分，'
        '未达到 60 分阈值。可适当降低信号阈值后重新回测。',
      ),
      findsOneWidget,
    );
  });

  testWidgets('显示三个因子的历史表现摘要', (tester) async {
    final result = QuantFactorBacktestResult(
      trades: [],
      signalThreshold: 60,
      holdingPeriod: 5,
      minimumLookback: 35,
      factorPerformances: [
        QuantFactorHistoricalPerformance(
          factorId: 'trend',
          label: '趋势因子',
          trades: [
            QuantBacktestTrade(
              entryDate: DateTime(2026, 1, 3),
              exitDate: DateTime(2026, 1, 8),
              entryPrice: 100,
              exitPrice: 108,
              signalScore: 66,
            ),
          ],
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
    expect(find.text('因子解读'), findsOneWidget);
    expect(
      find.text('趋势因子、动量因子、量价因子的历史信号均少于 5 次，样本不足，暂不比较因子强弱。'),
      findsOneWidget,
    );
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
    expect(find.text('暂无满足条件的历史信号'), findsNWidgets(2));
    expect(find.text('信号次数'), findsNothing);
    expect(find.text('逐笔信号明细'), findsNothing);

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
    expect(find.text('逐笔信号明细'), findsOneWidget);
    expect(find.text('第 1 笔信号'), findsOneWidget);
    expect(find.text('买入 2026-01-03 · 卖出 2026-01-08'), findsOneWidget);
    expect(find.text('净收益'), findsOneWidget);
    expect(find.text('因子分'), findsOneWidget);
    expect(find.text('66'), findsOneWidget);
  });

  testWidgets('因子解读标出样本充足且平均收益更高的因子', (tester) async {
    final positiveTrades = List.generate(
      5,
      (index) => QuantBacktestTrade(
        entryDate: DateTime(2026, 2, index + 1),
        exitDate: DateTime(2026, 2, index + 2),
        entryPrice: 100,
        exitPrice: 104,
        signalScore: 70,
      ),
    );
    final negativeTrades = List.generate(
      5,
      (index) => QuantBacktestTrade(
        entryDate: DateTime(2026, 3, index + 1),
        exitDate: DateTime(2026, 3, index + 2),
        entryPrice: 100,
        exitPrice: 96,
        signalScore: 62,
      ),
    );
    final result = QuantFactorBacktestResult(
      trades: [],
      signalThreshold: 60,
      holdingPeriod: 5,
      minimumLookback: 35,
      factorPerformances: [
        QuantFactorHistoricalPerformance(
          factorId: 'trend',
          label: '趋势因子',
          trades: positiveTrades,
        ),
        QuantFactorHistoricalPerformance(
          factorId: 'momentum',
          label: '动量因子',
          trades: negativeTrades,
        ),
        const QuantFactorHistoricalPerformance(
          factorId: 'volume',
          label: '量价因子',
          trades: [],
        ),
      ],
    );

    await tester.pumpWidget(buildSubject(result: result));

    expect(find.textContaining('趋势因子在样本充足的因子中平均净收益最高'), findsOneWidget);
    expect(find.textContaining('动量因子平均净收益未为正'), findsOneWidget);
    expect(find.textContaining('量价因子信号少于 5 次'), findsOneWidget);
  });
}
