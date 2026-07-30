import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'stock_daily_bar.dart';

class QuantVolumeChart extends StatelessWidget {
  const QuantVolumeChart({required this.bars, super.key});

  final List<StockDailyBar> bars;

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return const SizedBox.shrink();
    }

    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final maximumVolume = bars.map((bar) => bar.volume).reduce(math.max);
    final latestVolume = bars.last.volume;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '成交量趋势',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '展示当前所选交易日范围内的每日成交量',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _VolumeMetric(
                label: '区间最大',
                value: _formatVolume(maximumVolume),
              ),
            ),
            Expanded(
              child: _VolumeMetric(
                label: '最新成交量',
                value: _formatVolume(latestVolume),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 150,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
          decoration: BoxDecoration(
            color: palette.cardBackground,
            border: Border.all(color: palette.divider),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: _QuantVolumeChartPainter(
              bars: bars,
              risingColor: const Color(0xFF16A085),
              fallingColor: const Color(0xFFE05A47),
              gridColor: palette.divider,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _VolumeMetric extends StatelessWidget {
  const _VolumeMetric({required this.label, required this.value});

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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _QuantVolumeChartPainter extends CustomPainter {
  const _QuantVolumeChartPainter({
    required this.bars,
    required this.risingColor,
    required this.fallingColor,
    required this.gridColor,
  });

  final List<StockDailyBar> bars;
  final Color risingColor;
  final Color fallingColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) {
      return;
    }

    final maximumVolume = bars.map((bar) => bar.volume).reduce(math.max);
    final scaleMaximum = math.max(maximumVolume, 1);
    final slotWidth = size.width / bars.length;
    final barWidth = math.max(1.0, slotWidth * 0.62);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var index = 0; index <= 2; index++) {
      final y = size.height * index / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (var index = 0; index < bars.length; index++) {
      final bar = bars[index];
      final height = size.height * bar.volume / scaleMaximum;
      final centerX = slotWidth * index + slotWidth / 2;
      final rect = Rect.fromLTWH(
        centerX - barWidth / 2,
        size.height - height,
        barWidth,
        height,
      );

      canvas.drawRect(
        rect,
        Paint()..color = bar.close >= bar.open ? risingColor : fallingColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QuantVolumeChartPainter oldDelegate) {
    if (risingColor != oldDelegate.risingColor ||
        fallingColor != oldDelegate.fallingColor ||
        gridColor != oldDelegate.gridColor ||
        bars.length != oldDelegate.bars.length) {
      return true;
    }

    for (var index = 0; index < bars.length; index++) {
      final current = bars[index];
      final previous = oldDelegate.bars[index];

      if (current.tradingDate != previous.tradingDate ||
          current.open != previous.open ||
          current.close != previous.close ||
          current.volume != previous.volume) {
        return true;
      }
    }

    return false;
  }
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
