import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'quant_backtest_parameters.dart';
import 'quant_factor_backtest.dart';

class QuantBacktestParametersSection extends StatefulWidget {
  const QuantBacktestParametersSection({
    required this.parameters,
    required this.onChanged,
    super.key,
  });

  final QuantBacktestParameters parameters;
  final ValueChanged<QuantBacktestParameters> onChanged;

  @override
  State<QuantBacktestParametersSection> createState() =>
      _QuantBacktestParametersSectionState();
}

class _QuantBacktestParametersSectionState
    extends State<QuantBacktestParametersSection> {
  late double _signalThreshold;
  late int _holdingPeriod;

  late final TextEditingController _commissionController;
  late final TextEditingController _stampDutyController;
  late final TextEditingController _slippageController;

  @override
  void initState() {
    super.initState();

    _signalThreshold = widget.parameters.signalThreshold;
    _holdingPeriod = widget.parameters.holdingPeriod;

    _commissionController = TextEditingController(
      text: _formatRateAsPercent(widget.parameters.costSettings.commissionRate),
    );

    _stampDutyController = TextEditingController(
      text: _formatRateAsPercent(widget.parameters.costSettings.stampDutyRate),
    );

    _slippageController = TextEditingController(
      text: _formatRateAsPercent(widget.parameters.costSettings.slippageRate),
    );
  }

  @override
  void didUpdateWidget(covariant QuantBacktestParametersSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.parameters != widget.parameters) {
      _loadParameters(widget.parameters);
    }
  }

  @override
  void dispose() {
    _commissionController.dispose();
    _stampDutyController.dispose();
    _slippageController.dispose();
    super.dispose();
  }

  void _loadParameters(QuantBacktestParameters parameters) {
    _signalThreshold = parameters.signalThreshold;
    _holdingPeriod = parameters.holdingPeriod;

    _commissionController.text = _formatRateAsPercent(
      parameters.costSettings.commissionRate,
    );
    _stampDutyController.text = _formatRateAsPercent(
      parameters.costSettings.stampDutyRate,
    );
    _slippageController.text = _formatRateAsPercent(
      parameters.costSettings.slippageRate,
    );
  }

  void _resetToDefault() {
    const defaults = QuantBacktestParameters();

    setState(() {
      _signalThreshold = defaults.signalThreshold;
      _holdingPeriod = defaults.holdingPeriod;
      _commissionController.text = _formatRateAsPercent(
        defaults.costSettings.commissionRate,
      );
      _stampDutyController.text = _formatRateAsPercent(
        defaults.costSettings.stampDutyRate,
      );
      _slippageController.text = _formatRateAsPercent(
        defaults.costSettings.slippageRate,
      );
    });

    widget.onChanged(defaults);
  }

  void _applyParameters() {
    final commissionRate = _parsePercent(_commissionController.text);
    final stampDutyRate = _parsePercent(_stampDutyController.text);
    final slippageRate = _parsePercent(_slippageController.text);

    if (commissionRate == null ||
        stampDutyRate == null ||
        slippageRate == null) {
      _showValidationMessage('请输入有效的交易成本比例，例如 0.03');
      return;
    }

    if (commissionRate < 0 ||
        stampDutyRate < 0 ||
        slippageRate < 0 ||
        commissionRate >= 100 ||
        stampDutyRate >= 100 ||
        slippageRate >= 100) {
      _showValidationMessage('交易成本比例必须在 0 到 100 之间');
      return;
    }

    final parameters = QuantBacktestParameters(
      signalThreshold: _signalThreshold,
      holdingPeriod: _holdingPeriod,
      minimumLookback: widget.parameters.minimumLookback,
      costSettings: QuantBacktestCostSettings(
        commissionRate: commissionRate / 100,
        stampDutyRate: stampDutyRate / 100,
        slippageRate: slippageRate / 100,
      ),
    );

    widget.onChanged(parameters);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('回测参数已应用')));
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '回测参数',
          style: textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '调整参数后点击“应用参数”，再查看新的历史回测结果。',
          style: textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '信号阈值：${_signalThreshold.toStringAsFixed(0)} 分',
          style: textTheme.bodyLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        Slider(
          value: _signalThreshold,
          min: 0,
          max: 100,
          divisions: 20,
          label: _signalThreshold.toStringAsFixed(0),
          onChanged: (value) {
            setState(() {
              _signalThreshold = value;
            });
          },
        ),
        Text(
          '阈值越高，触发信号越少，但筛选条件更严格。',
          style: textTheme.bodySmall?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '持有周期',
          style: textTheme.bodyLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment<int>(value: 3, label: Text('3日')),
            ButtonSegment<int>(value: 5, label: Text('5日')),
            ButtonSegment<int>(value: 10, label: Text('10日')),
            ButtonSegment<int>(value: 20, label: Text('20日')),
          ],
          selected: {_holdingPeriod},
          onSelectionChanged: (values) {
            setState(() {
              _holdingPeriod = values.first;
            });
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '信号出现后，下一交易日开盘买入并持有指定交易日。',
          style: textTheme.bodySmall?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Text(
            '交易成本设置',
            style: textTheme.bodyLarge?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            '用于让回测结果更接近真实交易',
            style: textTheme.bodySmall?.copyWith(color: palette.secondaryText),
          ),
          children: [
            const SizedBox(height: AppSpacing.sm),
            _RateInput(
              controller: _commissionController,
              label: '佣金',
              helperText: '买入和卖出均收取',
            ),
            const SizedBox(height: AppSpacing.md),
            _RateInput(
              controller: _stampDutyController,
              label: '卖出印花税',
              helperText: '仅卖出时收取',
            ),
            const SizedBox(height: AppSpacing.md),
            _RateInput(
              controller: _slippageController,
              label: '单边滑点',
              helperText: '模拟成交价格偏离',
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _resetToDefault,
                icon: const Icon(Icons.restore_rounded),
                label: const Text('恢复默认'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton.icon(
                onPressed: _applyParameters,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('应用参数'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RateInput extends StatelessWidget {
  const _RateInput({
    required this.controller,
    required this.label,
    required this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: '%',
        helperText: helperText,
        helperStyle: TextStyle(color: palette.secondaryText),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

String _formatRateAsPercent(double rate) {
  return (rate * 100).toStringAsFixed(2);
}

double? _parsePercent(String value) {
  final normalized = value.trim().replaceAll(',', '.');

  if (normalized.isEmpty) {
    return null;
  }

  return double.tryParse(normalized);
}
