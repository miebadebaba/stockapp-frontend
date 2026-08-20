import 'package:flutter_stockapp/features/quant/quant_data_metadata.dart';
import 'package:flutter_stockapp/features/quant/stock_daily_bar.dart';
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

    test('根据日线数据生成历史范围和质量状态', () {
      final metadata = QuantDataMetadata.fromBars(
        bars: _buildBars(60),
        sourceName: 'Market 行情服务',
        priceAdjustment: PriceAdjustment.none,
        isSimulated: false,
      );

      expect(metadata.historyBarCount, 60);
      expect(metadata.formattedHistoryRange, '2026-01-01 至 2026-03-01');
      expect(metadata.quality, QuantDataQuality.usable);
      expect(metadata.hasRecommendedHistory, isTrue);
      expect(metadata.hasDataIssues, isFalse);
    });

    test('模拟数据优先显示模拟状态，异常行情会被标记', () {
      final simulated = QuantDataMetadata.fromBars(
        bars: _buildBars(2),
        sourceName: '内置模拟数据',
        priceAdjustment: PriceAdjustment.unknown,
        isSimulated: true,
      );
      expect(simulated.quality, QuantDataQuality.simulated);

      final invalid = QuantDataMetadata.fromBars(
        bars: [
          StockDailyBar(
            tradingDate: DateTime(2026, 1, 1),
            open: 100,
            high: 90,
            low: 95,
            close: 98,
            volume: 10,
          ),
        ],
        sourceName: 'Market 行情服务',
        priceAdjustment: PriceAdjustment.unknown,
        isSimulated: false,
      );
      expect(invalid.invalidBarCount, 1);
      expect(invalid.quality, QuantDataQuality.issuesDetected);
    });

    test('没有历史日线时仍保留最新报价日期', () {
      final metadata = QuantDataMetadata.fromBars(
        bars: const [],
        latestTradingDate: DateTime(2026, 8, 20),
        sourceName: 'Market 行情服务',
        priceAdjustment: PriceAdjustment.unknown,
        isSimulated: false,
      );

      expect(metadata.formattedTradingDate, '2026-08-20');
      expect(metadata.formattedHistoryRange, isNull);
      expect(metadata.quality, QuantDataQuality.limitedHistory);
    });
  });
}

List<StockDailyBar> _buildBars(int count) {
  return List.generate(
    count,
    (index) => StockDailyBar(
      tradingDate: DateTime(2026, 1, 1).add(Duration(days: index)),
      open: 100,
      high: 102,
      low: 98,
      close: 101,
      volume: 1000,
    ),
  );
}
