import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_ic.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_ic_dashboard.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_ic_dashboard_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows loading state', (tester) async {
    await _pumpSection(tester, result: null, isLoading: true);

    expect(find.text('因子有效性'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('暂无因子有效性结果'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows insufficient real stock state without IC values', (
    tester,
  ) async {
    await _pumpSection(
      tester,
      result: const QuantFactorIcDashboardResult(
        status: QuantFactorIcDashboardStatus.insufficientRealStocks,
        realStockCount: 2,
      ),
    );

    expect(find.text('真实股票样本不足'), findsOneWidget);
    expect(find.textContaining('当前只有 2 只真实数据股票'), findsOneWidget);
    expect(find.text('Rank IC'), findsNothing);
    expect(find.text('平均 IC'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows insufficient history state without IC values', (
    tester,
  ) async {
    await _pumpSection(
      tester,
      result: const QuantFactorIcDashboardResult(
        status: QuantFactorIcDashboardStatus.insufficientHistory,
        realStockCount: 3,
      ),
    );

    expect(find.text('历史数据不足'), findsOneWidget);
    expect(find.textContaining('已有 3 只真实数据股票'), findsOneWidget);
    expect(find.text('Rank IC'), findsNothing);
    expect(find.text('ICIR'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows backend load failure state', (tester) async {
    await _pumpSection(
      tester,
      result: const QuantFactorIcDashboardResult(
        status: QuantFactorIcDashboardStatus.loadFailure,
        realStockCount: 3,
      ),
    );

    expect(find.text('因子有效性加载失败'), findsOneWidget);
    expect(find.textContaining('请确认后端已启动后刷新重试'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    expect(find.text('Rank IC'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows metrics for all available factors', (tester) async {
    final result = QuantFactorIcDashboardResult(
      status: QuantFactorIcDashboardStatus.available,
      realStockCount: 6,
      factorResults: {
        'trend': _factorResult(
          factorId: 'trend',
          firstIc: 0.20,
          secondIc: 0.40,
        ),
        'momentum': _factorResult(
          factorId: 'momentum',
          firstIc: 0.10,
          secondIc: -0.10,
        ),
        'volume': _factorResult(
          factorId: 'volume',
          firstIc: -0.20,
          secondIc: -0.40,
        ),
      },
    );

    await _pumpSection(tester, result: result);

    expect(find.text('趋势因子'), findsOneWidget);
    expect(find.text('动量因子'), findsOneWidget);
    expect(find.text('量价因子'), findsOneWidget);

    expect(find.text('Rank IC'), findsNWidgets(3));
    expect(find.text('平均 IC'), findsNWidgets(3));
    expect(find.text('正 IC 比例'), findsNWidgets(3));
    expect(find.text('ICIR'), findsNWidgets(3));

    expect(find.text('+0.30'), findsNWidgets(2));
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);

    expect(find.textContaining('有效 2 期'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpSection(
  WidgetTester tester, {
  required QuantFactorIcDashboardResult? result,
  bool isLoading = false,
}) async {
  tester.view
    ..physicalSize = const Size(420, 900)
    ..devicePixelRatio = 1;

  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: QuantFactorIcDashboardSection(
            result: result,
            isLoading: isLoading,
          ),
        ),
      ),
    ),
  );
}

QuantFactorIcResult _factorResult({
  required String factorId,
  required double firstIc,
  required double secondIc,
}) {
  return QuantFactorIcResult(
    factorId: factorId,
    periods: [
      QuantFactorIcPeriodResult(
        date: DateTime(2026, 1, 1),
        sampleSize: 6,
        informationCoefficient: firstIc,
        rankInformationCoefficient: firstIc,
      ),
      QuantFactorIcPeriodResult(
        date: DateTime(2026, 1, 2),
        sampleSize: 6,
        informationCoefficient: secondIc,
        rankInformationCoefficient: secondIc,
      ),
    ],
  );
}
