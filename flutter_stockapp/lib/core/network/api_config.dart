import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static Uri get baseUri {
    if (_configuredBaseUrl.trim().isNotEmpty) {
      return Uri.parse(_configuredBaseUrl.trim());
    }

    final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : '127.0.0.1';
    return Uri.parse('http://$host:8000');
  }
}
