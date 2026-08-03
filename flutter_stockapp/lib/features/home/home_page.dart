import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import 'market_snapshot_api.dart';
import '../market/market_stock_detail_page.dart';
import 'market_snapshot_data.dart';
import 'market_stock_list_api.dart';
import 'markets_page.dart';
import 'stocks_page.dart';
import 'widgets/market_snapshot_section.dart';
import 'widgets/stock_list_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<MarketSnapshotOverviewData> _marketsFuture;
  late final Future<List<StockListItemData>> _stocksFuture;

  @override
  void initState() {
    super.initState();
    _marketsFuture = const MarketSnapshotApi().fetchOverview();
    _stocksFuture = const MarketStockListApi().fetchStocks();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return AnimatedPageWrapper(
      child: ColoredBox(
        color: palette.pageBackground,
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 96, 0, 140),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: FutureBuilder<MarketSnapshotOverviewData>(
                        future: _marketsFuture,
                        builder: (context, snapshot) {
                          final overview = snapshot.data;
                          if (overview != null &&
                              overview.previewItems.isNotEmpty) {
                            return MarketSnapshotSection(
                              titleText: 'Markets',
                              assets: overview.previewItems,
                              onTitleTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) {
                                      return MarketsPage(
                                        initialData: overview,
                                      );
                                    },
                                  ),
                                );
                              },
                              onAssetTap: (_) {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) {
                                      return MarketsPage(
                                        initialData: overview,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          }

                          if (snapshot.hasError) {
                            return const _MarketsStatusCard(
                              title: 'Markets',
                              message:
                                  'Live market indexes are temporarily unavailable.',
                            );
                          }

                          return const _MarketsLoadingSection();
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: FutureBuilder<List<StockListItemData>>(
                        future: _stocksFuture,
                        builder: (context, snapshot) {
                          final stocks = snapshot.data;
                          if (stocks != null && stocks.isNotEmpty) {
                            return StockListSection(
                              titleText: 'Stocks',
                              stocks: stocks.take(3).toList(),
                              onTitleTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) {
                                      return StocksPage(stocks: stocks);
                                    },
                                  ),
                                );
                              },
                              onStockTap: (stockId) {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) {
                                      return MarketStockDetailPage(
                                        stockId: stockId,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          }

                          if (snapshot.hasError) {
                            return const _StocksStatusCard(
                              title: 'Stocks',
                              message:
                                  'Live stock list is temporarily unavailable.',
                            );
                          }

                          return const _StocksLoadingSection();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketsLoadingSection extends StatelessWidget {
  const _MarketsLoadingSection();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return _MarketsStatusCard(
      title: 'Markets',
      message: 'Loading live market indexes...',
      trailing: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(palette.primaryText),
        ),
      ),
    );
  }
}

class _StocksLoadingSection extends StatelessWidget {
  const _StocksLoadingSection();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return _StocksStatusCard(
      title: 'Stocks',
      message: 'Loading live stocks...',
      trailing: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(palette.primaryText),
        ),
      ),
    );
  }
}

class _MarketsStatusCard extends StatelessWidget {
  const _MarketsStatusCard({
    required this.title,
    required this.message,
    this.trailing,
  });

  final String title;
  final String message;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 30,
              height: 1.12,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: palette.groupBackground,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: palette.secondaryText,
                    height: 1.45,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                trailing!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StocksStatusCard extends _MarketsStatusCard {
  const _StocksStatusCard({
    required super.title,
    required super.message,
    super.trailing,
  });
}
