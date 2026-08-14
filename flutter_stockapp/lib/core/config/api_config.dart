import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl => baseUri.toString();

  static Uri get baseUri {
    final fallbackHost = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : '127.0.0.1';
    final fallbackUri = Uri.parse('http://$fallbackHost:8000');
    final configured = _configuredBaseUrl.trim();
    if (configured.isEmpty) {
      return fallbackUri;
    }

    final parsed = Uri.tryParse(configured);
    if (parsed == null || parsed.host.isEmpty) {
      return fallbackUri;
    }

    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        _isLocalHost(parsed.host)) {
      final normalizedPort =
          parsed.hasPort && parsed.port < 49152 ? parsed.port : 8000;
      return parsed.replace(
        scheme: parsed.scheme.isEmpty ? 'http' : parsed.scheme,
        host: '10.0.2.2',
        port: normalizedPort,
      );
    }

    return parsed;
  }

  static const connectTimeout = Duration(seconds: 10);
  static const sendTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 15);

  static bool _isLocalHost(String host) {
    final normalized = host.trim().toLowerCase();
    return normalized == 'localhost' ||
        normalized == '127.0.0.1' ||
        normalized == '10.0.2.2';
  }
}
