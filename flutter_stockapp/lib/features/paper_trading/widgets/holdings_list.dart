import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_palette.dart';
import '../models/paper_portfolio.dart';

class HoldingsList extends StatelessWidget {
  const HoldingsList({required this.holdings, super.key});

  final List<HoldingPosition> holdings;

  @override
  Widget build(BuildContext context) {
    if (holdings.isEmpty) {
      return const _EmptyHoldings();
    }

    return Column(
      children: [
        for (var index = 0; index < holdings.length; index++) ...[
          _HoldingCard(position: holdings[index]),
          if (index != holdings.length - 1)
            const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({required this.position});

  final HoldingPosition position;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final metrics = [
      _HoldingMetric(
        label: '当前市值',
        value: PaperTradingFormatters.amount(position.marketValue),
      ),
      _HoldingMetric(
        label: '持仓盈亏',
        value: PaperTradingFormatters.amount(position.profitLoss),
        color: _profitLossColor(context, position.profitLoss),
      ),
      _HoldingMetric(
        label: '盈亏比例',
        value: PaperTradingFormatters.percentage(position.profitLossPercent),
        color: _profitLossColor(context, position.profitLossPercent),
      ),
      _HoldingMetric(
        label: '持仓数量',
        value: PaperTradingFormatters.quantity(position.quantity),
      ),
      _HoldingMetric(
        label: '可用数量',
        value: PaperTradingFormatters.quantity(position.availableQuantity),
      ),
      _HoldingMetric(
        label: '平均成本',
        value: PaperTradingFormatters.price(position.averageCost),
      ),
      _HoldingMetric(
        label: '当前价格',
        value: PaperTradingFormatters.price(position.currentPrice),
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              position.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${position.symbol} / ${position.market}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final columnCount = constraints.maxWidth >= 640 ? 4 : 2;
                const spacing = AppSpacing.md;
                final itemWidth =
                    (constraints.maxWidth - spacing * (columnCount - 1)) /
                    columnCount;

                return Wrap(
                  spacing: spacing,
                  runSpacing: AppSpacing.lg,
                  children: [
                    for (final metric in metrics)
                      SizedBox(
                        width: itemWidth,
                        child: _HoldingMetricView(
                          metric: metric,
                          palette: palette,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HoldingMetric {
  const _HoldingMetric({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;
}

class _HoldingMetricView extends StatelessWidget {
  const _HoldingMetricView({required this.metric, required this.palette});

  final _HoldingMetric metric;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          metric.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            metric.value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: metric.color ?? palette.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyHoldings extends StatelessWidget {
  const _EmptyHoldings();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Center(
        child: Text(
          '暂无持仓',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.secondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

Color _profitLossColor(BuildContext context, double value) {
  final palette = Theme.of(context).extension<AppThemePalette>()!;
  if (value == 0) {
    return palette.secondaryText;
  }
  if (value < 0) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFFF8A80)
        : AppColors.dangerSoft;
  }
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF66D19E)
      : const Color(0xFF25875B);
}
