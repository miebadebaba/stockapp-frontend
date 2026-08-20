import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_backtest_robustness.dart';

class QuantBacktestRobustnessSection extends StatelessWidget {
  const QuantBacktestRobustnessSection({required this.result, super.key});

  final QuantBacktestRobustnessResult result;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '多时间窗口验证',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '将同一参数放入连续历史阶段分别回测，观察结果是否只在单一时期有效。',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        _RobustnessInsightCard(result: result),
        if (result.windows.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          for (var index = 0; index < result.windows.length; index++) ...[
            _RobustnessWindowRow(window: result.windows[index]),
            if (index < result.windows.length - 1)
              const Divider(height: AppSpacing.xl),
          ],
        ],
      ],
    );
  }
}

class _RobustnessInsightCard extends StatelessWidget {
  const _RobustnessInsightCard({required this.result});

  final QuantBacktestRobustnessResult result;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Semantics(
      container: true,
      label: '多时间窗口解读',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: palette.cardBackground,
          border: Border.all(color: palette.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '稳定性解读',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _robustnessInsight(result),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.primaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '每个阶段至少完成 ${QuantBacktestRobustnessResult.minimumTradeCount} 笔交易才纳入判断；'
              '历史阶段表现不代表未来收益。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.secondaryText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RobustnessWindowRow extends StatelessWidget {
  const _RobustnessWindowRow({required this.window});

  final QuantBacktestWindowResult window;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final backtest = window.result;
    final hasTrades = backtest.tradeCount > 0;

    return Semantics(
      container: true,
      label: window.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  window.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                window.isReferenceable ? '样本可用' : '样本不足',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: window.isReferenceable
                      ? const Color(0xFF0EA078)
                      : const Color(0xFFE08A00),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            backtest.hasBacktestPeriod
                ? '${_formatDate(backtest.backtestStartDate!)} 至 ${_formatDate(backtest.backtestEndDate!)}'
                : '历史数据不足，无法形成完整阶段回测。',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '交易 ${backtest.tradeCount} 笔 · 净收益 '
            '${hasTrades ? _signedPercent(backtest.cumulativeReturn) : '--'} · '
            '超额收益 ${backtest.hasEquityComparison ? _signedPercent(backtest.excessReturn) : '--'}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.primaryText),
          ),
        ],
      ),
    );
  }
}

String _robustnessInsight(QuantBacktestRobustnessResult result) {
  final referenceable = result.referenceableWindows.length;
  final total = result.windows.length;

  return switch (result.level) {
    QuantBacktestRobustnessLevel.stable =>
      '共有 $referenceable 个样本充足的历史阶段，策略均跑赢同期买入持有基准，历史表现相对稳定。',
    QuantBacktestRobustnessLevel.mixed =>
      '共有 $referenceable 个样本充足的历史阶段，但部分阶段未跑赢同期基准，策略表现随市场阶段变化较大。',
    QuantBacktestRobustnessLevel.insufficient when total == 0 =>
      '历史数据不足，暂时无法拆分出可验证的回测阶段。',
    QuantBacktestRobustnessLevel.insufficient =>
      '当前仅有 $referenceable 个阶段达到至少 ${QuantBacktestRobustnessResult.minimumTradeCount} 笔交易，样本不足，暂不判断策略稳定性。',
  };
}

String _signedPercent(double value) {
  final sign = value > 0 ? '+' : '';
  return '$sign${(value * 100).toStringAsFixed(2)}%';
}

String _formatDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
