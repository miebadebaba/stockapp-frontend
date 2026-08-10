import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_score.dart';
import 'package:flutter_stockapp/features/quant/quant_overview_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject(QuantFactorScore result) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: QuantOverviewSection(result: result)),
    );
  }

  testWidgets('显示风险调整分、风险等级和因子摘要', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        _buildScore(
          riskAdjustedScore: 68,
          riskAdjustedRating: QuantTechnicalRating.positive,
        ),
      ),
    );

    expect(find.text('量化概览'), findsOneWidget);
    expect(find.text('68 / 100', findRichText: true), findsOneWidget);
    expect(find.text('偏强'), findsNWidgets(2));
    expect(find.text('中等'), findsOneWidget);
    expect(find.text('趋势'), findsOneWidget);
    expect(find.text('动量'), findsOneWidget);
    expect(find.text('量价'), findsOneWidget);
    expect(find.text('82'), findsOneWidget);
    expect(find.text('64'), findsOneWidget);
    expect(find.text('48'), findsOneWidget);
    expect(find.text('技术状态总体中性，趋势表现相对较好。'), findsOneWidget);
  });

  testWidgets('没有风险调整结果时回退显示原始技术分', (tester) async {
    await tester.pumpWidget(buildSubject(_buildScore()));

    expect(find.text('61 / 100', findRichText: true), findsOneWidget);
    expect(find.text('中性'), findsNWidgets(2));
    expect(find.text('中等'), findsOneWidget);
  });
}

QuantFactorScore _buildScore({
  double? riskAdjustedScore,
  QuantTechnicalRating? riskAdjustedRating,
}) {
  return QuantFactorScore(
    technicalScore: 61,
    riskAdjustedScore: riskAdjustedScore,
    riskPenalty: riskAdjustedScore == null ? null : 3,
    riskAdjustedRating: riskAdjustedRating,
    rating: QuantTechnicalRating.neutral,
    factors: const [
      QuantFactorItem(
        id: 'trend',
        label: '趋势',
        score: 82,
        weight: 0.40,
        signal: QuantFactorSignal.positive,
        summary: '趋势表现较好。',
        evidence: ['均线保持多头结构'],
      ),
      QuantFactorItem(
        id: 'momentum',
        label: '动量',
        score: 64,
        weight: 0.35,
        signal: QuantFactorSignal.neutral,
        summary: '动量表现中性。',
        evidence: ['RSI处于中性区间'],
      ),
      QuantFactorItem(
        id: 'volume',
        label: '量价',
        score: 48,
        weight: 0.25,
        signal: QuantFactorSignal.negative,
        summary: '量价支持不足。',
        evidence: ['成交量确认不足'],
      ),
    ],
    risk: const QuantRiskAssessment(
      level: QuantRiskLevel.medium,
      annualizedVolatility: 0.20,
      maximumDrawdown: 0.10,
      summary: '近期风险处于中等水平。',
    ),
    summary: '技术状态总体中性，趋势表现相对较好。',
    hasSufficientData: true,
  );
}
