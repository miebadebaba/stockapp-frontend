import 'package:flutter/material.dart';

import 'settings_models.dart';
import 'settings_page.dart';

class SettingsPreviewPage extends StatefulWidget {
  const SettingsPreviewPage({
    required this.themeMode,
    required this.onThemeModeChanged,
    this.onSettingsTap,
    this.onAvatarTap,
    this.bottomPadding = 140,
    super.key,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onAvatarTap;
  final double bottomPadding;

  @override
  State<SettingsPreviewPage> createState() => _SettingsPreviewPageState();
}

class _SettingsPreviewPageState extends State<SettingsPreviewPage> {
  late final List<SettingsGroupData> _groups = [
    SettingsGroupData(
      rows: const [
        SettingsRowData(
          id: 'wifi',
          icon: Icons.wifi_rounded,
          iconBackgroundColor: Color(0xFF007AFF),
          title: 'Wi-Fi',
          type: SettingsRowType.navigation,
          trailingText: 'Office-5G',
          showChevron: true,
        ),
        SettingsRowData(
          id: 'bluetooth',
          icon: Icons.bluetooth_rounded,
          iconBackgroundColor: Color(0xFF0A84FF),
          title: 'Bluetooth',
          type: SettingsRowType.navigation,
          trailingText: 'On',
          showChevron: true,
        ),
        SettingsRowData(
          id: 'airplane',
          icon: Icons.flight_rounded,
          iconBackgroundColor: Color(0xFFFF9500),
          title: 'Airplane Mode',
          type: SettingsRowType.toggle,
          toggleValue: false,
        ),
      ],
    ),
    SettingsGroupData(
      rows: const [
        SettingsRowData(
          id: 'general',
          icon: Icons.settings_rounded,
          iconBackgroundColor: Color(0xFF8E8E93),
          title: 'General',
          type: SettingsRowType.navigation,
          showChevron: true,
        ),
        SettingsRowData(
          id: 'display',
          icon: Icons.wb_sunny_rounded,
          iconBackgroundColor: Color(0xFFFFCC00),
          title: 'Display & Brightness',
          type: SettingsRowType.navigation,
          showChevron: true,
        ),
        SettingsRowData(
          id: 'appearance',
          icon: Icons.palette_outlined,
          iconBackgroundColor: Color(0xFF34C759),
          title: 'Appearance',
          type: SettingsRowType.appearance,
        ),
      ],
    ),
    SettingsGroupData(
      rows: const [
        SettingsRowData(
          id: 'notifications',
          icon: Icons.notifications_none_rounded,
          iconBackgroundColor: Color(0xFFFF3B30),
          title: 'Notifications',
          type: SettingsRowType.navigation,
          showChevron: true,
        ),
        SettingsRowData(
          id: 'privacy',
          icon: Icons.lock_outline_rounded,
          iconBackgroundColor: Color(0xFF5856D6),
          title: 'Privacy',
          type: SettingsRowType.navigation,
          showChevron: true,
        ),
      ],
    ),
  ];
  final Map<String, bool> _toggles = {'airplane': false};

  List<SettingsGroupData> get _effectiveGroups {
    return _groups
        .map(
          (group) => SettingsGroupData(
            rows: group.rows
                .map(
                  (row) => row.type == SettingsRowType.toggle
                      ? SettingsRowData(
                          id: row.id,
                          icon: row.icon,
                          iconBackgroundColor: row.iconBackgroundColor,
                          title: row.title,
                          type: row.type,
                          trailingText: row.trailingText,
                          showChevron: row.showChevron,
                          toggleValue: _toggles[row.id] ?? row.toggleValue,
                        )
                      : row,
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      groups: _effectiveGroups,
      initialThemeMode: widget.themeMode,
      contentBottomPadding: widget.bottomPadding + 32,
      onSettingsTap: widget.onSettingsTap,
      onAvatarTap: widget.onAvatarTap,
      onSearchChanged: (_) {},
      onRowTap: (_) {},
      onToggleChanged: (rowId, value) {
        setState(() => _toggles[rowId] = value);
      },
      onThemeModeChanged: widget.onThemeModeChanged,
    );
  }
}
