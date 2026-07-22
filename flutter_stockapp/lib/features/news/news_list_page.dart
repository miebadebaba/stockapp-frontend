import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/pressable_scale.dart';

class NewsListArticleData {
  const NewsListArticleData({
    required this.id,
    required this.category,
    required this.title,
    required this.publishedText,
    required this.readTimeText,
    required this.thumbnailIcon,
    required this.thumbnailColors,
    this.showListen = false,
    this.isBookmarked = false,
  });

  final String id;
  final String category;
  final String title;
  final String publishedText;
  final String readTimeText;
  final IconData thumbnailIcon;
  final List<Color> thumbnailColors;
  final bool showListen;
  final bool isBookmarked;
}

class NewsListPage extends StatefulWidget {
  const NewsListPage({
    required this.articles,
    this.onArticleTap,
    this.onListenTap,
    this.onShareTap,
    this.onBookmarkTap,
    this.onCloseTap,
    super.key,
  });

  final List<NewsListArticleData> articles;
  final ValueChanged<String>? onArticleTap;
  final ValueChanged<String>? onListenTap;
  final ValueChanged<String>? onShareTap;
  final ValueChanged<String>? onBookmarkTap;
  final VoidCallback? onCloseTap;

  factory NewsListPage.demo({
    ValueChanged<String>? onArticleTap,
    ValueChanged<String>? onListenTap,
    ValueChanged<String>? onShareTap,
    ValueChanged<String>? onBookmarkTap,
    VoidCallback? onCloseTap,
    Key? key,
  }) {
    return NewsListPage(
      key: key,
      articles: _demoArticles,
      onArticleTap: onArticleTap,
      onListenTap: onListenTap,
      onShareTap: onShareTap,
      onBookmarkTap: onBookmarkTap,
      onCloseTap: onCloseTap,
    );
  }

  static const List<NewsListArticleData> _demoArticles = [
    NewsListArticleData(
      id: 'markets-1',
      category: 'Markets',
      title: 'Stocks edge higher as traders watch inflation prints and rate-cut odds',
      publishedText: '1 hr ago',
      readTimeText: '2 min read',
      thumbnailIcon: Icons.show_chart_rounded,
      thumbnailColors: [AppColors.orbBlueLight, AppColors.orbBlueDeep],
      showListen: true,
      isBookmarked: false,
    ),
    NewsListArticleData(
      id: 'tech-1',
      category: 'Technology',
      title: 'Chipmakers rally after fresh AI spending guidance from major cloud buyers',
      publishedText: '3 hrs ago',
      readTimeText: '4 min read',
      thumbnailIcon: Icons.memory_rounded,
      thumbnailColors: [AppColors.orbViolet, AppColors.orbBlueDeep],
      showListen: false,
      isBookmarked: true,
    ),
    NewsListArticleData(
      id: 'earnings-1',
      category: 'Earnings',
      title: 'Retail earnings point to softer discretionary demand into the next quarter',
      publishedText: '5 hrs ago',
      readTimeText: '3 min read',
      thumbnailIcon: Icons.receipt_long_rounded,
      thumbnailColors: [AppColors.orbAmberLight, AppColors.orbAmberDeep],
      showListen: true,
      isBookmarked: false,
    ),
    NewsListArticleData(
      id: 'crypto-1',
      category: 'Crypto',
      title: 'Bitcoin steadies as derivative positioning resets after the latest breakout',
      publishedText: 'Yesterday',
      readTimeText: '5 min read',
      thumbnailIcon: Icons.currency_bitcoin_rounded,
      thumbnailColors: [AppColors.orbMint, AppColors.accentCyanCard],
      showListen: false,
      isBookmarked: false,
    ),
  ];

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  late Set<String> _bookmarkedIds;

  @override
  void initState() {
    super.initState();
    _bookmarkedIds = widget.articles
        .where((article) => article.isBookmarked)
        .map((article) => article.id)
        .toSet();
  }

  @override
  void didUpdateWidget(covariant NewsListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.articles != widget.articles) {
      _bookmarkedIds = widget.articles
          .where((article) => article.isBookmarked)
          .map((article) => article.id)
          .toSet();
    }
  }

  void _toggleBookmark(NewsListArticleData article) {
    setState(() {
      if (_bookmarkedIds.contains(article.id)) {
        _bookmarkedIds.remove(article.id);
      } else {
        _bookmarkedIds.add(article.id);
      }
    });
    widget.onBookmarkTap?.call(article.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return ColoredBox(
      color: palette.pageBackground,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'News',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 30,
                          height: 1.08,
                        ),
                      ),
                      if (widget.onCloseTap != null) ...[
                        const Spacer(),
                        Material(
                          color: palette.groupBackground,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            onTap: widget.onCloseTap,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: palette.primaryText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: widget.articles.length,
                      itemBuilder: (context, index) {
                        final article = widget.articles[index];
                        return NewsListItem(
                          article: article,
                          isBookmarked: _bookmarkedIds.contains(article.id),
                          onTap: widget.onArticleTap == null
                              ? null
                              : () => widget.onArticleTap!(article.id),
                          onListenTap: widget.onListenTap == null
                              ? null
                              : () => widget.onListenTap!(article.id),
                          onShareTap: widget.onShareTap == null
                              ? null
                              : () => widget.onShareTap!(article.id),
                          onBookmarkTap: () => _toggleBookmark(article),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: _DottedDivider(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NewsListItem extends StatelessWidget {
  const NewsListItem({
    required this.article,
    required this.isBookmarked,
    this.onTap,
    this.onListenTap,
    this.onShareTap,
    this.onBookmarkTap,
    super.key,
  });

  final NewsListArticleData article;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onListenTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        splashColor: palette.rowPressedOverlay,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NewsVisualColumn(article: article),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: palette.secondaryText,
                        fontSize: 11,
                        letterSpacing: 1.7,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: palette.primaryText,
                        fontSize: 20,
                        height: 1.12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (article.showListen) ...[
                          _PillActionButton(
                            label: 'LISTEN',
                            icon: Icons.headphones_rounded,
                            onTap: onListenTap,
                          ),
                          const SizedBox(width: 8),
                        ],
                        _IconActionButton(
                          icon: Icons.ios_share_rounded,
                          onTap: onShareTap,
                        ),
                        const SizedBox(width: 8),
                        _IconActionButton(
                          icon: isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          isSelected: isBookmarked,
                          onTap: onBookmarkTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsVisualColumn extends StatelessWidget {
  const _NewsVisualColumn({required this.article});

  final NewsListArticleData article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return SizedBox(
      width: 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NewsThumbnail(article: article),
          const SizedBox(height: 10),
          Text(
            article.publishedText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            article.readTimeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsThumbnail extends StatelessWidget {
  const _NewsThumbnail({required this.article});

  final NewsListArticleData article;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 100,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: article.thumbnailColors,
          ),
          boxShadow: [
            BoxShadow(
              color: article.thumbnailColors.last.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -10,
              right: -8,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -12,
              left: -10,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Center(
              child: Icon(
                article.thumbnailIcon,
                size: 30,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillActionButton extends StatelessWidget {
  const _PillActionButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isDark
                ? palette.groupBackground
                : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: palette.primaryText),
              const SizedBox(width: 5),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: palette.primaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    this.isSelected = false,
    this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isSelected
              ? palette.primaryText.withValues(alpha: 0.08)
              : isDark
                  ? palette.groupBackground
                  : AppColors.surfaceMuted,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? palette.primaryText : palette.secondaryText,
        ),
      ),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return SizedBox(
      width: double.infinity,
      height: 10,
      child: CustomPaint(
        painter: _DottedDividerPainter(color: palette.divider),
      ),
    );
  }
}

class _DottedDividerPainter extends CustomPainter {
  const _DottedDividerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dotRadius = 1.6;
    const gap = 7.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final y = size.height / 2;
    var x = dotRadius;
    while (x < size.width - dotRadius) {
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
      x += dotRadius * 2 + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedDividerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
