import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class IdeaBuilderSheet extends StatelessWidget {
  const IdeaBuilderSheet({
    this.onNewsTap,
    this.onTutorialTap,
    this.onForumTap,
    this.onSimulationTap,
    super.key,
  });

  final VoidCallback? onNewsTap;
  final VoidCallback? onTutorialTap;
  final VoidCallback? onForumTap;
  final VoidCallback? onSimulationTap;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return GlassContainer(
      width: screenSize.width > 408 ? 344 : screenSize.width - 40,
      height: screenSize.height > 760 ? 360 : screenSize.height * 0.46,
      blur: 32,
      opacity: 0.28,
      borderRadius: 28,
      showShadow: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          physics: const BouncingScrollPhysics(),
          primary: false,
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: [
            _GlassNavigationButton(
              icon: Icons.newspaper_rounded,
              label: 'News',
              onTap: onNewsTap,
            ),
            _GlassNavigationButton(
              icon: Icons.menu_book_rounded,
              label: 'Tutorial',
              onTap: onTutorialTap,
            ),
            _GlassNavigationButton(
              icon: Icons.forum_rounded,
              label: 'Forum',
              onTap: onForumTap,
            ),
            _GlassNavigationButton(
              icon: Icons.science_rounded,
              label: 'Simulation',
              onTap: onSimulationTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassNavigationButton extends StatelessWidget {
  const _GlassNavigationButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.surfaceCard.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: AppColors.textPrimary),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
