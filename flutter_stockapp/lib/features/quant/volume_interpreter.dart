import 'volume_analysis_result.dart';
import 'volume_insight.dart';

VolumeInsight interpretVolume(VolumeAnalysisResult? result) {
  const riskNotice = '量价关系只描述历史成交活跃度和价格变化，不能预测未来走势，也不构成投资建议。';

  if (result == null ||
      !result.averageVolume.isFinite ||
      !result.volumeRatio.isFinite ||
      result.latestVolume < 0 ||
      result.averageVolume <= 0 ||
      result.volumeRatio < 0) {
    return const VolumeInsight(
      state: VolumeInsightState.unavailable,
      title: '暂时无法解读成交量',
      explanation: '当前没有足够或有效的成交量数据，暂时无法判断量价状态。',
      riskNotice: riskNotice,
    );
  }

  if (result.volumeRatio >= 1.1) {
    final degree = result.volumeRatio >= 1.5 ? '明显' : '温和';

    return switch (result.priceDirection) {
      PriceDirection.up => VolumeInsight(
        state: VolumeInsightState.elevated,
        title: '$degree放量上涨',
        explanation:
            '最新成交量高于此前5日平均水平，同时收盘价较前一日上涨，'
            '说明价格上涨时市场成交活跃度有所提高。',
        riskNotice: riskNotice,
      ),
      PriceDirection.down => VolumeInsight(
        state: VolumeInsightState.elevated,
        title: '$degree放量下跌',
        explanation:
            '最新成交量高于此前5日平均水平，同时收盘价较前一日下跌，'
            '说明价格下跌时市场成交活跃度有所提高。',
        riskNotice: riskNotice,
      ),
      PriceDirection.flat => VolumeInsight(
        state: VolumeInsightState.elevated,
        title: '$degree放量但价格基本持平',
        explanation:
            '最新成交量高于此前5日平均水平，但收盘价变化不大，'
            '说明成交活跃度提高，价格方向暂时不明显。',
        riskNotice: riskNotice,
      ),
    };
  }

  if (result.volumeRatio >= 0.9) {
    return const VolumeInsight(
      state: VolumeInsightState.normal,
      title: '成交量接近近期平均水平',
      explanation:
          '最新成交量与此前5日平均成交量较为接近，'
          '说明当前成交活跃度没有出现明显放大或缩小。',
      riskNotice: riskNotice,
    );
  }

  final degree = result.volumeRatio < 0.6 ? '明显' : '温和';

  return switch (result.priceDirection) {
    PriceDirection.up => VolumeInsight(
      state: VolumeInsightState.reduced,
      title: '$degree缩量上涨',
      explanation:
          '最新成交量低于此前5日平均水平，同时收盘价较前一日上涨，'
          '说明价格上涨时市场成交参与度有所降低。',
      riskNotice: riskNotice,
    ),
    PriceDirection.down => VolumeInsight(
      state: VolumeInsightState.reduced,
      title: '$degree缩量下跌',
      explanation:
          '最新成交量低于此前5日平均水平，同时收盘价较前一日下跌，'
          '说明价格下跌时市场成交参与度有所降低。',
      riskNotice: riskNotice,
    ),
    PriceDirection.flat => VolumeInsight(
      state: VolumeInsightState.reduced,
      title: '$degree缩量且价格基本持平',
      explanation:
          '最新成交量低于此前5日平均水平，同时收盘价变化不大，'
          '说明当前市场成交活跃度有所降低。',
      riskNotice: riskNotice,
    ),
  };
}
