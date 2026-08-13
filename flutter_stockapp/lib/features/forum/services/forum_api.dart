import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

abstract interface class ForumApi {
  Future<List<ForumPost>> loadPublicPosts();

  Future<List<ForumPost>> loadMyPosts();

  Future<ForumPost> createPost({
    required String content,
    required String topicLabel,
  });
}

class HttpForumApi implements ForumApi {
  HttpForumApi({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        _ownsApiClient = apiClient == null;

  static const postsPath = '/api/v1/forum/posts';
  static const myPostsPath = '/api/v1/forum/me/posts';

  final ApiClient _apiClient;
  final bool _ownsApiClient;

  @override
  Future<List<ForumPost>> loadPublicPosts() async {
    try {
      final response = await _apiClient.getJson(path: postsPath);
      return _postsFromResponse(response);
    } on ApiException catch (error) {
      throw ForumApiException(_messageForApiError(error));
    } on FormatException {
      throw const ForumApiException('论坛数据格式不正确。');
    }
  }

  @override
  Future<List<ForumPost>> loadMyPosts() async {
    try {
      final response = await _apiClient.getJson(path: myPostsPath);
      return _postsFromResponse(response);
    } on ApiException catch (error) {
      throw ForumApiException(_messageForApiError(error));
    } on FormatException {
      throw const ForumApiException('论坛数据格式不正确。');
    }
  }

  @override
  Future<ForumPost> createPost({
    required String content,
    required String topicLabel,
  }) async {
    try {
      final response = await _apiClient.postJson(
        path: postsPath,
        body: {'content': content, 'topic_label': topicLabel},
      );
      return ForumPost.fromJson(response);
    } on ApiException catch (error) {
      throw ForumApiException(_messageForApiError(error));
    } on FormatException {
      throw const ForumApiException('论坛数据格式不正确。');
    }
  }

  void close() {
    if (_ownsApiClient) {
      _apiClient.close(force: true);
    }
  }
}

class ForumPost {
  const ForumPost({
    required this.id,
    required this.authorUserId,
    required this.authorUsername,
    required this.content,
    required this.topicLabel,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.moderationReason,
  });

  final int id;
  final int authorUserId;
  final String authorUsername;
  final String content;
  final String topicLabel;
  final String status;
  final String? moderationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: _asInt(json['id']),
      authorUserId: _asInt(json['author_user_id']),
      authorUsername: _asString(json['author_username']),
      content: _asString(json['content']),
      topicLabel: _asString(json['topic_label']),
      status: _asString(json['status']),
      moderationReason: json['moderation_reason'] as String?,
      createdAt: DateTime.parse(_asString(json['created_at'])),
      updatedAt: DateTime.parse(_asString(json['updated_at'])),
    );
  }
}

class ForumApiException implements Exception {
  const ForumApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

List<ForumPost> _postsFromResponse(Map<String, dynamic> response) {
  final items = response['items'];
  if (items is! List) {
    throw const FormatException('Expected forum items.');
  }
  return items
      .map((item) => ForumPost.fromJson(_asMap(item)))
      .toList(growable: false);
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  throw const FormatException('Expected JSON object.');
}

String _asString(Object? value) {
  if (value is String) {
    return value;
  }
  throw const FormatException('Expected string.');
}

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  throw const FormatException('Expected integer.');
}

String _messageForApiError(ApiException error) {
  if (error.statusCode == 401) {
    return '请先登录后查看自己的论坛内容。';
  }
  if (error.statusCode == 403) {
    return '当前账号不能执行此论坛操作。';
  }
  if (error.statusCode != null && error.statusCode! >= 500) {
    return '论坛服务暂时不可用，请稍后重试。';
  }
  return error.message;
}
