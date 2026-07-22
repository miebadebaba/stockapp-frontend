import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_palette.dart';

class SettingsListItemData {
  const SettingsListItemData({
    required this.icon,
    required this.label,
    this.showChevron = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool showChevron;
  final VoidCallback? onTap;
}

class SettingsListSection extends StatelessWidget {
  const SettingsListSection({required this.items, super.key});

  final List<SettingsListItemData> items;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return ListView.separated(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: item.onTap,
            child: Ink(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Icon(item.icon, size: 22, color: palette.primaryText),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      item.label,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (item.showChevron)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: palette.secondaryText,
                    ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Container(height: 1, color: palette.divider);
      },
    );
  }
}
