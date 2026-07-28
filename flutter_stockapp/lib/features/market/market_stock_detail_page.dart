import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import '../../core/widgets/chart_primitives.dart';
import '../home/widgets/investing_chart_card.dart';
import 'market_stock_detail_api.dart';
import 'market_news_article_page.dart';
import 'market_stock_detail_data.dart';

class MarketStockDetailPage extends StatefulWidget {
  const MarketStockDetailPage({required this.stockId, super.key});

  final String stockId;

  @override
  State<MarketStockDetailPage> createState() => _MarketStockDetailPageState();
}

class _MarketStockDetailPageState extends State<MarketStockDetailPage> {
  final MarketStockDetailApi _api = const MarketStockDetailApi();
  late Future<MarketStockDetailData> _stockFuture;
  MarketStockDetailData? _loadedStock;
  ChartDisplayMode _chartMode = ChartDisplayMode.candles;
  List<String> _visibleRanges = const [];
  String? _selectedRange;
  String? _initializedForStockId;

  @override
  void initState() {
    super.initState();
    _stockFuture = _api.fetchStockDetail(widget.stockId);
  }

  void _reload() {
    setState(() {
      _loadedStock = null;
      _initializedForStockId = null;
      _visibleRanges = const [];
      _selectedRange = null;
      _chartMode = ChartDisplayMode.candles;
      _stockFuture = _api.fetchStockDetail(widget.stockId);
    });
  }

  void _ensureChartState(MarketStockDetailData stock) {
    _loadedStock = stock;
    if (_initializedForStockId == stock.id && _visibleRanges.isNotEmpty) {
      return;
    }

    _initializedForStockId = stock.id;
    _visibleRanges = stock.chartSeries.keys.toList();
    _selectedRange = _visibleRanges.contains('1D')
        ? '1D'
        : (_visibleRanges.isNotEmpty ? _visibleRanges.first : null);
  }

  Map<String, List<double>> get _filteredLineSeries {
    final stock = _loadedStock;
    if (stock == null) {
      return const {};
    }
    return {
      for (final range in _visibleRanges)
        if (stock.chartSeries.containsKey(range))
          range: stock.chartSeries[range]!,
    };
  }

  Map<String, List<ChartCandleData>> get _filteredCandleSeries {
    final stock = _loadedStock;
    if (stock == null) {
      return const {};
    }
    return {
      for (final range in _visibleRanges)
        if (stock.candleSeries.containsKey(range))
          range: stock.candleSeries[range]!,
    };
  }

  Future<void> _openChartSettings() async {
    final stock = await _stockFuture;
    if (!mounted) {
      return;
    }
    final result = await showModalBottomSheet<_ChartSettingsResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ChartSettingsSheet(
        initialChartMode: _chartMode,
        initialVisibleRanges: _visibleRanges,
        availableRanges: stock.chartSeries.keys.toList(),
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _chartMode = result.chartMode;
      _visibleRanges = result.visibleRanges;
      if (!_visibleRanges.contains(_selectedRange)) {
        _selectedRange = _visibleRanges.first;
      }
    });
  }

  void _openArticle(MarketStockNewsArticleData article) {
    final stockId = _initializedForStockId;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => MarketNewsArticlePage(
          stockTicker: stockId?.toUpperCase() ?? widget.stockId.toUpperCase(),
          article: article,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

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
              child: FutureBuilder<MarketStockDetailData>(
                future: _stockFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return _LoadingState(
                      onBackTap: () => Navigator.of(context).maybePop(),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return _ErrorState(
                      onBackTap: () => Navigator.of(context).maybePop(),
                      onRetryTap: _reload,
                      message:
                          snapshot.error?.toString() ??
                          'Unable to load this stock detail right now.',
                    );
                  }

                  final stock = snapshot.data!;
                  _ensureChartState(stock);
                  return _LoadedStockDetailView(
                    stock: stock,
                    chartMode: _chartMode,
                    selectedRange: _selectedRange ?? _visibleRanges.first,
                    filteredLineSeries: _filteredLineSeries,
                    filteredCandleSeries: _filteredCandleSeries,
                    onBackTap: () => Navigator.of(context).maybePop(),
                    onSettingsTap: _openChartSettings,
                    onRangeChanged: (range) {
                      setState(() => _selectedRange = range);
                    },
                    onArticleTap: _openArticle,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadedStockDetailView extends StatelessWidget {
  const _LoadedStockDetailView({
    required this.stock,
    required this.chartMode,
    required this.selectedRange,
    required this.filteredLineSeries,
    required this.filteredCandleSeries,
    required this.onBackTap,
    required this.onSettingsTap,
    required this.onRangeChanged,
    required this.onArticleTap,
  });

  final MarketStockDetailData stock;
  final ChartDisplayMode chartMode;
  final String selectedRange;
  final Map<String, List<double>> filteredLineSeries;
  final Map<String, List<ChartCandleData>> filteredCandleSeries;
  final VoidCallback onBackTap;
  final Future<void> Function() onSettingsTap;
  final ValueChanged<String> onRangeChanged;
  final ValueChanged<MarketStockNewsArticleData> onArticleTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isPositive = stock.changePercent >= 0;
    final signedChange = isPositive ? '+' : '';
    final changeText =
        '$signedChange${stock.changeValue.toStringAsFixed(2)} (${stock.changePercent.toStringAsFixed(2)}%)';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              AnimatedPageWrapper(child: _HeaderRow(onBackTap: onBackTap)),
              const SizedBox(height: AppSpacing.md),
              AnimatedPageWrapper(
                delay: const Duration(milliseconds: 40),
                child: InvestingChartCard(
                  title: stock.ticker,
                  subtitle: '${stock.companyName}  -  ${stock.exchangeLabel}',
                  titleStyle: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(
                        color: palette.primaryText,
                        fontWeight: FontWeight.w900,
                        fontSize: 50,
                        height: 1.05,
                      ),
                  subtitleStyle: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(
                        color: palette.secondaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        height: 1.2,
                      ),
                  amountStyle: Theme.of(context).textTheme.headlineLarge
                      ?.copyWith(
                        color: palette.primaryText,
                        fontWeight: FontWeight.w900,
                        fontSize: 50,
                        height: 1.05,
                      ),
                  changeTextStyle: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
                  changeLabelStyle: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: palette.secondaryText, fontSize: 18),
                  amountText: '\$${stock.priceText}',
                  changeText: changeText,
                  changeLabel: stock.changeLabel,
                  mockData: filteredLineSeries,
                  candlestickData: filteredCandleSeries,
                  chartMode: chartMode,
                  initialRange: selectedRange,
                  isPositiveChange: isPositive,
                  showEndMarker: true,
                  contentHorizontalPadding: 10,
                  cardVerticalPadding: 30,
                  chartHeight: 250,
                  rangeSelectorHeight: 58,
                  rangeLabelFontSize: 18,
                  rangeControlSpacing: 10,
                  useScrollableRangeButtons: true,
                  rangeButtonHorizontalPadding: 16,
                  minRangeButtonWidth: 54,
                  enableSelectionDetails: true,
                  onRangeChanged: onRangeChanged,
                  onBadgeTap: () {},
                  onSettingsTap: onSettingsTap,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AnimatedPageWrapper(
                delay: const Duration(milliseconds: 90),
                child: _StatisticsSection(stats: stock.stats),
              ),
              if (stock.newsArticles.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxl),
                AnimatedPageWrapper(
                  delay: const Duration(milliseconds: 130),
                  child: _RecentNewsSection(
                    articles: stock.newsArticles,
                    onArticleTap: onArticleTap,
                  ),
                ),
              ],
              const SizedBox(height: 140),
            ]),
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              AnimatedPageWrapper(child: _HeaderRow(onBackTap: onBackTap)),
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: palette.primaryText),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Loading live stock detail...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.onBackTap,
    required this.onRetryTap,
    required this.message,
  });

  final VoidCallback onBackTap;
  final VoidCallback onRetryTap;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              AnimatedPageWrapper(child: _HeaderRow(onBackTap: onBackTap)),
              const SizedBox(height: AppSpacing.xxl),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: palette.groupBackground,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 34,
                      color: palette.secondaryText,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Live stock detail unavailable',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: palette.primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.secondaryText,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: onRetryTap,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.onBackTap});

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

class _StatisticsSection extends StatelessWidget {
  const _StatisticsSection({required this.stats});

  final List<MarketStockStatData> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;
    final splitIndex = (stats.length / 2).ceil();
    final leftColumn = stats.take(splitIndex).toList();
    final rightColumn = stats.skip(splitIndex).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            'Statistics',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 32,
              height: 1.08,
              color: palette.primaryText,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 8, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _StatisticsColumn(items: leftColumn)),
              const SizedBox(width: 40),
              Expanded(child: _StatisticsColumn(items: rightColumn)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatisticsColumn extends StatelessWidget {
  const _StatisticsColumn({required this.items});

  final List<MarketStockStatData> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: palette.primaryText,
                      fontSize: 28,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _RecentNewsSection extends StatelessWidget {
  const _RecentNewsSection({
    required this.articles,
    required this.onArticleTap,
  });

  final List<MarketStockNewsArticleData> articles;
  final ValueChanged<MarketStockNewsArticleData> onArticleTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            'Recent News',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 32,
              height: 1.08,
              color: palette.primaryText,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 8, 0),
          child: Column(
            children: [
              for (var i = 0; i < articles.length; i++) ...[
                _RecentNewsCard(
                  article: articles[i],
                  onTap: () => onArticleTap(articles[i]),
                ),
                if (i != articles.length - 1)
                  const SizedBox(height: AppSpacing.lg),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentNewsCard extends StatelessWidget {
  const _RecentNewsCard({required this.article, required this.onTap});

  final MarketStockNewsArticleData article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: palette.rowPressedOverlay,
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.groupBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecentNewsThumbnail(article: article),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          article.category.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: palette.secondaryText,
                            fontSize: 11,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          article.sourceName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.secondaryText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: palette.primaryText,
                        fontSize: 21,
                        height: 1.14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      article.summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.secondaryText,
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${article.publishedText}  -  ${article.readTimeText}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.secondaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: palette.primaryText,
                          size: 20,
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

class _RecentNewsThumbnail extends StatelessWidget {
  const _RecentNewsThumbnail({required this.article});

  final MarketStockNewsArticleData article;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 108,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
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
              top: -8,
              right: -10,
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
              bottom: -14,
              left: -10,
              child: Container(
                width: 58,
                height: 58,
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

class _ChartSettingsSheet extends StatefulWidget {
  const _ChartSettingsSheet({
    required this.initialChartMode,
    required this.initialVisibleRanges,
    required this.availableRanges,
  });

  final ChartDisplayMode initialChartMode;
  final List<String> initialVisibleRanges;
  final List<String> availableRanges;

  @override
  State<_ChartSettingsSheet> createState() => _ChartSettingsSheetState();
}

class _ChartSettingsSheetState extends State<_ChartSettingsSheet> {
  late ChartDisplayMode _chartMode;
  late Set<String> _visibleRanges;

  @override
  void initState() {
    super.initState();
    _chartMode = widget.initialChartMode;
    _visibleRanges = widget.initialVisibleRanges.toSet();
  }

  void _toggleRange(String range) {
    if (_visibleRanges.contains(range) && _visibleRanges.length == 1) {
      return;
    }

    setState(() {
      if (!_visibleRanges.add(range)) {
        _visibleRanges.remove(range);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Material(
        color: palette.groupBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Chart Settings',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: palette.primaryText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        _ChartSettingsResult(
                          chartMode: _chartMode,
                          visibleRanges: widget.availableRanges
                              .where(_visibleRanges.contains)
                              .toList(),
                        ),
                      );
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Chart type',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.primaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SettingsChip(
                    label: 'K-line',
                    selected: _chartMode == ChartDisplayMode.candles,
                    onTap: () {
                      setState(() => _chartMode = ChartDisplayMode.candles);
                    },
                  ),
                  _SettingsChip(
                    label: 'Line (Close)',
                    selected: _chartMode == ChartDisplayMode.line,
                    onTap: () {
                      setState(() => _chartMode = ChartDisplayMode.line);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Visible ranges',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.primaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Keep at least one range visible.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: palette.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final range in widget.availableRanges)
                    _SettingsChip(
                      label: range,
                      selected: _visibleRanges.contains(range),
                      onTap: () => _toggleRange(range),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsChip extends StatelessWidget {
  const _SettingsChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? palette.primaryText : palette.pageBackground,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected ? palette.pageBackground : palette.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartSettingsResult {
  const _ChartSettingsResult({
    required this.chartMode,
    required this.visibleRanges,
  });

  final ChartDisplayMode chartMode;
  final List<String> visibleRanges;
}
