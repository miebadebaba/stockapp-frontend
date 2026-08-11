import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_stockapp/core/network/api_client.dart';
import 'package:flutter_stockapp/core/network/api_exception.dart';
import 'package:flutter_stockapp/features/auth/auth_remote_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('register and login send JSON without Authorization', () async {
    final requests = <RequestOptions>[];
    final api = HttpAuthApi(
      apiClient: _client((request) async {
        requests.add(request);
        if (request.path.endsWith('/register')) {
          return _response(_userJson);
        }
        return _response({'access_token': 'token', 'token_type': 'bearer'});
      }),
    );

    await api.register(username: 'new-user', password: 'password');
    await api.login(username: 'new-user', password: 'password');

    expect(requests[0].data, {'username': 'new-user', 'password': 'password'});
    expect(requests[1].data, {'username': 'new-user', 'password': 'password'});
    expect(requests[0].headers['Authorization'], isNull);
    expect(requests[1].headers['Authorization'], isNull);
  });

  test('/auth/me sends the Bearer token', () async {
    late RequestOptions request;
    final api = HttpAuthApi(
      apiClient: _client((captured) async {
        request = captured;
        return _response(_userJson);
      }),
    );

    await api.getCurrentUser('token-value');

    expect(request.path, '/api/v1/auth/me');
    expect(request.headers['Authorization'], 'Bearer token-value');
  });

  test('login preserves the machine-readable disabled account code', () async {
    final api = HttpAuthApi(
      apiClient: _client((_) async {
        return _response(
          {'code': 'ACCOUNT_DISABLED', 'detail': 'Account is disabled.'},
          statusCode: 403,
        );
      }),
    );

    await expectLater(
      api.login(username: 'disabled-user', password: 'correct-password'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 403)
            .having((error) => error.code, 'code', 'ACCOUNT_DISABLED'),
      ),
    );
  });
}

ApiClient _client(_RequestHandler handler) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = _Adapter(handler);
  return ApiClient(dio: dio);
}

typedef _RequestHandler = Future<ResponseBody> Function(RequestOptions request);

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final _RequestHandler handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _response(Object data, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

const _userJson = {
  'id': 1,
  'username': 'testuser',
  'role': 'user',
  'status': 'active',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
};
