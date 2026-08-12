import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'api_exception.dart';

typedef AccessTokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient({Dio? dio, AccessTokenProvider? accessTokenProvider})
      : _dio = dio ?? _createDio(),
        _accessTokenProvider = accessTokenProvider;

  final Dio _dio;
  final AccessTokenProvider? _accessTokenProvider;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: const {Headers.acceptHeader: Headers.jsonContentType},
      ),
    );
  }

  Future<Map<String, dynamic>> getJson({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
        options: await _optionsFor(path: path, headers: headers),
      );

      return _requireJsonObject(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const ApiException(
        type: ApiErrorType.unknown,
        message: '请求处理失败，请稍后重试。',
      );
    }
  }

  Future<List<dynamic>> getJsonList({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
        options: await _optionsFor(path: path, headers: headers),
      );

      return _requireJsonList(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const ApiException(
        type: ApiErrorType.unknown,
        message: '请求处理失败，请稍后重试。',
      );
    }
  }

  Future<Map<String, dynamic>> postJson({
    required String path,
    required Object body,
    Duration? receiveTimeout,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        path,
        data: body,
        options: await _optionsFor(
          path: path,
          receiveTimeout: receiveTimeout,
          headers: headers,
        ),
      );

      return _requireJsonObject(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const ApiException(
        type: ApiErrorType.unknown,
        message: '请求处理失败，请稍后重试。',
      );
    }
  }

  void close({bool force = false}) {
    _dio.close(force: force);
  }

  Future<Options?> _optionsFor({
    required String path,
    Duration? receiveTimeout,
    Map<String, String>? headers,
  }) async {
    final effectiveHeaders = <String, String>{...?headers};
    if (!_hasAuthorization(effectiveHeaders) && _isOwnBackendRequest(path)) {
      final token = (await _accessTokenProvider?.call())?.trim();
      if (token != null && token.isNotEmpty) {
        effectiveHeaders['Authorization'] = 'Bearer $token';
      }
    }

    if (effectiveHeaders.isEmpty && receiveTimeout == null) {
      return null;
    }

    return Options(
      receiveTimeout: receiveTimeout,
      headers: effectiveHeaders.isEmpty ? null : effectiveHeaders,
    );
  }

  static bool _hasAuthorization(Map<String, String> headers) {
    return headers.keys.any((key) => key.toLowerCase() == 'authorization');
  }

  bool _isOwnBackendRequest(String path) {
    final requestUri = Uri.tryParse(path);
    if (requestUri == null) {
      return false;
    }
    if (!requestUri.hasScheme && requestUri.host.isEmpty) {
      return true;
    }

    final baseUri = Uri.tryParse(_dio.options.baseUrl);
    if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
      return false;
    }

    return requestUri.scheme.toLowerCase() == baseUri.scheme.toLowerCase() &&
        requestUri.host.toLowerCase() == baseUri.host.toLowerCase() &&
        _effectivePort(requestUri) == _effectivePort(baseUri);
  }

  static int _effectivePort(Uri uri) {
    if (uri.hasPort) {
      return uri.port;
    }
    return uri.scheme.toLowerCase() == 'https' ? 443 : 80;
  }

  static Map<String, dynamic> _requireJsonObject(Object? data) {
    if (data is! Map) {
      throw const ApiException(
        type: ApiErrorType.invalidResponse,
        message: '服务器返回的数据格式不正确。',
      );
    }

    final result = <String, dynamic>{};

    for (final entry in data.entries) {
      if (entry.key is! String) {
        throw const ApiException(
          type: ApiErrorType.invalidResponse,
          message: '服务器返回的数据格式不正确。',
        );
      }

      result[entry.key as String] = entry.value;
    }

    return result;
  }

  static List<dynamic> _requireJsonList(Object? data) {
    if (data is! List) {
      throw const ApiException(
        type: ApiErrorType.invalidResponse,
        message: '服务器返回的数据格式不正确。',
      );
    }
    return data;
  }

  static ApiException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          type: ApiErrorType.timeout,
          message: '请求超时，请检查网络后重试。',
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          type: ApiErrorType.connection,
          message: '无法连接服务器，请检查网络后重试。',
        );

      case DioExceptionType.cancel:
        return const ApiException(
          type: ApiErrorType.cancelled,
          message: '请求已取消。',
        );

      case DioExceptionType.badResponse:
        return _mapStatusCode(
          error.response?.statusCode,
          error.response?.data,
        );

      case DioExceptionType.badCertificate:
        return const ApiException(
          type: ApiErrorType.connection,
          message: '无法建立安全连接。',
        );

      case DioExceptionType.unknown:
        return const ApiException(
          type: ApiErrorType.unknown,
          message: '网络请求失败，请稍后重试。',
        );
    }
  }

  static ApiException _mapStatusCode(int? statusCode, Object? data) {
    final detail = data is Map ? data['detail'] : null;
    final code = data is Map && data['code'] is String ? data['code'] as String : null;
    switch (statusCode) {
      case 401:
        return ApiException(
          type: ApiErrorType.unauthorized,
          message: '登录状态已失效，请重新登录。',
          statusCode: 401,
          code: code,
          detail: detail,
        );

      case 403:
        return ApiException(
          type: ApiErrorType.forbidden,
          message: '当前账号无权执行此操作。',
          statusCode: 403,
          code: code,
          detail: detail,
        );

      case 404:
        return ApiException(
          type: ApiErrorType.notFound,
          message: '请求的内容不存在。',
          statusCode: 404,
          code: code,
          detail: detail,
        );

      case 504:
        return ApiException(
          type: ApiErrorType.timeout,
          message: '请求超时，请稍后重试。',
          statusCode: 504,
          code: code,
          detail: detail,
        );

      default:
        if (statusCode != null && statusCode >= 500) {
          return ApiException(
            type: ApiErrorType.server,
            message: '服务器暂时不可用，请稍后重试。',
            statusCode: statusCode,
            code: code,
            detail: detail,
          );
        }

        return ApiException(
          type: ApiErrorType.unknown,
          message: '请求失败，请稍后重试。',
          statusCode: statusCode,
          code: code,
          detail: detail,
        );
    }
  }
}
