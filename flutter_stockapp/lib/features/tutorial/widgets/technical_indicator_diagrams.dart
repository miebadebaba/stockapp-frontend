import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_palette.dart';

class MaTrendDiagram extends StatelessWidget {
  const MaTrendDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialDiagramFrame(
      key: const ValueKey('ma-teaching-diagram'),
      semanticLabel: '移动平均线教学图，包含价格线、短期均线、长期均线、金叉和死叉。',
      child: CustomPaint(
        painter: _MaTrendPainter(
          palette: Theme.of(context).extension<AppThemePalette>()!,
        ),
        child: const SizedBox(height: 210),
      ),
    );
  }
}

class MacdDiagram extends StatelessWidget {
  const MacdDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialDiagramFrame(
      key: const ValueKey('macd-teaching-diagram'),
      semanticLabel: 'MACD 教学图，包含价格趋势、DIF 线、DEA 线、正负柱状图和零轴。',
      child: CustomPaint(
        painter: _MacdPainter(
          palette: Theme.of(context).extension<AppThemePalette>()!,
        ),
        child: const SizedBox(height: 230),
      ),
    );
  }
}

class RsiDiagram extends StatelessWidget {
  const RsiDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialDiagramFrame(
      key: const ValueKey('rsi-teaching-diagram'),
      semanticLabel: 'RSI 教学图，包含 0 到 100 范围、70 参考线、30 参考线、超买和超卖区域。',
      child: CustomPaint(
        painter: _RsiPainter(
          palette: Theme.of(context).extension<AppThemePalette>()!,
        ),
        child: const SizedBox(height: 190),
      ),
    );
  }
}

class VolumeDiagram extends StatelessWidget {
  const VolumeDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialDiagramFrame(
      key: const ValueKey('volume-teaching-diagram'),
      semanticLabel: '成交量教学图，包含正常成交量、放量、缩量和近期平均成交量参考线。',
      child: CustomPaint(
        painter: _VolumePainter(
          palette: Theme.of(context).extension<AppThemePalette>()!,
        ),
        child: const SizedBox(height: 210),
      ),
    );
  }
}

class VwapDiagram extends StatelessWidget {
  const VwapDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialDiagramFrame(
      key: const ValueKey('vwap-teaching-diagram'),
      semanticLabel: 'VWAP 教学图，包含价格线、成交量柱、VWAP 线，以及价格位于 VWAP 上方和下方的区域。',
      child: CustomPaint(
        painter: _VwapPainter(
          palette: Theme.of(context).extension<AppThemePalette>()!,
        ),
        child: const SizedBox(height: 210),
      ),
    );
  }
}

class MarketRegimeDiagram extends StatelessWidget {
  const MarketRegimeDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialDiagramFrame(
      key: const ValueKey('market-regime-teaching-diagram'),
      semanticLabel: '趋势和震荡行情对比图，包含趋势行情、震荡行情和频繁假信号说明。',
      child: CustomPaint(
        painter: _MarketRegimePainter(
          palette: Theme.of(context).extension<AppThemePalette>()!,
        ),
        child: const SizedBox(height: 200),
      ),
    );
  }
}

class BacktestDrawdownDiagram extends StatelessWidget {
  const BacktestDrawdownDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialDiagramFrame(
      key: const ValueKey('backtest-drawdown-teaching-diagram'),
      semanticLabel: '回测资金曲线教学图，包含初始资金、资金高点、后续低点和最大回撤区域。',
      child: CustomPaint(
        painter: _BacktestDrawdownPainter(
          palette: Theme.of(context).extension<AppThemePalette>()!,
        ),
        child: const SizedBox(height: 210),
      ),
    );
  }
}

class QuantBiasDiagram extends StatelessWidget {
  const QuantBiasDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialDiagramFrame(
      key: const ValueKey('quant-bias-teaching-diagram'),
      semanticLabel: '过拟合和未来函数教学流程图，包含历史数据、反复调参、未见数据表现下降，以及偷看未来数据。',
      child: CustomPaint(
        painter: _QuantBiasPainter(
          palette: Theme.of(context).extension<AppThemePalette>()!,
        ),
        child: const SizedBox(height: 330),
      ),
    );
  }
}

class PositionImpactDiagram extends StatelessWidget {
  const PositionImpactDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialDiagramFrame(
      key: const ValueKey('position-impact-teaching-diagram'),
      semanticLabel: '仓位影响教学图，对比满仓和百分之二十仓位在股票下跌百分之三十时对账户的影响。',
      child: CustomPaint(
        painter: _PositionImpactPainter(
          palette: Theme.of(context).extension<AppThemePalette>()!,
        ),
        child: const SizedBox(height: 190),
      ),
    );
  }
}

class CorrelationDiagram extends StatelessWidget {
  const CorrelationDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialDiagramFrame(
      key: const ValueKey('correlation-teaching-diagram'),
      semanticLabel: '相关性教学图，对比高相关走势和低相关走势，并提示多只银行股不等于真正分散。',
      child: CustomPaint(
        painter: _CorrelationPainter(
          palette: Theme.of(context).extension<AppThemePalette>()!,
        ),
        child: const SizedBox(height: 205),
      ),
    );
  }
}

class VolatilityDrawdownDiagram extends StatelessWidget {
  const VolatilityDrawdownDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialDiagramFrame(
      key: const ValueKey('volatility-drawdown-teaching-diagram'),
      semanticLabel: '波动率与最大回撤教学图，包含较低波动、较高波动、历史高点、后续低点和最大回撤百分之二十五。',
      child: CustomPaint(
        painter: _VolatilityDrawdownPainter(
          palette: Theme.of(context).extension<AppThemePalette>()!,
        ),
        child: const SizedBox(height: 230),
      ),
    );
  }
}

class LeverageMarginDiagram extends StatelessWidget {
  const LeverageMarginDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialDiagramFrame(
      key: const ValueKey('leverage-margin-teaching-diagram'),
      semanticLabel: '杠杆与保证金教学图，对比无杠杆和二倍杠杆的亏损放大，并展示强制平仓流程。',
      child: CustomPaint(
        painter: _LeverageMarginPainter(
          palette: Theme.of(context).extension<AppThemePalette>()!,
        ),
        child: const SizedBox(height: 340),
      ),
    );
  }
}

class TradeRiskFlowDiagram extends StatelessWidget {
  const TradeRiskFlowDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return _TutorialDiagramFrame(
      key: const ValueKey('trade-risk-flow-teaching-diagram'),
      semanticLabel: '单笔风险上限计算流程图，展示账户总资产、单笔风险上限、每股潜在损失、可买数量、预计持仓金额和组合风险检查。',
      child: CustomPaint(
        painter: _TradeRiskFlowPainter(
          palette: Theme.of(context).extension<AppThemePalette>()!,
        ),
        child: const SizedBox(height: 260),
      ),
    );
  }
}

class _TutorialDiagramFrame extends StatelessWidget {
  const _TutorialDiagramFrame({
    required this.semanticLabel,
    required this.child,
    super.key,
  });

  final String semanticLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: palette.searchBackground.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: palette.divider),
        ),
        child: child,
      ),
    );
  }
}

class _ChartArea {
  const _ChartArea(this.rect, this.min, this.max);

  final Rect rect;
  final double min;
  final double max;

  double get left => rect.left;
  double get right => rect.right;
  double get top => rect.top;
  double get bottom => rect.bottom;
  double get width => rect.width;
  double get height => rect.height;

  Offset point(int index, int count, num value) {
    final x = rect.left + rect.width * index / math.max(1, count - 1);
    final ratio = (value - min) / (max - min);
    return Offset(x, rect.bottom - rect.height * ratio);
  }
}

abstract class _TutorialPainter extends CustomPainter {
  const _TutorialPainter({required this.palette});

  final AppThemePalette palette;

  TextStyle get labelStyle => TextStyle(
    color: palette.primaryText,
    fontSize: 10.5,
    fontWeight: FontWeight.w800,
  );

  TextStyle get mutedStyle => TextStyle(
    color: palette.secondaryText,
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
  );

  Paint get guidePaint => Paint()
    ..color = palette.divider
    ..strokeWidth = 1;

  void drawLabel(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    painter.paint(canvas, offset);
  }

  void drawCenteredLabel(
    Canvas canvas,
    String text,
    Rect rect,
    TextStyle style, {
    int maxLines = 2,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: maxLines,
      ellipsis: '...',
    )..layout(maxWidth: rect.width);
    painter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - painter.width) / 2,
        rect.top + (rect.height - painter.height) / 2,
      ),
    );
  }

  void drawLineSeries(
    Canvas canvas,
    _ChartArea area,
    List<num> values,
    Color color, {
    double width = 2.5,
  }) {
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final point = area.point(i, values.length, values[i]);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TutorialPainter oldDelegate) =>
      oldDelegate.palette != palette;
}

class _MaTrendPainter extends _TutorialPainter {
  const _MaTrendPainter({required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final area = _ChartArea(
      Rect.fromLTWH(28, 28, size.width - 50, size.height - 68),
      9,
      18,
    );
    final price = [10, 11, 12, 11, 13, 14, 15, 14, 13, 12, 11, 12, 13, 15, 16];
    final shortMa = [
      10.2,
      10.8,
      11.3,
      11.7,
      12.4,
      13.3,
      14.2,
      14.3,
      13.8,
      12.9,
      12.2,
      12.0,
      12.5,
      13.5,
      14.6,
    ];
    final longMa = [
      11.8,
      11.7,
      11.8,
      12.0,
      12.2,
      12.5,
      12.9,
      13.1,
      13.0,
      12.9,
      12.8,
      12.7,
      12.8,
      13.0,
      13.3,
    ];

    _drawAxes(canvas, area, '时间', '价格');
    drawLineSeries(
      canvas,
      area,
      price.map((v) => v.toDouble()).toList(),
      Colors.blue.shade500,
    );
    drawLineSeries(canvas, area, shortMa, Colors.orange.shade600);
    drawLineSeries(canvas, area, longMa, Colors.purple.shade400);

    drawLabel(canvas, '价格线', Offset(area.left + 8, 6), mutedStyle);
    drawLabel(canvas, '短期均线', Offset(area.left + 72, 6), mutedStyle);
    drawLabel(canvas, '长期均线', Offset(area.left + 156, 6), mutedStyle);
    drawLabel(
      canvas,
      '金叉',
      area.point(5, price.length, 14.7) + const Offset(-12, -26),
      labelStyle,
    );
    drawLabel(
      canvas,
      '死叉',
      area.point(10, price.length, 12.0) + const Offset(-12, 16),
      labelStyle,
    );
  }
}

class _MacdPainter extends _TutorialPainter {
  const _MacdPainter({required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final priceArea = _ChartArea(
      Rect.fromLTWH(28, 26, size.width - 50, 62),
      9,
      16,
    );
    final macdArea = _ChartArea(
      Rect.fromLTWH(28, 112, size.width - 50, 78),
      -2,
      2,
    );
    final price = [
      10,
      10.5,
      11.3,
      12.4,
      13.2,
      14,
      13.6,
      13.1,
      12.8,
      12.5,
      12.1,
      12.7,
      13.2,
    ];
    final dif = [-.8, -.4, .1, .7, 1.2, 1.5, 1.1, .6, .2, -.2, -.5, -.1, .4];
    final dea = [-.6, -.5, -.2, .2, .7, 1.1, 1.2, .9, .5, .1, -.2, -.2, .0];

    _drawAxes(canvas, priceArea, '', '价格');
    drawLineSeries(canvas, priceArea, price, Colors.blue.shade500);
    drawLabel(canvas, '简化价格趋势', Offset(priceArea.left, 4), mutedStyle);

    _drawAxes(canvas, macdArea, '时间', 'MACD');
    final zeroY = macdArea.point(0, 2, 0).dy;
    canvas.drawLine(
      Offset(macdArea.left, zeroY),
      Offset(macdArea.right, zeroY),
      guidePaint,
    );
    for (var i = 0; i < dif.length; i++) {
      final value = dif[i] - dea[i];
      final point = macdArea.point(i, dif.length, value);
      canvas.drawRect(
        Rect.fromLTRB(
          point.dx - 4,
          math.min(point.dy, zeroY),
          point.dx + 4,
          math.max(point.dy, zeroY),
        ),
        Paint()
          ..color = value >= 0 ? Colors.red.shade400 : Colors.green.shade500,
      );
    }
    drawLineSeries(canvas, macdArea, dif, Colors.orange.shade600);
    drawLineSeries(canvas, macdArea, dea, Colors.purple.shade400);
    drawLabel(
      canvas,
      'DIF',
      Offset(macdArea.left + 8, macdArea.top - 18),
      mutedStyle,
    );
    drawLabel(
      canvas,
      'DEA',
      Offset(macdArea.left + 52, macdArea.top - 18),
      mutedStyle,
    );
    drawLabel(
      canvas,
      '零轴',
      Offset(macdArea.right - 26, zeroY - 12),
      mutedStyle,
    );
    drawLabel(
      canvas,
      '动量增强',
      Offset(macdArea.left + 48, macdArea.top + 8),
      labelStyle,
    );
    drawLabel(
      canvas,
      '动量减弱',
      Offset(macdArea.right - 96, macdArea.top + 50),
      labelStyle,
    );
  }
}

class _RsiPainter extends _TutorialPainter {
  const _RsiPainter({required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final area = _ChartArea(
      Rect.fromLTWH(30, 24, size.width - 54, size.height - 58),
      0,
      100,
    );
    final rsi = [
      42,
      48,
      56,
      68,
      74,
      78,
      76,
      72,
      62,
      50,
      38,
      28,
      24,
      31,
      44,
      58,
    ];
    _drawAxes(canvas, area, '时间', 'RSI');
    final y70 = area.point(0, 2, 70).dy;
    final y30 = area.point(0, 2, 30).dy;
    canvas.drawRect(
      Rect.fromLTRB(area.left, area.top, area.right, y70),
      Paint()..color = Colors.red.withValues(alpha: 0.08),
    );
    canvas.drawRect(
      Rect.fromLTRB(area.left, y30, area.right, area.bottom),
      Paint()..color = Colors.green.withValues(alpha: 0.08),
    );
    canvas.drawLine(
      Offset(area.left, y70),
      Offset(area.right, y70),
      guidePaint,
    );
    canvas.drawLine(
      Offset(area.left, y30),
      Offset(area.right, y30),
      guidePaint,
    );
    drawLineSeries(
      canvas,
      area,
      rsi.map((v) => v.toDouble()).toList(),
      Colors.blue.shade500,
    );
    drawLabel(canvas, '70 超买参考', Offset(area.left + 6, y70 - 16), labelStyle);
    drawLabel(canvas, '30 超卖参考', Offset(area.left + 6, y30 + 4), labelStyle);
    drawLabel(canvas, '0', Offset(8, area.bottom - 8), mutedStyle);
    drawLabel(canvas, '100', Offset(4, area.top - 2), mutedStyle);
  }
}

class _VolumePainter extends _TutorialPainter {
  const _VolumePainter({required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final area = _ChartArea(
      Rect.fromLTWH(28, 24, size.width - 50, size.height - 58),
      0,
      220,
    );
    final priceArea = _ChartArea(
      Rect.fromLTWH(28, 24, size.width - 50, 62),
      9,
      14,
    );
    final volume = [95, 105, 100, 110, 98, 180, 205, 190, 120, 80, 62, 58, 75];
    final price = [
      10,
      10.2,
      10.4,
      10.3,
      10.6,
      11.6,
      12.8,
      12.2,
      11.7,
      11.3,
      11.0,
      10.8,
      11.1,
    ];
    _drawAxes(canvas, area, '时间', '成交量');
    final avgY = area.point(0, 2, 100).dy;
    canvas.drawLine(
      Offset(area.left, avgY),
      Offset(area.right, avgY),
      guidePaint,
    );
    for (var i = 0; i < volume.length; i++) {
      final point = area.point(i, volume.length, volume[i].toDouble());
      final color = volume[i] > 150
          ? Colors.red.shade400
          : volume[i] < 80
          ? Colors.green.shade500
          : Colors.blueGrey.shade300;
      canvas.drawRect(
        Rect.fromLTRB(point.dx - 4, point.dy, point.dx + 4, area.bottom),
        Paint()..color = color,
      );
    }
    drawLineSeries(canvas, priceArea, price, Colors.blue.shade500, width: 2);
    drawLabel(canvas, '近期平均成交量', Offset(area.left + 6, avgY - 16), labelStyle);
    drawLabel(
      canvas,
      '放量',
      Offset(area.left + area.width * .45, area.top + 10),
      labelStyle,
    );
    drawLabel(
      canvas,
      '缩量',
      Offset(area.left + area.width * .76, area.bottom - 48),
      labelStyle,
    );
  }
}

class _VwapPainter extends _TutorialPainter {
  const _VwapPainter({required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final priceArea = _ChartArea(
      Rect.fromLTWH(28, 24, size.width - 50, 112),
      9,
      14,
    );
    final volumeArea = _ChartArea(
      Rect.fromLTWH(28, 148, size.width - 50, 36),
      0,
      200,
    );
    final price = [
      10,
      10.5,
      11.2,
      12.4,
      12.1,
      11.7,
      11.1,
      10.8,
      11.5,
      12.2,
      12.8,
      12.4,
    ];
    final vwap = [
      10.0,
      10.3,
      10.8,
      11.4,
      11.6,
      11.7,
      11.6,
      11.4,
      11.5,
      11.7,
      12.0,
      12.1,
    ];
    final volume = [70, 90, 150, 190, 140, 110, 95, 80, 120, 160, 180, 130];
    _drawAxes(canvas, priceArea, '', '价格');
    for (var i = 0; i < volume.length; i++) {
      final point = volumeArea.point(i, volume.length, volume[i].toDouble());
      canvas.drawRect(
        Rect.fromLTRB(point.dx - 4, point.dy, point.dx + 4, volumeArea.bottom),
        Paint()..color = Colors.blueGrey.shade300,
      );
    }
    drawLineSeries(canvas, priceArea, price, Colors.blue.shade500);
    drawLineSeries(canvas, priceArea, vwap, Colors.orange.shade700);
    drawLabel(canvas, '价格线', Offset(priceArea.left + 6, 4), mutedStyle);
    drawLabel(canvas, 'VWAP 线', Offset(priceArea.left + 62, 4), mutedStyle);
    drawLabel(
      canvas,
      '高于 VWAP',
      Offset(priceArea.right - 78, priceArea.top + 18),
      labelStyle,
    );
    drawLabel(
      canvas,
      '低于 VWAP',
      Offset(priceArea.left + 12, priceArea.bottom - 24),
      labelStyle,
    );
  }
}

class _MarketRegimePainter extends _TutorialPainter {
  const _MarketRegimePainter({required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final left = _ChartArea(
      Rect.fromLTWH(20, 34, size.width * .42, 112),
      9,
      16,
    );
    final right = _ChartArea(
      Rect.fromLTWH(size.width * .53, 34, size.width * .40, 112),
      9,
      16,
    );
    final trend = [10, 10.5, 11, 11.8, 12.4, 13.2, 14.1, 15];
    final trendMa = [10.2, 10.4, 10.8, 11.3, 11.9, 12.6, 13.4, 14.2];
    final range = [12, 13.4, 11.2, 13.1, 11.5, 13.3, 11.1, 12.8];
    final rangeMa = [12.1, 12.5, 12.1, 12.4, 12.0, 12.4, 12.1, 12.3];
    _drawBox(canvas, left.rect);
    _drawBox(canvas, right.rect);
    drawLineSeries(
      canvas,
      left,
      trend.map((v) => v.toDouble()).toList(),
      Colors.blue.shade500,
    );
    drawLineSeries(
      canvas,
      left,
      trendMa.map((v) => v.toDouble()).toList(),
      Colors.orange.shade600,
    );
    drawLineSeries(
      canvas,
      right,
      range.map((v) => v.toDouble()).toList(),
      Colors.blue.shade500,
    );
    drawLineSeries(
      canvas,
      right,
      rangeMa.map((v) => v.toDouble()).toList(),
      Colors.orange.shade600,
    );
    drawLabel(canvas, '趋势行情', Offset(left.rect.left + 8, 8), labelStyle);
    drawLabel(canvas, '震荡行情', Offset(right.rect.left + 8, 8), labelStyle);
    drawLabel(
      canvas,
      '频繁假信号',
      Offset(right.rect.left + 28, right.rect.bottom + 14),
      mutedStyle,
    );
  }
}

class _BacktestDrawdownPainter extends _TutorialPainter {
  const _BacktestDrawdownPainter({required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final area = _ChartArea(
      Rect.fromLTWH(28, 28, size.width - 50, size.height - 66),
      80,
      130,
    );
    final equity = [100, 106, 112, 120, 116, 108, 96, 90, 94, 103, 111];
    _drawAxes(canvas, area, '时间', '资金');
    final high = area.point(3, equity.length, 120);
    final low = area.point(7, equity.length, 90);
    canvas.drawRect(
      Rect.fromLTRB(high.dx, high.dy, low.dx, low.dy),
      Paint()..color = Colors.red.withValues(alpha: 0.10),
    );
    drawLineSeries(
      canvas,
      area,
      equity.map((v) => v.toDouble()).toList(),
      Colors.blue.shade500,
    );
    canvas.drawCircle(high, 4, Paint()..color = Colors.red.shade500);
    canvas.drawCircle(low, 4, Paint()..color = Colors.green.shade600);
    drawLabel(
      canvas,
      '初始资金',
      Offset(area.left + 2, area.point(0, 2, 100).dy + 8),
      mutedStyle,
    );
    drawLabel(canvas, '资金高点', high + const Offset(-22, -24), labelStyle);
    drawLabel(canvas, '后续低点', low + const Offset(-12, 12), labelStyle);
    drawLabel(
      canvas,
      '最大回撤约 25%',
      Offset((high.dx + low.dx) / 2 - 38, high.dy + 42),
      labelStyle,
    );
  }
}

class _QuantBiasPainter extends _TutorialPainter {
  const _QuantBiasPainter({required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    _paintReadableLayout(canvas, size);
  }

  void _paintReadableLayout(Canvas canvas, Size size) {
    final padding = 10.0;
    final sectionWidth = size.width - padding * 2;
    final overfitRect = Rect.fromLTWH(padding, 10, sectionWidth, 172);
    final futureRect = Rect.fromLTWH(padding, 194, sectionWidth, 112);

    _drawSectionCard(canvas, overfitRect);
    _drawSectionCard(canvas, futureRect);

    drawLabel(
      canvas,
      '过拟合',
      overfitRect.topLeft + const Offset(10, 8),
      labelStyle,
    );
    drawLabel(
      canvas,
      '未来函数 / 偷看未来数据',
      futureRect.topLeft + const Offset(10, 8),
      labelStyle,
    );

    final steps = ['历史数据', '反复调参', '历史回测越来越好', '放到未见数据', '表现变差'];
    final stepWidth = overfitRect.width - 28;
    const stepHeight = 22.0;
    const stepGap = 7.0;
    var stepTop = overfitRect.top + 34;
    for (var i = 0; i < steps.length; i++) {
      final rect = Rect.fromLTWH(
        overfitRect.left + 14,
        stepTop,
        stepWidth,
        stepHeight,
      );
      _drawNode(canvas, rect, steps[i], highlight: i == steps.length - 1);
      if (i != steps.length - 1) {
        _drawDownArrow(canvas, Offset(overfitRect.center.dx, rect.bottom + 1));
      }
      stepTop += stepHeight + stepGap;
    }

    drawLabel(
      canvas,
      '错误地把明天的数据拿回今天使用',
      futureRect.topLeft + const Offset(10, 34),
      mutedStyle,
    );
    final timeAxisY = futureRect.top + 74;
    final today = Offset(futureRect.left + 24, timeAxisY);
    final tomorrow = Offset(futureRect.right - 24, timeAxisY);
    canvas.drawLine(
      today,
      tomorrow,
      Paint()
        ..color = palette.secondaryText
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(today, 5, Paint()..color = Colors.blue.shade500);
    canvas.drawCircle(tomorrow, 5, Paint()..color = Colors.orange.shade600);
    drawLabel(canvas, '今天', today + const Offset(-12, 16), labelStyle);
    drawCenteredLabel(
      canvas,
      '明天才知道的数据',
      Rect.fromLTWH(tomorrow.dx - 58, tomorrow.dy - 30, 116, 24),
      mutedStyle,
    );
    _drawArrow(
      canvas,
      Offset(tomorrow.dx - 2, tomorrow.dy - 2),
      Offset(today.dx + 4, today.dy - 2),
      color: Colors.red.shade400,
    );
  }

  void _drawNode(
    Canvas canvas,
    Rect rect,
    String text, {
    bool highlight = false,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(9)),
      Paint()
        ..color = highlight
            ? Colors.red.withValues(alpha: 0.10)
            : palette.segmentBackground.withValues(alpha: 0.82),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(9)),
      Paint()
        ..color = highlight ? Colors.red.shade300 : palette.divider
        ..style = PaintingStyle.stroke,
    );
    drawCenteredLabel(canvas, text, rect, labelStyle);
  }

  void _drawDownArrow(Canvas canvas, Offset start) {
    final paint = Paint()
      ..color = palette.secondaryText
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    final end = start + const Offset(0, 6);
    canvas.drawLine(start, end, paint);
    canvas.drawLine(end, end + const Offset(-4, -4), paint);
    canvas.drawLine(end, end + const Offset(4, -4), paint);
  }

  void _drawSectionCard(Canvas canvas, Rect rect) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()..color = palette.searchBackground.withValues(alpha: 0.74),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()
        ..color = palette.divider
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, {Color? color}) {
    final paint = Paint()
      ..color = color ?? palette.secondaryText
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    const size = 6.0;
    canvas.drawLine(
      end,
      end - Offset(math.cos(angle - .5) * size, math.sin(angle - .5) * size),
      paint,
    );
    canvas.drawLine(
      end,
      end - Offset(math.cos(angle + .5) * size, math.sin(angle + .5) * size),
      paint,
    );
  }
}

class _PositionImpactPainter extends _TutorialPainter {
  const _PositionImpactPainter({required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final left = Rect.fromLTWH(18, 44, size.width * .38, 94);
    final right = Rect.fromLTWH(size.width * .56, 44, size.width * .38, 94);
    drawLabel(canvas, '股票下跌 30%', Offset(size.width / 2 - 42, 8), labelStyle);
    _drawAccountBars(canvas, left, '满仓', '账户损失约 30%', 1.0, 0.70);
    _drawAccountBars(canvas, right, '20% 仓位', '账户损失约 6%', 1.0, 0.94);
  }

  void _drawAccountBars(
    Canvas canvas,
    Rect rect,
    String title,
    String loss,
    double before,
    double after,
  ) {
    _drawBox(canvas, rect);
    drawLabel(canvas, title, rect.topLeft + const Offset(8, -24), labelStyle);
    drawLabel(canvas, loss, rect.bottomLeft + const Offset(2, 10), mutedStyle);
    final barWidth = rect.width * .22;
    final beforeHeight = rect.height * before;
    final afterHeight = rect.height * after;
    final base = rect.bottom - 8;
    canvas.drawRect(
      Rect.fromLTWH(
        rect.left + rect.width * .24,
        base - beforeHeight,
        barWidth,
        beforeHeight,
      ),
      Paint()..color = Colors.blue.shade500,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        rect.left + rect.width * .56,
        base - afterHeight,
        barWidth,
        afterHeight,
      ),
      Paint()..color = Colors.red.shade400,
    );
    drawLabel(
      canvas,
      '前',
      Offset(rect.left + rect.width * .26, base + 4),
      mutedStyle,
    );
    drawLabel(
      canvas,
      '后',
      Offset(rect.left + rect.width * .58, base + 4),
      mutedStyle,
    );
  }
}

class _CorrelationPainter extends _TutorialPainter {
  const _CorrelationPainter({required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final left = _ChartArea(Rect.fromLTWH(20, 34, size.width * .42, 94), 8, 16);
    final right = _ChartArea(
      Rect.fromLTWH(size.width * .53, 34, size.width * .40, 94),
      8,
      16,
    );
    _drawBox(canvas, left.rect);
    _drawBox(canvas, right.rect);
    drawLineSeries(canvas, left, [
      10,
      12,
      11,
      13,
      15,
      14,
      16,
    ], Colors.blue.shade500);
    drawLineSeries(canvas, left, [
      9.8,
      11.7,
      10.8,
      12.7,
      14.7,
      13.8,
      15.6,
    ], Colors.orange.shade600);
    drawLineSeries(canvas, right, [
      10,
      12.5,
      11,
      13.5,
      12.2,
      14.5,
      13.6,
    ], Colors.blue.shade500);
    drawLineSeries(canvas, right, [
      14.8,
      12.6,
      14.2,
      11.8,
      13.7,
      10.8,
      12.4,
    ], Colors.orange.shade600);
    drawLabel(canvas, '高相关', Offset(left.left + 8, 8), labelStyle);
    drawLabel(
      canvas,
      '走势大多同步',
      Offset(left.left + 8, left.bottom + 8),
      mutedStyle,
    );
    drawLabel(canvas, '低相关', Offset(right.left + 8, 8), labelStyle);
    drawLabel(
      canvas,
      '走势不完全同步',
      Offset(right.left + 8, right.bottom + 8),
      mutedStyle,
    );
    drawLabel(
      canvas,
      '银行 A + 银行 B + 银行 C + 银行 D',
      const Offset(18, 166),
      mutedStyle,
    );
    drawLabel(canvas, '≠ 真正分散', Offset(size.width - 94, 166), labelStyle);
  }
}

class _VolatilityDrawdownPainter extends _TutorialPainter {
  const _VolatilityDrawdownPainter({required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final volatilityArea = _ChartArea(
      Rect.fromLTWH(28, 26, size.width - 54, 78),
      90,
      116,
    );
    final drawdownArea = _ChartArea(
      Rect.fromLTWH(28, 132, size.width - 54, 66),
      80,
      130,
    );
    _drawAxes(canvas, volatilityArea, '', '波动');
    drawLineSeries(canvas, volatilityArea, [
      100,
      101,
      100.5,
      102,
      101.5,
      103,
      102.5,
    ], Colors.blue.shade500);
    drawLineSeries(canvas, volatilityArea, [
      100,
      108,
      94,
      112,
      97,
      115,
      101,
    ], Colors.red.shade400);
    drawLabel(canvas, '较低波动', Offset(volatilityArea.left + 8, 6), mutedStyle);
    drawLabel(canvas, '较高波动', Offset(volatilityArea.left + 82, 6), mutedStyle);

    _drawAxes(canvas, drawdownArea, '时间', '资金');
    final equity = [100, 106, 115, 120, 108, 96, 90, 98, 104];
    final high = drawdownArea.point(3, equity.length, 120);
    final low = drawdownArea.point(6, equity.length, 90);
    canvas.drawRect(
      Rect.fromLTRB(high.dx, high.dy, low.dx, low.dy),
      Paint()..color = Colors.red.withValues(alpha: 0.10),
    );
    drawLineSeries(canvas, drawdownArea, equity, Colors.orange.shade700);
    canvas.drawCircle(high, 4, Paint()..color = Colors.red.shade500);
    canvas.drawCircle(low, 4, Paint()..color = Colors.green.shade600);
    drawLabel(canvas, '历史高点', high + const Offset(-24, -22), labelStyle);
    drawLabel(canvas, '后续低点', low + const Offset(-12, 10), labelStyle);
    drawLabel(
      canvas,
      '最大回撤 25%',
      Offset((high.dx + low.dx) / 2 - 34, high.dy + 34),
      labelStyle,
    );
  }
}

class _LeverageMarginPainter extends _TutorialPainter {
  const _LeverageMarginPainter({required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    _paintReadableLayout(canvas, size);
  }

  void _paintReadableLayout(Canvas canvas, Size size) {
    final padding = 10.0;
    final topArea = Rect.fromLTWH(padding, 12, size.width - padding * 2, 124);
    final bottomArea = Rect.fromLTWH(
      padding,
      150,
      size.width - padding * 2,
      172,
    );

    _drawSectionCard(canvas, topArea);
    _drawSectionCard(canvas, bottomArea);

    drawLabel(
      canvas,
      '无杠杆 vs 2倍杠杆',
      topArea.topLeft + const Offset(10, 8),
      labelStyle,
    );
    drawLabel(
      canvas,
      '同样下跌 10%，账户承受的损失不同',
      topArea.topLeft + const Offset(10, 28),
      mutedStyle,
    );

    final cardGap = 10.0;
    final cardWidth = (topArea.width - cardGap * 3) / 2;
    const cardHeight = 74.0;
    final left = Rect.fromLTWH(
      topArea.left + cardGap,
      topArea.top + 48,
      cardWidth,
      cardHeight,
    );
    final right = Rect.fromLTWH(
      left.right + cardGap,
      left.top,
      cardWidth,
      cardHeight,
    );
    _drawLeverageCard(
      canvas,
      left,
      '无杠杆',
      '持有 ￥10,000',
      '账户损失约 10%',
      Colors.blue.shade500,
    );
    _drawLeverageCard(
      canvas,
      right,
      '2 倍杠杆',
      '持有 ￥20,000',
      '自有资金损失约 20%',
      Colors.red.shade400,
    );

    drawLabel(
      canvas,
      '强制平仓流程',
      bottomArea.topLeft + const Offset(10, 8),
      labelStyle,
    );
    drawLabel(
      canvas,
      '账户权益下降后，流程会按顺序向下推进',
      bottomArea.topLeft + const Offset(10, 28),
      mutedStyle,
    );

    final steps = ['账户权益下降', '接近保证金要求', '追加保证金或减少仓位', '保证金不足', '强制平仓'];
    final stepWidth = bottomArea.width - 30;
    const stepHeight = 22.0;
    const stepGap = 13.0;
    var stepTop = bottomArea.top + 52;
    for (var i = 0; i < steps.length; i++) {
      final rect = Rect.fromLTWH(
        bottomArea.left + 15,
        stepTop,
        stepWidth,
        stepHeight,
      );
      _drawFlowNode(canvas, rect, steps[i], highlight: i == steps.length - 1);
      if (i != steps.length - 1) {
        _drawFlowArrow(canvas, Offset(rect.center.dx, rect.bottom + 1));
      }
      stepTop += stepHeight + stepGap;
    }
  }

  void _drawLeverageCard(
    Canvas canvas,
    Rect rect,
    String title,
    String holding,
    String loss,
    Color highlight,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..color = palette.segmentBackground.withValues(alpha: 0.75),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = palette.divider
        ..style = PaintingStyle.stroke,
    );
    drawLabel(canvas, title, rect.topLeft + const Offset(8, 6), labelStyle);
    drawLabel(canvas, holding, rect.topLeft + const Offset(12, 26), mutedStyle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left + 12, rect.top + 44, rect.width - 24, 12),
        const Radius.circular(6),
      ),
      Paint()..color = highlight.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left + 12, rect.top + 44, rect.width - 24, 12),
        const Radius.circular(6),
      ),
      Paint()
        ..color = highlight.withValues(alpha: 0.90)
        ..style = PaintingStyle.stroke,
    );
    drawLabel(canvas, loss, rect.topLeft + const Offset(12, 60), mutedStyle);
  }

  void _drawFlowNode(
    Canvas canvas,
    Rect rect,
    String text, {
    bool highlight = false,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = highlight
            ? Colors.red.withValues(alpha: 0.10)
            : palette.segmentBackground.withValues(alpha: 0.82),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = highlight ? Colors.red.shade300 : palette.divider
        ..style = PaintingStyle.stroke,
    );
    drawCenteredLabel(canvas, text, rect, labelStyle);
  }

  void _drawFlowArrow(Canvas canvas, Offset start) {
    final paint = Paint()
      ..color = palette.secondaryText
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final end = start + const Offset(0, 8);
    canvas.drawLine(start, end, paint);
    canvas.drawLine(end, end + const Offset(-4, -4), paint);
    canvas.drawLine(end, end + const Offset(4, -4), paint);
  }

  void _drawSectionCard(Canvas canvas, Rect rect) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()..color = palette.searchBackground.withValues(alpha: 0.72),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()
        ..color = palette.divider
        ..style = PaintingStyle.stroke,
    );
  }
}

class _TradeRiskFlowPainter extends _TutorialPainter {
  const _TradeRiskFlowPainter({required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    drawLabel(canvas, '教学示例', const Offset(10, 6), labelStyle);
    final rows = [
      '账户总资产 ¥100,000',
      '单笔风险上限 ¥1,000',
      '买入价 ¥50 − 失效价 ¥45',
      '每股潜在损失 ¥5',
      '可买数量 200 股',
      '预计持仓金额 ¥10,000',
      '预留费用并检查组合风险',
    ];
    var y = 30.0;
    for (var i = 0; i < rows.length; i++) {
      final rect = Rect.fromLTWH(24, y, size.width - 48, 25);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()..color = palette.segmentBackground.withValues(alpha: 0.78),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()
          ..color = palette.divider
          ..style = PaintingStyle.stroke,
      );
      drawLabel(
        canvas,
        rows[i],
        rect.topLeft + const Offset(10, 7),
        mutedStyle,
      );
      if (i != rows.length - 1) {
        canvas.drawLine(
          Offset(size.width / 2, rect.bottom + 2),
          Offset(size.width / 2, rect.bottom + 12),
          Paint()
            ..color = palette.secondaryText
            ..strokeWidth = 1.2,
        );
      }
      y += 31;
    }
  }
}

void _drawAxes(Canvas canvas, _ChartArea area, String xLabel, String yLabel) {
  final axisPaint = Paint()
    ..color = Colors.grey.withValues(alpha: 0.42)
    ..strokeWidth = 1;
  canvas.drawLine(
    Offset(area.left, area.bottom),
    Offset(area.right, area.bottom),
    axisPaint,
  );
  canvas.drawLine(
    Offset(area.left, area.top),
    Offset(area.left, area.bottom),
    axisPaint,
  );
  if (xLabel.isNotEmpty) {
    _drawStaticLabel(canvas, xLabel, Offset(area.right - 24, area.bottom + 8));
  }
  if (yLabel.isNotEmpty) {
    _drawStaticLabel(canvas, yLabel, Offset(area.left - 20, area.top - 18));
  }
}

void _drawBox(Canvas canvas, Rect rect) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, const Radius.circular(10)),
    Paint()
      ..color = Colors.grey.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, const Radius.circular(10)),
    Paint()
      ..color = Colors.grey.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke,
  );
}

void _drawStaticLabel(Canvas canvas, String text, Offset offset) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  painter.paint(canvas, offset);
}
