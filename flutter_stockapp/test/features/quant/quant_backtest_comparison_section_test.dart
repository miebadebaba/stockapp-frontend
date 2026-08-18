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
  });
}
