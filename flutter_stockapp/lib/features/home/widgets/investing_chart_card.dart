import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class InvestingChartCard extends StatefulWidget {
  const InvestingChartCard({
    required this.title,
    required this.amountText,
    required this.changeText,
    required this.changeLabel,
    required this.mockData,
    this.showBadge = false,
    this.badgeText = 'Gold perks',
    this.initialRange = 'ALL',
    this.chartHeight = 220,
    this.isPositiveChange = true,
    this.showEndMarker = true,
    this.onRangeChanged,
    this.onBadgeTap,
    this.onSettingsTap,
    super.key,
  });

  final String title;
  final String amountText;
  final String changeText;
  final String changeLabel;
  final Map<String, List<double>> mockData;
  final bool showBadge;
  final String badgeText;
  final String initialRange;
  final double chartHeight;
  final bool isPositiveChange;
  final bool showEndMarker;
  final ValueChanged<String>? onRangeChanged;
  final VoidCallback? onBadgeTap;
  final VoidCallback? onSettingsTap;

  @override
  State<InvestingChartCard> createState() => _InvestingChartCardState();
}

class _InvestingChartCardState extends State<InvestingChartCard>
    with SingleTickerProviderStateMixin {
  static const _selectionDuration = Duration(milliseconds: 260);
  static const _sectionHorizontalPadding = 16.0;
  static const _cardVerticalPadding = 26.0;

  late final List<String> _ranges;
  late String _selectedRange;
  late List<double> _fromSeries;
  late List<double> _toSeries;
  late final AnimationController _markerPulseController;

  @override
  void initState() {
    super.initState();
    _markerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _syncMarkerPulse();

    if (widget.mockData.isEmpty) {
      _ranges = <String>[];
      _selectedRange = widget.initialRange;
      _fromSeries = <double>[];
      _toSeries = <double>[];
      return;
    }

    _ranges = widget.mockData.keys.toList();
    _selectedRange = _ranges.contains(widget.initialRange)
        ? widget.initialRange
        : _ranges.first;
    _fromSeries = List<double>.from(
      widget.mockData[_selectedRange] ?? const <double>[],
    );
    _toSeries = List<double>.from(
      widget.mockData[_selectedRange] ?? const <double>[],
    );
  }

  @override
  void didUpdateWidget(covariant InvestingChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMarkerPulse();
    final newRanges = widget.mockData.keys.toList();
    final rangesChanged = newRanges.join('|') != _ranges.join('|');
    final dataChanged = !_deepEquals(widget.mockData, oldWidget.mockData);

    if (!rangesChanged && !dataChanged) {
      return;
    }

    _ranges
      ..clear()
      ..addAll(newRanges);

    if (!_ranges.contains(_selectedRange)) {
      _selectedRange = _ranges.isNotEmpty ? _ranges.first : widget.initialRange;
    }

    final nextSeries = widget.mockData[_selectedRange] ?? const <double>[];
    _fromSeries = List<double>.from(nextSeries);
    _toSeries = List<double>.from(nextSeries);
  }

  void _syncMarkerPulse() {
    if (widget.showEndMarker) {
      if (!_markerPulseController.isAnimating) {
        _markerPulseController.repeat(reverse: true);
      }
      return;
    }

    if (_markerPulseController.isAnimating) {
      _markerPulseController.stop();
    }
  }

  bool _deepEquals(
    Map<String, List<double>> current,
    Map<String, List<double>> previous,
  ) {
    if (current.length != previous.length) {
      return false;
    }

    for (final entry in current.entries) {
      final other = previous[entry.key];
      if (other == null || other.length != entry.value.length) {
        return false;
      }
      for (var i = 0; i < other.length; i++) {
        if (other[i] != entry.value[i]) {
          return false;
        }
      }
    }
    return true;
  }

  void _selectRange(String range) {
    if (range == _selectedRange) {
      return;
    }

    final nextSeries = widget.mockData[range];
    if (nextSeries == null || nextSeries.isEmpty) {
      return;
    }

    setState(() {
      _fromSeries = List<double>.from(_toSeries);
      _toSeries = List<double>.from(nextSeries);
      _selectedRange = range;
    });
    widget.onRangeChanged?.call(range);
  }

  List<double> _interpolatedSeries(double t) {
    final sampleCount = math.max(_fromSeries.length, _toSeries.length);
    if (sampleCount == 0) {
      return const [];
    }

    return List<double>.generate(sampleCount, (index) {
      final progress = sampleCount == 1 ? 0.0 : index / (sampleCount - 1);
      final fromValue = _sampleAt(_fromSeries, progress);
      final toValue = _sampleAt(_toSeries, progress);
      return lerpDouble(fromValue, toValue, t) ?? toValue;
    });
  }

  double _sampleAt(List<double> series, double progress) {
    if (series.isEmpty) {
      return 0;
    }
    if (series.length == 1) {
      return series.first;
    }

    final scaled = progress.clamp(0.0, 1.0) * (series.length - 1);
    final lowerIndex = scaled.floor();
    final upperIndex = scaled.ceil();
    if (lowerIndex == upperIndex) {
      return series[lowerIndex];
    }

    final localProgress = scaled - lowerIndex;
    return lerpDouble(series[lowerIndex], series[upperIndex], localProgress) ??
        series[upperIndex];
  }

  @override
  void dispose() {
    _markerPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final changeColor = widget.isPositiveChange
        ? const Color(0xFFE3515A)
        : const Color(0xFF2C9D69);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.symmetric(vertical: _cardVerticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _sectionHorizontalPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 32,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.amountText,
                            maxLines: 1,
                            softWrap: false,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 50,
                              height: 1.05,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isPositiveChange
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                size: 18,
                                color: changeColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                widget.changeText,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: changeColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.changeLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.showBadge) ...[
                  const SizedBox(width: AppSpacing.lg),
                  _BadgePill(text: widget.badgeText, onTap: widget.onBadgeTap),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: widget.chartHeight,
            child: TweenAnimationBuilder<double>(
              key: ValueKey(_selectedRange),
              tween: Tween(begin: 0, end: 1),
              duration: _selectionDuration,
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                if (!widget.showEndMarker) {
                  return RepaintBoundary(
                    child: CustomPaint(
                      painter: _InvestingChartPainter(
                        values: _interpolatedSeries(value),
                        showEndMarker: false,
                        markerPulseValue: 0,
                      ),
                    ),
                  );
                }

                return AnimatedBuilder(
                  animation: _markerPulseController,
                  builder: (context, child) {
                    return RepaintBoundary(
                      child: CustomPaint(
                        painter: _InvestingChartPainter(
                          values: _interpolatedSeries(value),
                          showEndMarker: widget.showEndMarker,
                          markerPulseValue: _markerPulseController.value,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _sectionHorizontalPadding,
            ),
            child: _RangeSelector(
              ranges: _ranges,
              selectedRange: _selectedRange,
              onSelected: _selectRange,
              onSettingsTap: widget.onSettingsTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF7ECCE),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.ranges,
    required this.selectedRange,
    required this.onSelected,
    this.onSettingsTap,
  });

  final List<String> ranges;
  final String selectedRange;
  final ValueChanged<String> onSelected;
  final VoidCallback? onSettingsTap;

  static const _selectorHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    if (ranges.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedIndex = ranges.contains(selectedRange)
        ? ranges.indexOf(selectedRange)
        : 0;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: _selectorHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 6.0;
                final segmentWidth =
                    (constraints.maxWidth - spacing * (ranges.length - 1)) /
                    ranges.length;
                final left = selectedIndex * (segmentWidth + spacing);

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      left: left,
                      top: 0,
                      width: segmentWidth,
                      height: _selectorHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.orbBlueDeep,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < ranges.length; i++) ...[
                          SizedBox(
                            width: segmentWidth,
                            height: _selectorHeight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                foregroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                              ),
                              onPressed: () => onSelected(ranges[i]),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                style:
                                    Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(
                                          fontSize: 16,
                                          color: i == selectedIndex
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                          fontWeight: i == selectedIndex
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                        ) ??
                                    const TextStyle(),
                                child: Text(ranges[i]),
                              ),
                            ),
                          ),
                          if (i != ranges.length - 1)
                            const SizedBox(width: spacing),
                        ],
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSettingsTap,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Ink(
              width: _selectorHeight,
              height: _selectorHeight,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InvestingChartPainter extends CustomPainter {
  const _InvestingChartPainter({
    required this.values,
    required this.showEndMarker,
    required this.markerPulseValue,
  });

  final List<double> values;
  final bool showEndMarker;
  final double markerPulseValue;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final valueSpan = math.max(maxValue - minValue, 1);
    const leftPadding = 0.0;
    const rightPadding = 0.0;
    const topPadding = 12.0;
    const bottomPadding = 10.0;
    final usableWidth = size.width - leftPadding - rightPadding;
    final usableHeight = size.height - topPadding - bottomPadding;

    final points = List<Offset>.generate(values.length, (index) {
      final x =
          leftPadding + usableWidth * index / math.max(values.length - 1, 1);
      final normalized = (values[index] - minValue) / valueSpan;
      final y = size.height - bottomPadding - normalized * usableHeight;
      return Offset(x, y);
    });

    final linePath = _buildSmoothPath(points);
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.orbBlueDeep.withValues(alpha: 0.26),
        AppColors.orbBlueDeep.withValues(alpha: 0.04),
        AppColors.orbBlueDeep.withValues(alpha: 0.0),
      ],
      stops: const [0, 0.58, 1],
    );

    canvas.drawPath(
      fillPath,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = gradient.createShader(Offset.zero & size),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = AppColors.orbBlueDeep
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (showEndMarker) {
      final endPoint = points.last;
      final pulseRadius = 10 + markerPulseValue * 8;
      final pulseAlpha = 0.22 * (1 - markerPulseValue);
      final coreRadius = 5 + markerPulseValue * 0.9;

      canvas.drawCircle(
        endPoint,
        pulseRadius,
        Paint()..color = AppColors.orbBlueDeep.withValues(alpha: pulseAlpha),
      );
      canvas.drawCircle(endPoint, 7, Paint()..color = Colors.white);
      canvas.drawCircle(
        endPoint,
        coreRadius,
        Paint()..color = AppColors.orbBlueDeep,
      );
    }
  }

  Path _buildSmoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final midX = (current.dx + next.dx) / 2;
      path.cubicTo(midX, current.dy, midX, next.dy, next.dx, next.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _InvestingChartPainter oldDelegate) {
    if (showEndMarker != oldDelegate.showEndMarker) {
      return true;
    }
    if (markerPulseValue != oldDelegate.markerPulseValue) {
      return true;
    }
    if (values.length != oldDelegate.values.length) {
      return true;
    }
    for (var i = 0; i < values.length; i++) {
      if (values[i] != oldDelegate.values[i]) {
        return true;
      }
    }
    return false;
  }
}
