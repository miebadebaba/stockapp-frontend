import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'macd_interpreter.dart';
import 'macd_result.dart';
import 'moving_average_interpreter.dart';
import 'rsi_interpreter.dart';
import 'volume_analysis_result.dart';
import 'volume_interpreter.dart';

class QuantTechnicalOverviewSection extends StatelessWidget {
  const QuantTechnicalOverviewSection({
    required this.close,
    required this.ma5,
    required this.ma10,
    required this.ma20,
    required this.macd,
    required this.rsi14,
    required this.volume,
    super.key,
  });

  final double? close;
  final double? ma5;
  final double? ma10;
  final double? ma20;
  final MacdResult? macd;
  final double? rsi14;
  final VolumeAnalysisResult? volume;

  @override
  Widget build(BuildContext context) {
    final movingAverageInsight = interpretMovingAverages(
      close: close,
      ma5: ma5,
      ma10: ma10,
      ma20: ma20,
    );
    final macdInsight = interpretMacd(macd);
    final rsiInsight = interpretRsi(rsi14);
    final volumeInsight = interpretVolume(volume);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '技术指标',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '先看指标状态，需要时展开详细解释。',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).extension<AppThemePalette>()!.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _TechnicalTile(
          icon: Icons.show_chart_rounded,
          title: '均线',
          summary: movingAverageInsight.title,
          details: movingAverageInsight.explanation,
          notice: movingAverageInsight.riskNotice,
        ),
        _TechnicalTile(
          icon: Icons.speed_rounded,
          title: 'MACD',
          summary: macdInsight.title,
          details: macdInsight.explanation,
          notice: macdInsight.riskNotice,
          metrics: switch (macd) {
            final value? =>
              'DIF ${value.dif.toStringAsFixed(2)}  ·  '
                  'DEA ${value.dea.toStringAsFixed(2)}  ·  '
                  '柱 ${value.histogram.toStringAsFixed(2)}',
            null => null,
          },
        ),
        _TechnicalTile(
          icon: Icons.monitor_heart_outlined,
          title: 'RSI14',
          summary: rsiInsight.title,
          details: rsiInsight.explanation,
          notice: rsiInsight.riskNotice,
          metrics: rsi14?.toStringAsFixed(2),
        ),
        _TechnicalTile(
          icon: Icons.bar_chart_rounded,
          title: '量价',
          summary: volumeInsight.title,
          details: volumeInsight.explanation,
          notice: volumeInsight.riskNotice,
          metrics: volume == null
              ? null
              : '量比 ${volume!.volumeRatio.toStringAsFixed(2)}  ·  '
                    '前5日均量 '
                    '${(volume!.averageVolume / 10000).toStringAsFixed(2)} 万股',
        ),
      ],
    );
  }
}

class _TechnicalTile extends StatelessWidget {
  const _TechnicalTile({
    required this.icon,
    required this.title,
    required this.summary,
    required this.details,
    required this.notice,
    this.metrics,
  });

  final IconData icon;
  final String title;
  final String summary;
  final String details;
  final String notice;
  final String? metrics;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: AppSpacing.md),
      leading: Icon(icon, color: palette.primaryText),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: palette.primaryText,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        summary,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
      ),
      children: [
        if (metrics != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              metrics!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            details,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.secondaryText,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            notice,
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
