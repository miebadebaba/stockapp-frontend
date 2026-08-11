import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_correlation_calculator.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_correlation_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('correlation section is collapsed by default and can expand', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: QuantFactorCorrelationSection(
              correlations: [
                QuantFactorCorrelation(
                  leftFactorId: 'trend',
                  rightFactorId: 'momentum',
                  sampleSize: 4,
                  coefficient: 0.50,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('因子相关性'), findsOneWidget);
    expect(find.text('股票池样本不足，结果仅供参考'), findsOneWidget);
    expect(find.text('趋势 / 动量'), findsNothing);

    await tester.tap(find.text('因子相关性'));
    await tester.pumpAndSettle();

    expect(find.text('趋势 / 动量'), findsOneWidget);
    expect(find.text('中等相关 · 样本不足 · 4只'), findsOneWidget);
    expect(find.text('+0.50'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows redundancy summary for adequate high correlation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: QuantFactorCorrelationSection(
            correlations: [
              QuantFactorCorrelation(
                leftFactorId: 'trend',
                rightFactorId: 'volume',
                sampleSize: 20,
                coefficient: 0.85,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('发现 1 组可能重复的因子'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty correlation list renders no section', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: QuantFactorCorrelationSection(correlations: []),
        ),
      ),
    );

    expect(find.text('因子相关性'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
