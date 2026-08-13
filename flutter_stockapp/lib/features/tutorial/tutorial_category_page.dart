import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import '../../core/widgets/pressable_scale.dart';
import 'fundamental_analysis_page.dart';
import 'simulation_app_guide_page.dart';
import 'stock_market_basics_page.dart';
import 'risk_portfolio_page.dart';
import 'technical_quant_analysis_page.dart';
import 'trading_basics_page.dart';

class TutorialCategoryData {
  const TutorialCategoryData({required this.id, required this.title});

  final String id;
  final String title;
}

class TutorialCategoryPage extends StatefulWidget {
  const TutorialCategoryPage({
    required this.categories,
    this.onSearchChanged,
    this.onCategoryTap,
    this.topPadding = AppSpacing.xl,
    this.bottomPadding = AppSpacing.xxl,
    super.key,
  });

  final List<TutorialCategoryData> categories;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onCategoryTap;
  final double topPadding;
  final double bottomPadding;

  factory TutorialCategoryPage.demo({
    ValueChanged<String>? onSearchChanged,
    ValueChanged<String>? onCategoryTap,
    double topPadding = AppSpacing.xl,
    double bottomPadding = AppSpacing.xxl,
    Key? key,
  }) {
    return TutorialCategoryPage(
      key: key,
      categories: _tutorialModules,
      onSearchChanged: onSearchChanged,
      onCategoryTap: onCategoryTap,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
    );
  }

  static const List<TutorialCategoryData> _tutorialModules = [
    TutorialCategoryData(id: 'stock-market-basics', title: '股票与行情基础'),
    TutorialCategoryData(id: 'trading-basics', title: '交易入门'),
    TutorialCategoryData(id: 'fundamental-analysis', title: '公司与基本面分析'),
    TutorialCategoryData(id: 'technical-quant-analysis', title: '技术指标与量化分析'),
    TutorialCategoryData(id: 'risk-portfolio', title: '风险与投资组合'),
    TutorialCategoryData(id: 'simulation-app-guide', title: '模拟交易与 App 使用'),
  ];

  @override
  State<TutorialCategoryPage> createState() => _TutorialCategoryPageState();
}

class _TutorialCategoryPageState extends State<TutorialCategoryPage> {
  late final TextEditingController _searchController;

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

  void _openCategory(String id) {
    final category = widget.categories.firstWhere((item) => item.id == id);
    widget.onCategoryTap?.call(id);
    final page = switch (id) {
      'stock-market-basics' => const StockMarketBasicsPage(),
      'trading-basics' => const TradingBasicsPage(),
      'fundamental-analysis' => const FundamentalAnalysisPage(),
      'technical-quant-analysis' => const TechnicalQuantAnalysisPage(),
      'risk-portfolio' => const RiskPortfolioPage(),
      'simulation-app-guide' => const SimulationAppGuidePage(),
      _ => TutorialModulePlaceholderPage(module: category),
    };
    Navigator.of(context)
        .push<void>(MaterialPageRoute<void>(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return AnimatedPageWrapper(
      child: Material(
        color: palette.pageBackground,
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                widget.topPadding,
                AppSpacing.lg,
                widget.bottomPadding,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TutorialSearchField(
                      controller: _searchController,
                      onChanged: widget.onSearchChanged,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TutorialCategoryGrid(
                      categories: widget.categories,
                      onCategoryTap: _openCategory,
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

class TutorialCategoryGrid extends StatelessWidget {
  const TutorialCategoryGrid({
    required this.categories,
    this.onCategoryTap,
    super.key,
  });

  final List<TutorialCategoryData> categories;
  final ValueChanged<String>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: categories.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return TutorialCategoryTile(
          category: category,
          onTap: onCategoryTap == null
              ? null
              : () => onCategoryTap!(category.id),
        );
      },
    );
  }
}

class TutorialCategoryTile extends StatelessWidget {
  const TutorialCategoryTile({required this.category, this.onTap, super.key});

  final TutorialCategoryData category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return PressableScale(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          key: ValueKey('tutorial-module-${category.id}'),
          decoration: BoxDecoration(
            color: palette.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: palette.divider),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                category.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TutorialModulePlaceholderPage extends StatelessWidget {
  const TutorialModulePlaceholderPage({required this.module, super.key});

  final TutorialCategoryData module;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return Scaffold(
      backgroundColor: palette.pageBackground,
      appBar: AppBar(
        backgroundColor: palette.pageBackground,
        foregroundColor: palette.primaryText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          module.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: const SizedBox.expand(),
    );
  }
}

class _TutorialSearchField extends StatelessWidget {
  const _TutorialSearchField({required this.controller, this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: palette.searchBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 22, color: palette.secondaryText),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: palette.primaryText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: palette.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
