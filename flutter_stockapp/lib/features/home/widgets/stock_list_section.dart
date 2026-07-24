import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_palette.dart';

class StockListItemData {
  const StockListItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priceText,
    required this.changePercent,
    required this.referenceValue,
    required this.sparklineValues,
  });

  final String id;
  final String title;
  final String subtitle;
  final String priceText;
  final double changePercent;
  final double referenceValue;
  final List<double> sparklineValues;
}

class StockListSection extends StatelessWidget {
  const StockListSection({
    required this.titleText,
    required this.stocks,
    this.onTitleTap,
    this.onStockTap,
    super.key,
  });

  final String titleText;
  final List<StockListItemData> stocks;
  final VoidCallback? onTitleTap;
  final ValueChanged<String>? onStockTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = Theme.of(context).extension<AppThemePalette>()!;

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
        ListView.separated(
          itemCount: stocks.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final stock = stocks[index];
            return _StockListTile(
              stock: stock,
              onTap: onStockTap == null ? null : () => onStockTap!(stock.id),
            );
          },
          separatorBuilder: (context, index) {
            return Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              color: palette.divider,
            );
          },
        ),
      ],
    );
  }
}

class _StockListTile extends StatelessWidget {
  const _StockListTile({required this.stock, this.onTap});

  final StockListItemData stock;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isPositive = stock.changePercent >= 0;
    final trendColor = isPositive
        ? const Color(0xFFDE7557)
        : const Color(0xFF2D9B68);
    final sign = isPositive ? '+' : '';
    final percentLabel = '$sign${stock.changePercent.toStringAsFixed(2)}%';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        splashColor: palette.rowPressedOverlay,
        highlightColor: Colors.transparent,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: palette.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      stock.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: palette.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                flex: 8,
                child: RepaintBoundary(
                  child: SizedBox(
                    height: 68,
                    child: CustomPaint(
                      painter: _StockTrendChartPainter(
                        values: stock.sparklineValues,
                        referenceValue: stock.referenceValue,
                        trendColor: trendColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              SizedBox(
                width: 94,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stock.priceText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: palette.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: trendColor,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        percentLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockTrendChartPainter extends CustomPainter {
  const _StockTrendChartPainter({
    required this.values,
    required this.referenceValue,
    required this.trendColor,
  });

  final List<double> values;
  final double referenceValue;
  final Color trendColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }

    const topPadding = 8.0;
    const bottomPadding = 8.0;
    final minValue = math.min(values.reduce(math.min), referenceValue);
    final maxValue = math.max(values.reduce(math.max), referenceValue);
    final valueSpan = math.max(maxValue - minValue, 1);
    final chartHeight = size.height - topPadding - bottomPadding;
    final chartBottom = size.height - bottomPadding;

    final points = List<Offset>.generate(values.length, (index) {
      final x = size.width * index / math.max(values.length - 1, 1);
      final normalized = (values[index] - minValue) / valueSpan;
      final y = chartBottom - normalized * chartHeight;
      return Offset(x, y);
    });

    final referenceNormalized = (referenceValue - minValue) / valueSpan;
    final referenceY = chartBottom - referenceNormalized * chartHeight;
    final linePath = _buildSmoothPath(points);
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, chartBottom)
      ..lineTo(points.first.dx, chartBottom)
      ..close();

    _drawDashedReferenceLine(
      canvas: canvas,
      width: size.width,
      y: referenceY,
    );

    canvas.drawPath(
      fillPath,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            trendColor.withValues(alpha: 0.28),
            trendColor.withValues(alpha: 0.08),
            trendColor.withValues(alpha: 0),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = trendColor,
    );
  }

  void _drawDashedReferenceLine({
    required Canvas canvas,
    required double width,
    required double y,
  }) {
    const dashWidth = 6.0;
    const dashGap = 4.0;
    final paint = Paint()
      ..color = trendColor.withValues(alpha: 0.28)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    var startX = 0.0;
    while (startX < width) {
      final endX = math.min(startX + dashWidth, width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += dashWidth + dashGap;
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
  bool shouldRepaint(covariant _StockTrendChartPainter oldDelegate) {
    if (referenceValue != oldDelegate.referenceValue ||
        trendColor != oldDelegate.trendColor ||
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
