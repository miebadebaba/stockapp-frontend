import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_palette.dart';
import '../../../core/widgets/chart_primitives.dart';

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
    this.chartMode = ChartDisplayMode.line,
    this.candlestickData,
    this.contentHorizontalPadding = _defaultSectionHorizontalPadding,
    this.cardVerticalPadding = _defaultCardVerticalPadding,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.amountStyle,
    this.changeTextStyle,
    this.changeLabelStyle,
    this.rangeSelectorHeight = _defaultRangeSelectorHeight,
    this.rangeLabelFontSize = 16,
    this.rangeControlSpacing = AppSpacing.md,
    this.useScrollableRangeButtons = false,
    this.rangeButtonHorizontalPadding = 14,
    this.minRangeButtonWidth = 0,
    this.enableSelectionDetails = false,
    this.onRangeChanged,
    this.onBadgeTap,
    this.onSettingsTap,
    super.key,
  });

  static const _defaultSectionHorizontalPadding = 16.0;
  static const _defaultCardVerticalPadding = 26.0;
  static const _defaultRangeSelectorHeight = 50.0;

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
  final ChartDisplayMode chartMode;
  final Map<String, List<ChartCandleData>>? candlestickData;
  final double contentHorizontalPadding;
  final double cardVerticalPadding;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? amountStyle;
  final TextStyle? changeTextStyle;
  final TextStyle? changeLabelStyle;
  final double rangeSelectorHeight;
  final double rangeLabelFontSize;
  final double rangeControlSpacing;
  final bool useScrollableRangeButtons;
  final double rangeButtonHorizontalPadding;
  final double minRangeButtonWidth;
  final bool enableSelectionDetails;
  final ValueChanged<String>? onRangeChanged;
  final VoidCallback? onBadgeTap;
  final VoidCallback? onSettingsTap;

  @override
  State<InvestingChartCard> createState() => _InvestingChartCardState();
}

class _InvestingChartCardState extends State<InvestingChartCard>
    with SingleTickerProviderStateMixin {
  static const _selectionDuration = Duration(milliseconds: 260);

  late final List<String> _ranges;
  late String _selectedRange;
  late List<double> _fromSeries;
  late List<double> _toSeries;
  late final AnimationController _markerPulseController;
  int? _selectedChartIndex;

  @override
  void initState() {
    super.initState();
    _markerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _syncMarkerPulse();

    final activeRangeSource = _activeRangeSource();
    if (activeRangeSource.isEmpty) {
      _ranges = <String>[];
      _selectedRange = widget.initialRange;
      _fromSeries = <double>[];
      _toSeries = <double>[];
      _selectedChartIndex = null;
      return;
    }

    _ranges = activeRangeSource.keys.toList();
    _selectedRange = _ranges.contains(widget.initialRange)
        ? widget.initialRange
        : _ranges.first;
    _fromSeries = List<double>.from(
      widget.mockData[_selectedRange] ?? const <double>[],
    );
    _toSeries = List<double>.from(
      widget.mockData[_selectedRange] ?? const <double>[],
    );
    _selectedChartIndex = null;
  }

  Map<String, Object> _activeRangeSource() {
    if (widget.chartMode == ChartDisplayMode.candles &&
        widget.candlestickData != null &&
        widget.candlestickData!.isNotEmpty) {
      return widget.candlestickData!;
    }
    return widget.mockData;
  }

  @override
  void didUpdateWidget(covariant InvestingChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMarkerPulse();
    final newRanges = _activeRangeSource().keys.toList();
    final rangesChanged = newRanges.join('|') != _ranges.join('|');
    final lineDataChanged = !_deepEquals(widget.mockData, oldWidget.mockData);
    final candleDataChanged = !_deepCandleEquals(
      widget.candlestickData ?? const <String, List<ChartCandleData>>{},
      oldWidget.candlestickData ?? const <String, List<ChartCandleData>>{},
    );

    if (!rangesChanged && !lineDataChanged && !candleDataChanged) {
      return;
    }

    _ranges
      ..clear()
      ..addAll(newRanges);

    if (!_ranges.contains(_selectedRange)) {
      _selectedRange = _ranges.isNotEmpty ? _ranges.first : widget.initialRange;
      widget.onRangeChanged?.call(_selectedRange);
    }

    final nextSeries = widget.mockData[_selectedRange] ?? const <double>[];
    _fromSeries = List<double>.from(nextSeries);
    _toSeries = List<double>.from(nextSeries);
    _selectedChartIndex = null;
  }

  void _syncMarkerPulse() {
    final shouldAnimateMarker =
        widget.showEndMarker && widget.chartMode == ChartDisplayMode.line;
    if (shouldAnimateMarker) {
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

  bool _deepCandleEquals(
    Map<String, List<ChartCandleData>> current,
    Map<String, List<ChartCandleData>> previous,
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
        final candle = entry.value[i];
        final prior = other[i];
        if (candle.open != prior.open ||
            candle.high != prior.high ||
            candle.low != prior.low ||
            candle.close != prior.close) {
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
    if ((widget.chartMode == ChartDisplayMode.line) &&
        (nextSeries == null || nextSeries.isEmpty)) {
      return;
    }

    setState(() {
      _fromSeries = List<double>.from(_toSeries);
      _toSeries = List<double>.from(nextSeries ?? const <double>[]);
      _selectedRange = range;
      _selectedChartIndex = null;
    });
    widget.onRangeChanged?.call(range);
  }

  void _setSelectedChartIndex(int? index) {
    if (_selectedChartIndex == index) {
      return;
    }

    setState(() {
      _selectedChartIndex = index;
    });
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

  _ChartSelectionData _lineSelectionData(List<double> values, int index) {
    return _ChartSelectionData(
      headline: _labelForSelection(index, values.length),
      metrics: [
        _ChartSelectionMetric(
          label: 'Close',
          value: _formatPrice(values[index]),
        ),
      ],
    );
  }

  _ChartSelectionData _candleSelectionData(
    List<ChartCandleData> candles,
    int index,
  ) {
    final candle = candles[index];
    return _ChartSelectionData(
      headline: _labelForSelection(index, candles.length),
      metrics: [
        _ChartSelectionMetric(label: 'Open', value: _formatPrice(candle.open)),
        _ChartSelectionMetric(label: 'High', value: _formatPrice(candle.high)),
        _ChartSelectionMetric(label: 'Low', value: _formatPrice(candle.low)),
        _ChartSelectionMetric(
          label: 'Close',
          value: _formatPrice(candle.close),
        ),
      ],
    );
  }

  String _labelForSelection(int index, int count) {
    final progress = count <= 1 ? 0.0 : index / (count - 1);
    final now = DateTime(2026, 7, 27);

    switch (_selectedRange) {
      case '1D':
        final minutesOffset = (390 * progress).round();
        final labelTime = DateTime(
          now.year,
          now.month,
          now.day,
          9,
          30,
        ).add(Duration(minutes: minutesOffset));
        return '${_twoDigits(labelTime.hour)}:${_twoDigits(labelTime.minute)}';
      case '1W':
        final start = now.subtract(const Duration(days: 4));
        final labelDate = start.add(Duration(days: (4 * progress).round()));
        return '${_twoDigits(labelDate.month)}/${_twoDigits(labelDate.day)}';
      case '1M':
        final start = now.subtract(const Duration(days: 29));
        final labelDate = start.add(Duration(days: (29 * progress).round()));
        return '${_twoDigits(labelDate.month)}/${_twoDigits(labelDate.day)}';
      case '3M':
        final start = now.subtract(const Duration(days: 89));
        final labelDate = start.add(Duration(days: (89 * progress).round()));
        return '${_twoDigits(labelDate.month)}/${_twoDigits(labelDate.day)}';
      case 'YTD':
        final start = DateTime(now.year, 1, 1);
        final daySpan = now.difference(start).inDays;
        final labelDate = start.add(Duration(days: (daySpan * progress).round()));
        return '${_twoDigits(labelDate.month)}/${_twoDigits(labelDate.day)}';
      case '1Y':
        final start = DateTime(now.year - 1, now.month, now.day);
        final labelDate = start.add(Duration(days: (365 * progress).round()));
        return '${_twoDigits(labelDate.month)}/${_twoDigits(labelDate.day)}';
      default:
        return 'Point ${index + 1}';
    }
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _formatPrice(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  _ChartSelectionData? _activeSelectionData({
    required List<double> values,
    required List<ChartCandleData> candles,
  }) {
    final index = _selectedChartIndex;
    if (!widget.enableSelectionDetails || index == null) {
      return null;
    }

    if (widget.chartMode == ChartDisplayMode.candles && candles.isNotEmpty) {
      final clampedIndex = index.clamp(0, candles.length - 1) as int;
      return _candleSelectionData(candles, clampedIndex);
    }

    if (values.isEmpty) {
      return null;
    }

    final clampedIndex = index.clamp(0, values.length - 1) as int;
    return _lineSelectionData(values, clampedIndex);
  }

  @override
  void dispose() {
    _markerPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;
    final isDark = theme.brightness == Brightness.dark;
    final changeColor = widget.isPositiveChange
        ? const Color(0xFFE3515A)
        : const Color(0xFF2C9D69);
    final chartColor = isDark ? const Color(0xFF8CCBFF) : AppColors.orbBlueDeep;
    final gridColor = isDark
        ? Colors.white.withValues(alpha: 0.30)
        : AppColors.outlineSoft;
    final currentValues = widget.mockData[_selectedRange] ?? const <double>[];
    final currentCandles =
        widget.candlestickData?[_selectedRange] ?? const <ChartCandleData>[];
    final activeSelectionData = _activeSelectionData(
      values: currentValues,
      candles: currentCandles,
    );

    return Container(
      decoration: BoxDecoration(
        color: palette.pageBackground,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: EdgeInsets.symmetric(vertical: widget.cardVerticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.contentHorizontalPadding,
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
                        style:
                            widget.titleStyle ??
                            theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 32,
                              height: 1.1,
                            ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle!,
                          style:
                              widget.subtitleStyle ??
                              theme.textTheme.bodyMedium?.copyWith(
                                color: palette.secondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
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
                            style:
                                widget.amountStyle ??
                                theme.textTheme.headlineLarge?.copyWith(
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
                                style:
                                    widget.changeTextStyle ??
                                    theme.textTheme.bodyMedium?.copyWith(
                                      color: changeColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                          Text(
                            widget.changeLabel,
                            style:
                                widget.changeLabelStyle ??
                                theme.textTheme.bodyMedium?.copyWith(
                                  color: palette.secondaryText,
                                  fontSize: 16,
                                ),
                          ),
                        ],
                      ),
                      if (activeSelectionData != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _InlineChartSelectionPanel(data: activeSelectionData),
                      ],
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
            child: widget.chartMode == ChartDisplayMode.candles &&
                    currentCandles.isNotEmpty
                ? _InteractiveCandlestickChart(
                    candles: currentCandles,
                    gainColor: const Color(0xFFE3515A),
                    lossColor: const Color(0xFF2C9D69),
                    gridColor: gridColor,
                    selectedIndex: _selectedChartIndex,
                    enableSelectionDetails: widget.enableSelectionDetails,
                    selectionDataBuilder: (index) {
                      return _candleSelectionData(currentCandles, index);
                    },
                    onSelectionChanged: _setSelectedChartIndex,
                  )
                : TweenAnimationBuilder<double>(
                    key: ValueKey(_selectedRange),
                    tween: Tween(begin: 0, end: 1),
                    duration: _selectionDuration,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      final currentValues = _interpolatedSeries(value);

                      if (!widget.showEndMarker) {
                        return _InteractiveLineChart(
                          values: currentValues,
                          showEndMarker: false,
                          markerPulseValue: 0,
                          lineColor: chartColor,
                          gridColor: gridColor,
                          selectedIndex: _selectedChartIndex,
                          enableSelectionDetails: widget.enableSelectionDetails,
                          selectionDataBuilder: (index) {
                            return _lineSelectionData(currentValues, index);
                          },
                          onSelectionChanged: _setSelectedChartIndex,
                        );
                      }

                      return AnimatedBuilder(
                        animation: _markerPulseController,
                        builder: (context, child) {
                          return _InteractiveLineChart(
                            values: currentValues,
                            showEndMarker: widget.showEndMarker,
                            markerPulseValue: _markerPulseController.value,
                            lineColor: chartColor,
                            gridColor: gridColor,
                            selectedIndex: _selectedChartIndex,
                            enableSelectionDetails: widget.enableSelectionDetails,
                            selectionDataBuilder: (index) {
                              return _lineSelectionData(currentValues, index);
                            },
                            onSelectionChanged: _setSelectedChartIndex,
                          );
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.contentHorizontalPadding,
            ),
            child: _RangeSelector(
              ranges: _ranges,
              selectedRange: _selectedRange,
              onSelected: _selectRange,
              onSettingsTap: widget.onSettingsTap,
              selectorHeight: widget.rangeSelectorHeight,
              labelFontSize: widget.rangeLabelFontSize,
              controlSpacing: widget.rangeControlSpacing,
              useScrollableRangeButtons: widget.useScrollableRangeButtons,
              rangeButtonHorizontalPadding: widget.rangeButtonHorizontalPadding,
              minRangeButtonWidth: widget.minRangeButtonWidth,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineChartSelectionPanel extends StatelessWidget {
  const _InlineChartSelectionPanel({required this.data});

  final _ChartSelectionData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.groupBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.headline,
            style: theme.textTheme.labelMedium?.copyWith(
              color: palette.secondaryText,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: [
              for (final metric in data.metrics)
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${metric.label} ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.secondaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: metric.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: palette.primaryText,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeBackground = isDark
        ? const Color(0xFF4B3910)
        : const Color(0xFFF7ECCE);
    final badgeForeground = isDark
        ? const Color(0xFFFFE08A)
        : AppColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: badgeBackground,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 16, color: badgeForeground),
              const SizedBox(width: 6),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: badgeForeground,
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
    required this.selectorHeight,
    required this.labelFontSize,
    required this.controlSpacing,
    required this.useScrollableRangeButtons,
    required this.rangeButtonHorizontalPadding,
    required this.minRangeButtonWidth,
    this.onSettingsTap,
  });

  final List<String> ranges;
  final String selectedRange;
  final ValueChanged<String> onSelected;
  final double selectorHeight;
  final double labelFontSize;
  final double controlSpacing;
  final bool useScrollableRangeButtons;
  final double rangeButtonHorizontalPadding;
  final double minRangeButtonWidth;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    if (ranges.isEmpty) {
      return const SizedBox.shrink();
    }

    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedIndex = ranges.contains(selectedRange)
        ? ranges.indexOf(selectedRange)
        : 0;

    return Row(
      children: [
        Expanded(
          child: useScrollableRangeButtons
              ? SizedBox(
                  height: selectorHeight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        for (var i = 0; i < ranges.length; i++) ...[
                          _RangeChip(
                            label: ranges[i],
                            selected: i == selectedIndex,
                            height: selectorHeight,
                            labelFontSize: labelFontSize,
                            minWidth: minRangeButtonWidth,
                            horizontalPadding: rangeButtonHorizontalPadding,
                            onTap: () => onSelected(ranges[i]),
                          ),
                          if (i != ranges.length - 1)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: selectorHeight,
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
                            height: selectorHeight,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.orbBlueDeep,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              for (var i = 0; i < ranges.length; i++) ...[
                                SizedBox(
                                  width: segmentWidth,
                                  height: selectorHeight,
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
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      style:
                                          Theme.of(context).textTheme.bodyMedium
                                              ?.copyWith(
                                                fontSize: labelFontSize,
                                                color: i == selectedIndex
                                                    ? Colors.white
                                                    : palette.secondaryText,
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
        SizedBox(width: controlSpacing),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSettingsTap,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Ink(
              width: selectorHeight,
              height: selectorHeight,
              decoration: BoxDecoration(
                color: isDark
                    ? palette.groupBackground
                    : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: palette.primaryText,
                size: selectorHeight * 0.48,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.height,
    required this.labelFontSize,
    required this.minWidth,
    required this.horizontalPadding,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double height;
  final double labelFontSize;
  final double minWidth;
  final double horizontalPadding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(
            minWidth: minWidth > 0 ? minWidth : 0,
            minHeight: height,
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: selected ? AppColors.orbBlueDeep : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            softWrap: false,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: labelFontSize,
                  color: selected ? Colors.white : palette.secondaryText,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _InteractiveLineChart extends StatelessWidget {
  const _InteractiveLineChart({
    required this.values,
    required this.showEndMarker,
    required this.markerPulseValue,
    required this.lineColor,
    required this.gridColor,
    required this.enableSelectionDetails,
    required this.selectionDataBuilder,
    required this.onSelectionChanged,
    this.selectedIndex,
  });

  final List<double> values;
  final bool showEndMarker;
  final double markerPulseValue;
  final Color lineColor;
  final Color gridColor;
  final bool enableSelectionDetails;
  final int? selectedIndex;
  final _ChartSelectionData Function(int index) selectionDataBuilder;
  final ValueChanged<int?> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final geometry = _LineChartGeometry.fromValues(values, size);
        final activeIndex = _effectiveSelectedIndex(selectedIndex, values.length);
        final selectedPoint = activeIndex == null
            ? null
            : geometry.pointForIndex(activeIndex);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enableSelectionDetails
              ? (details) => onSelectionChanged(
                    _resolveIndex(details.localPosition.dx, values.length, size),
                  )
              : null,
          onHorizontalDragStart: enableSelectionDetails
              ? (details) => onSelectionChanged(
                    _resolveIndex(details.localPosition.dx, values.length, size),
                  )
              : null,
          onHorizontalDragUpdate: enableSelectionDetails
              ? (details) => onSelectionChanged(
                    _resolveIndex(details.localPosition.dx, values.length, size),
                  )
              : null,
          onDoubleTap: enableSelectionDetails
              ? () => onSelectionChanged(null)
              : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  size: size,
                  painter: _InvestingChartPainter(
                    values: values,
                    showEndMarker: showEndMarker,
                    markerPulseValue: markerPulseValue,
                    lineColor: lineColor,
                    gridColor: gridColor,
                  ),
                ),
              ),
              if (enableSelectionDetails &&
                  activeIndex != null &&
                  selectedPoint != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _LineChartSelectionPainter(
                        point: selectedPoint,
                        lineColor: lineColor,
                        gridColor: gridColor,
                      ),
                    ),
                  ),
                ),
              if (enableSelectionDetails &&
                  activeIndex != null &&
                  selectedPoint != null)
                _ChartSelectionTooltip(
                  point: selectedPoint,
                  chartSize: size,
                  data: selectionDataBuilder(activeIndex),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InteractiveCandlestickChart extends StatelessWidget {
  const _InteractiveCandlestickChart({
    required this.candles,
    required this.gainColor,
    required this.lossColor,
    required this.gridColor,
    required this.enableSelectionDetails,
    required this.selectionDataBuilder,
    required this.onSelectionChanged,
    this.selectedIndex,
  });

  final List<ChartCandleData> candles;
  final Color gainColor;
  final Color lossColor;
  final Color gridColor;
  final bool enableSelectionDetails;
  final int? selectedIndex;
  final _ChartSelectionData Function(int index) selectionDataBuilder;
  final ValueChanged<int?> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final geometry = _CandlestickChartGeometry.fromCandles(candles, size);
        final activeIndex =
            _effectiveSelectedIndex(selectedIndex, candles.length);
        final selectedPoint = activeIndex == null
            ? null
            : geometry.anchorPointForIndex(activeIndex);
        final selectedCandle =
            activeIndex == null ? null : candles[activeIndex];

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enableSelectionDetails
              ? (details) => onSelectionChanged(
                    _resolveIndex(
                      details.localPosition.dx,
                      candles.length,
                      size,
                    ),
                  )
              : null,
          onHorizontalDragStart: enableSelectionDetails
              ? (details) => onSelectionChanged(
                    _resolveIndex(
                      details.localPosition.dx,
                      candles.length,
                      size,
                    ),
                  )
              : null,
          onHorizontalDragUpdate: enableSelectionDetails
              ? (details) => onSelectionChanged(
                    _resolveIndex(
                      details.localPosition.dx,
                      candles.length,
                      size,
                    ),
                  )
              : null,
          onDoubleTap: enableSelectionDetails
              ? () => onSelectionChanged(null)
              : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  size: size,
                  painter: _CandlestickChartPainter(
                    candles: candles,
                    gainColor: gainColor,
                    lossColor: lossColor,
                    gridColor: gridColor,
                  ),
                ),
              ),
              if (enableSelectionDetails &&
                  activeIndex != null &&
                  selectedPoint != null &&
                  selectedCandle != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _CandlestickSelectionPainter(
                        x: selectedPoint.dx,
                        highY: geometry.yForValue(selectedCandle.high),
                        lowY: geometry.yForValue(selectedCandle.low),
                        color: selectedCandle.close >= selectedCandle.open
                            ? gainColor
                            : lossColor,
                        gridColor: gridColor,
                      ),
                    ),
                  ),
                ),
              if (enableSelectionDetails &&
                  activeIndex != null &&
                  selectedPoint != null)
                _ChartSelectionTooltip(
                  point: selectedPoint,
                  chartSize: size,
                  data: selectionDataBuilder(activeIndex),
                ),
            ],
          ),
        );
      },
    );
  }
}

int? _effectiveSelectedIndex(int? index, int itemCount) {
  if (index == null || itemCount <= 0) {
    return null;
  }
  return index.clamp(0, itemCount - 1) as int;
}

int? _resolveIndex(double dx, int itemCount, Size size) {
  if (itemCount <= 0 || size.width <= 0) {
    return null;
  }

  final clampedX = dx.clamp(0.0, size.width).toDouble();
  final progress = itemCount == 1 ? 0.0 : clampedX / size.width;
  return (progress * (itemCount - 1)).round();
}

class _ChartSelectionTooltip extends StatelessWidget {
  const _ChartSelectionTooltip({
    required this.point,
    required this.chartSize,
    required this.data,
  });

  final Offset point;
  final Size chartSize;
  final _ChartSelectionData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;
    const tooltipWidth = 164.0;

    final left = (point.dx - tooltipWidth / 2).clamp(
      8.0,
      math.max(8.0, chartSize.width - tooltipWidth - 8.0),
    ).toDouble();
    final showBelow = point.dy < 92;
    final top = showBelow
        ? point.dy + 14
        : math.max(8.0, point.dy - 104);

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.groupBackground,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.headline,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: palette.secondaryText,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < data.metrics.length; i++) ...[
                  Row(
                    children: [
                      Text(
                        data.metrics[i].label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.secondaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        data.metrics[i].value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: palette.primaryText,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  if (i != data.metrics.length - 1)
                    const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartSelectionData {
  const _ChartSelectionData({
    required this.headline,
    required this.metrics,
  });

  final String headline;
  final List<_ChartSelectionMetric> metrics;
}

class _ChartSelectionMetric {
  const _ChartSelectionMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _LineChartGeometry {
  const _LineChartGeometry({
    required this.points,
  });

  static const leftPadding = 0.0;
  static const rightPadding = 0.0;
  static const topPadding = 12.0;
  static const bottomPadding = 10.0;

  final List<Offset> points;

  factory _LineChartGeometry.fromValues(List<double> values, Size size) {
    if (values.isEmpty) {
      return const _LineChartGeometry(points: <Offset>[]);
    }

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final valueSpan = math.max(maxValue - minValue, 1.0);
    final usableWidth = size.width - leftPadding - rightPadding;
    final usableHeight = size.height - topPadding - bottomPadding;

    final points = List<Offset>.generate(values.length, (index) {
      final x = leftPadding + usableWidth * index / math.max(values.length - 1, 1);
      final normalized = (values[index] - minValue) / valueSpan;
      final y = size.height - bottomPadding - normalized * usableHeight;
      return Offset(x, y);
    });

    return _LineChartGeometry(points: points);
  }

  Offset? pointForIndex(int index) {
    if (points.isEmpty) {
      return null;
    }
    return points[index.clamp(0, points.length - 1) as int];
  }
}

class _CandlestickChartGeometry {
  const _CandlestickChartGeometry({
    required this.candles,
    required this.size,
    required this.minValue,
    required this.valueSpan,
  });

  static const topPadding = 12.0;
  static const bottomPadding = 10.0;

  final List<ChartCandleData> candles;
  final Size size;
  final double minValue;
  final double valueSpan;

  factory _CandlestickChartGeometry.fromCandles(
    List<ChartCandleData> candles,
    Size size,
  ) {
    if (candles.isEmpty) {
      return _CandlestickChartGeometry(
        candles: candles,
        size: size,
        minValue: 0,
        valueSpan: 1,
      );
    }

    final minValue = candles.map((item) => item.low).reduce(math.min);
    final maxValue = candles.map((item) => item.high).reduce(math.max);
    final valueSpan = math.max(maxValue - minValue, 1.0).toDouble();

    return _CandlestickChartGeometry(
      candles: candles,
      size: size,
      minValue: minValue,
      valueSpan: valueSpan,
    );
  }

  Offset? anchorPointForIndex(int index) {
    if (candles.isEmpty) {
      return null;
    }

    final clampedIndex = index.clamp(0, candles.length - 1) as int;
    final centerX = size.width / candles.length * clampedIndex + size.width / candles.length / 2;
    final closeY = yForValue(candles[clampedIndex].close);
    return Offset(centerX, closeY);
  }

  double yForValue(double value) {
    final usableHeight = size.height - topPadding - bottomPadding;
    final normalized = (value - minValue) / valueSpan;
    return size.height - bottomPadding - normalized * usableHeight;
  }
}

class _LineChartSelectionPainter extends CustomPainter {
  const _LineChartSelectionPainter({
    required this.point,
    required this.lineColor,
    required this.gridColor,
  });

  final Offset point;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = gridColor.withValues(alpha: 0.9)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(point.dx, 0), Offset(point.dx, size.height), linePaint);

    canvas.drawCircle(
      point,
      11,
      Paint()..color = lineColor.withValues(alpha: 0.16),
    );
    canvas.drawCircle(point, 6, Paint()..color = Colors.white);
    canvas.drawCircle(point, 4, Paint()..color = lineColor);
  }

  @override
  bool shouldRepaint(covariant _LineChartSelectionPainter oldDelegate) {
    return oldDelegate.point != point ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _CandlestickSelectionPainter extends CustomPainter {
  const _CandlestickSelectionPainter({
    required this.x,
    required this.highY,
    required this.lowY,
    required this.color,
    required this.gridColor,
  });

  final double x;
  final double highY;
  final double lowY;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = gridColor.withValues(alpha: 0.9)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), guidePaint);

    canvas.drawCircle(
      Offset(x, lowY),
      11,
      Paint()..color = color.withValues(alpha: 0.14),
    );
    canvas.drawLine(
      Offset(x, highY),
      Offset(x, lowY),
      Paint()
        ..color = color
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CandlestickSelectionPainter oldDelegate) {
    return oldDelegate.x != x ||
        oldDelegate.highY != highY ||
        oldDelegate.lowY != lowY ||
        oldDelegate.color != color ||
        oldDelegate.gridColor != gridColor;
  }
}

class _InvestingChartPainter extends CustomPainter {
  const _InvestingChartPainter({
    required this.values,
    required this.showEndMarker,
    required this.markerPulseValue,
    required this.lineColor,
    required this.gridColor,
  });

  final List<double> values;
  final bool showEndMarker;
  final double markerPulseValue;
  final Color lineColor;
  final Color gridColor;

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

    _drawGrid(canvas, size);

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withValues(alpha: 0.26),
        lineColor.withValues(alpha: 0.04),
        lineColor.withValues(alpha: 0.0),
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
        ..color = lineColor
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
        Paint()..color = lineColor.withValues(alpha: pulseAlpha),
      );
      canvas.drawCircle(endPoint, 7, Paint()..color = Colors.white);
      canvas.drawCircle(endPoint, coreRadius, Paint()..color = lineColor);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    const rows = 3;
    const columns = 4;
    final paint = Paint()
      ..strokeWidth = 1.1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gridColor.withValues(alpha: 0.0),
          gridColor.withValues(alpha: 0.72),
          gridColor.withValues(alpha: 0.72),
          gridColor.withValues(alpha: 0.0),
        ],
        stops: const [0, 0.14, 0.86, 1],
      ).createShader(Offset.zero & size);

    for (var i = 1; i <= rows; i++) {
      final y = size.height * i / (rows + 1);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (var i = 1; i <= columns; i++) {
      final x = size.width * i / (columns + 1);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
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
    if (showEndMarker != oldDelegate.showEndMarker ||
        markerPulseValue != oldDelegate.markerPulseValue ||
        lineColor != oldDelegate.lineColor ||
        gridColor != oldDelegate.gridColor ||
        values.length != oldDelegate.values.length) {
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

class _CandlestickChartPainter extends CustomPainter {
  const _CandlestickChartPainter({
    required this.candles,
    required this.gainColor,
    required this.lossColor,
    required this.gridColor,
  });

  final List<ChartCandleData> candles;
  final Color gainColor;
  final Color lossColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) {
      return;
    }

    final double minValue =
        candles.map((item) => item.low).reduce(math.min);
    final double maxValue =
        candles.map((item) => item.high).reduce(math.max);
    final double valueSpan = math.max(maxValue - minValue, 1).toDouble();
    const topPadding = 12.0;
    const bottomPadding = 10.0;
    final usableHeight = size.height - topPadding - bottomPadding;
    final slotWidth = size.width / candles.length;
    final double bodyWidth =
        math.max(4.0, math.min(slotWidth * 0.58, 14.0)).toDouble();

    _drawGrid(canvas, size);

    for (var i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final centerX = slotWidth * i + slotWidth / 2;
      final openY = _mapValueToY(
        candle.open,
        minValue,
        valueSpan,
        size.height,
        topPadding,
        bottomPadding,
        usableHeight,
      );
      final closeY = _mapValueToY(
        candle.close,
        minValue,
        valueSpan,
        size.height,
        topPadding,
        bottomPadding,
        usableHeight,
      );
      final highY = _mapValueToY(
        candle.high,
        minValue,
        valueSpan,
        size.height,
        topPadding,
        bottomPadding,
        usableHeight,
      );
      final lowY = _mapValueToY(
        candle.low,
        minValue,
        valueSpan,
        size.height,
        topPadding,
        bottomPadding,
        usableHeight,
      );

      final isGain = candle.close >= candle.open;
      final color = isGain ? gainColor : lossColor;
      final double bodyTop = math.min(openY, closeY);
      final double bodyBottom = math.max(openY, closeY);
      final double bodyHeight =
          math.max(bodyBottom - bodyTop, 2.0).toDouble();

      final wickPaint = Paint()
        ..color = color
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      final bodyPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawLine(
        Offset(centerX, highY),
        Offset(centerX, lowY),
        wickPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(centerX, bodyTop + bodyHeight / 2),
            width: bodyWidth,
            height: bodyHeight,
          ),
          const Radius.circular(3),
        ),
        bodyPaint,
      );
    }
  }

  double _mapValueToY(
    double value,
    double minValue,
    double valueSpan,
    double height,
    double topPadding,
    double bottomPadding,
    double usableHeight,
  ) {
    final normalized = (value - minValue) / valueSpan;
    return height - bottomPadding - normalized * usableHeight;
  }

  void _drawGrid(Canvas canvas, Size size) {
    const rows = 3;
    const columns = 4;
    final paint = Paint()
      ..strokeWidth = 1.1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gridColor.withValues(alpha: 0.0),
          gridColor.withValues(alpha: 0.72),
          gridColor.withValues(alpha: 0.72),
          gridColor.withValues(alpha: 0.0),
        ],
        stops: const [0, 0.14, 0.86, 1],
      ).createShader(Offset.zero & size);

    for (var i = 1; i <= rows; i++) {
      final y = size.height * i / (rows + 1);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (var i = 1; i <= columns; i++) {
      final x = size.width * i / (columns + 1);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickChartPainter oldDelegate) {
    if (gainColor != oldDelegate.gainColor ||
        lossColor != oldDelegate.lossColor ||
        gridColor != oldDelegate.gridColor ||
        candles.length != oldDelegate.candles.length) {
      return true;
    }

    for (var i = 0; i < candles.length; i++) {
      final current = candles[i];
      final previous = oldDelegate.candles[i];
      if (current.open != previous.open ||
          current.high != previous.high ||
          current.low != previous.low ||
          current.close != previous.close) {
        return true;
      }
    }
    return false;
  }
}
