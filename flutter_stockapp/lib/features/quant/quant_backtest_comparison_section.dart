import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_backtest_comparison.dart';
import 'quant_backtest_overfitting.dart';
import 'quant_factor_backtest.dart';

class QuantBacktestComparisonSection extends StatelessWidget {
  const QuantBacktestComparisonSection({required this.result, super.key});

  final QuantBacktestComparisonResult result;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final bestReturn = result.bestReturnItem;
    final lowestDrawdown = result.lowestDrawdownItem;
    final balanced = result.balancedItem;
    final overfitAssessment = assessQuantBacktestOverfitting(result);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '多组参数回测对比',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '使用相同历史数据，比较不同参数组合下的策略表现。',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (bestReturn != null || lowestDrawdown != null)
          Row(
            children: [
              if (bestReturn != null)
                Expanded(
                  child: _HighlightMetric(
                    label: '累计收益最高',
                    value: bestReturn.caseDefinition.label,
                    color: const Color(0xFF0EA078),
                  ),
                ),
              if (bestReturn != null && lowestDrawdown != null)
                const SizedBox(width: AppSpacing.md),
              if (lowestDrawdown != null)
                Expanded(
                  child: _HighlightMetric(
                    label: '最大回撤最低',
                    value: lowestDrawdown.caseDefinition.label,
                    color: palette.primaryText,
                  ),
                ),
            ],
          ),
        if (bestReturn != null || lowestDrawdown != null)
          const SizedBox(height: AppSpacing.lg),
        _ComparisonInsightCard(result: result, balanced: balanced),
        const SizedBox(height: AppSpacing.lg),
        _OverfitRiskCard(assessment: overfitAssessment),
        const SizedBox(height: AppSpacing.lg),
        for (var index = 0; index < result.items.length; index++) ...[
          _ComparisonItem(
            item: result.items[index],
            isBestReturn: result.items[index] == bestReturn,
            isLowestDrawdown: result.items[index] == lowestDrawdown,
            isBalanced: result.items[index] == balanced,
          ),
          if (index < result.items.length - 1)
            const SizedBox(height: AppSpacing.md),
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
                '不同参数组合只代表历史数据下的模拟结果，不能保证未来收益。比较时应同时关注收益、胜率和最大回撤。',
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

class _OverfitRiskCard extends StatelessWidget {
  const _OverfitRiskCard({required this.assessment});

  final QuantBacktestOverfitAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final color = switch (assessment.risk) {
      QuantBacktestOverfitRisk.insufficientSample => const Color(0xFFE08A00),
      QuantBacktestOverfitRisk.low => const Color(0xFF0EA078),
      QuantBacktestOverfitRisk.moderate => const Color(0xFFE08A00),
      QuantBacktestOverfitRisk.high => const Color(0xFFE05A47),
    };

    return Semantics(
      container: true,
      label: '参数过拟合提醒',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          border: Border.all(color: color.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '参数过拟合提醒',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: palette.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _overfitInsight(assessment),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.primaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _overfitRiskLabel(assessment.risk),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonInsightCard extends StatelessWidget {
  const _ComparisonInsightCard({required this.result, required this.balanced});

  final QuantBacktestComparisonResult result;
  final QuantBacktestComparisonItem? balanced;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Semantics(
      container: true,
      label: '参数组合解读',
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
              '参数组合解读',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _comparisonInsight(result, balanced),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.primaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '综合参考仅比较至少 ${QuantBacktestComparisonResult.minimumReferenceTradeCount} 笔交易的组合，'
              '同时考虑累计收益、最大回撤和交易次数，不代表未来最优参数。',
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

class _ComparisonItem extends StatelessWidget {
  const _ComparisonItem({
    required this.item,
    required this.isBestReturn,
    required this.isLowestDrawdown,
    required this.isBalanced,
  });

  final QuantBacktestComparisonItem item;
  final bool isBestReturn;
  final bool isLowestDrawdown;
  final bool isBalanced;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final result = item.result;
    final hasTrades = result.tradeCount > 0;
    final hasLimitedSample =
        hasTrades &&
        result.tradeCount <
            QuantBacktestComparisonResult.minimumReferenceTradeCount;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: isBestReturn
              ? const Color(0xFF0EA078)
              : palette.secondaryText.withValues(alpha: 0.25),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.caseDefinition.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: palette.primaryText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (isBestReturn)
                  _Tag(text: '收益最高', color: const Color(0xFF0EA078)),
                if (isBestReturn && isLowestDrawdown)
                  const SizedBox(width: AppSpacing.xs),
                if (isLowestDrawdown)
                  _Tag(text: '回撤最低', color: palette.primaryText),
                if ((isBestReturn || isLowestDrawdown) && isBalanced)
                  const SizedBox(width: AppSpacing.xs),
                if (isBalanced)
                  _Tag(text: '综合参考', color: const Color(0xFF2F6FED)),
                if ((isBestReturn || isLowestDrawdown || isBalanced) &&
                    hasLimitedSample)
                  const SizedBox(width: AppSpacing.xs),
                if (hasLimitedSample)
                  _Tag(text: '样本有限', color: const Color(0xFFE08A00)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.caseDefinition.description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '阈值 ${item.caseDefinition.parameters.signalThreshold.toStringAsFixed(0)} 分'
              ' · 持有 ${item.caseDefinition.parameters.holdingPeriod} 日',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _Metric(label: '交易次数', value: '${result.tradeCount}'),
                ),
                Expanded(
                  child: _Metric(
                    label: '累计收益',
                    value: hasTrades
                        ? _signedPercent(result.cumulativeReturn)
                        : '--',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: '胜率',
                    value: hasTrades ? _percent(result.winRate) : '--',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: '最大回撤',
                    value: hasTrades ? _percent(result.maximumDrawdown) : '--',
                  ),
                ),
              ],
            ),
            if (result.hasEquityComparison) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: '基准收益',
                      value: _signedPercent(result.benchmarkReturn),
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      label: '超额收益',
                      value: _signedPercent(result.excessReturn),
                    ),
                  ),
                ],
              ),
            ],
            if (hasLimitedSample) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                '当前仅完成 ${result.tradeCount} 笔交易，至少完成 '
                '${QuantBacktestComparisonResult.minimumReferenceTradeCount} 笔交易后才参与参数比较。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.5,
                ),
              ),
            ],
            if (!hasTrades) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _comparisonNoTradeMessage(result),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HighlightMetric extends StatelessWidget {
  const _HighlightMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

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
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
      ),
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

String _comparisonNoTradeMessage(QuantFactorBacktestResult result) {
  switch (result.noTradeReason) {
    case QuantBacktestNoTradeReason.insufficientHistory:
      return '历史数据不足，无法形成完整交易。';

    case QuantBacktestNoTradeReason.invalidPrices:
      return '行情价格数据不完整，候选交易无法执行。';

    case QuantBacktestNoTradeReason.noQualifiedSignal:
      final highestScore = result.highestSignalScore;

      if (highestScore == null) {
        return '没有产生可用的综合评分。';
      }

      return '最高评分 ${highestScore.toStringAsFixed(0)} 分，'
          '未达到 ${result.signalThreshold.toStringAsFixed(0)} 分阈值。';

    case null:
      return '';
  }
}

String _comparisonInsight(
  QuantBacktestComparisonResult result,
  QuantBacktestComparisonItem? balanced,
) {
  final completed = result.items.where((item) => item.tradeCount > 0).length;
  final referenceable = result.referenceableItems.length;

  if (completed == 0) {
    return '当前各参数组合均未形成完整交易，暂时无法比较策略表现。';
  }

  if (balanced == null) {
    return '当前有 $completed 组参数形成交易，但只有 $referenceable 组达到至少 '
        '${QuantBacktestComparisonResult.minimumReferenceTradeCount} 笔交易的参考样本，'
        '暂不做参数优劣判断。';
  }

  final backtest = balanced.result;
  return '${balanced.caseDefinition.label}在当前历史区间的收益、回撤和交易次数之间相对更均衡：'
      '累计收益 ${_signedPercent(backtest.cumulativeReturn)}，'
      '最大回撤 ${_percent(backtest.maximumDrawdown)}，'
      '完成 ${backtest.tradeCount} 笔交易。'
      '${_comparisonBenchmarkInsight(backtest)}';
}

String _comparisonBenchmarkInsight(QuantFactorBacktestResult result) {
  if (!result.hasEquityComparison) {
    return '';
  }

  if (result.excessReturn > 0) {
    return '相对同期买入持有超额收益 ${_signedPercent(result.excessReturn)}。';
  }

  if (result.excessReturn < 0) {
    return '但相对同期买入持有仍落后 ${_percent(-result.excessReturn)}，'
        '不宜仅凭该组合直接判断策略有效性。';
  }

  return '与同期买入持有表现持平，仍需结合更多历史区间验证。';
}

String _overfitRiskLabel(QuantBacktestOverfitRisk risk) {
  return switch (risk) {
    QuantBacktestOverfitRisk.insufficientSample => '样本不足，暂不判断',
    QuantBacktestOverfitRisk.low => '暂未发现明显风险',
    QuantBacktestOverfitRisk.moderate => '存在一定风险，建议继续验证',
    QuantBacktestOverfitRisk.high => '风险较高，谨慎解读最优参数',
  };
}

String _overfitInsight(QuantBacktestOverfitAssessment assessment) {
  if (!assessment.hasEnoughReferenceSamples) {
    return '当前只有 ${assessment.referenceableCount} 组参数达到至少 '
        '${QuantBacktestComparisonResult.minimumReferenceTradeCount} 笔交易的参考样本，'
        '暂时无法检查参数是否过度适配历史数据。';
  }

  final best = assessment.bestReturnItem!;
  final second = assessment.secondBestReturnItem!;
  final gap = _signedPercent(assessment.bestReturnAdvantage);
  final sampleNote = assessment.bestHasLimitedSample
      ? '收益最高组合仅完成 ${best.tradeCount} 笔交易，样本仍偏少。'
      : '';
  final drawdownNote = assessment.hasDrawdownTradeoff
      ? '它的最大回撤也明显高于综合参考组合。'
      : '';

  switch (assessment.risk) {
    case QuantBacktestOverfitRisk.high:
      return '收益最高的${best.caseDefinition.label}比第二名${second.caseDefinition.label}高 '
          '$gap，但存在以下风险：$sampleNote$drawdownNote'
          '这可能说明参数刚好适配了当前历史区间，建议换时间窗口和股票继续验证。';
    case QuantBacktestOverfitRisk.moderate:
      return '收益最高的${best.caseDefinition.label}比第二名${second.caseDefinition.label}高 '
          '$gap。$sampleNote$drawdownNote'
          '参数优势还不够稳固，建议结合多时间窗口结果观察。';
    case QuantBacktestOverfitRisk.low:
      return '收益最高的${best.caseDefinition.label}只比第二名${second.caseDefinition.label}高 '
          '$gap，当前未发现明显的参数过拟合信号。仍建议用更多历史区间和股票复核。';
    case QuantBacktestOverfitRisk.insufficientSample:
      return '';
  }
}
