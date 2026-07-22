import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/pressable_scale.dart';

class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({
    required this.selectedIndex,
    required this.onChanged,
    required this.onAdd,
    this.addActive = false,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onAdd;
  final bool addActive;

  static const _items = [
    _NavItem(icon: Icons.support_agent_rounded, label: 'Agent'),
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.auto_awesome_outlined, label: 'Quant'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.bottomBarGap,
      ),
      child: Row(
        children: [
          Expanded(
            child: GlassContainer(
              blur: 24,
              opacity: 0.60,
              height: 76,
              borderRadius: AppRadius.pill,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: _NavButton(
                        item: _items[i],
                        selected: selectedIndex == i,
                        onTap: () => onChanged(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          PressableScale(
            onTap: onAdd,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: isDark ? palette.groupBackground : AppColors.ctaBlack,
                shape: BoxShape.circle,
                border: addActive
                    ? Border.all(
                        color: palette.primaryText.withValues(alpha: 0.20),
                        width: 1.5,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.ctaBlack)
                        .withValues(alpha: 0.24),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: palette.groupBackground.withValues(
                      alpha: isDark ? 0.20 : 0.70,
                    ),
                    blurRadius: 14,
                    offset: const Offset(-4, -5),
                  ),
                ],
              ),
              child: Icon(
                addActive ? Icons.close_rounded : Icons.add_rounded,
                color: isDark ? palette.primaryText : Colors.white,
                size: 34,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return PressableScale(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: selected ? 1.04 : 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 27,
              color: selected ? palette.primaryText : palette.secondaryText,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? palette.primaryText : palette.secondaryText,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
