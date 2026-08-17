import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_factor_ic.dart';
import 'quant_factor_ic_dashboard.dart';

class QuantFactorIcDashboardSection extends StatelessWidget {
  const QuantFactorIcDashboardSection({
    required this.result,
    this.isLoading = false,
    super.key,
  });

  final QuantFactorIcDashboardResult? result;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '因子有效性',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '根据股票池历史因子分与后续收益评价因子的预测能力',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          )
        else
          _buildContent(context, palette),
      ],
    );
  }

  Widget _buildContent(BuildContext context, AppThemePalette palette) {
    final currentResult = result;

    if (currentResult == null) {
      return _StatusMessage(
        icon: Icons.analytics_outlined,
        title: '暂无因子有效性结果',
        message: '等待股票池历史数据完成加载。',
      );
    }

    switch (currentResult.status) {
      case QuantFactorIcDashboardStatus.insufficientRealStocks:
        return _StatusMessage(
          icon: Icons.groups_outlined,
          title: '真实股票样本不足',
          message:
              '当前只有 ${currentResult.realStockCount} 只真实数据股票，'
              '至少需要 3 只才能计算 IC。',
        );

      case QuantFactorIcDashboardStatus.insufficientHistory:
        return _StatusMessage(
          icon: Icons.history_rounded,
          title: '历史数据不足',
          message:
              '已有 ${currentResult.realStockCount} 只真实数据股票，'
              '但尚未形成足够的历史因子与未来收益样本。',
        );

      case QuantFactorIcDashboardStatus.loadFailure:
        return const _StatusMessage(
          icon: Icons.cloud_off_outlined,
          title: '因子有效性加载失败',
          message: '暂时无法获取真实 IC 数据，请确认后端已启动后刷新重试。',
        );
      case QuantFactorIcDashboardStatus.available:
        return Column(
          children: [
            for (final factorId in const ['trend', 'momentum', 'volume'])
              if (currentResult.resultFor(factorId) case final factorResult?)
                _FactorIcRow(result: factorResult),
          ],
        );
    }
  }
}

class _FactorIcRow extends StatelessWidget {
  const _FactorIcRow({required this.result});

  final QuantFactorIcResult result;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _factorLabel(result.factorId),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: palette.primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    _reliabilityLabel(result.reliability),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.secondaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '有效 ${result.availablePeriodCount} 期 · '
                '平均 ${result.averageSampleSize.toStringAsFixed(1)} 只股票',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: palette.secondaryText),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.md,
                children: [
                  _Metric(
                    label: 'Rank IC',
                    value: _signed(result.averageRankInformationCoefficient),
                  ),
                  _Metric(
                    label: '平均 IC',
                    value: _signed(result.averageInformationCoefficient),
                  ),
                  _Metric(
                    label: '正 IC 比例',
                    value: _percent(result.positiveInformationCoefficientRate),
                  ),
                  _Metric(
                    label: 'ICIR',
                    value: _signed(result.icInformationRatio),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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

    return SizedBox(
      width: 112,
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: palette.secondaryText),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.secondaryText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _factorLabel(String factorId) {
  return switch (factorId) {
    'trend' => '趋势因子',
    'momentum' => '动量因子',
    'volume' => '量价因子',
    _ => factorId,
  };
}

String _reliabilityLabel(QuantFactorIcReliability reliability) {
  return switch (reliability) {
    QuantFactorIcReliability.insufficient => '样本不足',
    QuantFactorIcReliability.limited => '样本有限',
    QuantFactorIcReliability.adequate => '样本充分',
  };
}

String _signed(double? value) {
  if (value == null || !value.isFinite) {
    return '--';
  }

  return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}';
}

String _percent(double? value) {
  if (value == null || !value.isFinite) {
    return '--';
  }

  return '${(value * 100).toStringAsFixed(0)}%';
}
