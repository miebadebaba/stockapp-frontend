import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'macd_series.dart';
import 'moving_average_series.dart';
import 'quant_chart_timeline.dart';
import 'quant_macd_chart.dart';
import 'quant_moving_average_overlay.dart';
import 'stock_daily_bar.dart';
import 'quant_candlestick_chart.dart';
import 'quant_ohlc_details.dart';
import 'quant_rsi_chart.dart';
import 'quant_volume_chart.dart';
import 'rsi_series.dart';

class QuantPriceChart extends StatefulWidget {
  const QuantPriceChart({required this.bars, super.key});

  final List<StockDailyBar> bars;

  @override
  State<QuantPriceChart> createState() => _QuantPriceChartState();
}

class _QuantPriceChartState extends State<QuantPriceChart> {
  int _selectedRange = 60;
  bool _showCandlesticks = false;
  bool _showMa5 = true;
  bool _showMa10 = true;
  bool _showMa20 = true;
  DateTime? _selectedTradingDate;

  void _selectTradingDate(DateTime tradingDate) {
    setState(() {
      _selectedTradingDate = tradingDate;
    });
  }

  void _selectBarAt(double dx, double width, List<StockDailyBar> bars) {
    if (bars.isEmpty || width <= 0) {
      return;
    }

    final index = quantChartIndexForX(
      x: dx,
      itemCount: bars.length,
      width: width,
    );

    _selectTradingDate(bars[index].tradingDate);
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
    final visibleStartIndex = orderedBars.length - visibleBars.length;
    final movingAverageSeries = <int, List<double?>>{
      if (_showMa5)
        5: calculateMovingAverageSeries(
          bars: orderedBars,
          period: 5,
        ).sublist(visibleStartIndex),
      if (_showMa10)
        10: calculateMovingAverageSeries(
          bars: orderedBars,
          period: 10,
        ).sublist(visibleStartIndex),
      if (_showMa20)
        20: calculateMovingAverageSeries(
          bars: orderedBars,
          period: 20,
        ).sublist(visibleStartIndex),
    };

    final rsiSeries = calculateRsiSeries(
      bars: orderedBars,
      period: 14,
    ).sublist(visibleStartIndex);
    final macdSeries = calculateMacdSeries(
      bars: orderedBars,
    ).sublist(visibleStartIndex);
    final highest = visibleBars.map((bar) => bar.high).reduce(math.max);
    final lowest = visibleBars.map((bar) => bar.low).reduce(math.min);
    final latest = visibleBars.last.close;
    final selectedBar = _selectedTradingDate == null
        ? null
        : visibleBars
              .where((bar) => bar.tradingDate == _selectedTradingDate)
              .firstOrNull;
    final selectedBarIndex = selectedBar == null
        ? -1
        : orderedBars.indexWhere(
            (bar) => bar.tradingDate == selectedBar.tradingDate,
          );
    final previousClose = selectedBarIndex > 0
        ? orderedBars[selectedBarIndex - 1].close
        : null;

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
          '基于最近日线收盘价绘制',
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
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            _MovingAverageToggle(
              period: 5,
              color: const Color(0xFFF2A93B),
              value: _showMa5,
              onChanged: (value) {
                setState(() {
                  _showMa5 = value;
                });
              },
            ),
            _MovingAverageToggle(
              period: 10,
              color: const Color(0xFF8B5CF6),
              value: _showMa10,
              onChanged: (value) {
                setState(() {
                  _showMa10 = value;
                });
              },
            ),
            _MovingAverageToggle(
              period: 20,
              color: const Color(0xFF00A6A6),
              value: _showMa20,
              onChanged: (value) {
                setState(() {
                  _showMa20 = value;
                });
              },
            ),
          ],
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
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(12, 16, 8, 10),
          decoration: BoxDecoration(
            color: palette.cardBackground,
            border: Border.all(color: palette.divider),
            borderRadius: BorderRadius.circular(8),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final plotWidth = math.max(
                0.0,
                constraints.maxWidth - quantChartScaleWidth,
              );

              void selectAt(Offset position) {
                if (position.dx < 0 || position.dx > plotWidth) {
                  return;
                }

                _selectBarAt(position.dx, plotWidth, visibleBars);
              }

              return GestureDetector(
                key: const ValueKey('quant-price-chart-gesture'),
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => selectAt(details.localPosition),
                onHorizontalDragStart: (details) =>
                    selectAt(details.localPosition),
                onHorizontalDragUpdate: (details) =>
                    selectAt(details.localPosition),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: plotWidth,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_showCandlesticks)
                            QuantCandlestickChart(
                              bars: visibleBars,
                              selectedIndex: selectedBar == null
                                  ? null
                                  : visibleBars.indexOf(selectedBar),
                            )
                          else
                            CustomPaint(
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
                          QuantMovingAverageOverlay(
                            bars: visibleBars,
                            series: movingAverageSeries,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: plotWidth,
                      top: 0,
                      bottom: 0,
                      width: quantChartScaleWidth,
                      child: IgnorePointer(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              key: const ValueKey('quant-price-scale-high'),
                              highest.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: palette.secondaryText,
                                    fontSize: 10,
                                  ),
                            ),
                            Text(
                              key: const ValueKey('quant-price-scale-middle'),
                              ((highest + lowest) / 2).toStringAsFixed(2),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: palette.secondaryText,
                                    fontSize: 10,
                                  ),
                            ),
                            Text(
                              key: const ValueKey('quant-price-scale-low'),
                              lowest.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: palette.secondaryText,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          key: const ValueKey('quant-price-date-axis'),
          padding: const EdgeInsets.only(left: 12, right: 74),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(visibleBars.first.tradingDate),
                  textAlign: TextAlign.left,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
                ),
              ),
              Expanded(
                child: Text(
                  _formatDate(visibleBars[visibleBars.length ~/ 2].tradingDate),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
                ),
              ),
              Expanded(
                child: Text(
                  _formatDate(visibleBars.last.tradingDate),
                  textAlign: TextAlign.right,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
                ),
              ),
            ],
          ),
        ),
        if (selectedBar != null) ...[
          const SizedBox(height: AppSpacing.md),
          QuantOhlcDetails(
            bar: selectedBar,
            previousClose: previousClose,
            onClose: () {
              setState(() {
                _selectedTradingDate = null;
              });
            },
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        QuantVolumeChart(
          bars: visibleBars,
          selectedTradingDate: _selectedTradingDate,
          onSelectedTradingDate: _selectTradingDate,
        ),
        const SizedBox(height: AppSpacing.xxl),
        QuantRsiChart(
          bars: visibleBars,
          values: rsiSeries,
          selectedTradingDate: _selectedTradingDate,
          onSelectedTradingDate: _selectTradingDate,
        ),
        const SizedBox(height: AppSpacing.xxl),
        QuantMacdChart(
          bars: visibleBars,
          values: macdSeries,
          selectedTradingDate: _selectedTradingDate,
          onSelectedTradingDate: _selectTradingDate,
        ),
      ],
    );
  }
}

class _MovingAverageToggle extends StatelessWidget {
  const _MovingAverageToggle({
    required this.period,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final int period;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: ValueKey('quant-ma-$period-toggle'),
      width: 112,
      height: 48,
      child: Semantics(
        label: 'MA$period moving average',
        checked: value,
        child: GestureDetector(
          key: ValueKey('quant-ma-$period-checkbox'),
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(!value),
          child: Stack(
            children: [
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: value ? color : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: value
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                left: 44,
                right: 8,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'MA$period',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      final x = quantChartXForIndex(
        index: index,
        itemCount: bars.length,
        width: size.width,
      );
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
