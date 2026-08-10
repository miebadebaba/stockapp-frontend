import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_backtest_equity_chart.dart';
import 'quant_factor_backtest.dart';

class QuantFactorBacktestSection extends StatelessWidget {
  const QuantFactorBacktestSection({
    required this.result,
    required this.isSimulated,
    super.key,
  });

  final QuantFactorBacktestResult result;
  final bool isSimulated;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final costs = result.costSettings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '多因子历史回测',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '风险调整分达到 '
          '${result.signalThreshold.toStringAsFixed(0)} '
          '后，于下一交易日开盘买入并持有 '
          '${result.holdingPeriod} 个交易日',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '成本假设：佣金双向 '
          '${_percent(costs.commissionRate)}，'
          '卖出印花税 ${_percent(costs.stampDutyRate)}，'
          '单边滑点 ${_percent(costs.slippageRate)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: palette.secondaryText,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (result.trades.isEmpty)
          Text(
            '当前历史区间内没有满足条件的完整交易。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.secondaryText,
              height: 1.5,
            ),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: _BacktestMetric(
                  label: '交易次数',
                  value: '${result.tradeCount}',
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _BacktestMetric(
                  label: '净胜率',
                  value: _percent(result.winRate),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _BacktestMetric(
                  label: '平均毛收益',
                  value: _signedPercent(result.averageGrossReturn),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _BacktestMetric(
                  label: '平均净收益',
                  value: _signedPercent(result.averageReturn),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _BacktestMetric(
                  label: '累计毛收益',
                  value: _signedPercent(result.grossCumulativeReturn),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _BacktestMetric(
                  label: '累计净收益',
                  value: _signedPercent(result.cumulativeReturn),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _BacktestMetric(
                  label: '平均成本影响',
                  value: _percent(result.averageCostRate),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _BacktestMetric(
                  label: '累计成本影响',
                  value: _percent(result.cumulativeCostImpact),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _BacktestMetric(
            label: '策略最大回撤',
            value: _percent(result.maximumDrawdown),
          ),
        ],
        if (result.hasEquityComparison) ...[
          const SizedBox(height: AppSpacing.xxl),
          Text(
            '策略与基准对比',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '比较多因子策略净值与同期买入并持有的表现',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _BacktestMetric(
                  label: '基准收益',
                  value: _signedPercent(result.benchmarkReturn),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _BacktestMetric(
                  label: '超额收益',
                  value: _signedPercent(result.excessReturn),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          QuantBacktestEquityChart(points: result.equityCurve),
        ],
        if (result.factorPerformances.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxl),
          Text(
            '因子历史表现',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '分别统计单项因子达到同一阈值后，未来 ${result.holdingPeriod} 个交易日的表现',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (
            var index = 0;
            index < result.factorPerformances.length;
            index++
          ) ...[
            _FactorPerformanceRow(
              performance: result.factorPerformances[index],
            ),
            if (index < result.factorPerformances.length - 1)
              const Divider(height: AppSpacing.xxl),
          ],
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: palette.secondaryText,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                isSimulated
                    ? '当前回测基于内置模拟数据，只用于验证功能流程，不能用于判断策略真实效果。'
                    : '回测已估算佣金、印花税和滑点，不代表未来收益；暂未考虑最低佣金、涨跌停及停牌限制。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FactorPerformanceRow extends StatelessWidget {
  const _FactorPerformanceRow({required this.performance});

  final QuantFactorHistoricalPerformance performance;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final hasSignals = performance.signalCount > 0;

    final summary = hasSignals
        ? '信号 ${performance.signalCount} 次 · '
              '胜率 ${_percent(performance.winRate)} · '
              '平均净收益 ${_signedPercent(performance.averageReturn)}'
        : '暂无满足条件的历史信号';

    return ExpansionTile(
      key: ValueKey('quant-factor-performance-${performance.factorId}'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: AppSpacing.md),
      title: Text(
        performance.label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: palette.primaryText,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        summary,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: _BacktestMetric(
                label: '信号次数',
                value: '${performance.signalCount}',
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _BacktestMetric(
                label: '胜率',
                value: hasSignals ? _percent(performance.winRate) : '--',
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _BacktestMetric(
                label: '平均净收益',
                value: hasSignals
                    ? _signedPercent(performance.averageReturn)
                    : '--',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _BacktestMetric(
                label: '累计净收益',
                value: hasSignals
                    ? _signedPercent(performance.cumulativeReturn)
                    : '--',
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _BacktestMetric(
                label: '最大回撤',
                value: hasSignals
                    ? _percent(performance.maximumDrawdown)
                    : '--',
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

class _BacktestMetric extends StatelessWidget {
  const _BacktestMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

String _percent(double value) {
  return '${(value * 100).toStringAsFixed(2)}%';
}

String _signedPercent(double value) {
  final sign = value > 0 ? '+' : '';
  return '$sign${(value * 100).toStringAsFixed(2)}%';
}
