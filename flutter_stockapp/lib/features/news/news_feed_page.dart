import 'package:flutter/material.dart';

import '../../core/theme/app_theme_palette.dart';
import '../market/market_news_article_page.dart';
import '../market/market_stock_detail_data.dart';
import 'news_api.dart';
import 'news_list_page.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({this.onCloseTap, super.key});
  final VoidCallback? onCloseTap;

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final NewsApi _api = const NewsApi();
  late Future<List<NewsArticleData>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = _api.fetchNews(limit: 20);
  }

  void _retry() {
    setState(() => _articlesFuture = _api.fetchNews(limit: 20));
  }

  void _openArticle(List<NewsArticleData> articles, String articleId) {
    NewsArticleData? article;
    for (final item in articles) {
      if (item.id == articleId) {
        article = item;
        break;
      }
    }
    if (article == null || !mounted) {
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MarketNewsArticlePage(
          stockTicker: 'NEWS',
          article: _toMarketArticle(article!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsArticleData>>(
      future: _articlesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _NewsLoadingView();
        }
        if (snapshot.hasError) {
          return _NewsErrorView(message: snapshot.error.toString(), onRetry: _retry, onCloseTap: widget.onCloseTap);
        }
        final articles = snapshot.data ?? const <NewsArticleData>[];
        if (articles.isEmpty) {
          return _NewsErrorView(message: 'No news is available right now.', onRetry: _retry, onCloseTap: widget.onCloseTap);
        }
        return NewsListPage(
          articles: articles.map(_toListArticle).toList(growable: false),
          onCloseTap: widget.onCloseTap,
          onArticleTap: (id) => _openArticle(articles, id),
        );
      },
    );
  }
}

NewsListArticleData _toListArticle(NewsArticleData article) {
  return NewsListArticleData(
    id: article.id,
    category: article.category,
    title: article.title,
    publishedText: article.publishedText,
    readTimeText: article.readTimeText,
    thumbnailIcon: _iconForCategory(article.category),
    thumbnailColors: _colorsForCategory(article.category),
    imageUrl: article.imageUrl,
  );
}

IconData _iconForCategory(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('tech')) return Icons.memory_rounded;
  if (normalized.contains('crypto')) return Icons.currency_bitcoin_rounded;
  if (normalized.contains('earning')) return Icons.receipt_long_rounded;
  return Icons.show_chart_rounded;
}

List<Color> _colorsForCategory(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('tech')) return const [Color(0xff7b61ff), Color(0xff3151c7)];
  if (normalized.contains('crypto')) return const [Color(0xff33b7a4), Color(0xff197d94)];
  if (normalized.contains('earning')) return const [Color(0xffffbe63), Color(0xffd86c34)];
  return const [Color(0xff66a9ff), Color(0xff3151c7)];
}

MarketStockNewsArticleData _toMarketArticle(NewsArticleData article) {
  return MarketStockNewsArticleData(
    id: article.id,
    category: article.category,
    title: article.title,
    summary: article.summary,
    sourceName: article.sourceName,
    publishedText: article.publishedText,
    readTimeText: article.readTimeText,
    thumbnailIcon: _iconForCategory(article.category),
    thumbnailColors: _colorsForCategory(article.category),
    contentParagraphs: article.contentParagraphs,
    articleUrl: article.articleUrl,
    imageUrl: article.imageUrl,
  );
}

class _NewsLoadingView extends StatelessWidget {
  const _NewsLoadingView();
  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return ColoredBox(color: palette.pageBackground, child: const Center(child: CircularProgressIndicator()));
  }
}

class _NewsErrorView extends StatelessWidget {
  const _NewsErrorView({required this.message, required this.onRetry, this.onCloseTap});
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onCloseTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;
    return ColoredBox(
      color: palette.pageBackground,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 38, color: palette.secondaryText),
                const SizedBox(height: 12),
                Text('Unable to load news', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(message, maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: palette.secondaryText)),
                const SizedBox(height: 18),
                FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
                if (onCloseTap != null) ...[
                  const SizedBox(height: 8),
                  TextButton(onPressed: onCloseTap, child: const Text('Close')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
