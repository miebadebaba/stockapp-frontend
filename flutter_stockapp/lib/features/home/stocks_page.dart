import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import '../market/market_stock_detail_page.dart';
import 'widgets/stock_list_section.dart';

class StocksPage extends StatefulWidget {
  const StocksPage({required this.stocks, super.key});

  final List<StockListItemData> stocks;

  @override
  State<StocksPage> createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StockListItemData> get _filteredStocks {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return widget.stocks;
    }

    return widget.stocks.where((stock) {
      return stock.title.toLowerCase().contains(normalizedQuery) ||
          stock.subtitle.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  void _openStock(BuildContext context, String stockId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => MarketStockDetailPage(stockId: stockId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;
    final filteredStocks = _filteredStocks;

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
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        AnimatedPageWrapper(
                          child: _StocksHeader(
                            onBackTap: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AnimatedPageWrapper(
                          delay: const Duration(milliseconds: 40),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Stocks',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontSize: 36,
                                          height: 1.06,
                                          color: palette.primaryText,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                SizedBox(
                                  width: 220,
                                  child: _StocksSearchField(
                                    controller: _searchController,
                                    onChanged: (value) {
                                      setState(() => _query = value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AnimatedPageWrapper(
                          delay: const Duration(milliseconds: 80),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              _query.trim().isEmpty
                                  ? '${widget.stocks.length} symbols, keeping the same quick-read card style from home.'
                                  : '${filteredStocks.length} results for "${_query.trim()}".',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: palette.secondaryText,
                                fontSize: 16,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AnimatedPageWrapper(
                          delay: const Duration(milliseconds: 120),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: filteredStocks.isEmpty
                                ? _EmptySearchState(query: _query.trim())
                                : ListView.separated(
                                    itemCount: filteredStocks.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final stock = filteredStocks[index];
                                      return StockListTile(
                                        stock: stock,
                                        onTap: () =>
                                            _openStock(context, stock.id),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return Container(
                                        height: 1,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.xs,
                                        ),
                                        color: palette.divider,
                                      );
                                    },
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

class _StocksHeader extends StatelessWidget {
  const _StocksHeader({required this.onBackTap});

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

class _StocksSearchField extends StatelessWidget {
  const _StocksSearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: palette.primaryText,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: palette.secondaryText,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 20,
          color: palette.secondaryText,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: palette.secondaryText,
                ),
              ),
        filled: true,
        fillColor: isDark ? palette.groupBackground : AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(
            color: palette.primaryText.withValues(alpha: 0.10),
          ),
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: palette.groupBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 32,
            color: palette.secondaryText,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No stocks found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try another ticker or company name for "$query".',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.secondaryText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
