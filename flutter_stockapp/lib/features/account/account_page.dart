import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import '../navigation/app_top_actions.dart';
import 'widgets/action_card.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/settings_list_section.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({
    this.userName = 'Avery Coleman',
    this.showBadge = true,
    this.badgeText = 'PREMIUM',
    this.profileStats = const [
      ProfileStatData(value: '12', label: 'Positions'),
      ProfileStatData(value: '\$24.8K', label: 'Balance'),
      ProfileStatData(value: '4', label: 'Watchlists'),
    ],
    this.onSettingsTap,
    this.onTopProfileTap,
    this.onProfileTap,
    this.onPrimaryActionTap,
    this.onSecondaryActionTap,
    this.onRateUsTap,
    this.onHelpCenterTap,
    this.onPreferencesTap,
    this.onAboutTap,
    this.onSignOutTap,
    this.bottomContentPadding = 140,
    super.key,
  });

  final String userName;
  final bool showBadge;
  final String badgeText;
  final List<ProfileStatData> profileStats;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onTopProfileTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onPrimaryActionTap;
  final VoidCallback? onSecondaryActionTap;
  final VoidCallback? onRateUsTap;
  final VoidCallback? onHelpCenterTap;
  final VoidCallback? onPreferencesTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onSignOutTap;
  final double bottomContentPadding;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final settingsItems = [
      SettingsListItemData(
        icon: Icons.favorite_border_rounded,
        label: 'Rate us',
        onTap: onRateUsTap,
      ),
      SettingsListItemData(
        icon: Icons.help_outline_rounded,
        label: 'Help Center',
        onTap: onHelpCenterTap,
      ),
      SettingsListItemData(
        icon: Icons.tune_rounded,
        label: 'Preferences',
        onTap: onPreferencesTap,
      ),
      SettingsListItemData(
        icon: Icons.info_outline_rounded,
        label: 'About',
        showChevron: true,
        onTap: onAboutTap,
      ),
    ];

    return ColoredBox(
      color: palette.pageBackground,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 24, 24, bottomContentPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: AnimatedPageWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: AppTopActions(
                        onSettingsTap: onSettingsTap,
                        onProfileTap: onTopProfileTap,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ProfileHeaderCard(
                      userName: userName,
                      showBadge: showBadge,
                      badgeText: badgeText,
                      stats: profileStats,
                      onProfileTap: onProfileTap,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: ActionCard(
                            icon: Icons.pie_chart_outline_rounded,
                            title: 'Portfolio',
                            description: 'Review your holdings and balance.',
                            onTap: onPrimaryActionTap,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ActionCard(
                            icon: Icons.bookmark_border_rounded,
                            title: 'Watchlist',
                            description: 'Track saved tickers and options.',
                            onTap: onSecondaryActionTap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SettingsListSection(items: settingsItems),
                    const SizedBox(height: AppSpacing.lg),
                    _SignOutRow(onTap: onSignOutTap),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignOutRow extends StatelessWidget {
  const _SignOutRow({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dangerColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFFF8A80)
        : AppColors.dangerSoft;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 22, color: dangerColor),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Sign out',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: dangerColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
