import 'package:flutter/material.dart';

import '../../../core/theme/app_theme_palette.dart';

class AppearanceSegmentedControl extends StatefulWidget {
  const AppearanceSegmentedControl({
    this.initialMode = ThemeMode.system,
    this.modes = const [ThemeMode.light, ThemeMode.dark, ThemeMode.system],
    this.onThemeModeChanged,
    super.key,
  });

  final ThemeMode initialMode;
  final List<ThemeMode> modes;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  State<AppearanceSegmentedControl> createState() =>
      _AppearanceSegmentedControlState();
}

class _AppearanceSegmentedControlState
    extends State<AppearanceSegmentedControl> {
  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
  }

  @override
  void didUpdateWidget(covariant AppearanceSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMode != oldWidget.initialMode) {
      _selectedMode = widget.initialMode;
    }
  }

  void _selectMode(ThemeMode mode) {
    if (mode == _selectedMode) {
      return;
    }
    setState(() => _selectedMode = mode);
    widget.onThemeModeChanged?.call(mode);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final textTheme = Theme.of(context).textTheme;
    final options = widget.modes.map((mode) {
      return (
        mode: mode,
        label: switch (mode) {
          ThemeMode.light => 'Light',
          ThemeMode.dark => 'Dark',
          ThemeMode.system => 'System',
        },
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.segmentBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: () => _selectMode(option.mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedMode == option.mode
                        ? palette.segmentSelectedBackground
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    option.label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: _selectedMode == option.mode
                          ? palette.segmentSelectedText
                          : palette.secondaryText,
                      fontWeight: _selectedMode == option.mode
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
