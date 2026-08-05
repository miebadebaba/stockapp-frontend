enum QuantFactorPresetType { conservative, balanced, aggressive }

class QuantFactorPreset {
  const QuantFactorPreset({
    required this.type,
    required this.label,
    required this.description,
    required this.trendWeight,
    required this.momentumWeight,
    required this.volumeWeight,
    required this.riskPenaltyMultiplier,
  });

  final QuantFactorPresetType type;
  final String label;
  final String description;
  final double trendWeight;
  final double momentumWeight;
  final double volumeWeight;
  final double riskPenaltyMultiplier;

  double weightFor(String factorId) {
    return switch (factorId) {
      'trend' => trendWeight,
      'momentum' => momentumWeight,
      'volume' => volumeWeight,
      _ => 0,
    };
  }
}

const quantFactorPresets = <QuantFactorPreset>[
  QuantFactorPreset(
    type: QuantFactorPresetType.conservative,
    label: '稳健型',
    description: '更重视趋势稳定和风险控制',
    trendWeight: 0.50,
    momentumWeight: 0.20,
    volumeWeight: 0.30,
    riskPenaltyMultiplier: 1.25,
  ),
  QuantFactorPreset(
    type: QuantFactorPresetType.balanced,
    label: '均衡型',
    description: '兼顾趋势、动量和量价表现',
    trendWeight: 0.40,
    momentumWeight: 0.35,
    volumeWeight: 0.25,
    riskPenaltyMultiplier: 1.00,
  ),
  QuantFactorPreset(
    type: QuantFactorPresetType.aggressive,
    label: '进取型',
    description: '更重视上涨动量，同时保留风险约束',
    trendWeight: 0.30,
    momentumWeight: 0.50,
    volumeWeight: 0.20,
    riskPenaltyMultiplier: 0.75,
  ),
];

QuantFactorPreset quantFactorPresetByType(QuantFactorPresetType type) {
  return quantFactorPresets.firstWhere((preset) => preset.type == type);
}
