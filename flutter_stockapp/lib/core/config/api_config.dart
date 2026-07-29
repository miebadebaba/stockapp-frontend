class ApiConfig {
  const ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const connectTimeout = Duration(seconds: 10);
  static const sendTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 15);
}