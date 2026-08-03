import 'dart:async';

import 'package:flutter_stockapp/core/network/api_exception.dart';
import 'package:flutter_stockapp/features/quant/quant_analysis_status.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_api.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_controller.dart';
import 'package:flutter_stockapp/features/quant/technical_summary_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TechnicalSummaryController', () {
    test('starts in idle state', () {
      final controller = TechnicalSummaryController(
        api: TechnicalSummaryApi(
          postJson: ({required String path, required Object body}) async {
            return _successfulResponse();
          },
        ),
      );

      expect(controller.status, QuantAnalysisStatus.idle);
      expect(controller.result, isNull);

      controller.dispose();
    });

    test('uses empty state without calling api when bars are empty', () async {
      var callCount = 0;

      final controller = TechnicalSummaryController(
        api: TechnicalSummaryApi(
          postJson: ({required String path, required Object body}) async {
            callCount += 1;
            return _successfulResponse();
          },
        ),
      );

      await controller.analyze(const []);

      expect(callCount, 0);
      expect(controller.status, QuantAnalysisStatus.empty);
      expect(controller.result, isNull);

      controller.dispose();
    });

    test('changes from loading to success', () async {
      final responseCompleter = Completer<Map<String, dynamic>>();

      final controller = TechnicalSummaryController(
        api: TechnicalSummaryApi(
          postJson: ({required String path, required Object body}) {
            return responseCompleter.future;
          },
        ),
      );

      final analysisFuture = controller.analyze([_bar()]);

      expect(controller.status, QuantAnalysisStatus.loading);
      expect(controller.result, isNull);

      responseCompleter.complete(_successfulResponse());
      await analysisFuture;

      expect(controller.status, QuantAnalysisStatus.success);
      expect(controller.result, isNotNull);
      expect(controller.result?.trend, TrendState.upward);

      controller.dispose();
    });

    test('changes to failure when api throws an error', () async {
      final controller = TechnicalSummaryController(
        api: TechnicalSummaryApi(
          postJson: ({required String path, required Object body}) async {
            throw StateError('network unavailable');
          },
        ),
      );

      await controller.analyze([_bar()]);

      expect(controller.status, QuantAnalysisStatus.failure);
      expect(controller.result, isNull);

      controller.dispose();
    });

    test('uses empty state when backend returns not found', () async {
      final controller = TechnicalSummaryController(
        api: TechnicalSummaryApi(
          postJson: ({required String path, required Object body}) async {
            throw const ApiException(
              type: ApiErrorType.notFound,
              message: '请求的内容不存在。',
              statusCode: 404,
            );
          },
        ),
      );

      await controller.analyze([_bar()]);

      expect(controller.status, QuantAnalysisStatus.empty);
      expect(controller.result, isNull);

      controller.dispose();
    });

    test(
      'uses insufficient state when backend reports short history',
      () async {
        final controller = TechnicalSummaryController(
          api: TechnicalSummaryApi(
            postJson: ({required String path, required Object body}) async {
              return {
                'trend': 'insufficient_data',
                'momentum': 'insufficient_data',
                'strength': 'insufficient_data',
                'participation': 'insufficient_data',
                'consistency': 'unavailable',
                'risk_flags': ['data_insufficient'],
              };
            },
          ),
        );

        await controller.analyze([_bar()]);

        expect(controller.status, QuantAnalysisStatus.insufficientData);
        expect(controller.result, isNull);

        controller.dispose();
      },
    );

    test('an older request cannot overwrite a newer result', () async {
      final firstResponse = Completer<Map<String, dynamic>>();
      final secondResponse = Completer<Map<String, dynamic>>();
      var callCount = 0;

      final controller = TechnicalSummaryController(
        api: TechnicalSummaryApi(
          postJson: ({required String path, required Object body}) {
            callCount += 1;
            return callCount == 1
                ? firstResponse.future
                : secondResponse.future;
          },
        ),
      );

      final firstAnalysis = controller.analyze([_bar()]);
      final secondAnalysis = controller.analyze([_bar(close: 11)]);

      secondResponse.complete(_successfulResponse(trend: 'downward'));
      await secondAnalysis;

      expect(controller.result?.trend, TrendState.downward);

      firstResponse.complete(_successfulResponse(trend: 'upward'));
      await firstAnalysis;

      expect(controller.status, QuantAnalysisStatus.success);
      expect(controller.result?.trend, TrendState.downward);

      controller.dispose();
    });

    test('reset clears the current result', () async {
      final controller = TechnicalSummaryController(
        api: TechnicalSummaryApi(
          postJson: ({required String path, required Object body}) async {
            return _successfulResponse();
          },
        ),
      );

      await controller.analyze([_bar()]);
      controller.reset();

      expect(controller.status, QuantAnalysisStatus.idle);
      expect(controller.result, isNull);

      controller.dispose();
    });
  });
}

StockDailyBar _bar({double close = 10.5}) {
  return StockDailyBar(
    tradingDate: DateTime(2026, 1, 2),
    open: 10.1,
    high: 11,
    low: 9.9,
    close: close,
    volume: 1200,
  );
}

Map<String, dynamic> _successfulResponse({String trend = 'upward'}) {
  return {
    'trend': trend,
    'momentum': 'positive',
    'strength': 'relatively_strong',
    'participation': 'confirming',
    'consistency': 'high',
    'risk_flags': <String>[],
  };
}
