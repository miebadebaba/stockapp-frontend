import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_palette.dart';

class ActionCard extends StatelessWidget {
  const ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: palette.groupBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: palette.primaryText, size: 24),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: palette.secondaryText,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: palette.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
