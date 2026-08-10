import 'package:flutter/material.dart';
import 'package:flutter_stockapp/core/network/api_exception.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/quant/quant_page.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_analysis_mock.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_section.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/features/quant/quant_backtest_parameters_section.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_score_section.dart';
import 'package:flutter_stockapp/features/quant/quant_price_chart.dart';
import 'package:flutter_stockapp/features/quant/quant_overview_section.dart';

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
          rankingAnalyze: (symbol) async => buildMockQuantStockAnalysis(symbol),
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

    final chooseStockButton = find.widgetWithText(FilledButton, '选择股票');
    await tester.ensureVisible(chooseStockButton);
    await tester.pumpAndSettle();
    await tester.tap(chooseStockButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, '600519 · A股'));
    await tester.pumpAndSettle();

    expect(callCount, 1);
    expect(receivedPath, '/api/v1/quant/stocks/600519/analysis');
    expect(receivedQuery, {'limit': 60});
    expect(find.text('600519'), findsOneWidget);
    expect(find.byType(QuantOverviewSection), findsOneWidget);
    expect(find.text('当前数据来自 Market 行情服务'), findsOneWidget);
  });

  testWidgets('custom stock code requests backend analysis', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    String? receivedPath;
    Map<String, dynamic>? receivedQuery;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: QuantPage(
          rankingAnalyze: (symbol) async => buildMockQuantStockAnalysis(symbol),
          getJson:
              ({
                required String path,
                Map<String, dynamic>? queryParameters,
              }) async {
                receivedPath = path;
                receivedQuery = queryParameters;
                return _successfulResponse();
              },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chooseStockButton = find.widgetWithText(FilledButton, '选择股票');
    await tester.ensureVisible(chooseStockButton);
    await tester.pumpAndSettle();
    await tester.tap(chooseStockButton);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '000333');
    await tester.pumpAndSettle();

    final customCodeTile = find.widgetWithText(ListTile, '000333 · A股');
    expect(customCodeTile, findsOneWidget);

    await tester.tap(customCodeTile);
    await tester.pumpAndSettle();

    expect(receivedPath, '/api/v1/quant/stocks/000333/analysis');
    expect(receivedQuery, {'limit': 60});
    expect(find.text('000333'), findsOneWidget);
  });

  testWidgets('uses mock analysis when backend request fails', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var callCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: QuantPage(
          rankingAnalyze: (symbol) async => buildMockQuantStockAnalysis(symbol),
          getJson:
              ({
                required String path,
                Map<String, dynamic>? queryParameters,
              }) async {
                callCount += 1;
                throw StateError('temporary failure');
              },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chooseStockButton = find.widgetWithText(FilledButton, '选择股票');
    await tester.ensureVisible(chooseStockButton);
    await tester.pumpAndSettle();
    await tester.tap(chooseStockButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, '600519 · A股'));
    await tester.pumpAndSettle();

    expect(callCount, 1);
    expect(find.byType(QuantOverviewSection), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsNothing);
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(find.text('当前显示内置模拟数据，仅用于功能演示'), findsOneWidget);
    expect(find.text('当前数据来自 Market 行情服务'), findsNothing);
  });

  testWidgets('uses mock analysis when backend returns 404', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: QuantPage(
          rankingAnalyze: (symbol) async => buildMockQuantStockAnalysis(symbol),
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

    final chooseStockButton = find.widgetWithText(FilledButton, '选择股票');
    await tester.ensureVisible(chooseStockButton);
    await tester.pumpAndSettle();
    await tester.tap(chooseStockButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, '600519 · A股'));
    await tester.pumpAndSettle();

    expect(find.byType(QuantOverviewSection), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });
  testWidgets('detail tabs switch content and reset after changing stock', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: QuantPage(
          rankingAnalyze: (symbol) async => buildMockQuantStockAnalysis(symbol),
          getJson:
              ({
                required String path,
                Map<String, dynamic>? queryParameters,
              }) async {
                return _successfulResponse();
              },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chooseStockButton = find.widgetWithText(FilledButton, '选择股票');
    await tester.ensureVisible(chooseStockButton);
    await tester.tap(chooseStockButton);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, '600519 · A股'));
    await tester.pumpAndSettle();

    expect(find.byType(QuantOverviewSection), findsOneWidget);

    await tester.tap(find.text('技术'));
    await tester.pumpAndSettle();

    expect(find.byType(QuantPriceChart), findsOneWidget);
    expect(find.byType(TechnicalSummarySection), findsOneWidget);
    expect(find.byType(QuantOverviewSection), findsNothing);

    await tester.tap(find.text('多因子'));
    await tester.pumpAndSettle();

    expect(find.byType(QuantFactorScoreSection), findsOneWidget);
    expect(find.byType(QuantPriceChart), findsNothing);

    await tester.tap(find.text('回测'));
    await tester.pumpAndSettle();

    final backtestParametersTile = find.byKey(
      const ValueKey('quant-backtest-parameters'),
    );

    expect(backtestParametersTile, findsOneWidget);
    expect(find.byType(QuantBacktestParametersSection), findsNothing);

    await tester.ensureVisible(backtestParametersTile);
    await tester.tap(backtestParametersTile);
    await tester.pumpAndSettle();

    expect(find.byType(QuantBacktestParametersSection), findsOneWidget);

    final changeStockButton = find.widgetWithText(OutlinedButton, '更换股票');
    await tester.ensureVisible(changeStockButton);
    await tester.pumpAndSettle();
    await tester.tap(changeStockButton);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, '000001 · A股'));
    await tester.pumpAndSettle();

    expect(find.text('000001'), findsOneWidget);
    expect(find.byType(QuantOverviewSection), findsOneWidget);
    expect(find.byType(QuantBacktestParametersSection), findsNothing);
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
