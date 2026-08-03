import 'dart:async';

import 'package:flutter_stockapp/core/network/api_exception.dart';
import 'package:flutter_stockapp/features/quant/quant_analysis_status.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_analysis_api.dart';
import 'package:flutter_stockapp/features/quant/quant_stock_analysis_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuantStockAnalysisController', () {
    test('changes from loading to success', () async {
      final response = Completer<Map<String, dynamic>>();

      final controller = QuantStockAnalysisController(
        api: QuantStockAnalysisApi(
          getJson:
              ({required String path, Map<String, dynamic>? queryParameters}) {
                return response.future;
              },
        ),
      );

      final future = controller.analyze('000001');

      expect(controller.status, QuantAnalysisStatus.loading);
      expect(controller.result, isNull);

      response.complete(_successfulResponse());
      await future;

      expect(controller.status, QuantAnalysisStatus.success);
      expect(controller.result?.symbol, '000001');
      expect(controller.result?.latestBar.close, 11.43);

      controller.dispose();
    });

    test('uses empty state when backend returns 404', () async {
      final controller = QuantStockAnalysisController(
        api: QuantStockAnalysisApi(
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
      );

      await controller.analyze('000001');

      expect(controller.status, QuantAnalysisStatus.empty);
      expect(controller.result, isNull);

      controller.dispose();
    });

    test('uses failure state for unexpected errors', () async {
      final controller = QuantStockAnalysisController(
        api: QuantStockAnalysisApi(
          getJson:
              ({
                required String path,
                Map<String, dynamic>? queryParameters,
              }) async {
                throw StateError('network unavailable');
              },
        ),
      );

      await controller.analyze('000001');

      expect(controller.status, QuantAnalysisStatus.failure);
      expect(controller.result, isNull);

      controller.dispose();
    });

    test('uses insufficient state when history is too short', () async {
      final controller = QuantStockAnalysisController(
        api: QuantStockAnalysisApi(
          getJson:
              ({
                required String path,
                Map<String, dynamic>? queryParameters,
              }) async {
                return _successfulResponse(riskFlags: ['data_insufficient']);
              },
        ),
      );

      await controller.analyze('000001');

      expect(controller.status, QuantAnalysisStatus.insufficientData);
      expect(controller.result, isNull);

      controller.dispose();
    });
  });
}

Map<String, dynamic> _successfulResponse({List<String> riskFlags = const []}) {
  return {
    'symbol': '000001',
    'bars': [
      {
        'trade_date': '2026-07-30',
        'open': 11.28,
        'high': 11.45,
        'low': 11.18,
        'close': 11.43,
        'previous_close': 11.28,
        'volume': 63912219,
      },
    ],
    'latest_bar': {
      'trade_date': '2026-07-30',
      'open': 11.28,
      'high': 11.45,
      'low': 11.18,
      'close': 11.43,
      'previous_close': 11.28,
      'volume': 63912219,
    },
    'ma5': 11.224,
    'ma10': 11.078,
    'ma20': 10.821,
    'macd': {'dif': 0.1647, 'dea': 0.0854, 'histogram': 0.1586},
    'rsi14': 85.0,
    'volume': {
      'latest_volume': 63912219,
      'average_volume': 115317930.4,
      'volume_ratio': 0.5542,
      'price_direction': 'up',
    },
    'technical_summary': {
      'trend': riskFlags.contains('data_insufficient')
          ? 'insufficient_data'
          : 'upward',
      'momentum': riskFlags.contains('data_insufficient')
          ? 'insufficient_data'
          : 'positive',
      'strength': riskFlags.contains('data_insufficient')
          ? 'insufficient_data'
          : 'high',
      'participation': riskFlags.contains('data_insufficient')
          ? 'insufficient_data'
          : 'low',
      'consistency': riskFlags.contains('data_insufficient')
          ? 'unavailable'
          : 'moderate',
      'risk_flags': riskFlags,
    },
  };
}
