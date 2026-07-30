import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<Object?> fetchJson(String url) async {
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client
        .getUrl(Uri.parse(url))
        .timeout(const Duration(seconds: 10));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');

    final response = await request.close().timeout(const Duration(seconds: 12));
    final body = await utf8.decoder
        .bind(response)
        .join()
        .timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Request failed with status ${response.statusCode}: $body',
        uri: Uri.parse(url),
      );
    }

    return jsonDecode(body);
  } on TimeoutException {
    throw const HttpException('Request timed out');
  } finally {
    client.close(force: true);
  }
}
