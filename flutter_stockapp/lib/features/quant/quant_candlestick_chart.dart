import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'stock_daily_bar.dart';
import 'quant_chart_timeline.dart';

import '../../core/theme/app_theme_palette.dart';

class QuantCandlestickChart extends StatelessWidget {
  const QuantCandlestickChart({
    required this.bars,
    this.selectedIndex,
    super.key,
  });

  final List<StockDailyBar> bars;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: const ValueKey('quant-candlestick-chart'),
      painter: _QuantCandlestickChartPainter(
        bars: bars,
        selectedIndex: selectedIndex,
        risingColor: const Color(0xFF16A085),
        fallingColor: const Color(0xFFE05A47),
        gridColor:
            Theme.of(context).extension<AppThemePalette>()?.divider ??
            Theme.of(context).colorScheme.outlineVariant,
        selectionColor: const Color(0xFF2F6FED),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _QuantCandlestickChartPainter extends CustomPainter {
  const _QuantCandlestickChartPainter({
    required this.bars,
    required this.selectedIndex,
    required this.risingColor,
    required this.fallingColor,
    required this.gridColor,
    required this.selectionColor,
  });

  final List<StockDailyBar> bars;
  final int? selectedIndex;
  final Color risingColor;
  final Color fallingColor;
  final Color gridColor;
  final Color selectionColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) {
      return;
    }

    final minimum = bars.map((bar) => bar.low).reduce(math.min);
    final maximum = bars.map((bar) => bar.high).reduce(math.max);
    final span = math.max(maximum - minimum, 0.01);
    final slotWidth = size.width / bars.length;
    final bodyWidth = math.max(2.0, slotWidth * 0.62);

    double priceToY(double price) {
      final normalized = (price - minimum) / span;
      return size.height - normalized * size.height;
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var index = 0; index <= 3; index++) {
      final y = size.height * index / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final selection = selectedIndex;
    if (selection != null && selection >= 0 && selection < bars.length) {
      final centerX = quantChartXForIndex(
        index: selection,
        itemCount: bars.length,
        width: size.width,
      );

      canvas.drawRect(
        Rect.fromLTWH(centerX - slotWidth / 2, 0, slotWidth, size.height),
        Paint()
          ..color = selectionColor.withValues(alpha: 0.10)
          ..style = PaintingStyle.fill,
      );

      canvas.drawLine(
        Offset(centerX, 0),
        Offset(centerX, size.height),
        Paint()
          ..color = selectionColor.withValues(alpha: 0.45)
          ..strokeWidth = 1.5,
      );
    }

    for (var index = 0; index < bars.length; index++) {
      final bar = bars[index];
      final centerX = quantChartXForIndex(
        index: index,
        itemCount: bars.length,
        width: size.width,
      );
      final color = bar.close >= bar.open ? risingColor : fallingColor;

      final highY = priceToY(bar.high);
      final lowY = priceToY(bar.low);
      final openY = priceToY(bar.open);
      final closeY = priceToY(bar.close);

      canvas.drawLine(
        Offset(centerX, highY),
        Offset(centerX, lowY),
        Paint()
          ..color = color
          ..strokeWidth = 1.2,
      );

      final bodyTop = math.min(openY, closeY);
      final bodyHeight = math.max((openY - closeY).abs(), 1.5);

      canvas.drawRect(
        Rect.fromLTWH(centerX - bodyWidth / 2, bodyTop, bodyWidth, bodyHeight),
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QuantCandlestickChartPainter oldDelegate) {
    if (selectedIndex != oldDelegate.selectedIndex ||
        risingColor != oldDelegate.risingColor ||
        fallingColor != oldDelegate.fallingColor ||
        gridColor != oldDelegate.gridColor ||
        selectionColor != oldDelegate.selectionColor ||
        bars.length != oldDelegate.bars.length) {
      return true;
    }

    for (var index = 0; index < bars.length; index++) {
      final current = bars[index];
      final previous = oldDelegate.bars[index];

      if (current.tradingDate != previous.tradingDate ||
          current.open != previous.open ||
          current.high != previous.high ||
          current.low != previous.low ||
          current.close != previous.close) {
        return true;
      }
    }

    return false;
  }
}
