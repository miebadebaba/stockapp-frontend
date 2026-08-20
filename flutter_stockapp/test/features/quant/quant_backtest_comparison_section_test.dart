import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_backtest_comparison.dart';
import 'package:flutter_stockapp/features/quant/quant_backtest_comparison_section.dart';
import 'package:flutter_stockapp/features/quant/quant_backtest_parameters.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_backtest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('零交易策略显示未达到阈值的具体原因', (tester) async {
    const result = QuantBacktestComparisonResult(
      items: [
        QuantBacktestComparisonItem(
          caseDefinition: QuantBacktestComparisonCase(
            id: 'conservative',
            label: '稳健策略',
            description: '较高信号阈值，减少交易次数',
            parameters: QuantBacktestParameters(
              signalThreshold: 70,
              holdingPeriod: 10,
            ),
          ),
          result: QuantFactorBacktestResult(
            trades: [],
            signalThreshold: 70,
            holdingPeriod: 10,
            minimumLookback: 35,
            evaluatedSignalCount: 20,
            highestSignalScore: 64.2,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: QuantBacktestComparisonSection(result: result),
          ),
        ),
      ),
    );

    expect(find.text('稳健策略'), findsOneWidget);
    expect(find.text('交易次数'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('最高评分 64 分，未达到 70 分阈值。'), findsOneWidget);
    expect(find.text('当前各参数组合均未形成完整交易，暂时无法比较策略表现。'), findsOneWidget);
  });

  testWidgets('标出历史表现相对均衡的参数组合', (tester) async {
    final highestReturn = _buildItem(
      id: 'return-first',
      label: '收益优先策略',
      exitPrices: [160, 80],
    );
    final balanced = _buildItem(
      id: 'balanced',
      label: '均衡策略',
      exitPrices: [104, 104, 104, 104, 104],
      equityCurve: [
        QuantBacktestEquityPoint(
          date: DateTime(2026, 1, 1),
          strategyValue: 1,
          benchmarkValue: 1,
        ),
        QuantBacktestEquityPoint(
          date: DateTime(2026, 1, 10),
          strategyValue: 1.2,
          benchmarkValue: 1.1,
        ),
      ],
    );
    final weaker = _buildItem(
      id: 'weaker',
      label: '低效策略',
      exitPrices: [95, 95, 95, 95, 95],
    );
    final result = QuantBacktestComparisonResult(
      items: [highestReturn, balanced, weaker],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuantBacktestComparisonSection(result: result),
          ),
        ),
      ),
    );

    expect(result.balancedItem, same(balanced));
    expect(find.text('参数组合解读'), findsOneWidget);
    expect(
      find.textContaining('均衡策略在当前历史区间的收益、回撤和交易次数之间相对更均衡'),
      findsOneWidget,
    );
    expect(find.text('综合参考'), findsOneWidget);
    expect(find.textContaining('相对同期买入持有超额收益'), findsOneWidget);
  });

  testWidgets('样本充足的参数组合少于两组时不生成综合参考', (tester) async {
    final adequate = _buildItem(
      id: 'adequate',
      label: '样本充足策略',
      exitPrices: [104, 104, 104, 104, 104],
    );
    final limited = _buildItem(
      id: 'limited',
      label: '样本有限策略',
      exitPrices: [106],
    );
    final result = QuantBacktestComparisonResult(items: [adequate, limited]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuantBacktestComparisonSection(result: result),
          ),
        ),
      ),
    );

    expect(result.balancedItem, isNull);
    expect(find.textContaining('只有 1 组达到至少 5 笔交易的参考样本'), findsOneWidget);
    expect(find.text('综合参考'), findsNothing);
    expect(find.text('样本有限'), findsOneWidget);
    expect(find.text('当前仅完成 1 笔交易，至少完成 5 笔交易后才参与参数比较。'), findsOneWidget);
  });

  testWidgets('综合参考落后基准时提示策略有效性仍需验证', (tester) async {
    final balanced = _buildItem(
      id: 'balanced',
      label: '均衡策略',
      exitPrices: [104, 104, 104, 104, 104],
      equityCurve: [
        QuantBacktestEquityPoint(
          date: DateTime(2026, 1, 1),
          strategyValue: 1,
          benchmarkValue: 1,
        ),
        QuantBacktestEquityPoint(
          date: DateTime(2026, 1, 10),
          strategyValue: 1.2,
          benchmarkValue: 1.4,
        ),
      ],
    );
    final weaker = _buildItem(
      id: 'weaker',
      label: '低效策略',
      exitPrices: [95, 95, 95, 95, 95],
    );
    final result = QuantBacktestComparisonResult(items: [balanced, weaker]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuantBacktestComparisonSection(result: result),
          ),
        ),
      ),
    );

    expect(result.balancedItem, same(balanced));
    expect(find.textContaining('相对同期买入持有仍落后'), findsOneWidget);
    expect(find.textContaining('不宜仅凭该组合直接判断策略有效性'), findsOneWidget);
  });

  testWidgets('显示策略相对同期基准的收益', (tester) async {
    final result = QuantBacktestComparisonResult(
      items: [
        _buildItem(
          id: 'benchmark',
          label: '相对基准策略',
          exitPrices: [110],
          equityCurve: [
            QuantBacktestEquityPoint(
              date: DateTime(2026, 1, 1),
              strategyValue: 1,
              benchmarkValue: 1,
            ),
            QuantBacktestEquityPoint(
              date: DateTime(2026, 1, 2),
              strategyValue: 1.1,
              benchmarkValue: 1.05,
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuantBacktestComparisonSection(result: result),
          ),
        ),
      ),
    );

    expect(find.text('基准收益'), findsOneWidget);
    expect(find.text('超额收益'), findsOneWidget);
    expect(find.text('+5.00%'), findsNWidgets(2));
  });

  testWidgets('参数样本不足时显示暂不判断过拟合提示', (tester) async {
    final result = QuantBacktestComparisonResult(
      items: [
        _buildItem(
          id: 'adequate',
          label: '样本充足策略',
          exitPrices: [104, 104, 104, 104, 104],
        ),
        _buildItem(id: 'limited', label: '样本有限策略', exitPrices: [110]),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuantBacktestComparisonSection(result: result),
          ),
        ),
      ),
    );

    expect(find.text('参数过拟合提醒'), findsOneWidget);
    expect(find.text('样本不足，暂不判断'), findsOneWidget);
    expect(find.textContaining('暂时无法检查参数是否过度适配历史数据'), findsOneWidget);
  });

  testWidgets('最优参数样本偏少且收益差距大时提示较高风险', (tester) async {
    final result = QuantBacktestComparisonResult(
      items: [
        _buildItem(
          id: 'high-return',
          label: '高收益策略',
          exitPrices: [120, 120, 120, 120, 120],
        ),
        _buildItem(
          id: 'steady',
          label: '稳定策略',
          exitPrices: [102, 102, 102, 102, 102, 102, 102, 102, 102, 102],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuantBacktestComparisonSection(result: result),
          ),
        ),
      ),
    );

    expect(find.text('风险较高，谨慎解读最优参数'), findsOneWidget);
    expect(find.textContaining('高收益策略比第二名稳定策略高'), findsOneWidget);
    expect(find.textContaining('仅完成 5 笔交易'), findsOneWidget);
  });
}

QuantBacktestComparisonItem _buildItem({
  required String id,
  required String label,
  required List<double> exitPrices,
  List<QuantBacktestEquityPoint> equityCurve = const [],
}) {
  const costs = QuantBacktestCostSettings(
    commissionRate: 0,
    stampDutyRate: 0,
    slippageRate: 0,
  );

  final trades = List.generate(
    exitPrices.length,
    (index) => QuantBacktestTrade(
      entryDate: DateTime(2026, 1, index * 2 + 1),
      exitDate: DateTime(2026, 1, index * 2 + 2),
      entryPrice: 100,
      exitPrice: exitPrices[index],
      signalScore: 70,
      costSettings: costs,
    ),
  );

  return QuantBacktestComparisonItem(
    caseDefinition: QuantBacktestComparisonCase(
      id: id,
      label: label,
      description: '测试策略',
      parameters: const QuantBacktestParameters(costSettings: costs),
    ),
    result: QuantFactorBacktestResult(
      trades: trades,
      signalThreshold: 60,
      holdingPeriod: 5,
      minimumLookback: 35,
      costSettings: costs,
      equityCurve: equityCurve,
    ),
  );
}
