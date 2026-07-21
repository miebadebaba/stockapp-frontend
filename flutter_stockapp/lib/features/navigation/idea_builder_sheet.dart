import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/glass_orb_icon.dart';

class IdeaBuilderSheet extends StatelessWidget {
  const IdeaBuilderSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.84,
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.outlineSoft,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const Spacer(),
              const _DigestCard(),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Refresh ideas',
                icon: const Icon(Icons.refresh_rounded),
                variant: AppButtonVariant.secondary,
                expanded: false,
                onPressed: () {},
              ),
              const Spacer(flex: 2),
              const _FloatingPromptBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DigestCard extends StatelessWidget {
  const _DigestCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 52, 26, 32),
      decoration: BoxDecoration(
        color: AppColors.accentCyanCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const GlassOrbIcon(
            size: 104,
            colors: [AppColors.accentCyanCardSoft, AppColors.orbBlueDeep],
            icon: Icons.newspaper_rounded,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Curated News Digest',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: AppColors.accentCyanTextDark),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'A personalized daily summary based on your interests.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.accentCyanTextMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Divider(color: AppColors.accentCyanTextMuted.withValues(alpha: 0.18)),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Because you love to stay updated on what matters.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: AppColors.accentCyanTextMuted),
          ),
        ],
      ),
    );
  }
}

class _FloatingPromptBar extends StatelessWidget {
  const _FloatingPromptBar();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: 72,
      borderRadius: AppRadius.pill,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.surfaceMuted,
            child: Icon(Icons.add_rounded, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'What should we make?',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.surfaceMuted,
            child: Icon(Icons.mic_none_rounded, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
