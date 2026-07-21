import 'package:flutter/material.dart';

class AnimatedPageWrapper extends StatelessWidget {
  const AnimatedPageWrapper({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final effective = delay == Duration.zero
            ? value
            : ((value * (260 + delay.inMilliseconds) - delay.inMilliseconds) /
                      260)
                  .clamp(0.0, 1.0);
        return Opacity(
          opacity: effective,
          child: Transform.translate(
            offset: Offset(0, (1 - effective) * 14),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
