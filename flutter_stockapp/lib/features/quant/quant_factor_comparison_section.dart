import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_factor_score.dart';
import 'selected_stock.dart';

class QuantFactorComparisonSection extends StatelessWidget {
  const QuantFactorComparisonSection({
    required this.firstStock,
    required this.firstScore,
    required this.secondStock,
    required this.secondScore,
    super.key,
  });

  final SelectedStock firstStock;
  final QuantFactorScore firstScore;
  final SelectedStock secondStock;
  final QuantFactorScore secondScore;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '多股票因子对比',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '对比两只股票的综合评分、因子表现和风险调整结果',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ComparisonHeader(
          firstStock: firstStock,
          secondStock: secondStock,
          palette: palette,
        ),
        const SizedBox(height: AppSpacing.md),
        Divider(color: palette.divider),
        const SizedBox(height: AppSpacing.md),
        _ComparisonMetricRow(
          label: '综合评分',
          firstValue: _formatScore(firstScore.technicalScore),
          secondValue: _formatScore(secondScore.technicalScore),
          palette: palette,
        ),
        _ComparisonMetricRow(
          label: '风险调整分',
          firstValue: _formatScore(firstScore.riskAdjustedScore),
          secondValue: _formatScore(secondScore.riskAdjustedScore),
          palette: palette,
        ),
        _ComparisonMetricRow(
          label: '趋势因子',
          firstValue: _formatScore(_factorScore(firstScore, 'trend')),
          secondValue: _formatScore(_factorScore(secondScore, 'trend')),
          palette: palette,
        ),
        _ComparisonMetricRow(
          label: '动量因子',
          firstValue: _formatScore(_factorScore(firstScore, 'momentum')),
          secondValue: _formatScore(_factorScore(secondScore, 'momentum')),
          palette: palette,
        ),
        _ComparisonMetricRow(
          label: '量价因子',
          firstValue: _formatScore(_factorScore(firstScore, 'volume')),
          secondValue: _formatScore(_factorScore(secondScore, 'volume')),
          palette: palette,
        ),
      ],
    );
  }
}

class _ComparisonHeader extends StatelessWidget {
  const _ComparisonHeader({
    required this.firstStock,
    required this.secondStock,
    required this.palette,
  });

  final SelectedStock firstStock;
  final SelectedStock secondStock;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 96),
        Expanded(
          child: _StockName(stock: firstStock, palette: palette),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StockName(stock: secondStock, palette: palette),
        ),
      ],
    );
  }
}

class _StockName extends StatelessWidget {
  const _StockName({required this.stock, required this.palette});

  final SelectedStock stock;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          stock.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          stock.code,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
        ),
      ],
    );
  }
}

class _ComparisonMetricRow extends StatelessWidget {
  const _ComparisonMetricRow({
    required this.label,
    required this.firstValue,
    required this.secondValue,
    required this.palette,
  });

  final String label;
  final String firstValue;
  final String secondValue;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              firstValue,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              secondValue,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double? _factorScore(QuantFactorScore result, String id) {
  for (final factor in result.factors) {
    if (factor.id == id) {
      return factor.score;
    }
  }

  return null;
}

String _formatScore(double? value) {
  return value == null ? '--' : value.toStringAsFixed(0);
}
