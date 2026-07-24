import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_palette.dart';
import '../models/paper_portfolio.dart';

class PortfolioSummary extends StatelessWidget {
  const PortfolioSummary({required this.summary, super.key});

  final PaperPortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final metrics = [
      _SummaryMetric(
        label: '总资产',
        value: PaperTradingFormatters.amount(summary.totalAssets),
      ),
      _SummaryMetric(
        label: '总盈亏',
        value: PaperTradingFormatters.amount(summary.totalProfitLoss),
        color: _profitLossColor(context, summary.totalProfitLoss),
      ),
      _SummaryMetric(
        label: '当日盈亏',
        value: PaperTradingFormatters.amount(summary.dailyProfitLoss),
        color: _profitLossColor(context, summary.dailyProfitLoss),
      ),
      _SummaryMetric(
        label: '当日盈亏比例',
        value: PaperTradingFormatters.percentage(
          summary.dailyProfitLossPercent,
        ),
        color: _profitLossColor(context, summary.dailyProfitLossPercent),
      ),
      _SummaryMetric(
        label: '总市值',
        value: PaperTradingFormatters.amount(summary.totalMarketValue),
      ),
      _SummaryMetric(
        label: '可用资金',
        value: PaperTradingFormatters.amount(summary.availableCash),
      ),
      _SummaryMetric(
        label: '可取资金',
        value: PaperTradingFormatters.amount(summary.withdrawableCash),
      ),
      _SummaryMetric(
        label: '仓位比例',
        value: PaperTradingFormatters.percentage(
          summary.positionRatio,
          fractionDigits: 1,
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= 720
            ? 4
            : constraints.maxWidth >= 520
            ? 3
            : 2;
        const spacing = AppSpacing.md;
        final itemWidth =
            (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: itemWidth,
                child: _SummaryMetricCard(metric: metric, palette: palette),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryMetric {
  const _SummaryMetric({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;
}

class _SummaryMetricCard extends StatelessWidget {
  const _SummaryMetricCard({required this.metric, required this.palette});

  final _SummaryMetric metric;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
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
              metric.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                metric.value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: metric.color ?? palette.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
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
