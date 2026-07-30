import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import 'home_stock_data.dart';
import '../market/market_stock_detail_page.dart';
import 'stocks_page.dart';
import 'widgets/market_snapshot_section.dart';
import 'widgets/stock_list_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                        stocks: homeStocks.take(3).toList(),
                        onTitleTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) {
                                return const StocksPage(stocks: homeStocks);
                              },
                            ),
                          );
                        },
                        onStockTap: (stockId) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) {
                                return MarketStockDetailPage(stockId: stockId);
                              },
                            ),
                          );
                        },
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
