import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'technical_summary_interpreter.dart';
import 'technical_summary_result.dart';

class TechnicalSummarySection extends StatelessWidget {
  const TechnicalSummarySection({required this.result, super.key});

  final TechnicalSummaryResult result;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final insight = interpretTechnicalSummary(result);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '综合技术状态',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          insight.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          insight.overview,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: palette.secondaryText,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _EvidenceItem(
          icon: Icons.trending_up_rounded,
          label: '趋势',
          description: insight.trendText,
        ),
        const SizedBox(height: AppSpacing.lg),
        _EvidenceItem(
          icon: Icons.speed_rounded,
          label: '动量',
          description: insight.momentumText,
        ),
        const SizedBox(height: AppSpacing.lg),
        _EvidenceItem(
          icon: Icons.monitor_heart_outlined,
          label: '相对强弱',
          description: insight.strengthText,
        ),
        const SizedBox(height: AppSpacing.lg),
        _EvidenceItem(
          icon: Icons.bar_chart_rounded,
          label: '成交量参与度',
          description: insight.participationText,
        ),
        const SizedBox(height: AppSpacing.lg),
        _EvidenceItem(
          icon: Icons.fact_check_outlined,
          label: '证据一致性',
          description: insight.consistencyText,
        ),
        if (insight.riskMessages.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            '风险提醒',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final message in insight.riskMessages) ...[
            _RiskMessage(message: message),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
        const SizedBox(height: AppSpacing.lg),
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
                insight.riskNotice,
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

class _EvidenceItem extends StatelessWidget {
  const _EvidenceItem({
    required this.icon,
    required this.label,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: palette.secondaryText),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
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

class _RiskMessage extends StatelessWidget {
  const _RiskMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.warning_amber_rounded,
          size: 18,
          color: palette.secondaryText,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.secondaryText,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
