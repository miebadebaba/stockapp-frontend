import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/network/api_exception.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_page.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selecting a stock requests and displays backend analysis', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    String? receivedPath;
    Object? receivedBody;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: QuantPage(
          postJson: ({required String path, required Object body}) async {
            receivedPath = path;
            receivedBody = body;

            return {
              'trend': 'upward',
              'momentum': 'positive',
              'strength': 'relatively_strong',
              'participation': 'confirming',
              'consistency': 'high',
              'risk_flags': <String>[],
            };
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('600519'));
    await tester.pumpAndSettle();

    expect(receivedPath, '/api/v1/quant/technical-summary');
    expect(receivedBody, isA<List<Map<String, dynamic>>>());
    expect((receivedBody! as List).isNotEmpty, isTrue);
    expect(find.text('600519'), findsOneWidget);
    expect(find.byType(TechnicalSummarySection), findsOneWidget);
  });

  testWidgets('retry succeeds after the first backend request fails', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var callCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: QuantPage(
          postJson: ({required String path, required Object body}) async {
            callCount += 1;

            if (callCount == 1) {
              throw StateError('temporary failure');
            }

            return {
              'trend': 'upward',
              'momentum': 'positive',
              'strength': 'relatively_strong',
              'participation': 'confirming',
              'consistency': 'high',
              'risk_flags': <String>[],
            };
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('600519'));
    await tester.pumpAndSettle();

    expect(callCount, 1);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(callCount, 2);
    expect(find.byType(TechnicalSummarySection), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });

  testWidgets('shows empty market state when backend returns 404', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: QuantPage(
          postJson: ({required String path, required Object body}) async {
            throw const ApiException(
              type: ApiErrorType.notFound,
              message: '请求的内容不存在。',
              statusCode: 404,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('600519'));
    await tester.pumpAndSettle();

    expect(find.text('暂无行情数据'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byType(TechnicalSummarySection), findsNothing);
  });
}
