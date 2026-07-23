import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';

class QuantPage extends StatelessWidget {
  const QuantPage({this.selectedStockCode, this.onChooseStock, super.key});

  final String? selectedStockCode;
  final VoidCallback? onChooseStock;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final hasSelectedStock =
        selectedStockCode != null && selectedStockCode!.isNotEmpty;

    return AnimatedPageWrapper(
      child: ColoredBox(
        color: palette.pageBackground,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              96,
              AppSpacing.lg,
              140,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '量化分析',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: palette.primaryText,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '通过行情和技术指标，理解股票当前状态。',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (hasSelectedStock)
                      _SelectedStockState(stockCode: selectedStockCode!)
                    else
                      _EmptyStockState(onChooseStock: onChooseStock),
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

class _EmptyStockState extends StatelessWidget {
  const _EmptyStockState({this.onChooseStock});

  final VoidCallback? onChooseStock;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.query_stats_rounded, size: 42, color: palette.primaryText),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '还没有选择股票',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '请先选择一只A股，随后查看行情、技术指标和通俗解释。',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: onChooseStock,
          icon: const Icon(Icons.search_rounded),
          label: const Text('选择股票'),
        ),
      ],
    );
  }
}

class _SelectedStockState extends StatelessWidget {
  const _SelectedStockState({required this.stockCode});

  final String stockCode;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '已选择股票',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          stockCode,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
