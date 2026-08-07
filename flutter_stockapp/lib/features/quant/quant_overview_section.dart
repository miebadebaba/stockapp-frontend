import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_factor_score.dart';

class QuantOverviewSection extends StatelessWidget {
  const QuantOverviewSection({required this.result, super.key});

  final QuantFactorScore result;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final score = result.riskAdjustedScore ?? result.technicalScore;
    final rating = result.riskAdjustedRating ?? result.rating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '量化概览',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '快速了解当前技术状态、风险和主要因子表现',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _SummaryMetric(
                label: '风险调整分',
                value: score.toStringAsFixed(0),
                suffix: ' / 100',
              ),
            ),
            Expanded(
              child: _SummaryMetric(label: '技术状态', value: _ratingLabel(rating)),
            ),
            Expanded(
              child: _SummaryMetric(
                label: '风险等级',
                value: _riskLabel(result.risk.level),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Divider(color: palette.divider),
        const SizedBox(height: AppSpacing.sm),
        for (final factor in result.factors)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    factor.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  factor.score.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 48,
                  child: Text(
                    _signalLabel(factor.signal),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _signalColor(factor.signal),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Text(
          result.summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: palette.secondaryText,
            height: 1.5,
          ),
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
                '评分描述当前历史周期内的技术状态，不代表未来收益，也不构成投资建议。',
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

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    this.suffix = '',
  });

  final String label;
  final String value;
  final String suffix;

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
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              text: value,
              children: [
                TextSpan(
                  text: suffix,
                  style: TextStyle(color: palette.secondaryText, fontSize: 12),
                ),
              ],
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

String _ratingLabel(QuantTechnicalRating rating) {
  return switch (rating) {
    QuantTechnicalRating.strong => '强势',
    QuantTechnicalRating.positive => '偏强',
    QuantTechnicalRating.neutral => '中性',
    QuantTechnicalRating.negative => '偏弱',
    QuantTechnicalRating.weak => '弱势',
    QuantTechnicalRating.unavailable => '暂无',
  };
}

String _riskLabel(QuantRiskLevel level) {
  return switch (level) {
    QuantRiskLevel.low => '较低',
    QuantRiskLevel.medium => '中等',
    QuantRiskLevel.high => '较高',
    QuantRiskLevel.unavailable => '暂无',
  };
}

String _signalLabel(QuantFactorSignal signal) {
  return switch (signal) {
    QuantFactorSignal.strong => '强势',
    QuantFactorSignal.positive => '偏强',
    QuantFactorSignal.neutral => '中性',
    QuantFactorSignal.negative => '偏弱',
    QuantFactorSignal.unavailable => '暂无',
  };
}

Color _signalColor(QuantFactorSignal signal) {
  return switch (signal) {
    QuantFactorSignal.strong => const Color(0xFF0E8F73),
    QuantFactorSignal.positive => const Color(0xFF16A085),
    QuantFactorSignal.neutral => const Color(0xFFB7791F),
    QuantFactorSignal.negative => const Color(0xFFE05A47),
    QuantFactorSignal.unavailable => const Color(0xFF6B6B70),
  };
}
