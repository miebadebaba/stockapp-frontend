import 'package:flutter/material.dart';

enum SettingsRowType { navigation, toggle, appearance }

class SettingsGroupData {
  const SettingsGroupData({required this.rows});

  final List<SettingsRowData> rows;
}

class SettingsRowData {
  const SettingsRowData({
    required this.id,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.type,
    this.trailingText,
    this.showChevron = false,
    this.toggleValue = false,
  });

  final String id;
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final SettingsRowType type;
  final String? trailingText;
  final bool showChevron;
  final bool toggleValue;
}
