import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_palette.dart';

class StockListItemData {
  const StockListItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.changePercent,
  });

  final String id;
  final String title;
  final String subtitle;
  final double changePercent;
}

class StockListSection extends StatelessWidget {
  const StockListSection({
    required this.titleText,
    required this.stocks,
    this.onTitleTap,
    this.onStockTap,
    super.key,
  });

  final String titleText;
  final List<StockListItemData> stocks;
  final VoidCallback? onTitleTap;
  final ValueChanged<String>? onStockTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: onTitleTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titleText,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 30,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: palette.primaryText,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ListView.separated(
          itemCount: stocks.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final stock = stocks[index];
            return _StockListTile(
              stock: stock,
              onTap: onStockTap == null ? null : () => onStockTap!(stock.id),
            );
          },
          separatorBuilder: (context, index) {
            return Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              color: palette.divider,
            );
          },
        ),
      ],
    );
  }
}

class _StockListTile extends StatelessWidget {
  const _StockListTile({required this.stock, this.onTap});

  final StockListItemData stock;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isPositive = stock.changePercent >= 0;
    final badgeColor = isPositive
        ? const Color(0xFFDE7557)
        : const Color(0xFF2D9B68);
    final sign = isPositive ? '+' : '';
    final percentLabel = '$sign${stock.changePercent.toStringAsFixed(2)}%';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        splashColor: palette.rowPressedOverlay,
        highlightColor: Colors.transparent,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: palette.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      stock.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: palette.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  percentLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
