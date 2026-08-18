import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_backtest_comparison.dart';
import 'quant_factor_backtest.dart';

class QuantBacktestComparisonSection extends StatelessWidget {
  const QuantBacktestComparisonSection({required this.result, super.key});

  final QuantBacktestComparisonResult result;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final bestReturn = result.bestReturnItem;
    final lowestDrawdown = result.lowestDrawdownItem;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '多组参数回测对比',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '使用相同历史数据，比较不同参数组合下的策略表现。',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (bestReturn != null || lowestDrawdown != null)
          Row(
            children: [
              if (bestReturn != null)
                Expanded(
                  child: _HighlightMetric(
                    label: '累计收益最高',
                    value: bestReturn.caseDefinition.label,
                    color: const Color(0xFF0EA078),
                  ),
                ),
              if (bestReturn != null && lowestDrawdown != null)
                const SizedBox(width: AppSpacing.md),
              if (lowestDrawdown != null)
                Expanded(
                  child: _HighlightMetric(
                    label: '最大回撤最低',
                    value: lowestDrawdown.caseDefinition.label,
                    color: palette.primaryText,
                  ),
                ),
            ],
          ),
        if (bestReturn != null || lowestDrawdown != null)
          const SizedBox(height: AppSpacing.lg),
        for (var index = 0; index < result.items.length; index++) ...[
          _ComparisonItem(
            item: result.items[index],
            isBestReturn: result.items[index] == bestReturn,
            isLowestDrawdown: result.items[index] == lowestDrawdown,
          ),
          if (index < result.items.length - 1)
            const SizedBox(height: AppSpacing.md),
        ],
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
                '不同参数组合只代表历史数据下的模拟结果，不能保证未来收益。比较时应同时关注收益、胜率和最大回撤。',
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

class _ComparisonItem extends StatelessWidget {
  const _ComparisonItem({
    required this.item,
    required this.isBestReturn,
    required this.isLowestDrawdown,
  });

  final QuantBacktestComparisonItem item;
  final bool isBestReturn;
  final bool isLowestDrawdown;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final result = item.result;
    final hasTrades = result.tradeCount > 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: isBestReturn
              ? const Color(0xFF0EA078)
              : palette.secondaryText.withValues(alpha: 0.25),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.caseDefinition.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: palette.primaryText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (isBestReturn)
                  _Tag(text: '收益最高', color: const Color(0xFF0EA078)),
                if (isBestReturn && isLowestDrawdown)
                  const SizedBox(width: AppSpacing.xs),
                if (isLowestDrawdown)
                  _Tag(text: '回撤最低', color: palette.primaryText),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.caseDefinition.description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '阈值 ${item.caseDefinition.parameters.signalThreshold.toStringAsFixed(0)} 分'
              ' · 持有 ${item.caseDefinition.parameters.holdingPeriod} 日',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _Metric(label: '交易次数', value: '${result.tradeCount}'),
                ),
                Expanded(
                  child: _Metric(
                    label: '累计收益',
                    value: hasTrades
                        ? _signedPercent(result.cumulativeReturn)
                        : '--',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: '胜率',
                    value: hasTrades ? _percent(result.winRate) : '--',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: '最大回撤',
                    value: hasTrades ? _percent(result.maximumDrawdown) : '--',
                  ),
                ),
              ],
            ),
            if (!hasTrades) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _comparisonNoTradeMessage(result),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HighlightMetric extends StatelessWidget {
  const _HighlightMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

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
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

String _percent(double value) {
  return '${(value * 100).toStringAsFixed(2)}%';
}

String _signedPercent(double value) {
  final sign = value > 0 ? '+' : '';
  return '$sign${(value * 100).toStringAsFixed(2)}%';
}

String _comparisonNoTradeMessage(QuantFactorBacktestResult result) {
  switch (result.noTradeReason) {
    case QuantBacktestNoTradeReason.insufficientHistory:
      return '历史数据不足，无法形成完整交易。';

    case QuantBacktestNoTradeReason.invalidPrices:
      return '行情价格数据不完整，候选交易无法执行。';

    case QuantBacktestNoTradeReason.noQualifiedSignal:
      final highestScore = result.highestSignalScore;

      if (highestScore == null) {
        return '没有产生可用的综合评分。';
      }

      return '最高评分 ${highestScore.toStringAsFixed(0)} 分，'
          '未达到 ${result.signalThreshold.toStringAsFixed(0)} 分阈值。';

    case null:
      return '';
  }
}
