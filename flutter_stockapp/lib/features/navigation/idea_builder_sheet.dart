import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class IdeaBuilderSheet extends StatelessWidget {
  const IdeaBuilderSheet({super.key});

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
          children: const [
            _GlassNavigationButton(
              icon: Icons.newspaper_rounded,
              label: 'News',
            ),
            _GlassNavigationButton(
              icon: Icons.menu_book_rounded,
              label: 'Tutorial',
            ),
            _GlassNavigationButton(
              icon: Icons.forum_rounded,
              label: 'Forum',
            ),
            _GlassNavigationButton(
              icon: Icons.science_rounded,
              label: 'Simulation',
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassNavigationButton extends StatelessWidget {
  const _GlassNavigationButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {},
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
