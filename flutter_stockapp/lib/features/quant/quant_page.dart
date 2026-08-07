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
import 'quant_price_chart.dart';
import 'quant_risk_metrics_section.dart';
import 'quant_overview_section.dart';
import 'quant_factor_score_calculator.dart';
import 'quant_factor_score_section.dart';
import 'quant_factor_comparison_section.dart';
import 'quant_factor_backtest_calculator.dart';
import 'quant_backtest_parameters.dart';
import 'quant_backtest_parameters_section.dart';
import 'quant_backtest_comparison.dart';
import 'quant_backtest_comparison_section.dart';
import 'quant_factor_backtest_section.dart';
import 'quant_stock_catalog.dart';
import 'quant_factor_preset.dart';
import 'quant_stock_ranking.dart';
import 'quant_stock_ranking_calculator.dart';
import 'quant_stock_ranking_section.dart';

enum QuantDetailTab { overview, technical, factors, backtest }

class QuantPage extends StatefulWidget {
  const QuantPage({this.getJson, this.rankingAnalyze, super.key});

  final JsonGet? getJson;
  final Future<QuantStockAnalysis> Function(String symbol)? rankingAnalyze;

  @override
  State<QuantPage> createState() => _QuantPageState();
}

class _QuantPageState extends State<QuantPage> {
  SelectedStock? selectedStock;
  SelectedStock? comparisonStock;

  QuantAnalysisStatus _analysisStatus = QuantAnalysisStatus.idle;
  QuantAnalysisStatus _comparisonAnalysisStatus = QuantAnalysisStatus.idle;

  QuantStockAnalysis? comparisonAnalysis;
  QuantMarket _rankingMarket = QuantMarket.aShare;
  QuantRankingSort _rankingSort = QuantRankingSort.riskAdjustedScore;
  QuantFactorPresetType _rankingPresetType = QuantFactorPresetType.balanced;
  QuantStockRankingResult? _rankingResult;
  bool _isRankingLoading = false;
  QuantBacktestParameters _backtestParameters = const QuantBacktestParameters();
  QuantDetailTab _detailTab = QuantDetailTab.overview;

  late final QuantStockAnalysisController _stockAnalysisController;
  late final QuantStockAnalysisController _comparisonStockAnalysisController;

  @override
  void initState() {
    super.initState();
    _stockAnalysisController = QuantStockAnalysisController(
      api: QuantStockAnalysisApi(
        getJson: widget.getJson ?? ApiClient().getJson,
      ),
    );
    _comparisonStockAnalysisController = QuantStockAnalysisController(
      api: QuantStockAnalysisApi(
        getJson: widget.getJson ?? ApiClient().getJson,
      ),
    );
    _loadRanking();
  }

  @override
  void dispose() {
    _stockAnalysisController.dispose();
    _comparisonStockAnalysisController.dispose();
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

    setState(() {
      selectedStock = stock;
      comparisonStock = null;
      comparisonAnalysis = null;
      _detailTab = QuantDetailTab.overview;
      _comparisonAnalysisStatus = QuantAnalysisStatus.idle;
    });

    await _loadAnalysis(stock);
  }

  Future<void> _chooseComparisonStock() async {
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

    if (selectedStock?.code == stock.code) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('对比股票不能与当前股票相同')));
      return;
    }

    setState(() {
      comparisonStock = stock;
      comparisonAnalysis = null;
      _comparisonAnalysisStatus = QuantAnalysisStatus.loading;
    });

    await _comparisonStockAnalysisController.analyze(stock.code);

    if (!mounted) {
      return;
    }

    setState(() {
      comparisonAnalysis = _comparisonStockAnalysisController.result;
      _comparisonAnalysisStatus = _comparisonStockAnalysisController.status;
    });
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

  Future<void> _loadRanking() async {
    final market = _rankingMarket;
    final sortBy = _rankingSort;
    final presetType = _rankingPresetType;

    final stocks = quantStockCatalog
        .where((stock) => stock.market == market)
        .toList();

    setState(() {
      _isRankingLoading = true;
    });

    final result = await calculateQuantStockRanking(
      stocks: stocks,
      analyze:
          widget.rankingAnalyze ??
          (symbol) => _stockAnalysisController.api.analyze(symbol),
      sortBy: sortBy,
      presetType: presetType,
    );

    if (!mounted ||
        market != _rankingMarket ||
        sortBy != _rankingSort ||
        presetType != _rankingPresetType) {
      return;
    }

    setState(() {
      _rankingResult = result;
      _isRankingLoading = false;
    });
  }

  void _onRankingMarketChanged(QuantMarket market) {
    setState(() {
      _rankingMarket = market;
      _rankingResult = null;
    });

    _loadRanking();
  }

  void _onRankingSortChanged(QuantRankingSort sortBy) {
    setState(() {
      _rankingSort = sortBy;
      _rankingResult = null;
    });

    _loadRanking();
  }

  void _onRankingPresetChanged(QuantFactorPresetType presetType) {
    setState(() {
      _rankingPresetType = presetType;
      _rankingResult = null;
    });

    _loadRanking();
  }

  void _onRankingStockSelected(SelectedStock stock) {
    setState(() {
      selectedStock = stock;
      comparisonStock = null;
      comparisonAnalysis = null;
      _comparisonAnalysisStatus = QuantAnalysisStatus.idle;
      _detailTab = QuantDetailTab.overview;
    });

    _loadAnalysis(stock);
  }

  void _retryAnalysis() {
    final stock = selectedStock;

    if (stock != null) {
      _loadAnalysis(stock);
    }
  }

  void _onBacktestParametersChanged(QuantBacktestParameters parameters) {
    setState(() {
      _backtestParameters = parameters;
    });
  }

  void _showStockPool() {
    setState(() {
      selectedStock = null;
      comparisonStock = null;
      comparisonAnalysis = null;
      _analysisStatus = QuantAnalysisStatus.idle;
      _comparisonAnalysisStatus = QuantAnalysisStatus.idle;
      _detailTab = QuantDetailTab.overview;
    });
  }

  void _onDetailTabChanged(QuantDetailTab tab) {
    setState(() {
      _detailTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final hasSelectedStock =
        selectedStock != null && selectedStock!.code.isNotEmpty;

    return AnimatedPageWrapper(
      child: Material(
        color: palette.pageBackground,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            key: ValueKey(
              hasSelectedStock ? selectedStock!.code : 'stock-pool',
            ),
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
                    if (!hasSelectedStock) ...[
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
                        '从股票池中筛选股票，进入个股页面查看详细量化分析。',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: palette.secondaryText,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      QuantStockRankingSection(
                        result: _rankingResult,
                        market: _rankingMarket,
                        presetType: _rankingPresetType,
                        isLoading: _isRankingLoading,
                        onMarketChanged: _onRankingMarketChanged,
                        onPresetChanged: _onRankingPresetChanged,
                        onSortChanged: _onRankingSortChanged,
                        onRefresh: _loadRanking,
                        onStockSelected: _onRankingStockSelected,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton.icon(
                        onPressed: _chooseStock,
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('选择股票'),
                      ),
                    ] else ...[
                      TextButton.icon(
                        onPressed: _showStockPool,
                        style: TextButton.styleFrom(
                          foregroundColor: palette.primaryText,
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('返回股票池'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (_analysisStatus == QuantAnalysisStatus.success)
                        _SelectedStockState(
                          stock: selectedStock!,
                          analysis: _stockAnalysisController.result!,
                          backtestParameters: _backtestParameters,
                          onBacktestParametersChanged:
                              _onBacktestParametersChanged,
                          presetType: _rankingPresetType,
                          onChooseStock: _chooseStock,
                          comparisonStock: comparisonStock,
                          comparisonAnalysis: comparisonAnalysis,
                          comparisonStatus: _comparisonAnalysisStatus,
                          onChooseComparisonStock: _chooseComparisonStock,
                          selectedTab: _detailTab,
                          onTabChanged: _onDetailTabChanged,
                        )
                      else
                        QuantAnalysisStateView(
                          status: _analysisStatus,
                          onRetry:
                              _analysisStatus == QuantAnalysisStatus.failure ||
                                  _analysisStatus ==
                                      QuantAnalysisStatus.empty ||
                                  _analysisStatus ==
                                      QuantAnalysisStatus.insufficientData
                              ? _retryAnalysis
                              : null,
                        ),
                    ],
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

class _SelectedStockState extends StatelessWidget {
  const _SelectedStockState({
    required this.stock,
    required this.analysis,
    required this.presetType,
    required this.onChooseStock,
    required this.comparisonStock,
    required this.comparisonAnalysis,
    required this.comparisonStatus,
    required this.onChooseComparisonStock,
    required this.backtestParameters,
    required this.onBacktestParametersChanged,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final SelectedStock stock;
  final QuantStockAnalysis analysis;
  final QuantFactorPresetType presetType;
  final VoidCallback onChooseStock;
  final SelectedStock? comparisonStock;
  final QuantStockAnalysis? comparisonAnalysis;
  final QuantAnalysisStatus comparisonStatus;
  final VoidCallback onChooseComparisonStock;
  final QuantBacktestParameters backtestParameters;
  final ValueChanged<QuantBacktestParameters> onBacktestParametersChanged;
  final QuantDetailTab selectedTab;
  final ValueChanged<QuantDetailTab> onTabChanged;

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
    final factorScore = calculateQuantFactorScore(analysis: analysis);
    final comparisonFactorScore = comparisonAnalysis == null
        ? null
        : calculateQuantFactorScore(analysis: comparisonAnalysis!);
    final factorBacktest = calculateQuantFactorBacktest(
      symbol: analysis.symbol,
      bars: analysis.bars,
      parameters: backtestParameters,
    );

    final comparisonResult = calculateQuantBacktestComparison(
      symbol: analysis.symbol,
      bars: analysis.bars,
      cases: defaultQuantBacktestComparisonCases(),
    );
    final metadata = quote == null
        ? null
        : QuantDataMetadata(
            latestTradingDate: quote.tradingDate,
            sourceName: analysis.isSimulated ? '内置模拟数据' : 'Market 行情服务',
            priceAdjustment: PriceAdjustment.unknown,
            isSimulated: analysis.isSimulated,
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
                  analysis.isSimulated
                      ? '当前显示内置模拟数据，仅用于功能演示'
                      : '当前数据来自 Market 行情服务',
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
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<QuantDetailTab>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: QuantDetailTab.overview, label: Text('概览')),
              ButtonSegment(value: QuantDetailTab.technical, label: Text('技术')),
              ButtonSegment(value: QuantDetailTab.factors, label: Text('多因子')),
              ButtonSegment(value: QuantDetailTab.backtest, label: Text('回测')),
            ],
            selected: {selectedTab},
            onSelectionChanged: (values) {
              onTabChanged(values.first);
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        if (selectedTab == QuantDetailTab.technical) ...[
          QuantPriceChart(bars: analysis.bars),
        ],
        const SizedBox(height: AppSpacing.xxl),
        if (selectedTab == QuantDetailTab.factors) ...[
          QuantFactorScoreSection(result: factorScore, presetType: presetType),
          const SizedBox(height: AppSpacing.lg),
          if (comparisonStatus == QuantAnalysisStatus.loading)
            const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: AppSpacing.md),
                Text('正在分析对比股票...'),
              ],
            )
          else if (comparisonStock != null &&
              comparisonAnalysis != null &&
              comparisonFactorScore != null) ...[
            QuantFactorComparisonSection(
              firstStock: stock,
              firstScore: factorScore,
              secondStock: comparisonStock!,
              secondScore: comparisonFactorScore,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onChooseComparisonStock,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('更换对比股票'),
            ),
          ] else ...[
            if (comparisonStock != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  '对比股票分析失败，请重新选择。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.secondaryText,
                  ),
                ),
              ),
            OutlinedButton.icon(
              onPressed: onChooseComparisonStock,
              icon: const Icon(Icons.compare_arrows_rounded),
              label: Text(comparisonStock == null ? '添加对比股票' : '重新选择对比股票'),
            ),
          ],
        ],
        if (selectedTab == QuantDetailTab.backtest) ...[
          const SizedBox(height: AppSpacing.xxl),
          QuantBacktestParametersSection(
            parameters: backtestParameters,
            onChanged: onBacktestParametersChanged,
          ),
          const SizedBox(height: AppSpacing.xxl),
          QuantFactorBacktestSection(
            result: factorBacktest,
            isSimulated: analysis.isSimulated,
          ),
          const SizedBox(height: AppSpacing.xxl),
          QuantBacktestComparisonSection(result: comparisonResult),
        ],
        if (selectedTab == QuantDetailTab.overview) ...[
          QuantOverviewSection(result: factorScore),
        ],
        if (selectedTab == QuantDetailTab.technical) ...[
          const SizedBox(height: AppSpacing.xxl),
          TechnicalSummarySection(result: analysis.technicalSummary),
          const SizedBox(height: AppSpacing.xxl),
          QuantRiskMetricsSection(bars: analysis.bars),
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
          _QuoteMetric(
            label: 'RSI14',
            value: rsi14?.toStringAsFixed(2) ?? '--',
          ),
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
        ],
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
