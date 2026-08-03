import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../agent/agent_input_preview_page.dart';
import 'quant_stock_analysis.dart';
import 'risk_metrics_calculator.dart';
import 'selected_stock.dart';

class QuantAiAnalysisSection extends StatelessWidget {
  const QuantAiAnalysisSection({
    required this.stock,
    required this.analysis,
    super.key,
  });

  final SelectedStock stock;
  final QuantStockAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI 辅助解读',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '将当前股票的技术指标和风险数据带入 AI，获得进一步说明。',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (context) => AgentInputPreviewPage(
                  initialMessage: buildQuantAiPrompt(
                    stock: stock,
                    analysis: analysis,
                  ),
                ),
              ),
            );
          },
          icon: const Icon(Icons.auto_awesome_outlined),
          label: const Text('让 AI 解读'),
        ),
      ],
    );
  }
}

String buildQuantAiPrompt({
  required SelectedStock stock,
  required QuantStockAnalysis analysis,
}) {
  final quote = analysis.latestBar;
  final macd = analysis.macd;
  final volume = analysis.volume;
  final risk = calculateRiskMetrics(bars: analysis.bars);
  final summary = analysis.technicalSummary;

  String number(double? value) => value?.toStringAsFixed(2) ?? '暂无';
  String percent(double? value) =>
      value == null ? '暂无' : '${(value * 100).toStringAsFixed(2)}%';

  return '''
请用中文解读以下股票的历史行情技术指标。

股票：${stock.name}（${stock.code}）
最新收盘价：${number(quote.close)}
当日涨跌幅：${quote.changePercent.toStringAsFixed(2)}%
MA5：${number(analysis.ma5)}
MA10：${number(analysis.ma10)}
MA20：${number(analysis.ma20)}
RSI14：${number(analysis.rsi14)}
MACD DIF：${number(macd?.dif)}
MACD DEA：${number(macd?.dea)}
MACD 柱值：${number(macd?.histogram)}
成交量比值：${number(volume?.volumeRatio)}
年化波动率：${percent(risk?.annualizedVolatility)}
最大回撤：${percent(risk?.maximumDrawdown)}
趋势状态：${summary.trend.name}
动能状态：${summary.momentum.name}
强弱状态：${summary.strength.name}
成交量参与度：${summary.participation.name}
指标一致性：${summary.consistency.name}
风险标记：${summary.riskFlags.map((flag) => flag.name).join('、')}

请分别说明趋势、动能、量价配合和风险，并指出还需要观察哪些信息。
分析仅用于解释历史数据，不预测未来走势，也不构成投资建议。
''';
}
