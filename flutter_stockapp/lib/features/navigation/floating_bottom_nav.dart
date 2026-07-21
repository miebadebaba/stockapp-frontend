import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/pressable_scale.dart';

class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({
    required this.selectedIndex,
    required this.onChanged,
    required this.onAdd,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onAdd;

  static const _items = [
    _NavItem(icon: Icons.search_rounded, label: 'Search'),
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.auto_awesome_outlined, label: 'Explore'),
  ];

  @override
  Widget build(BuildContext context) {
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
              blur: 30,
              opacity: 0.52,
              height: 76,
              borderRadius: AppRadius.pill,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / _items.length;
                  return Stack(
                    children: [
                      const Positioned.fill(child: _LiquidGlassTint()),
                      const Positioned.fill(child: _SpecularLine()),
                      const Positioned.fill(child: _LiquidLightSweep()),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOutCubic,
                        left: selectedIndex * itemWidth,
                        top: 0,
                        bottom: 0,
                        width: itemWidth,
                        child: const _LiquidSelectionIndicator(),
                      ),
                      Row(
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
                    ],
                  );
                },
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
                color: AppColors.ctaBlack,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ctaBlack.withValues(alpha: 0.24),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: AppColors.surfaceCard.withValues(alpha: 0.7),
                    blurRadius: 14,
                    offset: const Offset(-4, -5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiquidGlassTint extends StatelessWidget {
  const _LiquidGlassTint();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceCard.withValues(alpha: 0.56),
            AppColors.accentCyanCard.withValues(alpha: 0.12),
            AppColors.bgGradientLavenderStart.withValues(alpha: 0.22),
            AppColors.surfaceCard.withValues(alpha: 0.44),
          ],
          stops: const [0, 0.36, 0.72, 1],
        ),
      ),
    );
  }
}

class _SpecularLine extends StatelessWidget {
  const _SpecularLine();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 1.2,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.surfaceCard.withValues(alpha: 0.86),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidLightSweep extends StatefulWidget {
  const _LiquidLightSweep();

  @override
  State<_LiquidLightSweep> createState() => _LiquidLightSweepState();
}

class _LiquidLightSweepState extends State<_LiquidLightSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FractionalTranslation(
          translation: Offset(-0.6 + _controller.value * 1.2, 0),
          child: child,
        );
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Transform.rotate(
          angle: -0.28,
          child: Container(
            width: 86,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.surfaceCard.withValues(alpha: 0.28),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidSelectionIndicator extends StatelessWidget {
  const _LiquidSelectionIndicator();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceCard.withValues(alpha: 0.84),
            AppColors.surfaceMuted.withValues(alpha: 0.68),
            AppColors.accentCyanCard.withValues(alpha: 0.20),
          ],
        ),
        border: Border.all(
          color: AppColors.surfaceCard.withValues(alpha: 0.62),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyanCard.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
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
