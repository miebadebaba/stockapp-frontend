import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: const {
          Headers.acceptHeader: Headers.jsonContentType,
        },
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
        options: headers == null ? null : Options(headers: headers),
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

  Future<Map<String, dynamic>> postJson({
    required String path,
    required Object body,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        path,
        data: body,
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
    switch (statusCode) {
      case 401:
        return ApiException(
          type: ApiErrorType.unauthorized,
          message: '登录状态已失效，请重新登录。',
          statusCode: 401,
          detail: detail,
        );

      case 403:
        return ApiException(
          type: ApiErrorType.forbidden,
          message: '当前账号无权执行此操作。',
          statusCode: 403,
          detail: detail,
        );

      case 404:
        return ApiException(
          type: ApiErrorType.notFound,
          message: '请求的内容不存在。',
          statusCode: 404,
          detail: detail,
        );

      default:
        if (statusCode != null && statusCode >= 500) {
          return ApiException(
            type: ApiErrorType.server,
            message: '服务器暂时不可用，请稍后重试。',
            statusCode: statusCode,
            detail: detail,
          );
        }

        return ApiException(
          type: ApiErrorType.unknown,
          message: '请求失败，请稍后重试。',
          statusCode: statusCode,
          detail: detail,
        );
    }
  }
}
