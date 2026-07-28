import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'models/paper_portfolio.dart';
import 'widgets/holdings_list.dart';
import 'widgets/portfolio_summary.dart';

class PaperTradingPage extends StatelessWidget {
  const PaperTradingPage({this.portfolio = PaperPortfolio.mock, super.key});

  final PaperPortfolio portfolio;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Scaffold(
      backgroundColor: palette.pageBackground,
      appBar: AppBar(
        backgroundColor: palette.pageBackground,
        foregroundColor: palette.primaryText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '模拟交易',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '模拟练习区',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: palette.secondaryText, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TradingActionBar(),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(title: '资产概览', palette: palette),
                  const SizedBox(height: AppSpacing.md),
                  PortfolioSummary(summary: portfolio.summary),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(title: '持仓股票', palette: palette),
                  const SizedBox(height: AppSpacing.md),
                  HoldingsList(holdings: portfolio.holdings),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.palette});

  final String title;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(color: palette.primaryText, fontWeight: FontWeight.w800),
    );
  }
}

class _TradingActionBar extends StatelessWidget {
  const _TradingActionBar();

  static const _actions = [
    _TradingActionData(label: '买入', icon: Icons.add_shopping_cart_rounded),
    _TradingActionData(label: '卖出', icon: Icons.sell_outlined),
    _TradingActionData(label: '撤单', icon: Icons.cancel_schedule_send_rounded),
    _TradingActionData(
      label: '持仓',
      icon: Icons.pie_chart_outline_rounded,
      selected: true,
    ),
    _TradingActionData(label: '查询', icon: Icons.manage_search_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.groupBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        children: [
          for (final action in _actions)
            Expanded(
              child: _TradingActionButton(
                action: action,
                palette: palette,
                onTap: action.selected
                    ? null
                    : () => _showPendingMessage(context),
              ),
            ),
        ],
      ),
    );
  }

  void _showPendingMessage(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('功能待接入'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _TradingActionData {
  const _TradingActionData({
    required this.label,
    required this.icon,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
}

class _TradingActionButton extends StatelessWidget {
  const _TradingActionButton({
    required this.action,
    required this.palette,
    required this.onTap,
  });

  final _TradingActionData action;
  final AppThemePalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;
    return Material(
      color: action.selected
          ? selectedColor.withValues(alpha: 0.12)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                action.icon,
                size: 21,
                color: action.selected ? selectedColor : palette.secondaryText,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: action.selected
                      ? selectedColor
                      : palette.secondaryText,
                  fontWeight: action.selected
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
