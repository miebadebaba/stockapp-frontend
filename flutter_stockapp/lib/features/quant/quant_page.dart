import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import 'quant_stock_search_sheet.dart';
import 'selected_stock.dart';
import 'mock_stock_quotes.dart';
import 'mock_stock_daily_bars.dart';
import 'moving_average_calculator.dart';
import 'moving_average_interpreter.dart';

class QuantPage extends StatefulWidget {
  const QuantPage({super.key});

  @override
  State<QuantPage> createState() => _QuantPageState();
}

class _QuantPageState extends State<QuantPage> {
  SelectedStock? selectedStock;

  Future<void> _chooseStock() async {
    final stock = await showModalBottomSheet<SelectedStock>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.75,
        child: QuantStockSearchSheet(),
      ),
    );

    if (stock == null || !mounted) {
      return;
    }

    setState(() => selectedStock = stock);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final hasSelectedStock =
        selectedStock != null && selectedStock!.code.isNotEmpty;

    return AnimatedPageWrapper(
      child: ColoredBox(
        color: palette.pageBackground,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              96,
              AppSpacing.lg,
              140,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '量化分析',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: palette.primaryText,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '通过行情和技术指标，理解股票当前状态。',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (hasSelectedStock)
                      _SelectedStockState(
                        stock: selectedStock!,
                        onChooseStock: _chooseStock,
                      )
                    else
                      _EmptyStockState(onChooseStock: _chooseStock),
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

class _EmptyStockState extends StatelessWidget {
  const _EmptyStockState({this.onChooseStock});

  final VoidCallback? onChooseStock;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.query_stats_rounded, size: 42, color: palette.primaryText),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '还没有选择股票',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '请先选择一只A股，随后查看行情、技术指标和通俗解释。',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: onChooseStock,
          icon: const Icon(Icons.search_rounded),
          label: const Text('选择股票'),
        ),
      ],
    );
  }
}

class _SelectedStockState extends StatelessWidget {
  const _SelectedStockState({required this.stock, required this.onChooseStock});

  final SelectedStock stock;
  final VoidCallback onChooseStock;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final quote = mockStockQuotes[stock.code];
    final bars = mockStockDailyBars[stock.code] ?? const [];

    final ma5 = calculateMovingAverage(bars: bars, period: 5);
    final ma10 = calculateMovingAverage(bars: bars, period: 10);
    final ma20 = calculateMovingAverage(bars: bars, period: 20);
    final insight = interpretMovingAverages(
      close: quote?.close,
      ma5: ma5,
      ma10: ma10,
      ma20: ma20,
    );
    final tradingDate = quote == null
        ? ''
        : '${quote.tradingDate.year}-'
              '${quote.tradingDate.month.toString().padLeft(2, '0')}-'
              '${quote.tradingDate.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '已选择股票',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          stock.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          stock.code,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.secondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (quote != null) ...[
          Text(
            '最近交易日收盘· $tradingDate',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            quote.close.toStringAsFixed(2),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${quote.change >= 0 ? '+' : ''}${quote.change.toStringAsFixed(2)}  '
            '${quote.changePercent >= 0 ? '+' : ''}'
            '${quote.changePercent.toStringAsFixed(2)}%',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: palette.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _QuoteMetric(
                  label: '开盘',
                  value: quote.open.toStringAsFixed(2),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _QuoteMetric(
                  label: '最高',
                  value: quote.high.toStringAsFixed(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _QuoteMetric(
                  label: '最低',
                  value: quote.low.toStringAsFixed(2),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _QuoteMetric(
                  label: '成交量',
                  value: '${(quote.volume / 10000).toStringAsFixed(2)} 万股',
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          '移动平均线',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '根据最近交易日的收盘价计算',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _QuoteMetric(
                label: 'MA5',
                value: ma5?.toStringAsFixed(2) ?? '--',
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _QuoteMetric(
                label: 'MA10',
                value: ma10?.toStringAsFixed(2) ?? '--',
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _QuoteMetric(
                label: 'MA20',
                value: ma20?.toStringAsFixed(2) ?? '--',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          '指标解读',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          insight.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          insight.explanation,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: palette.secondaryText,
            height: 1.5,
          ),
        ),
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
                insight.riskNotice,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        OutlinedButton.icon(
          onPressed: onChooseStock,
          icon: const Icon(Icons.swap_horiz_rounded),
          label: const Text('更换股票'),
        ),
      ],
    );
  }
}

class _QuoteMetric extends StatelessWidget {
  const _QuoteMetric({required this.label, required this.value});

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
