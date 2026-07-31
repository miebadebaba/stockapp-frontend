import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'stock_daily_bar.dart';
import 'quant_candlestick_chart.dart';
import 'quant_volume_chart.dart';

class QuantPriceChart extends StatefulWidget {
  const QuantPriceChart({required this.bars, super.key});

  final List<StockDailyBar> bars;

  @override
  State<QuantPriceChart> createState() => _QuantPriceChartState();
}

class _QuantPriceChartState extends State<QuantPriceChart> {
  int _selectedRange = 60;
  bool _showCandlesticks = false;
  DateTime? _selectedTradingDate;

  void _selectBarAt(double dx, double width, List<StockDailyBar> bars) {
    if (bars.isEmpty || width <= 0) {
      return;
    }

    final position = (dx / width).clamp(0.0, 1.0);
    final index = (position * (bars.length - 1)).round();

    setState(() {
      _selectedTradingDate = bars[index].tradingDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bars = widget.bars;
    if (bars.isEmpty) {
      return const SizedBox.shrink();
    }

    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final orderedBars = List<StockDailyBar>.of(bars)
      ..sort((a, b) => a.tradingDate.compareTo(b.tradingDate));
    final visibleBars = orderedBars.length <= _selectedRange
        ? orderedBars
        : orderedBars.sublist(orderedBars.length - _selectedRange);

    final highest = visibleBars.map((bar) => bar.high).reduce(math.max);
    final lowest = visibleBars.map((bar) => bar.low).reduce(math.min);
    final latest = visibleBars.last.close;
    final selectedBar = _selectedTradingDate == null
        ? null
        : visibleBars
              .where((bar) => bar.tradingDate == _selectedTradingDate)
              .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '近$_selectedRange个交易日价格走势',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '基于真实日线收盘价绘制',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(value: false, label: Text('折线图')),
              ButtonSegment<bool>(value: true, label: Text('K线图')),
            ],
            selected: {_showCandlesticks},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              setState(() {
                _showCandlesticks = selection.first;
                _selectedTradingDate = null;
              });
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(value: 20, label: Text('20日')),
              ButtonSegment<int>(value: 40, label: Text('40日')),
              ButtonSegment<int>(value: 60, label: Text('60日')),
            ],
            selected: {_selectedRange},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              setState(() {
                _selectedRange = selection.first;
                _selectedTradingDate = null;
              });
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _ChartMetric(
                label: '区间最高',
                value: highest.toStringAsFixed(2),
              ),
            ),
            Expanded(
              child: _ChartMetric(
                label: '区间最低',
                value: lowest.toStringAsFixed(2),
              ),
            ),
            Expanded(
              child: _ChartMetric(
                label: '最新收盘',
                value: latest.toStringAsFixed(2),
              ),
            ),
          ],
        ),
        if (selectedBar != null) ...[
          Text(
            '${_formatDate(selectedBar.tradingDate)}  '
            '收盘价 ${selectedBar.close.toStringAsFixed(2)}  '
            '成交量 ${selectedBar.volume.toStringAsFixed(0)}',
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
          decoration: BoxDecoration(
            color: palette.cardBackground,
            border: Border.all(color: palette.divider),
            borderRadius: BorderRadius.circular(8),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              void selectAt(Offset position) {
                _selectBarAt(position.dx, constraints.maxWidth, visibleBars);
              }

              return GestureDetector(
                key: const ValueKey('quant-price-chart-gesture'),
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => selectAt(details.localPosition),
                onHorizontalDragStart: (details) =>
                    selectAt(details.localPosition),
                onHorizontalDragUpdate: (details) =>
                    selectAt(details.localPosition),
                child: _showCandlesticks
                    ? QuantCandlestickChart(
                        bars: visibleBars,
                        selectedIndex: selectedBar == null
                            ? null
                            : visibleBars.indexOf(selectedBar),
                      )
                    : CustomPaint(
                        painter: _QuantPriceChartPainter(
                          bars: visibleBars,
                          selectedIndex: selectedBar == null
                              ? null
                              : visibleBars.indexOf(selectedBar),
                          lineColor: const Color(0xFF2F6FED),
                          gridColor: palette.divider,
                        ),
                        child: const SizedBox.expand(),
                      ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDate(visibleBars.first.tradingDate),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
            ),
            Text(
              _formatDate(visibleBars.last.tradingDate),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        QuantVolumeChart(
          bars: visibleBars,
          selectedTradingDate: _selectedTradingDate,
        ),
      ],
    );
  }
}

class _ChartMetric extends StatelessWidget {
  const _ChartMetric({required this.label, required this.value});

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

class _QuantPriceChartPainter extends CustomPainter {
  const _QuantPriceChartPainter({
    required this.bars,
    required this.selectedIndex,
    required this.lineColor,
    required this.gridColor,
  });

  final List<StockDailyBar> bars;
  final int? selectedIndex;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.length < 2) {
      return;
    }

    final minimum = bars.map((bar) => bar.low).reduce(math.min);
    final maximum = bars.map((bar) => bar.high).reduce(math.max);
    final span = math.max(maximum - minimum, 0.01);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var index = 0; index <= 3; index++) {
      final y = size.height * index / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = List<Offset>.generate(bars.length, (index) {
      final x = size.width * index / (bars.length - 1);
      final normalized = (bars[index].close - minimum) / span;
      final y = size.height - normalized * size.height;

      return Offset(x, y);
    });

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (var index = 1; index < points.length; index++) {
      linePath.lineTo(points[index].dx, points[index].dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = lineColor.withValues(alpha: 0.10)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawCircle(points.last, 4, Paint()..color = lineColor);
    final selection = selectedIndex;
    if (selection != null && selection >= 0 && selection < points.length) {
      final selectedPoint = points[selection];

      canvas.drawLine(
        Offset(selectedPoint.dx, 0),
        Offset(selectedPoint.dx, size.height),
        Paint()
          ..color = lineColor.withValues(alpha: 0.35)
          ..strokeWidth = 1.5,
      );

      canvas.drawCircle(selectedPoint, 6, Paint()..color = lineColor);
      canvas.drawCircle(selectedPoint, 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _QuantPriceChartPainter oldDelegate) {
    if (selectedIndex != oldDelegate.selectedIndex ||
        lineColor != oldDelegate.lineColor ||
        gridColor != oldDelegate.gridColor ||
        bars.length != oldDelegate.bars.length) {
      return true;
    }

    for (var index = 0; index < bars.length; index++) {
      final current = bars[index];
      final previous = oldDelegate.bars[index];

      if (current.tradingDate != previous.tradingDate ||
          current.close != previous.close ||
          current.high != previous.high ||
          current.low != previous.low) {
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
