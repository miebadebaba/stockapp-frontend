import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_factor_score.dart';
import 'quant_factor_preset.dart';
import 'quant_factor_preset_calculator.dart';

class QuantFactorScoreSection extends StatelessWidget {
  const QuantFactorScoreSection({
    required this.result,
    this.presetType = QuantFactorPresetType.balanced,
    super.key,
  });

  final QuantFactorScore result;
  final QuantFactorPresetType presetType;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final preset = quantFactorPresetByType(presetType);
    final technicalScore = calculatePresetTechnicalScore(
      score: result,
      preset: preset,
    );
    final riskAdjustedScore = calculatePresetRiskAdjustedScore(
      score: result,
      preset: preset,
    );
    final adjustedRiskPenalty = result.riskPenalty == null
        ? null
        : result.riskPenalty! * preset.riskPenaltyMultiplier;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '当前股票因子解析',
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
                technicalScore.toStringAsFixed(0),
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
            value: technicalScore / 100,
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
          if (riskAdjustedScore != null && result.riskPenalty != null) ...[
            Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: palette.secondaryText,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '风险调整参考分：'
                    '${riskAdjustedScore.toStringAsFixed(0)}'
                    '（风险扣分 '
                    '${adjustedRiskPenalty!.toStringAsFixed(1)}）',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _ratingLabel(result.riskAdjustedRating!),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          for (var index = 0; index < result.factors.length; index++) ...[
            _FactorRow(
              factor: result.factors[index],
              weight: preset.weightFor(result.factors[index].id),
            ),
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
  const _FactorRow({required this.factor, required this.weight});

  final QuantFactorItem factor;
  final double weight;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final contribution = factor.score * weight;
    final signalColor = _signalColor(context, factor.signal);

    return ExpansionTile(
      key: ValueKey('quant-factor-${factor.id}'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      leading: SizedBox(
        width: 42,
        child: Text(
          factor.score.toStringAsFixed(0),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: signalColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              factor.label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: signalColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              child: Text(
                _signalLabel(factor.signal),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: signalColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: factor.score / 100,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              backgroundColor: palette.segmentBackground,
              color: signalColor,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '权重 ${(weight * 100).toStringAsFixed(0)}% · '
              '加权贡献 ${contribution.toStringAsFixed(1)} 分',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            factor.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
        if (factor.evidence.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '判断依据',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final evidence in factor.evidence)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: palette.secondaryText)),
                  Expanded(
                    child: Text(
                      evidence,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.secondaryText,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
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

String _signalLabel(QuantFactorSignal signal) {
  return switch (signal) {
    QuantFactorSignal.strong => '强势',
    QuantFactorSignal.positive => '偏强',
    QuantFactorSignal.neutral => '中性',
    QuantFactorSignal.negative => '偏弱',
    QuantFactorSignal.unavailable => '暂无数据',
  };
}

Color _signalColor(BuildContext context, QuantFactorSignal signal) {
  final colorScheme = Theme.of(context).colorScheme;

  return switch (signal) {
    QuantFactorSignal.strong => const Color(0xFF0E8F73),
    QuantFactorSignal.positive => const Color(0xFF16A085),
    QuantFactorSignal.neutral => const Color(0xFFB7791F),
    QuantFactorSignal.negative => const Color(0xFFE05A47),
    QuantFactorSignal.unavailable => colorScheme.outline,
  };
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
