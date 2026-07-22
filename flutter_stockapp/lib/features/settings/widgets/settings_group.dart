import 'package:flutter/material.dart';

import '../../../core/theme/app_theme_palette.dart';
import '../settings_models.dart';
import 'settings_row.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.group,
    this.onRowTap,
    this.onToggleChanged,
    this.onThemeModeChanged,
    this.initialThemeMode = ThemeMode.system,
    super.key,
  });

  final SettingsGroupData group;
  final ValueChanged<String>? onRowTap;
  final void Function(String rowId, bool value)? onToggleChanged;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Container(
      decoration: BoxDecoration(
        color: palette.groupBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (var i = 0; i < group.rows.length; i++) ...[
            SettingsRow(
              data: group.rows[i],
              onRowTap: onRowTap,
              onToggleChanged: onToggleChanged,
              onThemeModeChanged: onThemeModeChanged,
              initialThemeMode: initialThemeMode,
            ),
            if (i != group.rows.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Divider(height: 1, thickness: 1, color: palette.divider),
              ),
          ],
        ],
      ),
    );
  }
}
