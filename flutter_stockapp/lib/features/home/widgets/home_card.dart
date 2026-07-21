import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_page_wrapper.dart';
import '../../../core/widgets/glass_orb_icon.dart';
import 'creator_tag.dart';

class HomeCardData {
  const HomeCardData({
    required this.title,
    required this.creator,
    required this.orbColors,
    required this.icon,
    required this.avatarColor,
    this.active = false,
  });

  final String title;
  final String creator;
  final List<Color> orbColors;
  final IconData icon;
  final Color avatarColor;
  final bool active;
}

class HomeCard extends StatelessWidget {
  const HomeCard({required this.data, required this.index, super.key});

  final HomeCardData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AnimatedPageWrapper(
      delay: Duration(milliseconds: index * 45),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 22,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final orbSize = constraints.maxWidth * 0.72;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    GlassOrbIcon(
                      size: orbSize,
                      colors: data.orbColors,
                      icon: data.icon,
                      animate: data.active,
                    ),
                    Positioned(
                      bottom: -12,
                      child: CreatorTag(
                        name: data.creator,
                        avatarColor: data.avatarColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  data.title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: data.active
                        ? AppColors.accentBlueLink
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
