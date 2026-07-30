import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme_palette.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_result.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject(TechnicalSummaryResult result) {
    return MaterialApp(
      theme: ThemeData(extensions: const [AppThemePalette.light]),
      home: Scaffold(
        body: SingleChildScrollView(
          child: TechnicalSummarySection(result: result),
        ),
      ),
    );
  }

  testWidgets('displays all technical evidence categories', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        const TechnicalSummaryResult(
          trend: TrendState.upward,
          momentum: MomentumState.positive,
          strength: StrengthState.relativelyStrong,
          participation: ParticipationState.confirming,
          consistency: EvidenceConsistency.high,
          riskFlags: [],
        ),
      ),
    );

    expect(find.text('综合技术状态'), findsOneWidget);
    expect(find.text('趋势'), findsOneWidget);
    expect(find.text('动量'), findsOneWidget);
    expect(find.text('相对强弱'), findsOneWidget);
    expect(find.text('成交量参与度'), findsOneWidget);
    expect(find.text('证据一致性'), findsOneWidget);
    expect(find.text('风险提醒'), findsNothing);
  });

  testWidgets('displays risk section when risk flags exist', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        const TechnicalSummaryResult(
          trend: TrendState.upward,
          momentum: MomentumState.positive,
          strength: StrengthState.overextendedHigh,
          participation: ParticipationState.confirming,
          consistency: EvidenceConsistency.high,
          riskFlags: [
            TechnicalRiskFlag.rsiHigh,
            TechnicalRiskFlag.priceExtended,
          ],
        ),
      ),
    );

    expect(find.text('风险提醒'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
  });

  testWidgets('displays unavailable evidence without crashing', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        const TechnicalSummaryResult(
          trend: TrendState.unavailable,
          momentum: MomentumState.unavailable,
          strength: StrengthState.unavailable,
          participation: ParticipationState.unavailable,
          consistency: EvidenceConsistency.unavailable,
          riskFlags: [TechnicalRiskFlag.dataInsufficient],
        ),
      ),
    );

    expect(find.text('综合技术状态'), findsOneWidget);
    expect(find.text('风险提醒'), findsOneWidget);
    expect(find.byType(TechnicalSummarySection), findsOneWidget);
  });
}
