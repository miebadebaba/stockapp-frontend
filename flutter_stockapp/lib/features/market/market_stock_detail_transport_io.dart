import 'dart:convert';
import 'dart:io';

Future<Object?> fetchJson(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');

    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Request failed with status ${response.statusCode}: $body',
        uri: Uri.parse(url),
      );
    }

    return jsonDecode(body);
  } finally {
    client.close(force: true);
  }
}
