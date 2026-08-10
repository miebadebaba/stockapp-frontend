import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_score.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_score_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: QuantFactorScoreSection(
            result: const QuantFactorScore(
              technicalScore: 76,
              riskAdjustedScore: 72,
              riskPenalty: 4,
              riskAdjustedRating: QuantTechnicalRating.positive,
              rating: QuantTechnicalRating.positive,
              factors: [
                QuantFactorItem(
                  id: 'trend',
                  label: '趋势',
                  score: 85,
                  weight: 0.40,
                  signal: QuantFactorSignal.strong,
                  summary: '趋势表现较强',
                  evidence: ['均线保持多头排列'],
                ),
                QuantFactorItem(
                  id: 'momentum',
                  label: '动量',
                  score: 72,
                  weight: 0.35,
                  signal: QuantFactorSignal.positive,
                  summary: '动量表现偏强',
                  evidence: ['RSI处于相对强势区间'],
                ),
                QuantFactorItem(
                  id: 'volume',
                  label: '量价',
                  score: 70,
                  weight: 0.25,
                  signal: QuantFactorSignal.positive,
                  summary: '量价关系形成一定支持',
                  evidence: ['价格上涨，成交量放大'],
                ),
              ],
              risk: QuantRiskAssessment(
                level: QuantRiskLevel.medium,
                summary: '近期风险处于中等水平',
              ),
              summary: '技术状态偏强，趋势表现相对较好',
              hasSufficientData: true,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('多因子默认折叠详细内容', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byType(ExpansionTile), findsNWidgets(3));

    expect(find.byKey(const ValueKey('quant-factor-trend')), findsOneWidget);
    expect(find.byKey(const ValueKey('quant-factor-momentum')), findsOneWidget);
    expect(find.byKey(const ValueKey('quant-factor-volume')), findsOneWidget);

    expect(find.text('趋势表现较强'), findsNothing);
    expect(find.text('均线保持多头排列'), findsNothing);
    expect(find.text('动量表现偏强'), findsNothing);
    expect(find.text('价格上涨，成交量放大'), findsNothing);
  });

  testWidgets('点击趋势因子后显示详细内容', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byKey(const ValueKey('quant-factor-trend')));
    await tester.pumpAndSettle();

    expect(find.text('趋势表现较强'), findsOneWidget);
    expect(find.text('判断依据'), findsOneWidget);
    expect(find.text('均线保持多头排列'), findsOneWidget);
  });

  testWidgets('点击量价因子后显示详细内容', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byKey(const ValueKey('quant-factor-volume')));
    await tester.pumpAndSettle();

    expect(find.text('量价关系形成一定支持'), findsOneWidget);
    expect(find.text('价格上涨，成交量放大'), findsOneWidget);
  });
}
