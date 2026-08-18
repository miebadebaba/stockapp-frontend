import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'stock_daily_bar.dart';

class QuantRsiChart extends StatelessWidget {
  const QuantRsiChart({
    required this.bars,
    required this.values,
    this.selectedTradingDate,
    super.key,
  });

  final List<StockDailyBar> bars;
  final List<double?> values;
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
    final selectedValue = selectedIndex >= 0 ? values[selectedIndex] : null;
    final displayValue = selectedValue ?? _latestRsi(values);
    final firstAvailableIndex = values.indexWhere((value) => value != null);
    final chartValues = firstAvailableIndex < 0
        ? values
        : values.sublist(firstAvailableIndex);

    final chartSelectedIndex =
        firstAvailableIndex >= 0 && selectedIndex >= firstAvailableIndex
        ? selectedIndex - firstAvailableIndex
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RSI相对强弱指标',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'RSI14展示近期上涨与下跌力量，30和70为常用参考线',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        if (firstAvailableIndex > 0) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '前 $firstAvailableIndex 个交易日用于指标预热，'
            '图表从首个有效 RSI 数据开始显示。',
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
              child: _RsiMetric(
                label: selectedValue == null ? '最新RSI14' : '所选日期RSI14',
                value: displayValue?.toStringAsFixed(2) ?? '--',
              ),
            ),
            Expanded(
              child: _RsiMetric(
                label: '当前状态',
                value: _describeRsi(displayValue),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 180,
          padding: const EdgeInsets.fromLTRB(12, 14, 8, 14),
          decoration: BoxDecoration(
            color: palette.cardBackground,
            border: Border.all(color: palette.divider),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            key: const ValueKey('quant-rsi-chart'),
            painter: _QuantRsiChartPainter(
              values: chartValues,
              selectedIndex: chartSelectedIndex,
              lineColor: const Color(0xFF2F6FED),
              gridColor: palette.divider,
              labelColor: palette.secondaryText,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _RsiMetric extends StatelessWidget {
  const _RsiMetric({required this.label, required this.value});

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

class _QuantRsiChartPainter extends CustomPainter {
  const _QuantRsiChartPainter({
    required this.values,
    required this.selectedIndex,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<double?> values;
  final int? selectedIndex;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }

    const labelWidth = 28.0;
    final plotWidth = size.width - labelWidth;

    for (final level in const [70.0, 50.0, 30.0]) {
      final y = _valueToY(level, size.height);
      final isBoundary = level == 70 || level == 30;

      canvas.drawLine(
        Offset(0, y),
        Offset(plotWidth, y),
        Paint()
          ..color = isBoundary
              ? const Color(0xFFF2A93B).withValues(alpha: 0.65)
              : gridColor
          ..strokeWidth = isBoundary ? 1.5 : 1,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: level.toInt().toString(),
          style: TextStyle(color: labelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(plotWidth + 5, y - textPainter.height / 2),
      );
    }

    final path = Path();
    var hasStartedPath = false;

    for (var index = 0; index < values.length; index++) {
      final value = values[index];

      if (value == null) {
        hasStartedPath = false;
        continue;
      }

      final point = Offset(
        _indexToX(index, values.length, plotWidth),
        _valueToY(value, size.height),
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
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final selection = selectedIndex;
    if (selection == null || selection < 0 || selection >= values.length) {
      return;
    }

    final selectedX = _indexToX(selection, values.length, plotWidth);

    canvas.drawLine(
      Offset(selectedX, 0),
      Offset(selectedX, size.height),
      Paint()
        ..color = lineColor.withValues(alpha: 0.55)
        ..strokeWidth = 1.5,
    );

    final selectedValue = values[selection];
    if (selectedValue != null) {
      canvas.drawCircle(
        Offset(selectedX, _valueToY(selectedValue, size.height)),
        4,
        Paint()..color = lineColor,
      );
    }
  }

  double _indexToX(int index, int length, double width) {
    if (length <= 1) {
      return width / 2;
    }

    return width * index / (length - 1);
  }

  double _valueToY(double value, double height) {
    final normalized = value.clamp(0.0, 100.0) / 100;
    return height * (1 - normalized);
  }

  @override
  bool shouldRepaint(covariant _QuantRsiChartPainter oldDelegate) {
    if (selectedIndex != oldDelegate.selectedIndex ||
        lineColor != oldDelegate.lineColor ||
        gridColor != oldDelegate.gridColor ||
        labelColor != oldDelegate.labelColor ||
        values.length != oldDelegate.values.length) {
      return true;
    }

    for (var index = 0; index < values.length; index++) {
      if (values[index] != oldDelegate.values[index]) {
        return true;
      }
    }

    return false;
  }
}

double? _latestRsi(List<double?> values) {
  for (var index = values.length - 1; index >= 0; index--) {
    if (values[index] != null) {
      return values[index];
    }
  }

  return null;
}

String _describeRsi(double? value) {
  if (value == null) {
    return '数据不足';
  }

  if (value >= 70) {
    return '高位区间';
  }

  if (value <= 30) {
    return '低位区间';
  }

  return '中性区间';
}
