import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_palette.dart';

class ProfileStatData {
  const ProfileStatData({required this.value, required this.label});

  final String value;
  final String label;
}

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.userName,
    required this.stats,
    this.avatar,
    this.showBadge = false,
    this.badgeText = 'PREMIUM',
    this.onProfileTap,
    super.key,
  });

  final String userName;
  final List<ProfileStatData> stats;
  final Widget? avatar;
  final bool showBadge;
  final String badgeText;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onProfileTap,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? palette.groupBackground : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  avatar ?? const _DefaultAvatar(),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (showBadge) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlueLink.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Text(
                              badgeText,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.accentBlueLink,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: palette.secondaryText,
                    size: 24,
                  ),
                ],
              ),
              if (stats.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    for (var i = 0; i < stats.length; i++)
                      Expanded(
                        child: _ProfileStat(
                          data: stats[i],
                          alignEnd: i == stats.length - 1,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: const BoxDecoration(
        color: AppColors.accentCyanCardSoft,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 34,
        color: AppColors.accentCyanTextDark,
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.data, required this.alignEnd});

  final ProfileStatData data;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          data.value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          data.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: palette.secondaryText,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
