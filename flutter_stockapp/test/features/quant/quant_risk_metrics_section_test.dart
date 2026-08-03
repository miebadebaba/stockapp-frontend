import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_risk_metrics_section.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('显示年化波动率和最大回撤', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantRiskMetricsSection(
            bars: _barsFromCloses([100, 102, 101, 103]),
          ),
        ),
      ),
    );

    expect(find.text('风险指标'), findsOneWidget);
    expect(find.text('年化波动率'), findsOneWidget);
    expect(find.text('最大回撤'), findsOneWidget);
    expect(find.textContaining('%'), findsNWidgets(2));
    expect(find.text('0.98%'), findsOneWidget);
  });

  testWidgets('历史数据不足时显示占位内容', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuantRiskMetricsSection(bars: _barsFromCloses([100, 101])),
        ),
      ),
    );

    expect(find.text('--'), findsNWidgets(2));
    expect(find.text('历史数据不足，暂时无法计算风险指标。'), findsOneWidget);
  });
}

List<StockDailyBar> _barsFromCloses(List<double> closes) {
  return List.generate(
    closes.length,
    (index) => StockDailyBar(
      tradingDate: DateTime(2026, 7, index + 1),
      open: closes[index],
      high: closes[index],
      low: closes[index],
      close: closes[index],
      volume: 1000,
    ),
  );
}
