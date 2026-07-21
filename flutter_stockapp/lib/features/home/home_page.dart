import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/animated_page_wrapper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedPageWrapper(
      child: ColoredBox(
        color: AppColors.bgPrimary,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.xl,
                AppSpacing.page,
                0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RoundIconButton(icon: Icons.notifications_none_rounded),
                  SizedBox(width: AppSpacing.md),
                  _ProfileAvatar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.textPrimary, size: 27),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.accentCyanCardSoft,
      child: Icon(Icons.person_rounded, color: AppColors.accentCyanTextDark),
    );
  }
}
