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
          '成本假设：单边佣金 '
          '${_percent(costs.commissionRate)}，'
          '买入税费 ${_percent(costs.buyTransactionCostRate)}，'
          '卖出税费 ${_percent(costs.sellTransactionCostRate)}，'
          '单边滑点 ${_percent(costs.slippageRate)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: palette.secondaryText,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (result.trades.isEmpty)
          Text(
            _noTradeMessage(result),
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
          const SizedBox(height: AppSpacing.xxl),
          Text(
            '专业回测指标',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '用于从收益质量、风险和稳定性三个角度补充观察。至少需要 '
            '${QuantFactorBacktestResult.minimumProfessionalMetricSampleSize} 笔交易，'
            '否则不做可靠性判断。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProfessionalMetricsGrid(result: result),
          const SizedBox(height: AppSpacing.xxl),
          _BacktestConclusion(result: result),
          const SizedBox(height: AppSpacing.xxl),
          _BacktestTradeDetails(trades: result.trades),
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
          _FactorInsightCard(performances: result.factorPerformances),
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
                    : '回测已估算佣金、市场税费和滑点，不代表未来收益；实际费用因市场、券商和成交金额而异。',
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

class _FactorInsightCard extends StatelessWidget {
  const _FactorInsightCard({required this.performances});

  final List<QuantFactorHistoricalPerformance> performances;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Semantics(
      container: true,
      label: '因子解读',
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
              '因子解读',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _factorInsight(performances),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.primaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '仅基于当前回测区间的历史信号，因子表现会随市场环境变化。',
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

class _BacktestConclusion extends StatelessWidget {
  const _BacktestConclusion({required this.result});

  final QuantFactorBacktestResult result;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Semantics(
      container: true,
      label: '回测结论',
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
              '回测结论',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _backtestConclusion(result),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.primaryText,
                height: 1.5,
              ),
            ),
            if (result.hasBacktestPeriod) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '回测区间：${_formatDate(result.backtestStartDate!)} 至 '
                '${_formatDate(result.backtestEndDate!)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              _backtestRiskReminder(result),
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
        if (hasSignals) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            '逐笔信号明细',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var index = 0; index < performance.trades.length; index++) ...[
            _FactorTradeRow(trade: performance.trades[index], index: index + 1),
            if (index < performance.trades.length - 1)
              const Divider(height: AppSpacing.lg),
          ],
        ],
      ],
    );
  }
}

class _FactorTradeRow extends StatelessWidget {
  const _FactorTradeRow({required this.trade, required this.index});

  final QuantBacktestTrade trade;
  final int index;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final returnColor = trade.isWinning
        ? const Color(0xFF16A085)
        : const Color(0xFFE05A47);

    return Semantics(
      container: true,
      label: '第 $index 笔因子信号',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '第 $index 笔信号',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _signedPercent(trade.netReturnRate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: returnColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '买入 ${_formatDate(trade.entryDate)} · 卖出 ${_formatDate(trade.exitDate)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _BacktestMetric(
                    label: '净收益',
                    value: _signedPercent(trade.netReturnRate),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _BacktestMetric(
                    label: '成本影响',
                    value: _percent(trade.estimatedCostRate),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _BacktestMetric(
                    label: '因子分',
                    value: trade.signalScore.toStringAsFixed(0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BacktestTradeDetails extends StatelessWidget {
  const _BacktestTradeDetails({required this.trades});

  final List<QuantBacktestTrade> trades;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return ExpansionTile(
      key: const ValueKey('quant-backtest-trade-details'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: AppSpacing.md),
      title: Text(
        '逐笔交易明细',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: palette.primaryText,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        '共 ${trades.length} 笔，按买入日期排序',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
      ),
      children: [
        for (var index = 0; index < trades.length; index++) ...[
          _BacktestTradeRow(trade: trades[index], index: index + 1),
          if (index < trades.length - 1) const Divider(height: AppSpacing.lg),
        ],
      ],
    );
  }
}

class _BacktestTradeRow extends StatelessWidget {
  const _BacktestTradeRow({required this.trade, required this.index});

  final QuantBacktestTrade trade;
  final int index;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isWinning = trade.isWinning;
    final returnColor = isWinning
        ? const Color(0xFF16A085)
        : const Color(0xFFE05A47);

    return Semantics(
      container: true,
      label: '第 $index 笔交易',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '第 $index 笔',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: palette.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _signedPercent(trade.netReturnRate),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: returnColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '买入 ${_formatDate(trade.entryDate)} · 卖出 ${_formatDate(trade.exitDate)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _BacktestMetric(
                    label: '买入成交价',
                    value: trade.executedEntryPrice.toStringAsFixed(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _BacktestMetric(
                    label: '卖出成交价',
                    value: trade.executedExitPrice.toStringAsFixed(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _BacktestMetric(
                    label: '毛收益',
                    value: _signedPercent(trade.grossReturnRate),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _BacktestMetric(
                    label: '成本影响',
                    value: _percent(trade.estimatedCostRate),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _BacktestMetric(
                    label: '信号分',
                    value: trade.signalScore.toStringAsFixed(0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

class _ProfessionalMetricsGrid extends StatelessWidget {
  const _ProfessionalMetricsGrid({required this.result});

  final QuantFactorBacktestResult result;

  @override
  Widget build(BuildContext context) {
    final hasEnoughSamples = result.hasSufficientProfessionalMetricSample;
    final sampleValue = hasEnoughSamples ? null : '样本不足';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _BacktestMetric(
                label: '盈亏比',
                value: sampleValue ?? _ratio(result.profitLossRatio),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _BacktestMetric(
                label: '盈利因子',
                value: sampleValue ?? _ratio(result.profitFactor),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _BacktestMetric(
                label: '年化收益率',
                value:
                    sampleValue ??
                    _signedPercentOrUnavailable(result.annualizedReturn),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _BacktestMetric(
                label: '夏普比率',
                value: sampleValue ?? _ratio(result.sharpeRatio),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          hasEnoughSamples
              ? '盈亏比看平均一赢一亏的大小，盈利因子看总盈利能否覆盖总亏损；年化收益率统一不同区间的收益尺度，夏普比率同时考虑波动风险。'
              : '当前只有 ${result.tradeCount} 笔交易，少于最低 ${QuantFactorBacktestResult.minimumProfessionalMetricSampleSize} 笔样本；这些指标暂不用于判断策略优劣。',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).extension<AppThemePalette>()!.secondaryText,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

String _noTradeMessage(QuantFactorBacktestResult result) {
  switch (result.noTradeReason) {
    case QuantBacktestNoTradeReason.insufficientHistory:
      return '历史数据不足，暂时无法形成完整交易。请增加回测数据区间，或缩短持有周期。';

    case QuantBacktestNoTradeReason.invalidPrices:
      return '候选交易日的开盘价或收盘价无效，无法完成交易。请检查行情数据是否完整。';

    case QuantBacktestNoTradeReason.noQualifiedSignal:
      final highestScore = result.highestSignalScore;

      if (highestScore == null) {
        return '已评估 ${result.evaluatedSignalCount} 个候选交易日，'
            '但没有产生可用的综合评分。请检查因子数据是否完整。';
      }

      return '已评估 ${result.evaluatedSignalCount} 个候选交易日，'
          '最高风险调整分为 ${highestScore.toStringAsFixed(0)} 分，'
          '未达到 ${result.signalThreshold.toStringAsFixed(0)} 分阈值。'
          '可适当降低信号阈值后重新回测。';

    case null:
      return '';
  }
}

String _backtestConclusion(QuantFactorBacktestResult result) {
  final sampleNote = result.tradeCount < 5
      ? '交易样本较少，结论仅作初步观察。'
      : '样本覆盖 ${result.tradeCount} 笔交易，可结合更多历史区间继续验证。';

  final comparisonNote = switch (result.hasEquityComparison) {
    false => '未提供同期基准曲线，暂不比较超额收益。',
    true when result.excessReturn > 0 =>
      '策略在该历史区间跑赢买入持有基准 ${_signedPercent(result.excessReturn)}。',
    true when result.excessReturn < 0 =>
      '策略在该历史区间落后买入持有基准 ${_percent(-result.excessReturn)}。',
    true => '策略与买入持有基准表现持平。',
  };

  return '本次回测共完成 ${result.tradeCount} 笔交易，'
      '净胜率 ${_percent(result.winRate)}。'
      '$sampleNote'
      '$comparisonNote';
}

String _factorInsight(List<QuantFactorHistoricalPerformance> performances) {
  const minimumSampleSize = 5;
  final referenceable = performances
      .where((performance) => performance.signalCount >= minimumSampleSize)
      .toList();
  final insufficient = performances
      .where((performance) => performance.signalCount < minimumSampleSize)
      .toList();

  if (referenceable.isEmpty) {
    final labels = insufficient
        .map((performance) => performance.label)
        .join('、');
    return '$labels的历史信号均少于 $minimumSampleSize 次，样本不足，暂不比较因子强弱。';
  }

  referenceable.sort(
    (left, right) => right.averageReturn.compareTo(left.averageReturn),
  );
  final strongest = referenceable.first;
  final positive = strongest.averageReturn > 0;
  final strongestNote = positive
      ? '${strongest.label}在样本充足的因子中平均净收益最高'
            '（${_signedPercent(strongest.averageReturn)}），可作为初步参考。'
      : '${strongest.label}在样本充足的因子中平均净收益最高，'
            '但仍为${_signedPercent(strongest.averageReturn)}，暂未显示正向历史表现。';

  final weaker = referenceable
      .where((performance) => performance.averageReturn <= 0)
      .map((performance) => performance.label)
      .toList();
  final weakerNote = weaker.isEmpty
      ? ''
      : '${weaker.join('、')}平均净收益未为正，使用时需要更谨慎。';
  final insufficientNote = insufficient.isEmpty
      ? ''
      : '${insufficient.map((performance) => performance.label).join('、')}信号少于 '
            '$minimumSampleSize 次，暂不作强弱判断。';

  return '$strongestNote$weakerNote$insufficientNote';
}

String _backtestRiskReminder(QuantFactorBacktestResult result) {
  final drawdown = _percent(result.maximumDrawdown);
  final drawdownNote = switch (result.maximumDrawdown) {
    >= 0.10 => '策略最大回撤为 $drawdown，历史回撤压力较大。',
    >= 0.05 => '策略最大回撤为 $drawdown，需要留意回撤风险。',
    _ => '策略最大回撤为 $drawdown，历史回撤相对较小。',
  };

  return '$drawdownNote 历史回测不能推断未来表现。';
}

String _percent(double value) {
  return '${(value * 100).toStringAsFixed(2)}%';
}

String _signedPercent(double value) {
  final sign = value > 0 ? '+' : '';
  return '$sign${(value * 100).toStringAsFixed(2)}%';
}

String _signedPercentOrUnavailable(double? value) {
  return value == null ? '暂无' : _signedPercent(value);
}

String _ratio(double? value) {
  return value == null ? '暂无' : value.toStringAsFixed(2);
}

String _formatDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
