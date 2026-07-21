import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_orb_icon.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: -46,
                top: 18,
                child: GlassOrbIcon(
                  size: 54,
                  colors: const [AppColors.orbViolet, AppColors.orbBlueDeep],
                  icon: Icons.auto_graph_rounded,
                ),
              ),
              Positioned(
                right: -42,
                bottom: 8,
                child: GlassOrbIcon(
                  size: 48,
                  colors: const [AppColors.orbRose, AppColors.orbAmberDeep],
                  icon: Icons.trending_up_rounded,
                ),
              ),
              const GlassOrbIcon(
                size: 118,
                colors: [AppColors.accentCyanCard, AppColors.orbBlueDeep],
                icon: Icons.blur_on_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.md),
        Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
