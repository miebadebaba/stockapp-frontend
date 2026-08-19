import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'stock_daily_bar.dart';

class QuantOhlcDetails extends StatelessWidget {
  const QuantOhlcDetails({
    required this.bar,
    this.previousClose,
    this.onClose,
    super.key,
  });

  final StockDailyBar bar;
  final double? previousClose;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final change = previousClose == null ? null : bar.close - previousClose!;
    final changePercent = previousClose == null || previousClose == 0
        ? null
        : change! / previousClose! * 100;
    final changeColor = change == null
        ? palette.secondaryText
        : change >= 0
        ? const Color(0xFF16A085)
        : const Color(0xFFE05A47);

    return Container(
      key: const ValueKey('quant-ohlc-details'),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(bar.tradingDate),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _formatChange(change, changePercent),
                key: const ValueKey('quant-ohlc-change'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: changeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (onClose != null) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  key: const ValueKey('quant-clear-chart-selection'),
                  tooltip: '取消选择日期',
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - AppSpacing.md) / 2;

              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _DetailMetric(
                    width: itemWidth,
                    label: '开盘价',
                    value: bar.open.toStringAsFixed(2),
                  ),
                  _DetailMetric(
                    width: itemWidth,
                    label: '最高价',
                    value: bar.high.toStringAsFixed(2),
                  ),
                  _DetailMetric(
                    width: itemWidth,
                    label: '最低价',
                    value: bar.low.toStringAsFixed(2),
                  ),
                  _DetailMetric(
                    width: itemWidth,
                    label: '收盘价',
                    value: bar.close.toStringAsFixed(2),
                  ),
                  _DetailMetric(
                    width: itemWidth,
                    label: '成交量',
                    value: _formatVolume(bar.volume),
                  ),
                  _DetailMetric(
                    width: itemWidth,
                    label: '涨跌幅',
                    value: changePercent == null
                        ? '--'
                        : '${_signed(changePercent)}%',
                    valueColor: changeColor,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({
    required this.width,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final double width;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return SizedBox(
      width: width,
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
              color: valueColor ?? palette.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '${date.year}-$month-$day';
}

String _formatChange(double? change, double? percent) {
  if (change == null || percent == null) {
    return '涨跌 --';
  }

  return '${_signed(change)}  ${_signed(percent)}%';
}

String _signed(double value) {
  final prefix = value > 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(2)}';
}

String _formatVolume(int volume) {
  if (volume >= 100000000) {
    return '${(volume / 100000000).toStringAsFixed(2)} 亿股';
  }

  if (volume >= 10000) {
    return '${(volume / 10000).toStringAsFixed(2)} 万股';
  }

  return '$volume 股';
}
