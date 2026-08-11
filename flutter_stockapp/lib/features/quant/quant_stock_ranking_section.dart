import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_factor_preset.dart';
import 'quant_factor_preset_calculator.dart';
import 'quant_factor_score.dart';
import 'quant_stock_ranking.dart';
import 'selected_stock.dart';
import 'quant_factor_correlation_section.dart';

class QuantStockRankingSection extends StatelessWidget {
  const QuantStockRankingSection({
    required this.result,
    required this.market,
    required this.presetType,
    required this.isLoading,
    required this.onMarketChanged,
    required this.onPresetChanged,
    required this.onSortChanged,
    required this.onRefresh,
    required this.onStockSelected,
    this.onAddStock,
    super.key,
  });

  final QuantStockRankingResult? result;
  final QuantMarket market;
  final QuantFactorPresetType presetType;
  final bool isLoading;
  final ValueChanged<QuantMarket> onMarketChanged;
  final ValueChanged<QuantFactorPresetType> onPresetChanged;
  final ValueChanged<QuantRankingSort> onSortChanged;
  final VoidCallback onRefresh;
  final ValueChanged<SelectedStock> onStockSelected;
  final VoidCallback? onAddStock;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final selectedSort = result?.sortBy ?? QuantRankingSort.riskAdjustedScore;

    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '股票池筛选',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: '刷新排名',
                onPressed: isLoading ? null : onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '按市场和因子评分筛选并排序股票',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<QuantMarket>(
              segments: QuantMarket.values
                  .map(
                    (value) => ButtonSegment<QuantMarket>(
                      value: value,
                      label: Text(value.label),
                    ),
                  )
                  .toList(),
              selected: {market},
              onSelectionChanged: isLoading
                  ? null
                  : (selection) {
                      onMarketChanged(selection.first);
                    },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '策略偏好',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<QuantFactorPresetType>(
              segments: quantFactorPresets
                  .map(
                    (preset) => ButtonSegment<QuantFactorPresetType>(
                      value: preset.type,
                      label: Text(preset.label),
                    ),
                  )
                  .toList(),
              selected: {presetType},
              onSelectionChanged: isLoading
                  ? null
                  : (selection) {
                      onPresetChanged(selection.first);
                    },
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            quantFactorPresetByType(presetType).description,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<QuantRankingSort>(
            initialValue: selectedSort,
            decoration: const InputDecoration(
              labelText: '排序方式',
              border: OutlineInputBorder(),
            ),
            items: QuantRankingSort.values
                .map(
                  (value) => DropdownMenuItem<QuantRankingSort>(
                    value: value,
                    child: Text(value.label),
                  ),
                )
                .toList(),
            onChanged: isLoading
                ? null
                : (value) {
                    if (value != null) {
                      onSortChanged(value);
                    }
                  },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selectedSort.isCrossSectional
                    ? Icons.compare_arrows_rounded
                    : Icons.info_outline_rounded,
                size: 18,
                color: palette.secondaryText,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  selectedSort.explanation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.secondaryText,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppSpacing.md),
                    Text('正在计算股票池排名...'),
                  ],
                ),
              ),
            )
          else if (result == null || result!.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.star_border_rounded,
                      size: 36,
                      color: palette.secondaryText,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${market.label}暂无自选股票',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: palette.primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '当前市场暂无可用于排名的股票数据。',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.secondaryText,
                      ),
                    ),
                    if (onAddStock != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton.icon(
                        onPressed: onAddStock,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('添加自选股票'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            ...result!.items.map(
              (item) => _RankingRow(
                item: item,
                sortBy: result!.sortBy,
                presetType: result!.presetType,
                onPressed: () => onStockSelected(item.stock),
              ),
            ),
          if (!isLoading &&
              result != null &&
              result!.items.isNotEmpty &&
              result!.factorCorrelations.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            QuantFactorCorrelationSection(
              correlations: result!.factorCorrelations,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            '排名仅描述当前数据周期内的相对技术状态，不代表未来收益。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.item,
    required this.sortBy,
    required this.presetType,
    required this.onPressed,
  });

  final QuantStockRankingItem item;
  final QuantRankingSort sortBy;
  final QuantFactorPresetType presetType;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        overlayColor: WidgetStatePropertyAll(palette.rowPressedOverlay),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: Text(
                  '${item.rank}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.stock.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${item.stock.code} · '
                      '${_riskLabel(item.score.risk.level)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.secondaryText,
                      ),
                    ),
                    if (item.crossSectionalScore?.totalFactorCount != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          '${item.crossSectionalScore!.availableFactorCount}/'
                          '${item.crossSectionalScore!.totalFactorCount} factors',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: palette.secondaryText),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _displayScore(item, sortBy, presetType).toStringAsFixed(0),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: palette.primaryText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    sortBy.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.chevron_right_rounded, color: palette.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

double _displayScore(
  QuantStockRankingItem item,
  QuantRankingSort sortBy,
  QuantFactorPresetType presetType,
) {
  final preset = quantFactorPresetByType(presetType);

  return switch (sortBy) {
    QuantRankingSort.poolCompositeScore => item.poolCompositeScore ?? 0,
    QuantRankingSort.riskAdjustedScore =>
      calculatePresetRiskAdjustedScore(score: item.score, preset: preset) ??
          calculatePresetTechnicalScore(score: item.score, preset: preset),
    QuantRankingSort.technicalScore => calculatePresetTechnicalScore(
      score: item.score,
      preset: preset,
    ),
    QuantRankingSort.trend => item.factorPercentile('trend') ?? 0,
    QuantRankingSort.momentum => item.factorPercentile('momentum') ?? 0,
    QuantRankingSort.volume => item.factorPercentile('volume') ?? 0,
  };
}

String _riskLabel(QuantRiskLevel level) {
  return switch (level) {
    QuantRiskLevel.low => '风险较低',
    QuantRiskLevel.medium => '风险中等',
    QuantRiskLevel.high => '风险较高',
    QuantRiskLevel.unavailable => '风险未知',
  };
}
