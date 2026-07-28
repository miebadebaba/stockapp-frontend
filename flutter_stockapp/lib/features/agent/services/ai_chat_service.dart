import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../core/network/api_config.dart';
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
    Uri? baseUri,
    HttpClient? httpClient,
    this.timeout = const Duration(seconds: 30),
  }) : _baseUri = baseUri ?? ApiConfig.baseUri,
       _httpClient = httpClient ?? HttpClient() {
    _httpClient.connectionTimeout = timeout;
  }

  static const maxHistoryMessages = 9;

  final Uri _baseUri;
  final HttpClient _httpClient;
  final Duration timeout;

  Uri get _chatUri {
    final baseUrl = _baseUri.toString().replaceFirst(RegExp(r'/$'), '');
    return Uri.parse('$baseUrl/api/v1/ai/chat');
  }

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

    try {
      return await _send(
        message: trimmedMessage,
        history: limitedHistory,
      ).timeout(timeout);
    } on TimeoutException {
      throw const AiChatRequestException('AI 回复超时，请稍后重试。');
    } on SocketException {
      throw const AiChatRequestException('无法连接到后端，请检查服务是否已启动。');
    } on HttpException {
      throw const AiChatRequestException('后端连接异常，请稍后重试。');
    } on FormatException {
      throw const AiChatRequestException('后端返回了无法识别的数据。');
    }
  }

  Future<String> _send({
    required String message,
    required List<AiChatMessage> history,
  }) async {
    final request = await _httpClient.postUrl(_chatUri);
    request.headers.contentType = ContentType.json;
    request.write(
      jsonEncode({
        'message': message,
        'history': history.map((item) => item.toJson()).toList(),
      }),
    );

    final response = await request.close();
    final responseBody = await utf8.decoder.bind(response).join();
    if (response.statusCode != HttpStatus.ok) {
      throw AiChatRequestException(_messageForStatus(response.statusCode));
    }

    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object.');
    }
    final reply = decoded['reply'];
    if (reply is! String || reply.trim().isEmpty) {
      throw const FormatException('Missing reply text.');
    }
    return reply.trim();
  }

  String _messageForStatus(int statusCode) {
    return switch (statusCode) {
      HttpStatus.unprocessableEntity => '问题内容不符合要求，请修改后重试。',
      HttpStatus.gatewayTimeout => 'AI 回复超时，请稍后重试。',
      HttpStatus.badGateway ||
      HttpStatus.serviceUnavailable => 'AI 服务暂时不可用，请稍后重试。',
      _ => '发送失败，请稍后重试。',
    };
  }

  @override
  void close() {
    _httpClient.close(force: true);
  }
}

class AiChatRequestException implements Exception {
  const AiChatRequestException(this.message);

  final String message;
}
