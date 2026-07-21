import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'pressable_scale.dart';

enum AppButtonVariant { primary, secondary, dark }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.expanded = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AppButtonVariant variant;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final isDark =
        variant == AppButtonVariant.primary || variant == AppButtonVariant.dark;
    final borderColor = variant == AppButtonVariant.secondary
        ? AppColors.outlineSoft
        : Colors.transparent;
    final foreground = isDark ? Colors.white : AppColors.textPrimary;
    final background = isDark ? AppColors.ctaBlack : AppColors.ctaWhiteOutline;

    final content = Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: foreground, size: 24),
              child: icon!,
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );

    return PressableScale(
      onTap: onPressed,
      enabled: onPressed != null,
      child: expanded
          ? SizedBox(width: double.infinity, child: content)
          : content,
    );
  }
}
