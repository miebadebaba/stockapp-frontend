import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    this.blur = 20,
    this.opacity = 0.64,
    this.borderRadius = AppRadius.pill,
    this.padding = EdgeInsets.zero,
    this.width,
    this.height,
    super.key,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    // True glass is reserved for floating controls, matching the product brief.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 34,
            offset: Offset(0, 16),
          ),
        ],
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
              color: AppColors.surfaceCard.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.surfaceCard.withValues(alpha: 0.46),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
