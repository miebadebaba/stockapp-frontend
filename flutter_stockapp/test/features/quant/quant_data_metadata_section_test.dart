import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_data_metadata.dart';
import 'package:flutter_stockapp/features/quant/quant_data_metadata_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('展示数据区间、数量、复权状态和质量说明', (tester) async {
    final metadata = QuantDataMetadata(
      latestTradingDate: DateTime(2026, 3, 1),
      historyStartDate: DateTime(2026, 1, 1),
      historyBarCount: 60,
      sourceName: 'Market 行情服务',
      priceAdjustment: PriceAdjustment.forward,
      isSimulated: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuantDataMetadataSection(metadata: metadata),
          ),
        ),
      ),
    );

    expect(find.text('数据质量与适用范围'), findsOneWidget);
    expect(find.text('可用于初步分析'), findsOneWidget);
    expect(find.text('2026-01-01 至 2026-03-01'), findsOneWidget);
    expect(find.text('60 条'), findsOneWidget);
    expect(find.text('前复权'), findsOneWidget);
    expect(find.text('Market 行情服务'), findsOneWidget);
    expect(find.textContaining('满足初步技术分析和回测要求'), findsOneWidget);
  });

  testWidgets('模拟数据显示明确限制', (tester) async {
    final metadata = QuantDataMetadata(
      latestTradingDate: DateTime(2026, 3, 1),
      sourceName: '内置模拟数据',
      priceAdjustment: PriceAdjustment.unknown,
      isSimulated: true,
      historyBarCount: 2,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: QuantDataMetadataSection(metadata: metadata)),
      ),
    );

    expect(find.text('模拟数据'), findsOneWidget);
    expect(find.textContaining('仅用于体验功能流程'), findsOneWidget);
  });
}
