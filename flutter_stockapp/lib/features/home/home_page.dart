import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import 'widgets/investing_chart_card.dart';
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
      id: 'acot-call',
      title: 'ACOT \$20 Call',
      subtitle: '7/14 Exp · 1 Buy',
      changePercent: 3.00,
    ),
    StockListItemData(
      id: 'tsla-common',
      title: 'TSLA',
      subtitle: 'Long stock · 4 Shares',
      changePercent: -1.42,
    ),
    StockListItemData(
      id: 'nvda-call',
      title: 'NVDA \$160 Call',
      subtitle: '8/02 Exp · 2 Buys',
      changePercent: 6.85,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedPageWrapper(
      child: ColoredBox(
        color: AppColors.bgPrimary,
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
