import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_palette.dart';

class MarketSnapshotItemData {
  const MarketSnapshotItemData({
    required this.id,
    required this.assetName,
    required this.valueText,
    required this.changePercent,
    required this.sparklineValues,
  });

  final String id;
  final String assetName;
  final String valueText;
  final double changePercent;
  final List<double> sparklineValues;

  factory MarketSnapshotItemData.fromBackendJson(Map<String, dynamic> json) {
    final sparklineJson = json['sparkline_values'];
    final sparklineValues = sparklineJson is List
        ? sparklineJson
              .whereType<num>()
              .map((value) => value.toDouble())
              .toList()
        : const <double>[];

    return MarketSnapshotItemData(
      id: json['id'] as String? ?? '',
      assetName:
          json['display_name'] as String? ??
          json['symbol'] as String? ??
          '',
      valueText: json['value_text'] as String? ?? '--',
      changePercent: (json['change_percent'] as num?)?.toDouble() ?? 0,
      sparklineValues: sparklineValues,
    );
  }
}

class MarketSnapshotSection extends StatelessWidget {
  const MarketSnapshotSection({
    required this.titleText,
    required this.assets,
    this.onTitleTap,
    this.onAssetTap,
    super.key,
  });

  final String titleText;
  final List<MarketSnapshotItemData> assets;
  final VoidCallback? onTitleTap;
  final ValueChanged<String>? onAssetTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: onTitleTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titleText,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 30,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: palette.primaryText,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.builder(
          itemCount: assets.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 142,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
          ),
          itemBuilder: (context, index) {
            final asset = assets[index];
            final isLeftColumn = index.isEven;
            final isLastRow =
                index >= assets.length - (assets.length % 2 == 0 ? 2 : 1);
            return _MarketSnapshotCard(
              item: asset,
              isLeftColumn: isLeftColumn,
              isLastRow: isLastRow,
              onTap: onAssetTap == null ? null : () => onAssetTap!(asset.id),
            );
          },
        ),
      ],
    );
  }
}

class _MarketSnapshotCard extends StatelessWidget {
  const _MarketSnapshotCard({
    required this.item,
    required this.isLeftColumn,
    required this.isLastRow,
    this.onTap,
  });

  final MarketSnapshotItemData item;
  final bool isLeftColumn;
  final bool isLastRow;
  final VoidCallback? onTap;

  Color _trendColor() {
    return item.changePercent >= 0
        ? const Color(0xFFE3515A)
        : const Color(0xFF2C9D69);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;
    final trendColor = _trendColor();
    final borderColor = palette.divider.withValues(alpha: 0.72);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: palette.rowPressedOverlay,
        highlightColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: palette.pageBackground,
            border: Border(
              right: isLeftColumn
                  ? BorderSide(color: borderColor, width: 1)
                  : BorderSide.none,
              bottom: isLastRow
                  ? BorderSide.none
                  : BorderSide(color: borderColor, width: 1),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.assetName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: palette.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                item.valueText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: palette.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Row(
                children: [
                  Icon(
                    item.changePercent >= 0
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 16,
                    color: trendColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.changePercent >= 0 ? '+' : ''}${item.changePercent.toStringAsFixed(2)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: trendColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 66,
                    height: 26,
                    child: CustomPaint(
                      painter: _MarketSparklinePainter(
                        values: item.sparklineValues,
                        lineColor: trendColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketSparklinePainter extends CustomPainter {
  const _MarketSparklinePainter({
    required this.values,
    required this.lineColor,
  });

  final List<double> values;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final span = math.max(maxValue - minValue, 1);
    final width = size.width;
    final height = size.height;

    final points = List<Offset>.generate(values.length, (index) {
      final x = width * index / math.max(values.length - 1, 1);
      final normalized = (values[index] - minValue) / span;
      final y = height - normalized * height;
      return Offset(x, y);
    });

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final midX = (current.dx + next.dx) / 2;
      path.cubicTo(midX, current.dy, midX, next.dy, next.dx, next.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = lineColor,
    );
  }

  @override
  bool shouldRepaint(covariant _MarketSparklinePainter oldDelegate) {
    if (lineColor != oldDelegate.lineColor) {
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
