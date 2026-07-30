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

    var callCount = 0;
    String? receivedPath;
    Map<String, dynamic>? receivedQuery;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: QuantPage(
          getJson:
              ({
                required String path,
                Map<String, dynamic>? queryParameters,
              }) async {
                callCount += 1;
                receivedPath = path;
                receivedQuery = queryParameters;
                return _successfulResponse();
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
    expect(receivedPath, '/api/v1/quant/stocks/600519/analysis');
    expect(receivedQuery, {'limit': 60});
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
          getJson:
              ({
                required String path,
                Map<String, dynamic>? queryParameters,
              }) async {
                callCount += 1;

                if (callCount == 1) {
                  throw StateError('temporary failure');
                }

                return _successfulResponse();
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
          getJson:
              ({
                required String path,
                Map<String, dynamic>? queryParameters,
              }) async {
                throw const ApiException(
                  type: ApiErrorType.notFound,
                  message: 'Not found',
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

    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byType(TechnicalSummarySection), findsNothing);
  });
}

Map<String, dynamic> _successfulResponse() {
  return {
    'symbol': '600519',
    'bars': [
      {
        'trade_date': '2026-07-30',
        'open': 1450.0,
        'high': 1470.0,
        'low': 1440.0,
        'close': 1465.0,
        'previous_close': 1450.0,
        'volume': 100000,
      },
    ],
    'latest_bar': {
      'trade_date': '2026-07-30',
      'open': 1450.0,
      'high': 1470.0,
      'low': 1440.0,
      'close': 1465.0,
      'previous_close': 1450.0,
      'volume': 100000,
    },
    'ma5': 1458.0,
    'ma10': 1449.0,
    'ma20': 1438.0,
    'macd': {'dif': 2.5, 'dea': 1.8, 'histogram': 1.4},
    'rsi14': 62.0,
    'volume': {
      'latest_volume': 100000,
      'average_volume': 90000.0,
      'volume_ratio': 1.11,
      'price_direction': 'up',
    },
    'technical_summary': {
      'trend': 'upward',
      'momentum': 'positive',
      'strength': 'relatively_strong',
      'participation': 'confirming',
      'consistency': 'high',
      'risk_flags': <String>[],
    },
  };
}
