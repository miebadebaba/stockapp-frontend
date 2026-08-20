import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_backtest_robustness.dart';
import 'package:flutter_stockapp/features/quant/quant_backtest_robustness_section.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_backtest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('样本不足时说明暂不判断稳定性', (tester) async {
    const result = QuantBacktestRobustnessResult(
      windows: [
        QuantBacktestWindowResult(
          label: '阶段 1',
          result: QuantFactorBacktestResult(
            trades: [],
            signalThreshold: 60,
            holdingPeriod: 5,
            minimumLookback: 35,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: QuantBacktestRobustnessSection(result: result),
        ),
      ),
    );

    expect(find.text('多时间窗口验证'), findsOneWidget);
    expect(find.text('稳定性解读'), findsOneWidget);
    expect(find.textContaining('样本不足，暂不判断策略稳定性'), findsOneWidget);
    expect(find.text('样本不足'), findsOneWidget);
  });
}
