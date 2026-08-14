import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import '../navigation/app_top_actions.dart';
import '../quant/selected_stock.dart';
import '../settings/widgets/appearance_segmented_control.dart';
import '../watchlist/watchlist_controller.dart';
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
    this.watchlistController,
    this.onTopProfileTap,
    this.onProfileTap,
    this.onPrimaryActionTap,
    this.onSecondaryActionTap,
    this.onRateUsTap,
    this.onHelpCenterTap,
    this.onAboutTap,
    this.onSignOutTap,
    this.initialThemeMode = ThemeMode.system,
    this.onThemeModeChanged,
    this.bottomContentPadding = 140,
    super.key,
  });

  final String userName;
  final bool showBadge;
  final String badgeText;
  final List<ProfileStatData> profileStats;
  final WatchlistController? watchlistController;
  final VoidCallback? onTopProfileTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onPrimaryActionTap;
  final VoidCallback? onSecondaryActionTap;
  final VoidCallback? onRateUsTap;
  final VoidCallback? onHelpCenterTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onSignOutTap;
  final ThemeMode initialThemeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final double bottomContentPadding;

  @override
  Widget build(BuildContext context) {
    final controller = watchlistController;
    if (controller == null) {
      return _buildPage(context, const []);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => _buildPage(context, controller.stocks),
    );
  }

  Widget _buildPage(BuildContext context, List<SelectedStock> watchlistStocks) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final watchlistCount = watchlistStocks.length;
    final watchlistDescription = watchlistCount == 0
        ? 'Syncs with stars you save on stock detail pages.'
        : '$watchlistCount saved ${watchlistCount == 1 ? 'ticker' : 'tickers'}, synced with stock detail.';
    final effectiveProfileStats = _resolveProfileStats(watchlistCount);
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
                      child: AppTopActions(onProfileTap: onTopProfileTap),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ProfileHeaderCard(
                      userName: userName,
                      showBadge: showBadge,
                      badgeText: badgeText,
                      stats: effectiveProfileStats,
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
                            description: watchlistDescription,
                            onTap: onSecondaryActionTap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _WatchlistPreviewSection(
                      stocks: watchlistStocks,
                      onTap: onSecondaryActionTap,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _PreferencesSection(
                      initialThemeMode: initialThemeMode,
                      onThemeModeChanged: onThemeModeChanged,
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

  List<ProfileStatData> _resolveProfileStats(int watchlistCount) {
    final resolvedStats = <ProfileStatData>[];
    var replacedWatchlistStat = false;

    for (final stat in profileStats) {
      final normalizedLabel = stat.label.trim().toLowerCase();
      if (normalizedLabel.startsWith('watchlist')) {
        resolvedStats.add(
          ProfileStatData(value: '$watchlistCount', label: stat.label),
        );
        replacedWatchlistStat = true;
      } else {
        resolvedStats.add(stat);
      }
    }

    if (!replacedWatchlistStat) {
      resolvedStats.add(
        ProfileStatData(value: '$watchlistCount', label: 'Watchlist'),
      );
    }

    return resolvedStats;
  }
}

class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection({
    required this.initialThemeMode,
    this.onThemeModeChanged,
  });

  final ThemeMode initialThemeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.groupBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: palette.primaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: palette.segmentBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: palette.primaryText,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: palette.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose how StockApp looks for you.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppearanceSegmentedControl(
            initialMode: initialThemeMode,
            modes: const [ThemeMode.light, ThemeMode.dark],
            onThemeModeChanged: onThemeModeChanged,
          ),
        ],
      ),
    );
  }
}

class _WatchlistPreviewSection extends StatelessWidget {
  const _WatchlistPreviewSection({required this.stocks, this.onTap});

  final List<SelectedStock> stocks;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;
    final previewStocks = stocks.reversed.take(3).toList(growable: false);
    final remainingCount = stocks.length - previewStocks.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: palette.groupBackground,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Watchlist',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: palette.primaryText,
                      ),
                    ),
                  ),
                  Text(
                    '${stocks.length}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: palette.secondaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: palette.secondaryText,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (previewStocks.isEmpty)
                Text(
                  'Open a stock detail page and tap the star to add it here.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.secondaryText,
                    height: 1.45,
                  ),
                )
              else ...[
                for (var index = 0; index < previewStocks.length; index++) ...[
                  _WatchlistPreviewRow(stock: previewStocks[index]),
                  if (index != previewStocks.length - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
                if (remainingCount > 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '$remainingCount more in your synced watchlist',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WatchlistPreviewRow extends StatelessWidget {
  const _WatchlistPreviewRow({required this.stock});

  final SelectedStock stock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;
    final code = stock.code.trim().toUpperCase();
    final badgeText = code.length <= 2 ? code : code.substring(0, 2);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.segmentBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            badgeText,
            style: theme.textTheme.labelLarge?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.primaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stock.name.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: palette.secondaryText,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
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
