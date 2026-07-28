import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_stockapp/core/network/api_client.dart';
import 'package:flutter_stockapp/core/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiClient', () {
    test('getJson sends path and query parameters', () async {
      late RequestOptions capturedRequest;
      final client = _buildClient((request) async {
        capturedRequest = request;
        return _jsonResponse(
          statusCode: 200,
          data: {'status': 'ok'},
        );
      });

      final result = await client.getJson(
        path: '/api/v1/health',
        queryParameters: {'source': 'flutter'},
      );

      expect(capturedRequest.path, '/api/v1/health');
      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.queryParameters, {'source': 'flutter'});
      expect(result, {'status': 'ok'});
    });

    test('postJson sends the supplied JSON body', () async {
      late RequestOptions capturedRequest;
      final client = _buildClient((request) async {
        capturedRequest = request;
        return _jsonResponse(
          statusCode: 200,
          data: {'accepted': true},
        );
      });

      final result = await client.postJson(
        path: '/api/v1/example',
        body: {
          'symbol': '600519.SH',
          'period': 20,
        },
      );

      expect(capturedRequest.path, '/api/v1/example');
      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.data, {
        'symbol': '600519.SH',
        'period': 20,
      });
      expect(result, {'accepted': true});
    });

    test('rejects a response that is not a JSON object', () async {
      final client = _buildClient((request) async {
        return _jsonResponse(
          statusCode: 200,
          data: ['unexpected', 'list'],
        );
      });

      await expectLater(
        client.getJson(path: '/api/v1/example'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiErrorType.invalidResponse,
          ),
        ),
      );
    });

    test('maps timeout errors to ApiException', () async {
      final client = _buildClient((request) async {
        throw DioException(
          requestOptions: request,
          type: DioExceptionType.connectionTimeout,
        );
      });

      await expectLater(
        client.getJson(path: '/api/v1/example'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiErrorType.timeout,
          ),
        ),
      );
    });

    test('maps connection errors to ApiException', () async {
      final client = _buildClient((request) async {
        throw DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        );
      });

      await expectLater(
        client.getJson(path: '/api/v1/example'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiErrorType.connection,
          ),
        ),
      );
    });

    test('maps a 404 response without exposing its body', () async {
      final client = _buildClient((request) async {
        return _jsonResponse(
          statusCode: 404,
          data: {
            'detail': 'internal resource information',
          },
        );
      });

      await expectLater(
        client.getJson(path: '/api/v1/missing'),
        throwsA(
          isA<ApiException>()
              .having(
                (error) => error.type,
                'type',
                ApiErrorType.notFound,
              )
              .having(
                (error) => error.statusCode,
                'statusCode',
                404,
              ),
        ),
      );
    });

    test('maps server errors to ApiException', () async {
      final client = _buildClient((request) async {
        return _jsonResponse(
          statusCode: 503,
          data: {
            'detail': 'private server stack information',
          },
        );
      });

      await expectLater(
        client.getJson(path: '/api/v1/example'),
        throwsA(
          isA<ApiException>()
              .having(
                (error) => error.type,
                'type',
                ApiErrorType.server,
              )
              .having(
                (error) => error.statusCode,
                'statusCode',
                503,
              ),
        ),
      );
    });
  });
}

ApiClient _buildClient(_RequestHandler handler) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example.test',
      responseType: ResponseType.json,
    ),
  );

  dio.httpClientAdapter = _StubAdapter(handler);

  return ApiClient(dio: dio);
}

typedef _RequestHandler = Future<ResponseBody> Function(
  RequestOptions request,
);

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.handler);

  final _RequestHandler handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse({
  required int statusCode,
  required Object data,
}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}