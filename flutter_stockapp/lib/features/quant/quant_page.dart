import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import 'rsi_interpreter.dart';
import 'quant_stock_search_sheet.dart';
import 'selected_stock.dart';
import 'macd_interpreter.dart';
import 'moving_average_interpreter.dart';
import 'volume_interpreter.dart';
import 'technical_summary_section.dart';
import 'quant_analysis_state_view.dart';
import 'quant_analysis_status.dart';
import 'quant_data_metadata.dart';
import '../../core/network/api_client.dart';
import 'quant_stock_analysis.dart';
import 'quant_stock_analysis_api.dart';
import 'quant_stock_analysis_controller.dart';

class QuantPage extends StatefulWidget {
  const QuantPage({this.getJson, super.key});

  final JsonGet? getJson;

  @override
  State<QuantPage> createState() => _QuantPageState();
}

class _QuantPageState extends State<QuantPage> {
  SelectedStock? selectedStock;
  QuantAnalysisStatus _analysisStatus = QuantAnalysisStatus.idle;
  late final QuantStockAnalysisController _stockAnalysisController;

  @override
  void initState() {
    super.initState();
    _stockAnalysisController = QuantStockAnalysisController(
      api: QuantStockAnalysisApi(
        getJson: widget.getJson ?? ApiClient().getJson,
      ),
    );
  }

  @override
  void dispose() {
    _stockAnalysisController.dispose();
    super.dispose();
  }

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

    selectedStock = stock;
    await _loadAnalysis(stock);
  }

  Future<void> _loadAnalysis(SelectedStock stock) async {
    setState(() {
      _analysisStatus = QuantAnalysisStatus.loading;
    });

    await _stockAnalysisController.analyze(stock.code);

    if (!mounted) {
      return;
    }

    setState(() {
      _analysisStatus = _stockAnalysisController.status;
    });
  }

  void _retryAnalysis() {
    final stock = selectedStock;

    if (stock != null) {
      _loadAnalysis(stock);
    }
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
                    if (!hasSelectedStock)
                      _EmptyStockState(onChooseStock: _chooseStock)
                    else if (_analysisStatus == QuantAnalysisStatus.success)
                      _SelectedStockState(
                        stock: selectedStock!,
                        analysis: _stockAnalysisController.result!,
                        onChooseStock: _chooseStock,
                      )
                    else
                      QuantAnalysisStateView(
                        status: _analysisStatus,
                        onRetry:
                            _analysisStatus == QuantAnalysisStatus.failure ||
                                _analysisStatus == QuantAnalysisStatus.empty ||
                                _analysisStatus ==
                                    QuantAnalysisStatus.insufficientData
                            ? _retryAnalysis
                            : null,
                      ),
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
  const _SelectedStockState({
    required this.stock,
    required this.analysis,
    required this.onChooseStock,
  });

  final SelectedStock stock;
  final QuantStockAnalysis analysis;
  final VoidCallback onChooseStock;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final quote = analysis.bars.isEmpty ? null : analysis.latestBar;
    final ma5 = analysis.ma5;
    final ma10 = analysis.ma10;
    final ma20 = analysis.ma20;
    final macd = analysis.macd;
    final macdInsight = interpretMacd(macd);
    final rsi14 = analysis.rsi14;
    final rsiInsight = interpretRsi(rsi14);
    final volumeAnalysis = analysis.volume;
    final volumeInsight = interpretVolume(volumeAnalysis);
    final insight = interpretMovingAverages(
      close: quote?.close,
      ma5: ma5,
      ma10: ma10,
      ma20: ma20,
    );
    final metadata = quote == null
        ? null
        : QuantDataMetadata(
            latestTradingDate: quote.tradingDate,
            sourceName: 'Market 行情服务',
            priceAdjustment: PriceAdjustment.unknown,
            isSimulated: false,
          );
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
          Row(
            children: [
              Icon(
                Icons.cloud_done_outlined,
                size: 18,
                color: palette.secondaryText,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '当前数据来自 Market 行情服务',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '最近交易日收盘 · ${metadata!.formattedTradingDate}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '数据来源：${metadata.sourceName} · 复权方式：${metadata.priceAdjustment.label}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),
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
        const SizedBox(height: AppSpacing.xxl),
        TechnicalSummarySection(result: analysis.technicalSummary),
        const SizedBox(height: AppSpacing.xxl),
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
          '趋势动量指标',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'MACD用于观察短期与长期价格趋势的差异',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _QuoteMetric(
                label: 'DIF',
                value: macd?.dif.toStringAsFixed(2) ?? '--',
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _QuoteMetric(
                label: 'DEA',
                value: macd?.dea.toStringAsFixed(2) ?? '--',
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _QuoteMetric(
                label: 'MACD柱',
                value: macd?.histogram.toStringAsFixed(2) ?? '--',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          macdInsight.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          macdInsight.explanation,
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
                macdInsight.riskNotice,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          '动量指标',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'RSI用于观察近期上涨和下跌力量的相对变化',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        _QuoteMetric(label: 'RSI14', value: rsi14?.toStringAsFixed(2) ?? '--'),
        const SizedBox(height: AppSpacing.lg),
        Text(
          rsiInsight.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          rsiInsight.explanation,
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
                rsiInsight.riskNotice,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          '量价分析',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '比较最新成交量与此前5日平均成交量',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _QuoteMetric(
                label: '前5日均量',
                value: volumeAnalysis == null
                    ? '--'
                    : '${(volumeAnalysis.averageVolume / 10000).toStringAsFixed(2)} 万股',
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _QuoteMetric(
                label: '量比',
                value: volumeAnalysis?.volumeRatio.toStringAsFixed(2) ?? '--',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          volumeInsight.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          volumeInsight.explanation,
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
                volumeInsight.riskNotice,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          '均线解读',
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
