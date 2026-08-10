import '../../core/network/api_config.dart';
import '../market/market_stock_detail_transport.dart';

class NewsArticleData {
  const NewsArticleData({required this.id, required this.category, required this.title, required this.summary, required this.sourceName, required this.publishedText, required this.readTimeText, required this.articleUrl, this.imageUrl, this.contentParagraphs = const <String>[]});
  final String id;
  final String category;
  final String title;
  final String summary;
  final String sourceName;
  final String publishedText;
  final String readTimeText;
  final String articleUrl;
  final String? imageUrl;
  final List<String> contentParagraphs;

  factory NewsArticleData.fromJson(Map<String, dynamic> json) {
    final rawParagraphs = json['content_paragraphs'];
    return NewsArticleData(
      id: _asString(json['id'], fallback: json['article_url']),
      category: _asString(json['category'], fallback: 'News'),
      title: _asString(json['title'], fallback: 'Untitled article'),
      summary: _asString(json['summary']),
      sourceName: _asString(json['source_name'], fallback: 'NewsAPI'),
      publishedText: _asString(json['published_text'], fallback: 'Recently'),
      readTimeText: _asString(json['read_time_text'], fallback: '1 min read'),
      articleUrl: _asString(json['article_url']),
      imageUrl: _nullableString(json['image_url']),
      contentParagraphs: rawParagraphs is List ? rawParagraphs.whereType<String>().toList(growable: false) : const <String>[],
    );
  }
}

class NewsApi {
  const NewsApi({this.apiBaseUrl});
  final String? apiBaseUrl;

  Future<List<NewsArticleData>> fetchNews({String category = 'markets', int limit = 20}) async {
    final baseUrl = (apiBaseUrl ?? ApiConfig.baseUri.toString()).trim();
    final uri = Uri.parse('$baseUrl/api/v1/news').replace(queryParameters: {'category': category, 'limit': '$limit'});
    return _parseArticles(await fetchJson(uri.toString()));
  }
}

List<NewsArticleData> _parseArticles(Object? json) {
  if (json is! Map<String, dynamic>) throw const NewsApiException('The news response was not a JSON object.');
  final articles = json['articles'];
  if (articles is! List) throw const NewsApiException('The news response did not include articles.');
  return articles.whereType<Map<String, dynamic>>().map(NewsArticleData.fromJson).toList(growable: false);
}

class NewsApiException implements Exception {
  const NewsApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

String _asString(Object? value, {Object? fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? (fallback?.toString() ?? '') : text;
}

String? _nullableString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
