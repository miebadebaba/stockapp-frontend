import 'package:flutter/material.dart';
import 'package:flutter_stockapp/features/quant/quant_analysis_state_view.dart';
import 'package:flutter_stockapp/features/quant/quant_analysis_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    required QuantAnalysisStatus status,
    VoidCallback? onRetry,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: QuantAnalysisStateView(status: status, onRetry: onRetry),
      ),
    );
  }

  testWidgets('加载状态显示进度指示器和提示文字', (tester) async {
    await tester.pumpWidget(buildSubject(status: QuantAnalysisStatus.loading));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('正在获取行情并计算技术指标...'), findsOneWidget);
  });

  testWidgets('空数据状态显示数据不足提示', (tester) async {
    await tester.pumpWidget(buildSubject(status: QuantAnalysisStatus.empty));

    expect(find.text('暂无可分析数据'), findsOneWidget);
    expect(find.text('当前股票的历史数据不足，请稍后重试或选择其他股票。'), findsOneWidget);
  });

  testWidgets('失败状态显示错误信息和重试按钮', (tester) async {
    await tester.pumpWidget(
      buildSubject(status: QuantAnalysisStatus.failure, onRetry: () {}),
    );

    expect(find.text('分析失败'), findsOneWidget);
    expect(find.text('重新尝试'), findsOneWidget);
  });

  testWidgets('点击重新尝试按钮会执行重试操作', (tester) async {
    var retryCalled = false;

    await tester.pumpWidget(
      buildSubject(
        status: QuantAnalysisStatus.failure,
        onRetry: () {
          retryCalled = true;
        },
      ),
    );

    await tester.tap(find.text('重新尝试'));
    await tester.pump();

    expect(retryCalled, isTrue);
  });

  testWidgets('成功状态不显示额外状态界面', (tester) async {
    await tester.pumpWidget(buildSubject(status: QuantAnalysisStatus.success));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('分析失败'), findsNothing);
    expect(find.text('暂无可分析数据'), findsNothing);
  });
}
