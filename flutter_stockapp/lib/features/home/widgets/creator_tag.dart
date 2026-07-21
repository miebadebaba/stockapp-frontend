import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class CreatorTag extends StatelessWidget {
  const CreatorTag({required this.name, required this.avatarColor, super.key});

  final String name;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 6, 12, 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.outlineSoft),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: avatarColor,
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
