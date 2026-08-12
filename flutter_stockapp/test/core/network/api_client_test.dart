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
        return _jsonResponse(statusCode: 200, data: {'status': 'ok'});
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
        return _jsonResponse(statusCode: 200, data: {'accepted': true});
      });

      final result = await client.postJson(
        path: '/api/v1/example',
        body: {'symbol': '600519.SH', 'period': 20},
        receiveTimeout: const Duration(seconds: 120),
      );

      expect(capturedRequest.path, '/api/v1/example');
      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.receiveTimeout, const Duration(seconds: 120));
      expect(capturedRequest.data, {'symbol': '600519.SH', 'period': 20});
      expect(result, {'accepted': true});
    });

    test('getJsonList accepts a JSON array response', () async {
      late RequestOptions capturedRequest;
      final client = _buildClient((request) async {
        capturedRequest = request;
        return _jsonResponse(
          statusCode: 200,
          data: [
            {'id': 1},
            {'id': 2},
          ],
        );
      });

      final result = await client.getJsonList(
        path: '/api/v1/paper-trading/orders',
        queryParameters: {'limit': 50},
      );

      expect(capturedRequest.path, '/api/v1/paper-trading/orders');
      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.queryParameters, {'limit': 50});
      expect(result, [
        {'id': 1},
        {'id': 2},
      ]);
    });

    test('does not add Authorization when no token is available', () async {
      late RequestOptions capturedRequest;
      final client = _buildClient(
        (request) async {
          capturedRequest = request;
          return _jsonResponse(statusCode: 200, data: {'status': 'ok'});
        },
        accessTokenProvider: () async => null,
      );

      await client.getJson(path: '/api/v1/health');

      expect(capturedRequest.headers['Authorization'], isNull);
    });

    test('adds a Bearer token to relative backend requests', () async {
      late RequestOptions capturedRequest;
      final client = _buildClient(
        (request) async {
          capturedRequest = request;
          return _jsonResponse(statusCode: 200, data: {'status': 'ok'});
        },
        accessTokenProvider: () async => 'current-token',
      );

      await client.getJson(path: '/api/v1/quant/stocks/600519/analysis');

      expect(capturedRequest.headers['Authorization'], 'Bearer current-token');
    });

    test('reads the token again for every request', () async {
      final requests = <RequestOptions>[];
      var token = 'first-token';
      final client = _buildClient(
        (request) async {
          requests.add(request);
          return _jsonResponse(statusCode: 200, data: {'status': 'ok'});
        },
        accessTokenProvider: () async => token,
      );

      await client.getJson(path: '/api/v1/ai/chat');
      token = 'second-token';
      await client.getJson(path: '/api/v1/paper-trading/portfolio');

      expect(requests[0].headers['Authorization'], 'Bearer first-token');
      expect(requests[1].headers['Authorization'], 'Bearer second-token');
    });

    test('stops sending Authorization after the token is cleared', () async {
      final requests = <RequestOptions>[];
      String? token = 'saved-token';
      final client = _buildClient(
        (request) async {
          requests.add(request);
          return _jsonResponse(statusCode: 200, data: {'status': 'ok'});
        },
        accessTokenProvider: () async => token,
      );

      await client.getJson(path: '/api/v1/ai/chat');
      token = null;
      await client.getJson(path: '/api/v1/ai/chat');

      expect(requests[0].headers['Authorization'], 'Bearer saved-token');
      expect(requests[1].headers['Authorization'], isNull);
    });

    test('does not send JWT to third-party absolute URLs', () async {
      late RequestOptions capturedRequest;
      final client = _buildClient(
        (request) async {
          capturedRequest = request;
          return _jsonResponse(statusCode: 200, data: {'status': 'ok'});
        },
        accessTokenProvider: () async => 'current-token',
      );

      await client.getJson(path: 'https://third-party.test/v1/news');

      expect(capturedRequest.headers['Authorization'], isNull);
    });

    test('adds a Bearer token to same-origin absolute backend URLs', () async {
      late RequestOptions capturedRequest;
      final client = _buildClient(
        (request) async {
          capturedRequest = request;
          return _jsonResponse(statusCode: 200, data: {'status': 'ok'});
        },
        accessTokenProvider: () async => 'current-token',
      );

      await client.getJson(path: 'https://example.test/api/v1/ai/chat');

      expect(capturedRequest.headers['Authorization'], 'Bearer current-token');
    });

    test('does not override an explicit Authorization header', () async {
      late RequestOptions capturedRequest;
      final client = _buildClient(
        (request) async {
          capturedRequest = request;
          return _jsonResponse(statusCode: 200, data: {'status': 'ok'});
        },
        accessTokenProvider: () async => 'current-token',
      );

      await client.getJson(
        path: '/api/v1/auth/me',
        headers: {'Authorization': 'Bearer explicit-token'},
      );

      expect(capturedRequest.headers['Authorization'], 'Bearer explicit-token');
    });

    test('rejects a response that is not a JSON object', () async {
      final client = _buildClient((request) async {
        return _jsonResponse(statusCode: 200, data: ['unexpected', 'list']);
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
          data: {'detail': 'internal resource information'},
        );
      });

      await expectLater(
        client.getJson(path: '/api/v1/missing'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.type, 'type', ApiErrorType.notFound)
              .having((error) => error.statusCode, 'statusCode', 404),
        ),
      );
    });

    test('maps server errors to ApiException', () async {
      final client = _buildClient((request) async {
        return _jsonResponse(
          statusCode: 503,
          data: {'detail': 'private server stack information'},
        );
      });

      await expectLater(
        client.getJson(path: '/api/v1/example'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.type, 'type', ApiErrorType.server)
              .having((error) => error.statusCode, 'statusCode', 503),
        ),
      );
    });

    test('maps a 504 response to a timeout', () async {
      final client = _buildClient((request) async {
        return _jsonResponse(
          statusCode: 504,
          data: {'detail': 'upstream timeout'},
        );
      });

      await expectLater(
        client.postJson(path: '/api/v1/ai/chat', body: const {}),
        throwsA(
          isA<ApiException>()
              .having((error) => error.type, 'type', ApiErrorType.timeout)
              .having((error) => error.statusCode, 'statusCode', 504),
        ),
      );
    });
  });
}

ApiClient _buildClient(
  _RequestHandler handler, {
  AccessTokenProvider? accessTokenProvider,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example.test',
      responseType: ResponseType.json,
    ),
  );

  dio.httpClientAdapter = _StubAdapter(handler);

  return ApiClient(dio: dio, accessTokenProvider: accessTokenProvider);
}

typedef _RequestHandler = Future<ResponseBody> Function(RequestOptions request);

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

ResponseBody _jsonResponse({required int statusCode, required Object data}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
