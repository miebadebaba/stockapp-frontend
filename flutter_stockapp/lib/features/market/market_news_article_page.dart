import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import 'market_stock_detail_data.dart';

class MarketNewsArticlePage extends StatelessWidget {
  const MarketNewsArticlePage({
    required this.stockTicker,
    required this.article,
    super.key,
  });

  final String stockTicker;
  final MarketStockNewsArticleData article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Scaffold(
      backgroundColor: palette.pageBackground,
      body: ColoredBox(
        color: palette.pageBackground,
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        AnimatedPageWrapper(
                          child: _ArticleHeader(
                            onBackTap: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AnimatedPageWrapper(
                          delay: const Duration(milliseconds: 40),
                          child: _ArticleHero(
                            stockTicker: stockTicker,
                            article: article,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AnimatedPageWrapper(
                          delay: const Duration(milliseconds: 90),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _MetaPill(label: article.category),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        article.sourceName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            theme.textTheme.bodyMedium?.copyWith(
                                          color: palette.secondaryText,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  article.title,
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    color: palette.primaryText,
                                    fontSize: 34,
                                    height: 1.06,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  '${article.publishedText}  -  ${article.readTimeText}',
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: palette.secondaryText,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Text(
                                  article.summary,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: palette.primaryText,
                                    fontSize: 20,
                                    height: 1.45,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                for (final paragraph
                                    in article.contentParagraphs) ...[
                                  Text(
                                    paragraph,
                                    style:
                                        theme.textTheme.bodyLarge?.copyWith(
                                      color: palette.primaryText,
                                      fontSize: 18,
                                      height: 1.75,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 120),
                      ]),
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

class _ArticleHeader extends StatelessWidget {
  const _ArticleHeader({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: palette.groupBackground,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: onBackTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: palette.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArticleHero extends StatelessWidget {
  const _ArticleHero({
    required this.stockTicker,
    required this.article,
  });

  final String stockTicker;
  final MarketStockNewsArticleData article;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: article.thumbnailColors,
        ),
        boxShadow: [
          BoxShadow(
            color: article.thumbnailColors.last.withValues(alpha: 0.20),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -22,
            right: -10,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -32,
            left: -18,
            child: Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stockTicker,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.90),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                      ),
                ),
                const Spacer(),
                Icon(
                  article.thumbnailIcon,
                  size: 40,
                  color: Colors.white.withValues(alpha: 0.96),
                ),
                const SizedBox(height: 12),
                Text(
                  article.category.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.groupBackground,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
        ),
      ),
    );
  }
}
