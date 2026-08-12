import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/ai_chat_message.dart';

abstract interface class AiChatService {
  Future<String> sendMessage({
    required String message,
    required List<AiChatMessage> history,
  });

  void close();
}

class HttpAiChatService implements AiChatService {
  HttpAiChatService({
    ApiClient? apiClient,
    this.receiveTimeout = const Duration(seconds: 120),
  }) : _apiClient = apiClient ?? ApiClient(),
       _ownsApiClient = apiClient == null;

  static const maxHistoryMessages = 9;
  static const endpointPath = '/api/v1/ai/chat';

  final ApiClient _apiClient;
  final bool _ownsApiClient;
  final Duration receiveTimeout;

  @override
  Future<String> sendMessage({
    required String message,
    required List<AiChatMessage> history,
  }) async {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      throw const AiChatRequestException('请输入问题后再发送。');
    }

    final limitedHistory = history.length <= maxHistoryMessages
        ? history
        : history.sublist(history.length - maxHistoryMessages);
    final stopwatch = Stopwatch()..start();
    _debugLog('started');

    try {
      final response = await _apiClient
          .postJson(
            path: endpointPath,
            body: {
              'message': trimmedMessage,
              'history': limitedHistory.map((item) => item.toJson()).toList(),
            },
            receiveTimeout: receiveTimeout,
          )
          .timeout(receiveTimeout);
      final reply = response['reply'];
      if (reply is! String || reply.trim().isEmpty) {
        throw const AiChatRequestException('后端返回了无法识别的数据。');
      }
      _debugLog('completed in ${stopwatch.elapsedMilliseconds}ms');
      return reply.trim();
    } on TimeoutException {
      _debugLog('failed: timeout after ${stopwatch.elapsedMilliseconds}ms');
      throw const AiChatRequestException('AI 回复超时，请稍后重试。');
    } on ApiException catch (error) {
      _debugLog(
        'failed: ${error.type.name} after ${stopwatch.elapsedMilliseconds}ms',
      );
      throw AiChatRequestException(_messageForApiError(error));
    } on AiChatRequestException {
      _debugLog(
        'failed: invalidResponse after ${stopwatch.elapsedMilliseconds}ms',
      );
      rethrow;
    } catch (error) {
      _debugLog(
        'failed: ${error.runtimeType} after ${stopwatch.elapsedMilliseconds}ms',
      );
      throw const AiChatRequestException('发送失败，请稍后重试。');
    }
  }

  String _messageForApiError(ApiException error) {
    if (error.statusCode == 422) {
      return '问题内容不符合要求，请修改后重试。';
    }

    return switch (error.type) {
      ApiErrorType.timeout => 'AI 回复超时，请稍后重试。',
      ApiErrorType.connection => '无法连接到后端，请检查服务是否已启动。',
      ApiErrorType.server => 'AI 服务暂时不可用，请稍后重试。',
      ApiErrorType.invalidResponse => '后端返回了无法识别的数据。',
      ApiErrorType.cancelled => '请求已取消。',
      _ => '发送失败，请稍后重试。',
    };
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('AI chat request $message');
    }
  }

  @override
  void close() {
    if (_ownsApiClient) {
      _apiClient.close(force: true);
    }
  }
}

class AiChatRequestException implements Exception {
  const AiChatRequestException(this.message);

  final String message;
}
