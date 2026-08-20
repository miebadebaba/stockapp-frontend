import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_data_metadata.dart';

class QuantDataMetadataSection extends StatelessWidget {
  const QuantDataMetadataSection({required this.metadata, super.key});

  final QuantDataMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final qualityColor = switch (metadata.quality) {
      QuantDataQuality.usable => const Color(0xFF0EA078),
      QuantDataQuality.simulated ||
      QuantDataQuality.limitedHistory => const Color(0xFFE08A00),
      QuantDataQuality.issuesDetected => const Color(0xFFE05A47),
    };

    return Semantics(
      container: true,
      label: '数据质量与适用范围',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: palette.cardBackground,
          border: Border.all(color: palette.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '数据质量与适用范围',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              metadata.quality.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: qualityColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _DataMetric(
                    label: '历史区间',
                    value: metadata.formattedHistoryRange ?? '暂无',
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _DataMetric(
                    label: '日线数量',
                    value: '${metadata.historyBarCount} 条',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _DataMetric(
                    label: '复权状态',
                    value: metadata.priceAdjustment.label,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _DataMetric(label: '数据来源', value: metadata.sourceName),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _qualityExplanation(metadata),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.secondaryText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataMetric extends StatelessWidget {
  const _DataMetric({required this.label, required this.value});

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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

String _qualityExplanation(QuantDataMetadata metadata) {
  switch (metadata.quality) {
    case QuantDataQuality.simulated:
      return '当前为内置模拟数据，仅用于体验功能流程，不能作为真实行情分析或回测依据。';
    case QuantDataQuality.limitedHistory:
      return '当前日线少于 ${QuantDataMetadata.minimumRecommendedHistoryCount} 条，'
          '部分指标和回测结论可能不稳定，建议补充更长历史区间后再判断。';
    case QuantDataQuality.issuesDetected:
      final issueParts = <String>[];
      if (metadata.invalidBarCount > 0) {
        issueParts.add('${metadata.invalidBarCount} 条价格或成交量异常');
      }
      if (metadata.duplicateDateCount > 0) {
        issueParts.add('${metadata.duplicateDateCount} 个重复交易日');
      }
      return '检测到${issueParts.join('、')}。相关技术指标和回测结果仅供参考，建议检查行情数据。';
    case QuantDataQuality.usable:
      return '当前历史日线数量满足初步技术分析和回测要求。复权状态为“${metadata.priceAdjustment.label}”，'
          '仍建议结合更多市场阶段验证策略。';
  }
}
