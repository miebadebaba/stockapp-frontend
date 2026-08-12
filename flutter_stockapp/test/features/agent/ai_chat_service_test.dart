import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_stockapp/core/network/api_client.dart';
import 'package:flutter_stockapp/features/agent/models/ai_chat_message.dart';
import 'package:flutter_stockapp/features/agent/services/ai_chat_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns an immediate UTF-8 reply with the existing schema', () async {
    late RequestOptions capturedRequest;
    final apiClient = _buildApiClient((request) async {
      capturedRequest = request;
      return _jsonResponse({'reply': '连接成功'});
    });
    final service = HttpAiChatService(apiClient: apiClient);

    final reply = await service.sendMessage(
      message: '你好',
      history: const [
        AiChatMessage(role: AiChatRole.user, content: '上一条问题'),
        AiChatMessage(role: AiChatRole.assistant, content: '上一条回答'),
      ],
    );

    expect(reply, '连接成功');
    expect(capturedRequest.path, HttpAiChatService.endpointPath);
    expect(capturedRequest.receiveTimeout, const Duration(seconds: 120));
    expect(capturedRequest.data, {
      'message': '你好',
      'history': [
        {'role': 'user', 'content': '上一条问题'},
        {'role': 'assistant', 'content': '上一条回答'},
      ],
    });
  });

  testWidgets('allows a mocked 25 second AI response', (tester) async {
    final apiClient = _buildApiClient((request) async {
      await Future<void>.delayed(const Duration(seconds: 25));
      return _jsonResponse({'reply': '慢速回复成功'});
    });
    final service = HttpAiChatService(apiClient: apiClient);

    final replyFuture = service.sendMessage(message: '请回答', history: const []);
    await tester.pump();
    await tester.pump(const Duration(seconds: 25));

    await expectLater(replyFuture, completion('慢速回复成功'));
  });

  testWidgets('reports a friendly timeout after the AI receive timeout', (
    tester,
  ) async {
    final apiClient = _buildApiClient((request) async {
      await Future<void>.delayed(const Duration(seconds: 121));
      return _jsonResponse({'reply': '不应显示'});
    });
    final service = HttpAiChatService(apiClient: apiClient);

    final expectation = expectLater(
      service.sendMessage(message: '请回答', history: const []),
      throwsA(
        isA<AiChatRequestException>().having(
          (error) => error.message,
          'message',
          'AI 回复超时，请稍后重试。',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 121));

    await expectation;
  });
}

ApiClient _buildApiClient(_RequestHandler handler) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000',
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
    ),
  );
  dio.httpClientAdapter = _StubAdapter(handler);
  return ApiClient(dio: dio);
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

ResponseBody _jsonResponse(Map<String, dynamic> data) {
  return ResponseBody.fromString(
    jsonEncode(data),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
