import 'package:flutter/material.dart';

import '../../../core/theme/app_theme_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../settings_models.dart';
import 'appearance_segmented_control.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.data,
    this.onRowTap,
    this.onToggleChanged,
    this.onThemeModeChanged,
    this.initialThemeMode = ThemeMode.system,
    super.key,
  });

  final SettingsRowData data;
  final ValueChanged<String>? onRowTap;
  final void Function(String rowId, bool value)? onToggleChanged;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final textTheme = Theme.of(context).textTheme;
    final isNavigation = data.type == SettingsRowType.navigation;

    if (data.type == SettingsRowType.appearance) {
      return Material(
        color: Colors.transparent,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: data.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  data.icon,
                  color: palette.iconTileForeground,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  data.title,
                  style: textTheme.titleMedium?.copyWith(
                    color: palette.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AppearanceSegmentedControl(
                initialMode: initialThemeMode,
                modes: const [ThemeMode.light, ThemeMode.dark],
                onThemeModeChanged: onThemeModeChanged,
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isNavigation ? () => onRowTap?.call(data.id) : null,
        splashColor: palette.rowPressedOverlay,
        highlightColor: Colors.transparent,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: data.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  data.icon,
                  color: palette.iconTileForeground,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  data.title,
                  style: textTheme.titleMedium?.copyWith(
                    color: palette.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _buildTrailing(context, palette, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    AppThemePalette palette,
    TextTheme textTheme,
  ) {
    switch (data.type) {
      case SettingsRowType.navigation:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (data.trailingText case final trailingText?)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Text(
                  trailingText,
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.secondaryText,
                  ),
                ),
              ),
            if (data.showChevron)
              Icon(
                Icons.chevron_right_rounded,
                color: palette.secondaryText,
                size: 22,
              ),
          ],
        );
      case SettingsRowType.toggle:
        return Switch.adaptive(
          value: data.toggleValue,
          onChanged: (value) => onToggleChanged?.call(data.id, value),
        );
      case SettingsRowType.appearance:
        return const SizedBox.shrink();
    }
  }
}
