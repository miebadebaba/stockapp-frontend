import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_score.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_score_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject(QuantFactorScore result) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: QuantFactorScoreSection(result: result),
        ),
      ),
    );
  }

  testWidgets('显示技术评分、因子得分和独立风险等级', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        const QuantFactorScore(
          technicalScore: 76.7,
          riskAdjustedScore: 72.7,
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
              summary: '短中期趋势偏强。',
              evidence: ['均线呈多头排列'],
            ),
            QuantFactorItem(
              id: 'momentum',
              label: '动量',
              score: 72,
              weight: 0.35,
              signal: QuantFactorSignal.positive,
              summary: '当前上涨动量相对较强。',
              evidence: ['RSI处于相对强势区间'],
            ),
            QuantFactorItem(
              id: 'volume',
              label: '量价',
              score: 70,
              weight: 0.25,
              signal: QuantFactorSignal.positive,
              summary: '量价关系对当前走势形成一定支持。',
              evidence: ['价格上涨，成交量放大'],
            ),
          ],
          risk: QuantRiskAssessment(
            level: QuantRiskLevel.medium,
            annualizedVolatility: 0.25,
            maximumDrawdown: 0.12,
            summary: '近期风险处于中等水平。',
          ),
          summary: '技术状态偏强，趋势表现相对较好。',
          hasSufficientData: true,
        ),
      ),
    );

    expect(find.text('当前股票因子解析'), findsOneWidget);
    expect(find.text('77'), findsOneWidget);
    expect(find.text('/ 100'), findsOneWidget);
    expect(find.text('偏强'), findsNWidgets(2));
    expect(find.text('风险调整参考分：73（风险扣分 4.0）'), findsOneWidget);
    expect(find.text('趋势'), findsOneWidget);
    expect(find.text('动量'), findsOneWidget);
    expect(find.text('量价'), findsOneWidget);
    expect(find.text('权重 40%'), findsOneWidget);
    expect(find.text('风险等级：中等'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(4));
  });

  testWidgets('数据不足时显示不可用状态', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        const QuantFactorScore(
          technicalScore: 0,
          rating: QuantTechnicalRating.unavailable,
          factors: [],
          risk: QuantRiskAssessment(
            level: QuantRiskLevel.unavailable,
            summary: '历史数据不足，暂时无法评价风险。',
          ),
          summary: '部分技术指标数据不足，暂时无法生成完整评分。',
          hasSufficientData: false,
        ),
      ),
    );

    expect(find.text('当前股票因子解析'), findsOneWidget);
    expect(find.text('部分技术指标数据不足，暂时无法生成完整评分。'), findsOneWidget);
    expect(find.text('风险等级：暂不可用'), findsOneWidget);
    expect(find.text('/ 100'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
