import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'macd_result.dart';
import 'quant_chart_timeline.dart';
import 'stock_daily_bar.dart';

class QuantMacdChart extends StatelessWidget {
  const QuantMacdChart({
    required this.bars,
    required this.values,
    this.selectedTradingDate,
    super.key,
  });

  final List<StockDailyBar> bars;
  final List<MacdResult?> values;
  final DateTime? selectedTradingDate;

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty || values.length != bars.length) {
      return const SizedBox.shrink();
    }

    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final selectedIndex = selectedTradingDate == null
        ? -1
        : bars.indexWhere((bar) => bar.tradingDate == selectedTradingDate);
    final hasSelectedDate = selectedIndex >= 0;
    final displayValue = hasSelectedDate
        ? values[selectedIndex]
        : _latestMacd(values);
    final firstAvailableIndex = values.indexWhere((value) => value != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MACD趋势指标',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'DIF和DEA展示趋势变化，柱状图展示两者差异；0轴用于区分正负动能',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        if (firstAvailableIndex > 0) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '前 $firstAvailableIndex 个交易日用于指标预热，'
            '对应区间保留为空白。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.secondaryText,
              height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _MacdMetric(
                label: hasSelectedDate ? '所选日期DIF' : '最新DIF',
                value: displayValue?.dif.toStringAsFixed(2) ?? '--',
                color: const Color(0xFF2F6FED),
              ),
            ),
            Expanded(
              child: _MacdMetric(
                label: hasSelectedDate ? '所选日期DEA' : '最新DEA',
                value: displayValue?.dea.toStringAsFixed(2) ?? '--',
                color: const Color(0xFFF2A93B),
              ),
            ),
            Expanded(
              child: _MacdMetric(
                label: hasSelectedDate ? '所选日期MACD柱' : '最新MACD柱',
                value: displayValue?.histogram.toStringAsFixed(2) ?? '--',
                color: displayValue == null
                    ? palette.primaryText
                    : displayValue.histogram >= 0
                    ? const Color(0xFF16A085)
                    : const Color(0xFFE05A47),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(12, 14, 8, 14),
          decoration: BoxDecoration(
            color: palette.cardBackground,
            border: Border.all(color: palette.divider),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            key: const ValueKey('quant-macd-chart'),
            painter: _QuantMacdChartPainter(
              values: values,
              selectedIndex: hasSelectedDate ? selectedIndex : null,
              difColor: const Color(0xFF2F6FED),
              deaColor: const Color(0xFFF2A93B),
              positiveColor: const Color(0xFF16A085),
              negativeColor: const Color(0xFFE05A47),
              gridColor: palette.divider,
              labelColor: palette.secondaryText,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        if (bars.isNotEmpty)
          Padding(
            key: const ValueKey('quant-macd-date-axis'),
            padding: const EdgeInsets.only(left: 12, right: 74),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(bars.first.tradingDate),
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatDate(bars[bars.length ~/ 2].tradingDate),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatDate(bars.last.tradingDate),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        const Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.xs,
          children: [
            _MacdLegend(label: 'DIF', color: Color(0xFF2F6FED)),
            _MacdLegend(label: 'DEA', color: Color(0xFFF2A93B)),
            _MacdLegend(label: '正柱', color: Color(0xFF16A085)),
            _MacdLegend(label: '负柱', color: Color(0xFFE05A47)),
          ],
        ),
      ],
    );
  }
}

class _MacdMetric extends StatelessWidget {
  const _MacdMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

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
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MacdLegend extends StatelessWidget {
  const _MacdLegend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 4, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
        ),
      ],
    );
  }
}

class _QuantMacdChartPainter extends CustomPainter {
  const _QuantMacdChartPainter({
    required this.values,
    required this.selectedIndex,
    required this.difColor,
    required this.deaColor,
    required this.positiveColor,
    required this.negativeColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<MacdResult?> values;
  final int? selectedIndex;
  final Color difColor;
  final Color deaColor;
  final Color positiveColor;
  final Color negativeColor;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    final availableValues = values.whereType<MacdResult>().toList();
    if (availableValues.isEmpty) {
      return;
    }

    final maximumMagnitude = availableValues
        .expand(
          (value) => [value.dif.abs(), value.dea.abs(), value.histogram.abs()],
        )
        .fold<double>(0, math.max);
    final scaleMagnitude = math.max(maximumMagnitude, 0.000001);
    final plotWidth = size.width - quantChartScaleWidth;
    final zeroY = size.height / 2;
    final slotWidth = plotWidth / values.length;
    final histogramWidth = math.max(1.5, slotWidth * 0.55);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    canvas.drawLine(Offset(0, zeroY), Offset(plotWidth, zeroY), gridPaint);

    final zeroLabelPainter = TextPainter(
      text: TextSpan(
        text: '0',
        style: TextStyle(color: labelColor, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    zeroLabelPainter.paint(
      canvas,
      Offset(plotWidth + 5, zeroY - zeroLabelPainter.height / 2),
    );
    canvas.drawLine(
      Offset(0, size.height * 0.25),
      Offset(plotWidth, size.height * 0.25),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(plotWidth, size.height * 0.75),
      gridPaint,
    );

    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      if (value == null) {
        continue;
      }

      final centerX = quantChartXForIndex(
        index: index,
        itemCount: values.length,
        width: plotWidth,
      );
      final histogramY = _valueToY(
        value.histogram,
        scaleMagnitude,
        size.height,
      );

      canvas.drawRect(
        Rect.fromLTRB(
          centerX - histogramWidth / 2,
          math.min(zeroY, histogramY),
          centerX + histogramWidth / 2,
          math.max(zeroY, histogramY),
        ),
        Paint()..color = value.histogram >= 0 ? positiveColor : negativeColor,
      );
    }

    _drawLine(
      canvas: canvas,
      size: size,
      plotWidth: plotWidth,
      scaleMagnitude: scaleMagnitude,
      color: difColor,
      readValue: (value) => value.dif,
    );
    _drawLine(
      canvas: canvas,
      size: size,
      plotWidth: plotWidth,
      scaleMagnitude: scaleMagnitude,
      color: deaColor,
      readValue: (value) => value.dea,
    );

    final selection = selectedIndex;
    if (selection == null || selection < 0 || selection >= values.length) {
      return;
    }

    final selectedX = quantChartXForIndex(
      index: selection,
      itemCount: values.length,
      width: plotWidth,
    );

    canvas.drawLine(
      Offset(selectedX, 0),
      Offset(selectedX, size.height),
      Paint()
        ..color = difColor.withValues(alpha: 0.55)
        ..strokeWidth = 1.5,
    );

    final selectedValue = values[selection];
    if (selectedValue != null) {
      canvas.drawCircle(
        Offset(
          selectedX,
          _valueToY(selectedValue.dif, scaleMagnitude, size.height),
        ),
        4,
        Paint()..color = difColor,
      );
      canvas.drawCircle(
        Offset(
          selectedX,
          _valueToY(selectedValue.dea, scaleMagnitude, size.height),
        ),
        4,
        Paint()..color = deaColor,
      );
    }
  }

  void _drawLine({
    required Canvas canvas,
    required Size size,
    required double plotWidth,
    required double scaleMagnitude,
    required Color color,
    required double Function(MacdResult value) readValue,
  }) {
    final path = Path();
    var hasStartedPath = false;

    for (var index = 0; index < values.length; index++) {
      final value = values[index];

      if (value == null) {
        hasStartedPath = false;
        continue;
      }

      final point = Offset(
        quantChartXForIndex(
          index: index,
          itemCount: values.length,
          width: plotWidth,
        ),
        _valueToY(readValue(value), scaleMagnitude, size.height),
      );

      if (!hasStartedPath) {
        path.moveTo(point.dx, point.dy);
        hasStartedPath = true;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  double _valueToY(double value, double magnitude, double height) {
    return height / 2 - value / magnitude * height * 0.45;
  }

  @override
  bool shouldRepaint(covariant _QuantMacdChartPainter oldDelegate) {
    if (selectedIndex != oldDelegate.selectedIndex ||
        difColor != oldDelegate.difColor ||
        deaColor != oldDelegate.deaColor ||
        positiveColor != oldDelegate.positiveColor ||
        negativeColor != oldDelegate.negativeColor ||
        gridColor != oldDelegate.gridColor ||
        labelColor != oldDelegate.labelColor ||
        values.length != oldDelegate.values.length) {
      return true;
    }

    for (var index = 0; index < values.length; index++) {
      final current = values[index];
      final previous = oldDelegate.values[index];

      if (current?.dif != previous?.dif ||
          current?.dea != previous?.dea ||
          current?.histogram != previous?.histogram) {
        return true;
      }
    }

    return false;
  }
}

MacdResult? _latestMacd(List<MacdResult?> values) {
  for (var index = values.length - 1; index >= 0; index--) {
    if (values[index] != null) {
      return values[index];
    }
  }

  return null;
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '${date.year}-$month-$day';
}
