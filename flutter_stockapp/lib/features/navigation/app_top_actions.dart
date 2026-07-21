import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppTopActions extends StatelessWidget {
  const AppTopActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _RoundIconButton(icon: Icons.search_rounded),
        SizedBox(width: 12),
        _ProfileAvatar(),
      ],
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
