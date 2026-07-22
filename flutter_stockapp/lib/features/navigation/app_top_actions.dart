import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_palette.dart';

class AppTopActions extends StatelessWidget {
  const AppTopActions({this.onSettingsTap, this.onProfileTap, super.key});

  final VoidCallback? onSettingsTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundIconButton(
          icon: Icons.settings_rounded,
          onTap: onSettingsTap,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? palette.groupBackground
              : AppColors.surfaceCard,
          iconColor: palette.primaryText,
        ),
        const SizedBox(width: 12),
        _ProfileAvatar(onTap: onProfileTap),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 27),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: CircleAvatar(
          radius: 22.5,
          backgroundColor: isDark
              ? palette.groupBackground
              : AppColors.accentCyanCardSoft,
          child: Icon(
            Icons.person_rounded,
            color: isDark ? palette.primaryText : AppColors.accentCyanTextDark,
          ),
        ),
      ),
    );
  }
}
