import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';

class SimulationAppGuidePage extends StatelessWidget {
  const SimulationAppGuidePage({super.key});

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
        title: Text(
          '模拟交易与 App 使用',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedPageWrapper(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SingleChildScrollView(
                key: const ValueKey('simulation-app-guide-scroll'),
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _GuideSectionCard(
                      sequence: '01',
                      icon: Icons.apps_rounded,
                      title: '认识主要功能',
                      children: [
                        _GuideBullet('首页：查看市场行情和股票信息'),
                        _GuideBullet('AI助手：针对股票和市场问题提供辅助分析'),
                        _GuideBullet('量化分析：查看因子及量化分析结果'),
                        _GuideBullet('论坛：浏览和发布讨论内容'),
                        _GuideBullet('模拟交易：使用虚拟资金练习交易'),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    _GuideSectionCard(
                      sequence: '02',
                      icon: Icons.trending_up_rounded,
                      title: '开始模拟交易',
                      children: [
                        _GuideStep(number: 1, text: '进入模拟交易页面'),
                        _GuideStep(number: 2, text: '选择股票并输入买入数量'),
                        _GuideStep(number: 3, text: '确认订单'),
                        _GuideStep(number: 4, text: '在持仓和订单记录中查看结果'),
                        _GuideNote('可用资金不足时不能买入；当前模拟交易不支持卖空；未成交订单可以撤销。'),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    _GuideSectionCard(
                      sequence: '03',
                      icon: Icons.account_balance_wallet_rounded,
                      title: '查看账户与重置',
                      children: [
                        _GuideBullet('总资产：当前现金与持仓市值合计'),
                        _GuideBullet('总盈亏：相对初始模拟资金的累计变化'),
                        _GuideBullet('当日盈亏：当天产生的盈亏变化'),
                        _GuideBullet('如果希望重新开始，可使用“重置模拟账户”'),
                        _GuideNote('重置会清空持仓、订单和交易记录，并恢复初始模拟资金；重置前需要进行二次确认。'),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    _ReminderCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideSectionCard extends StatelessWidget {
  const _GuideSectionCard({
    required this.sequence,
    required this.icon,
    required this.title,
    required this.children,
  });

  final String sequence;
  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Container(
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    sequence,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: palette.secondaryText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(icon, color: palette.primaryText, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: palette.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ..._withSpacing(children),
          ],
        ),
      ),
    );
  }
}

class _GuideBullet extends StatelessWidget {
  const _GuideBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Icon(Icons.circle, size: 6, color: palette.secondaryText),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: palette.secondaryText,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.segmentBackground.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: palette.divider),
          ),
          child: Text(
            '$number',
            style: theme.textTheme.labelMedium?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: palette.secondaryText,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _GuideNote extends StatelessWidget {
  const _GuideNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.searchBackground.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: palette.primaryText, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.primaryText,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Container(
      decoration: BoxDecoration(
        color: palette.segmentBackground.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: palette.divider),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: palette.primaryText),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '使用提醒',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _GuideBullet('所有资金和交易均为模拟数据，不涉及真实资金'),
          const SizedBox(height: AppSpacing.sm),
          const _GuideBullet('行情数据可能存在延迟或使用备用数据'),
          const SizedBox(height: AppSpacing.sm),
          const _GuideBullet('AI和量化分析结果仅供学习参考，不构成投资建议'),
          const SizedBox(height: AppSpacing.sm),
          const _GuideBullet('发布论坛内容后可能需要等待管理员审核'),
        ],
      ),
    );
  }
}

List<Widget> _withSpacing(List<Widget> children) {
  return [
    for (var index = 0; index < children.length; index++) ...[
      children[index],
      if (index != children.length - 1) const SizedBox(height: AppSpacing.sm),
    ],
  ];
}
