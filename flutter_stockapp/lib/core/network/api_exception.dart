enum ApiErrorType {
  timeout,
  connection,
  unauthorized,
  forbidden,
  notFound,
  server,
  cancelled,
  invalidResponse,
  unknown,
}

class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.detail,
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final Object? detail;

  @override
  String toString() => message;
}
