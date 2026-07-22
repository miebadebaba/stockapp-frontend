import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme_palette.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    this.blur = 20,
    this.opacity = 0.64,
    this.borderRadius = AppRadius.pill,
    this.padding = EdgeInsets.zero,
    this.width,
    this.height,
    this.showShadow = true,
    super.key,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // True glass is reserved for floating controls, matching the product brief.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: palette.primaryText.withValues(
                    alpha: isDark ? 0.18 : 0.12,
                  ),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: palette.groupBackground.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: palette.primaryText.withValues(
                  alpha: isDark ? 0.12 : 0.08,
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
