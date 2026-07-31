import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'stock_daily_bar.dart';

class QuantMovingAverageOverlay extends StatelessWidget {
  const QuantMovingAverageOverlay({
    required this.bars,
    required this.series,
    required this.candlestickMode,
    super.key,
  });

  final List<StockDailyBar> bars;
  final Map<int, List<double?>> series;
  final bool candlestickMode;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        key: const ValueKey('quant-moving-average-overlay'),
        painter: _MovingAveragePainter(
          bars: bars,
          series: series,
          candlestickMode: candlestickMode,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MovingAveragePainter extends CustomPainter {
  const _MovingAveragePainter({
    required this.bars,
    required this.series,
    required this.candlestickMode,
  });

  final List<StockDailyBar> bars;
  final Map<int, List<double?>> series;
  final bool candlestickMode;

  static const _colors = <int, Color>{
    5: Color(0xFFF2A93B),
    10: Color(0xFF8B5CF6),
    20: Color(0xFF00A6A6),
  };

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) {
      return;
    }

    final minimum = bars.map((bar) => bar.low).reduce(math.min);
    final maximum = bars.map((bar) => bar.high).reduce(math.max);
    final span = math.max(maximum - minimum, 0.01);

    double priceToY(double price) {
      final normalized = (price - minimum) / span;
      return size.height - normalized * size.height;
    }

    double indexToX(int index) {
      if (candlestickMode) {
        final slotWidth = size.width / bars.length;
        return slotWidth * index + slotWidth / 2;
      }

      if (bars.length == 1) {
        return size.width / 2;
      }

      return size.width * index / (bars.length - 1);
    }

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    for (final entry in series.entries) {
      final values = entry.value;
      final color = _colors[entry.key];
      if (color == null || values.length != bars.length) {
        continue;
      }

      final path = Path();
      var hasStarted = false;

      for (var index = 0; index < values.length; index++) {
        final value = values[index];
        if (value == null) {
          hasStarted = false;
          continue;
        }

        final x = indexToX(index);
        final y = priceToY(value);

        if (!hasStarted) {
          path.moveTo(x, y);
          hasStarted = true;
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MovingAveragePainter oldDelegate) {
    return bars != oldDelegate.bars ||
        series != oldDelegate.series ||
        candlestickMode != oldDelegate.candlestickMode;
  }
}
