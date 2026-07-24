import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import 'widgets/investing_chart_card.dart';
import 'widgets/market_snapshot_section.dart';
import 'widgets/stock_list_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Map<String, List<double>> _mockSeries = {
    '1D': [62, 63, 62.5, 63.2, 63.0, 63.5, 64.4, 66.3, 69.8, 73.2],
    '1W': [58, 58.7, 59.1, 58.8, 59.4, 60.1, 60.0, 61.3, 63.7, 67.2],
    '1M': [51, 51.6, 52.0, 51.8, 52.3, 52.1, 53.0, 54.6, 57.4, 61.0],
    '3M': [42, 42.5, 42.7, 42.4, 42.8, 43.2, 44.3, 46.8, 50.9, 56.5],
    'YTD': [35, 35.4, 35.0, 35.8, 36.2, 36.0, 37.3, 39.6, 44.1, 49.8],
    '1Y': [28, 28.8, 29.1, 28.9, 29.8, 30.2, 31.6, 34.0, 38.7, 45.6],
    'ALL': [18, 18.5, 18.2, 19.0, 18.7, 19.6, 22.4, 28.6, 37.8, 52.4],
  };

  static const List<StockListItemData> _mockStocks = [
    StockListItemData(
      id: 'aapl',
      title: 'AAPL',
      subtitle: 'Apple Inc.',
      priceText: '208.65',
      changePercent: 3.00,
      referenceValue: 204.10,
      sparklineValues: [
        201.8,
        202.4,
        203.1,
        202.7,
        204.6,
        205.2,
        206.1,
        205.8,
        207.4,
        208.65,
      ],
    ),
    StockListItemData(
      id: 'tsla',
      title: 'TSLA',
      subtitle: 'Tesla, Inc.',
      priceText: '246.18',
      changePercent: -1.42,
      referenceValue: 249.70,
      sparklineValues: [
        251.1,
        250.4,
        249.8,
        250.2,
        248.9,
        248.1,
        247.6,
        247.1,
        246.7,
        246.18,
      ],
    ),
    StockListItemData(
      id: 'nvda',
      title: 'NVDA',
      subtitle: 'NVIDIA Corporation',
      priceText: '134.92',
      changePercent: 6.85,
      referenceValue: 126.40,
      sparklineValues: [
        124.2,
        124.8,
        125.7,
        126.1,
        127.6,
        128.9,
        130.8,
        132.3,
        133.7,
        134.92,
      ],
    ),
  ];

  static const List<MarketSnapshotItemData> _mockMarkets = [
    MarketSnapshotItemData(
      id: 'sp500',
      assetName: 'S&P 500',
      valueText: '5,634.2',
      changePercent: 0.84,
      sparklineValues: [18, 19, 18.6, 19.5, 20.4, 20.1, 21.2],
    ),
    MarketSnapshotItemData(
      id: 'nasdaq100',
      assetName: 'Nasdaq 100',
      valueText: '19,402.8',
      changePercent: -0.42,
      sparklineValues: [22, 21.8, 22.4, 22.1, 21.7, 21.4, 21.1],
    ),
    MarketSnapshotItemData(
      id: 'dowjones',
      assetName: 'Dow Jones',
      valueText: '41,228.6',
      changePercent: 0.31,
      sparklineValues: [15, 15.4, 15.1, 15.9, 16.2, 16.0, 16.5],
    ),
    MarketSnapshotItemData(
      id: 'semis',
      assetName: 'Semiconductors',
      valueText: '4,812.3',
      changePercent: -1.18,
      sparklineValues: [28, 27.4, 27.8, 27.1, 26.3, 25.8, 25.2],
    ),
    MarketSnapshotItemData(
      id: 'energy',
      assetName: 'Energy',
      valueText: '1,084.7',
      changePercent: 1.06,
      sparklineValues: [12, 12.3, 12.8, 12.6, 13.1, 13.5, 13.8],
    ),
    MarketSnapshotItemData(
      id: 'healthcare',
      assetName: 'Healthcare',
      valueText: '3,226.9',
      changePercent: -0.26,
      sparklineValues: [20, 19.9, 20.1, 19.8, 19.6, 19.4, 19.3],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return AnimatedPageWrapper(
      child: ColoredBox(
        color: palette.pageBackground,
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 96, 0, 140),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InvestingChartCard(
                      title: 'Investing',
                      amountText: '\$8,153.31',
                      changeText: '\$922.47 (12.76%)',
                      changeLabel: 'All time',
                      showBadge: true,
                      badgeText: 'Gold perks',
                      initialRange: 'ALL',
                      mockData: _mockSeries,
                      showEndMarker: false,
                      onRangeChanged: (_) {},
                      onBadgeTap: () {},
                      onSettingsTap: () {},
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: MarketSnapshotSection(
                        titleText: 'Markets',
                        assets: _mockMarkets,
                        onTitleTap: () {},
                        onAssetTap: (_) {},
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: StockListSection(
                        titleText: 'Stocks',
                        stocks: _mockStocks,
                        onTitleTap: () {},
                        onStockTap: (_) {},
                      ),
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
