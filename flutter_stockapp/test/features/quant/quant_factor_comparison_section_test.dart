import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_comparison_section.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_score.dart';
import 'package:flutter_stockapp/features/quant/selected_stock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('显示两只股票的综合评分和各项因子得分', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: QuantFactorComparisonSection(
              firstStock: SelectedStock(code: '600519', name: '贵州茅台'),
              firstScore: QuantFactorScore(
                technicalScore: 78,
                riskAdjustedScore: 74,
                riskPenalty: 4,
                riskAdjustedRating: QuantTechnicalRating.positive,
                rating: QuantTechnicalRating.positive,
                factors: [
                  QuantFactorItem(
                    id: 'trend',
                    label: '趋势',
                    score: 80,
                    weight: 0.40,
                    signal: QuantFactorSignal.strong,
                    summary: '趋势较强',
                    evidence: ['均线表现较好'],
                  ),
                  QuantFactorItem(
                    id: 'momentum',
                    label: '动量',
                    score: 70,
                    weight: 0.35,
                    signal: QuantFactorSignal.positive,
                    summary: '动量偏强',
                    evidence: ['动量指标表现较好'],
                  ),
                  QuantFactorItem(
                    id: 'volume',
                    label: '量价',
                    score: 60,
                    weight: 0.25,
                    signal: QuantFactorSignal.neutral,
                    summary: '量价中性',
                    evidence: ['量价配合一般'],
                  ),
                ],
                risk: QuantRiskAssessment(
                  level: QuantRiskLevel.medium,
                  summary: '风险中等',
                ),
                summary: '技术状态偏强',
                hasSufficientData: true,
              ),
              secondStock: SelectedStock(code: '000001', name: '平安银行'),
              secondScore: QuantFactorScore(
                technicalScore: 65,
                riskAdjustedScore: 62,
                riskPenalty: 3,
                riskAdjustedRating: QuantTechnicalRating.neutral,
                rating: QuantTechnicalRating.neutral,
                factors: [
                  QuantFactorItem(
                    id: 'trend',
                    label: '趋势',
                    score: 68,
                    weight: 0.40,
                    signal: QuantFactorSignal.positive,
                    summary: '趋势偏强',
                    evidence: ['均线表现尚可'],
                  ),
                  QuantFactorItem(
                    id: 'momentum',
                    label: '动量',
                    score: 61,
                    weight: 0.35,
                    signal: QuantFactorSignal.neutral,
                    summary: '动量中性',
                    evidence: ['动量方向不明确'],
                  ),
                  QuantFactorItem(
                    id: 'volume',
                    label: '量价',
                    score: 64,
                    weight: 0.25,
                    signal: QuantFactorSignal.neutral,
                    summary: '量价中性',
                    evidence: ['量价配合一般'],
                  ),
                ],
                risk: QuantRiskAssessment(
                  level: QuantRiskLevel.low,
                  summary: '风险较低',
                ),
                summary: '技术状态中性',
                hasSufficientData: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('对比股票分析'), findsOneWidget);
    expect(find.text('贵州茅台'), findsOneWidget);
    expect(find.text('平安银行'), findsOneWidget);
    expect(find.text('综合评分'), findsOneWidget);
    expect(find.text('风险调整分'), findsOneWidget);
    expect(find.text('趋势因子'), findsOneWidget);
    expect(find.text('动量因子'), findsOneWidget);
    expect(find.text('量价因子'), findsOneWidget);
    expect(find.text('78'), findsOneWidget);
    expect(find.text('65'), findsOneWidget);
    expect(find.text('74'), findsOneWidget);
    expect(find.text('62'), findsOneWidget);
  });
}
