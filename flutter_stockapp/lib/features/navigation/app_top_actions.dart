import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_palette.dart';

class AppTopActions extends StatelessWidget {
  const AppTopActions({this.onProfileTap, super.key});

  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return _ProfileAvatar(onTap: onProfileTap);
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
