import 'package:flutter/material.dart';

import '../../core/theme/app_theme_palette.dart';
import '../../core/theme/app_typography.dart';
import '../navigation/app_top_actions.dart';
import '../settings/settings_models.dart';
import 'widgets/settings_group.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.groups,
    this.initialThemeMode = ThemeMode.system,
    this.contentBottomPadding = 180,
    this.onSettingsTap,
    this.onAvatarTap,
    this.onSearchChanged,
    this.onRowTap,
    this.onToggleChanged,
    this.onThemeModeChanged,
    super.key,
  });

  final List<SettingsGroupData> groups;
  final ThemeMode initialThemeMode;
  final double contentBottomPadding;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onAvatarTap;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onRowTap;
  final void Function(String rowId, bool value)? onToggleChanged;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: palette.pageBackground,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 18, 20, contentBottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Settings',
                      style: AppTypography.textTheme.displayLarge?.copyWith(
                        fontSize: 42,
                        color: palette.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AppTopActions(
                    onSettingsTap: onSettingsTap,
                    onProfileTap: onAvatarTap,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: palette.searchBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: palette.secondaryText,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: onSearchChanged,
                        style: textTheme.bodyLarge?.copyWith(
                          color: palette.primaryText,
                        ),
                        cursorColor: palette.primaryText,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: textTheme.bodyLarge?.copyWith(
                            color: palette.secondaryText,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.mic_none_rounded,
                      color: palette.secondaryText,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              for (var i = 0; i < groups.length; i++) ...[
                SettingsGroup(
                  group: groups[i],
                  initialThemeMode: initialThemeMode,
                  onRowTap: onRowTap,
                  onToggleChanged: onToggleChanged,
                  onThemeModeChanged: onThemeModeChanged,
                ),
                if (i != groups.length - 1) const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
