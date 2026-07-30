import 'package:flutter_stockapp/features/quant/quant_data_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriceAdjustmentLabel', () {
    test('返回正确的复权方式中文标签', () {
      expect(PriceAdjustment.none.label, '不复权');
      expect(PriceAdjustment.forward.label, '前复权');
      expect(PriceAdjustment.backward.label, '后复权');
      expect(PriceAdjustment.unknown.label, '暂未提供');
    });
  });

  group('QuantDataMetadata', () {
    test('交易日期统一格式化为年月日', () {
      final metadata = QuantDataMetadata(
        latestTradingDate: DateTime(2026, 7, 2),
        sourceName: '本地模拟数据',
        priceAdjustment: PriceAdjustment.unknown,
        isSimulated: true,
      );

      expect(metadata.formattedTradingDate, '2026-07-02');
    });

    test('保留数据来源和模拟数据标记', () {
      final metadata = QuantDataMetadata(
        latestTradingDate: DateTime(2026, 7, 22),
        sourceName: '本地模拟数据',
        priceAdjustment: PriceAdjustment.unknown,
        isSimulated: true,
      );

      expect(metadata.sourceName, '本地模拟数据');
      expect(metadata.isSimulated, isTrue);
    });
  });
}
