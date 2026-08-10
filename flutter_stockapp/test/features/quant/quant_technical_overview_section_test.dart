import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/macd_result.dart';
import 'package:flutter_stockapp/features/quant/quant_technical_overview_section.dart';
import 'package:flutter_stockapp/features/quant/volume_analysis_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    double? close = 105,
    double? ma5 = 104,
    double? ma10 = 101,
    double? ma20 = 98,
    MacdResult? macd = const MacdResult(dif: 1.2, dea: 0.8, histogram: 0.4),
    double? rsi14 = 58,
    VolumeAnalysisResult? volume = const VolumeAnalysisResult(
      latestVolume: 1200000,
      averageVolume: 1000000,
      volumeRatio: 1.2,
      priceDirection: PriceDirection.up,
    ),
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: QuantTechnicalOverviewSection(
            close: close,
            ma5: ma5,
            ma10: ma10,
            ma20: ma20,
            macd: macd,
            rsi14: rsi14,
            volume: volume,
          ),
        ),
      ),
    );
  }

  testWidgets('显示技术指标并默认折叠', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byType(QuantTechnicalOverviewSection), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNWidgets(4));

    expect(find.text('MACD'), findsOneWidget);
    expect(find.text('RSI14'), findsOneWidget);

    // 默认折叠时，MACD 的详细数值不应显示。
    expect(find.textContaining('1.20'), findsNothing);
  });

  testWidgets('点击技术指标后显示详细内容', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('MACD'));
    await tester.pumpAndSettle();

    // 展开后应显示 MACD 的指标数值。
    expect(find.textContaining('1.20'), findsOneWidget);
    expect(find.textContaining('0.80'), findsOneWidget);
    expect(find.textContaining('0.40'), findsOneWidget);
  });

  testWidgets('数据不足时仍显示技术指标区域', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        close: null,
        ma5: null,
        ma10: null,
        ma20: null,
        macd: null,
        rsi14: null,
        volume: null,
      ),
    );

    expect(find.byType(QuantTechnicalOverviewSection), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNWidgets(4));
    expect(find.text('MACD'), findsOneWidget);
    expect(find.text('RSI14'), findsOneWidget);
  });
}
