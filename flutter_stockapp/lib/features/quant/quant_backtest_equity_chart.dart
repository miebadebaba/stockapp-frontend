import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_factor_backtest.dart';

class QuantBacktestEquityChart extends StatefulWidget {
  const QuantBacktestEquityChart({required this.points, super.key});

  final List<QuantBacktestEquityPoint> points;

  @override
  State<QuantBacktestEquityChart> createState() =>
      _QuantBacktestEquityChartState();
}

class _QuantBacktestEquityChartState extends State<QuantBacktestEquityChart> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.points.length - 1;
  }

  @override
  void didUpdateWidget(covariant QuantBacktestEquityChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.points != oldWidget.points) {
      _selectedIndex = widget.points.length - 1;
    }
  }

  void _selectPoint(Offset localPosition, double chartWidth) {
    const labelWidth = 42.0;
    const rightPadding = 4.0;
    final plotWidth = chartWidth - labelWidth - rightPadding;
    final normalized = ((localPosition.dx - labelWidth) / plotWidth).clamp(
      0.0,
      1.0,
    );
    final index = (normalized * (widget.points.length - 1)).round();

    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.length < 2) {
      return const SizedBox.shrink();
    }

    final palette = Theme.of(context).extension<AppThemePalette>()!;
    const strategyColor = Color(0xFF2F6FED);
    const benchmarkColor = Color(0xFFE08A24);
    final selectedPoint = widget.points[_selectedIndex];
    final selectedExcessReturn =
        selectedPoint.strategyValue - selectedPoint.benchmarkValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _Legend(color: strategyColor, label: '多因子策略'),
            const SizedBox(width: AppSpacing.lg),
            const _Legend(color: benchmarkColor, label: '买入持有基准'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 210,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          decoration: BoxDecoration(
            color: palette.cardBackground,
            border: Border.all(color: palette.divider),
            borderRadius: BorderRadius.circular(8),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                key: const ValueKey('quant-backtest-equity-chart'),
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) =>
                    _selectPoint(details.localPosition, constraints.maxWidth),
                child: CustomPaint(
                  painter: _EquityChartPainter(
                    points: widget.points,
                    selectedIndex: _selectedIndex,
                    strategyColor: strategyColor,
                    benchmarkColor: benchmarkColor,
                    gridColor: palette.divider,
                    labelColor: palette.secondaryText,
                  ),
                  child: const SizedBox.expand(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          container: true,
          label: '已选 ${_formatDate(selectedPoint.date)} 的净值表现',
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
                  '已选 ${_formatDate(selectedPoint.date)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _SelectedValue(
                        label: '策略收益',
                        value: _signedPercent(selectedPoint.strategyValue - 1),
                      ),
                    ),
                    Expanded(
                      child: _SelectedValue(
                        label: '基准收益',
                        value: _signedPercent(selectedPoint.benchmarkValue - 1),
                      ),
                    ),
                    Expanded(
                      child: _SelectedValue(
                        label: '当日超额',
                        value: _signedPercent(selectedExcessReturn),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDate(widget.points.first.date),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
            ),
            Text(
              _formatDate(widget.points.last.date),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
            ),
          ],
        ),
      ],
    );
  }
}

class _SelectedValue extends StatelessWidget {
  const _SelectedValue({required this.label, required this.value});

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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 18, height: 3, color: color),
        const SizedBox(width: AppSpacing.sm),
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

class _EquityChartPainter extends CustomPainter {
  const _EquityChartPainter({
    required this.points,
    required this.selectedIndex,
    required this.strategyColor,
    required this.benchmarkColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<QuantBacktestEquityPoint> points;
  final int selectedIndex;
  final Color strategyColor;
  final Color benchmarkColor;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    const labelWidth = 42.0;
    const rightPadding = 4.0;
    const verticalPadding = 8.0;

    final plotLeft = labelWidth;
    final plotRight = size.width - rightPadding;
    final plotWidth = plotRight - plotLeft;
    final plotHeight = size.height - verticalPadding * 2;

    final values = <double>[
      1,
      for (final point in points) point.strategyValue,
      for (final point in points) point.benchmarkValue,
    ];

    var minimum = values.reduce((left, right) => left < right ? left : right);
    var maximum = values.reduce((left, right) => left > right ? left : right);

    if ((maximum - minimum).abs() < 0.001) {
      minimum -= 0.02;
      maximum += 0.02;
    } else {
      final padding = (maximum - minimum) * 0.12;
      minimum -= padding;
      maximum += padding;
    }

    double valueToY(double value) {
      final normalized = (value - minimum) / (maximum - minimum);
      return verticalPadding + plotHeight * (1 - normalized);
    }

    double indexToX(int index) {
      return plotLeft + plotWidth * index / (points.length - 1);
    }

    for (var index = 0; index < 3; index++) {
      final ratio = index / 2;
      final value = maximum - (maximum - minimum) * ratio;
      final y = verticalPadding + plotHeight * ratio;

      canvas.drawLine(
        Offset(plotLeft, y),
        Offset(plotRight, y),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1,
      );

      final label = '${((value - 1) * 100).toStringAsFixed(1)}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: labelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: labelWidth - 4);

      textPainter.paint(
        canvas,
        Offset(labelWidth - textPainter.width - 4, y - textPainter.height / 2),
      );
    }

    if (minimum <= 1 && maximum >= 1) {
      final zeroY = valueToY(1);

      canvas.drawLine(
        Offset(plotLeft, zeroY),
        Offset(plotRight, zeroY),
        Paint()
          ..color = labelColor.withValues(alpha: 0.55)
          ..strokeWidth = 1.2,
      );
    }

    final strategyPath = Path();
    final benchmarkPath = Path();

    for (var index = 0; index < points.length; index++) {
      final x = indexToX(index);
      final strategyY = valueToY(points[index].strategyValue);
      final benchmarkY = valueToY(points[index].benchmarkValue);

      if (index == 0) {
        strategyPath.moveTo(x, strategyY);
        benchmarkPath.moveTo(x, benchmarkY);
      } else {
        strategyPath.lineTo(x, strategyY);
        benchmarkPath.lineTo(x, benchmarkY);
      }
    }

    canvas.drawPath(
      benchmarkPath,
      Paint()
        ..color = benchmarkColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      strategyPath,
      Paint()
        ..color = strategyColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final selectedPoint = points[selectedIndex];
    final selectedX = indexToX(selectedIndex);
    final selectedStrategyY = valueToY(selectedPoint.strategyValue);
    final selectedBenchmarkY = valueToY(selectedPoint.benchmarkValue);

    canvas.drawLine(
      Offset(selectedX, verticalPadding),
      Offset(selectedX, size.height - verticalPadding),
      Paint()
        ..color = labelColor.withValues(alpha: 0.45)
        ..strokeWidth = 1,
    );

    canvas.drawCircle(
      Offset(selectedX, selectedBenchmarkY),
      4,
      Paint()..color = benchmarkColor,
    );
    canvas.drawCircle(
      Offset(selectedX, selectedStrategyY),
      4.5,
      Paint()..color = strategyColor,
    );
  }

  @override
  bool shouldRepaint(covariant _EquityChartPainter oldDelegate) {
    if (strategyColor != oldDelegate.strategyColor ||
        benchmarkColor != oldDelegate.benchmarkColor ||
        gridColor != oldDelegate.gridColor ||
        labelColor != oldDelegate.labelColor ||
        points.length != oldDelegate.points.length ||
        selectedIndex != oldDelegate.selectedIndex) {
      return true;
    }

    for (var index = 0; index < points.length; index++) {
      final current = points[index];
      final previous = oldDelegate.points[index];

      if (current.date != previous.date ||
          current.strategyValue != previous.strategyValue ||
          current.benchmarkValue != previous.benchmarkValue) {
        return true;
      }
    }

    return false;
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _signedPercent(double value) {
  final sign = value >= 0 ? '+' : '';
  return '$sign${(value * 100).toStringAsFixed(2)}%';
}
