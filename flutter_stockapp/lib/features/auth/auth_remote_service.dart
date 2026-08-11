import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import 'auth_models.dart';

abstract interface class AuthApi {
  Future<AuthUser> register({
    required String username,
    required String password,
  });

  Future<AuthToken> login({
    required String username,
    required String password,
  });

  Future<AuthUser> getCurrentUser(String accessToken);
}

class HttpAuthApi implements AuthApi {
  HttpAuthApi({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        _ownsApiClient = apiClient == null;

  static const registerPath = '/api/v1/auth/register';
  static const loginPath = '/api/v1/auth/login';
  static const currentUserPath = '/api/v1/auth/me';

  final ApiClient _apiClient;
  final bool _ownsApiClient;

  @override
  Future<AuthUser> register({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      path: registerPath,
      body: {'username': username.trim(), 'password': password},
    );
    return AuthUser.fromJson(response);
  }

  @override
  Future<AuthToken> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      path: loginPath,
      body: {'username': username.trim(), 'password': password},
    );
    return AuthToken.fromJson(response);
  }

  @override
  Future<AuthUser> getCurrentUser(String accessToken) async {
    if (accessToken.trim().isEmpty) {
      throw const ApiException(
        type: ApiErrorType.unauthorized,
        message: 'Authentication token is missing.',
        statusCode: 401,
      );
    }
    final response = await _apiClient.getJson(
      path: currentUserPath,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return AuthUser.fromJson(response);
  }

  void close() {
    if (_ownsApiClient) {
      _apiClient.close(force: true);
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
