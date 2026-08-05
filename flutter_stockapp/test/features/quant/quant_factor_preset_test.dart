import 'package:flutter_stockapp/features/quant/quant_factor_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('每套策略的因子权重合计为100%', () {
    for (final preset in quantFactorPresets) {
      final total =
          preset.trendWeight + preset.momentumWeight + preset.volumeWeight;

      expect(total, closeTo(1.0, 0.000001));
    }
  });

  test('根据因子编号返回对应权重', () {
    final balanced = quantFactorPresetByType(QuantFactorPresetType.balanced);

    expect(balanced.weightFor('trend'), 0.40);
    expect(balanced.weightFor('momentum'), 0.35);
    expect(balanced.weightFor('volume'), 0.25);
    expect(balanced.weightFor('unknown'), 0);
  });

  test('三套策略具有不同的风险偏好', () {
    final conservative = quantFactorPresetByType(
      QuantFactorPresetType.conservative,
    );
    final balanced = quantFactorPresetByType(QuantFactorPresetType.balanced);
    final aggressive = quantFactorPresetByType(
      QuantFactorPresetType.aggressive,
    );

    expect(
      conservative.riskPenaltyMultiplier,
      greaterThan(balanced.riskPenaltyMultiplier),
    );
    expect(
      balanced.riskPenaltyMultiplier,
      greaterThan(aggressive.riskPenaltyMultiplier),
    );
  });
}
