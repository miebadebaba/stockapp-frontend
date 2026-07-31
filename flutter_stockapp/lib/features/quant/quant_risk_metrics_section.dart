import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'risk_metrics_calculator.dart';
import 'stock_daily_bar.dart';

class QuantRiskMetricsSection extends StatelessWidget {
  const QuantRiskMetricsSection({required this.bars, super.key});

  final List<StockDailyBar> bars;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final metrics = calculateRiskMetrics(bars: bars);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '风险指标',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '根据当前历史行情计算，帮助观察价格波动与下跌风险',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _RiskMetric(
                label: '年化波动率',
                value: metrics == null
                    ? '--'
                    : '${(metrics.annualizedVolatility * 100).toStringAsFixed(2)}%',
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _RiskMetric(
                label: '最大回撤',
                value: metrics == null
                    ? '--'
                    : '${(metrics.maximumDrawdown * 100).toStringAsFixed(2)}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: palette.secondaryText,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                metrics == null
                    ? '历史数据不足，暂时无法计算风险指标。'
                    : '波动率越高，价格变化通常越剧烈；最大回撤表示这段行情中从高点到低点的最大跌幅。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RiskMetric extends StatelessWidget {
  const _RiskMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
