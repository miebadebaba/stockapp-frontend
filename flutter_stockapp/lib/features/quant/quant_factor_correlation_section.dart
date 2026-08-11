import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_factor_correlation_calculator.dart';

class QuantFactorCorrelationSection extends StatelessWidget {
  const QuantFactorCorrelationSection({required this.correlations, super.key});

  final List<QuantFactorCorrelation> correlations;

  @override
  Widget build(BuildContext context) {
    if (correlations.isEmpty) {
      return const SizedBox.shrink();
    }

    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return ExpansionTile(
      key: const PageStorageKey('quant-factor-correlation-section'),
      initiallyExpanded: false,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: const Border(),
      collapsedShape: const Border(),
      leading: Icon(Icons.compare_arrows_rounded, color: palette.secondaryText),
      title: Text(
        '因子相关性',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: palette.primaryText,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        _summaryText(correlations),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
      ),
      children: [
        const Divider(height: 1),
        for (final correlation in correlations)
          _CorrelationRow(correlation: correlation),
      ],
    );
  }
}

class _CorrelationRow extends StatelessWidget {
  const _CorrelationRow({required this.correlation});

  final QuantFactorCorrelation correlation;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final coefficient = correlation.coefficient;
    final coefficientText = coefficient == null
        ? '--'
        : '${coefficient >= 0 ? '+' : ''}${coefficient.toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_factorLabel(correlation.leftFactorId)} / '
                  '${_factorLabel(correlation.rightFactorId)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${_strengthLabel(correlation.strength)} · '
                  '${_reliabilityLabel(correlation.reliability)} · '
                  '${correlation.sampleSize}只',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            coefficientText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: correlation.isPotentiallyRedundant
                  ? Theme.of(context).colorScheme.error
                  : palette.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

String _summaryText(List<QuantFactorCorrelation> correlations) {
  final redundantCount = correlations
      .where((correlation) => correlation.isPotentiallyRedundant)
      .length;

  if (redundantCount > 0) {
    return '发现 $redundantCount 组可能重复的因子';
  }

  if (correlations.every(
    (correlation) =>
        correlation.reliability ==
        QuantFactorCorrelationReliability.insufficient,
  )) {
    return '股票池样本不足，结果仅供参考';
  }

  if (correlations.any(
    (correlation) =>
        correlation.reliability == QuantFactorCorrelationReliability.limited,
  )) {
    return '当前样本有限，结果仅供参考';
  }

  return '共 ${correlations.length} 组因子组合';
}

String _factorLabel(String factorId) {
  return switch (factorId) {
    'trend' => '趋势',
    'momentum' => '动量',
    'volume' => '量价',
    _ => factorId,
  };
}

String _strengthLabel(QuantFactorCorrelationStrength strength) {
  return switch (strength) {
    QuantFactorCorrelationStrength.unavailable => '暂不可计算',
    QuantFactorCorrelationStrength.weak => '弱相关',
    QuantFactorCorrelationStrength.moderate => '中等相关',
    QuantFactorCorrelationStrength.strong => '强相关',
  };
}

String _reliabilityLabel(QuantFactorCorrelationReliability reliability) {
  return switch (reliability) {
    QuantFactorCorrelationReliability.insufficient => '样本不足',
    QuantFactorCorrelationReliability.limited => '样本有限',
    QuantFactorCorrelationReliability.adequate => '样本可用',
  };
}
