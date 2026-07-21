import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GlassOrbIcon extends StatefulWidget {
  const GlassOrbIcon({
    required this.size,
    required this.colors,
    this.icon,
    this.child,
    this.animate = true,
    super.key,
  });

  final double size;
  final List<Color> colors;
  final IconData? icon;
  final Widget? child;
  final bool animate;

  @override
  State<GlassOrbIcon> createState() => _GlassOrbIconState();
}

class _GlassOrbIconState extends State<GlassOrbIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant GlassOrbIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final lift = widget.animate
            ? math.sin(_controller.value * math.pi) * 3
            : 0.0;
        return Transform.translate(
          offset: Offset(0, -lift),
          child: SizedBox.square(
            dimension: widget.size,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowSoft,
                    blurRadius: 26,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.28, -0.35),
                          radius: 0.95,
                          colors: widget.colors,
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: _OrbPatternPainter(widget.colors.last),
                    ),
                    Center(child: child),
                    Positioned(
                      left: widget.size * (0.18 + _controller.value * 0.08),
                      top: widget.size * 0.08,
                      child: Transform.rotate(
                        angle: -0.55,
                        child: Container(
                          width: widget.size * 0.42,
                          height: widget.size * 0.16,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.48),
                            borderRadius: BorderRadius.circular(widget.size),
                          ),
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.28),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.20),
                          ],
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.62),
                          width: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      child:
          widget.child ??
          Icon(
            widget.icon ?? Icons.auto_awesome,
            color: Colors.white.withValues(alpha: 0.92),
            size: widget.size * 0.36,
          ),
    );
  }
}

class _OrbPatternPainter extends CustomPainter {
  const _OrbPatternPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.26 + i * 0.12);
      canvas.drawArc(
        Rect.fromLTWH(
          size.width * 0.2,
          y,
          size.width * 0.6,
          size.height * 0.22,
        ),
        math.pi * 0.08,
        math.pi * 0.84,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
