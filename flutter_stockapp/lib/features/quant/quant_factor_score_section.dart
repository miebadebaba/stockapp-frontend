import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_factor_score.dart';

class QuantFactorScoreSection extends StatelessWidget {
  const QuantFactorScoreSection({required this.result, super.key});

  final QuantFactorScore result;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '多因子技术评分',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '综合趋势、动量和量价表现，风险等级单独展示',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (!result.hasSufficientData)
          _UnavailableResult(summary: result.summary)
        else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                result.technicalScore.toStringAsFixed(0),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: palette.primaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xs,
                  bottom: AppSpacing.xs,
                ),
                child: Text(
                  '/ 100',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _ratingLabel(result.rating),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: palette.primaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: result.technicalScore / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            backgroundColor: palette.segmentBackground,
            color: palette.primaryText,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            result.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          for (var index = 0; index < result.factors.length; index++) ...[
            _FactorRow(factor: result.factors[index]),
            if (index < result.factors.length - 1)
              const SizedBox(height: AppSpacing.lg),
          ],
        ],
        const SizedBox(height: AppSpacing.xl),
        Divider(height: 1, color: palette.divider),
        const SizedBox(height: AppSpacing.lg),
        _RiskSummary(risk: result.risk),
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
                '评分只描述当前历史周期内的技术状态，不代表未来收益，也不构成投资建议。',
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

class _FactorRow extends StatelessWidget {
  const _FactorRow({required this.factor});

  final QuantFactorItem factor;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                factor.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: palette.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '权重 ${(factor.weight * 100).toStringAsFixed(0)}%',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: factor.score / 100,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                      backgroundColor: palette.segmentBackground,
                      color: palette.primaryText,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 32,
                    child: Text(
                      factor.score.toStringAsFixed(0),
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                factor.summary,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                factor.evidence.join('；'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RiskSummary extends StatelessWidget {
  const _RiskSummary({required this.risk});

  final QuantRiskAssessment risk;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.shield_outlined, size: 22, color: palette.secondaryText),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '风险等级：${_riskLabel(risk.level)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: palette.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                risk.summary,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnavailableResult extends StatelessWidget {
  const _UnavailableResult({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.data_usage_rounded, size: 22, color: palette.secondaryText),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.secondaryText,
              height: 1.5,
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
    QuantTechnicalRating.unavailable => '暂不可用',
  };
}

String _riskLabel(QuantRiskLevel level) {
  return switch (level) {
    QuantRiskLevel.low => '较低',
    QuantRiskLevel.medium => '中等',
    QuantRiskLevel.high => '较高',
    QuantRiskLevel.unavailable => '暂不可用',
  };
}
