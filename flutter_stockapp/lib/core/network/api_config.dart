import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static Uri get baseUri {
    final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : '127.0.0.1';
    final fallbackUri = Uri.parse('http://$host:8000');
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

  static bool _isLocalHost(String host) {
    final normalized = host.trim().toLowerCase();
    return normalized == 'localhost' ||
        normalized == '127.0.0.1' ||
        normalized == '10.0.2.2';
  }
}
