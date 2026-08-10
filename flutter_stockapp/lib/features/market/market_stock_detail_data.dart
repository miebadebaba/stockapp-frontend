import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/chart_primitives.dart';

class MarketStockStatData {
  const MarketStockStatData({required this.label, required this.value});

  final String label;
  final String value;
}

class MarketStockNewsArticleData {
  const MarketStockNewsArticleData({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.sourceName,
    required this.publishedText,
    required this.readTimeText,
    required this.thumbnailIcon,
    required this.thumbnailColors,
    required this.contentParagraphs,
    this.articleUrl,
    this.imageUrl,
  });

  final String id;
  final String category;
  final String title;
  final String summary;
  final String sourceName;
  final String publishedText;
  final String readTimeText;
  final IconData thumbnailIcon;
  final List<Color> thumbnailColors;
  final List<String> contentParagraphs;
  final String? articleUrl;
  final String? imageUrl;
}

class MarketStockDetailData {
  const MarketStockDetailData({
    required this.id,
    required this.ticker,
    required this.companyName,
    required this.exchangeLabel,
    required this.priceText,
    required this.changeValue,
    required this.changePercent,
    required this.changeLabel,
    required this.chartSeries,
    required this.candleSeries,
    required this.stats,
    required this.newsArticles,
  });

  final String id;
  final String ticker;
  final String companyName;
  final String exchangeLabel;
  final String priceText;
  final double changeValue;
  final double changePercent;
  final String changeLabel;
  final Map<String, List<double>> chartSeries;
  final Map<String, List<ChartCandleData>> candleSeries;
  final List<MarketStockStatData> stats;
  final List<MarketStockNewsArticleData> newsArticles;

  factory MarketStockDetailData.fromBackendJson(
    Map<String, dynamic> json, {
    List<MarketStockNewsArticleData>? fallbackNews,
  }) {
    final rawChartRanges = _asTypedList<Map<String, dynamic>>(
      json['chart_ranges'],
    );
    final defaultRange = (json['default_chart_range'] as String?)?.trim();
    final orderedRanges = _moveDefaultRangeFirst(rawChartRanges, defaultRange);

    final chartSeries = <String, List<double>>{};
    final candleSeries = <String, List<ChartCandleData>>{};

    for (final rangeJson in orderedRanges) {
      final range = (rangeJson['range'] as String?)?.trim();
      if (range == null || range.isEmpty) {
        continue;
      }

      final linePoints = _asTypedList<Map<String, dynamic>>(
        rangeJson['line_points'],
      );
      final candlePoints = _asTypedList<Map<String, dynamic>>(
        rangeJson['candle_points'],
      );

      final closes = linePoints
          .map((point) => _asDouble(point['close']))
          .whereType<double>()
          .toList();
      final candles = candlePoints
          .map(
            (point) => ChartCandleData(
              open: _asDouble(point['open']) ?? 0,
              high: _asDouble(point['high']) ?? 0,
              low: _asDouble(point['low']) ?? 0,
              close: _asDouble(point['close']) ?? 0,
            ),
          )
          .where((point) {
            return point.open != 0 ||
                point.high != 0 ||
                point.low != 0 ||
                point.close != 0;
          })
          .toList();

      if (closes.length >= 2) {
        chartSeries[range] = closes;
      }
      if (candles.length >= 2) {
        candleSeries[range] = candles;
      }
    }

    final stats = _asTypedList<Map<String, dynamic>>(json['stats'])
        .map(
          (item) => MarketStockStatData(
            label: (item['label'] as String?)?.trim() ?? '--',
            value: (item['value'] as String?)?.trim() ?? '--',
          ),
        )
        .toList();

    return MarketStockDetailData(
      id: (json['id'] as String?)?.trim() ?? '',
      ticker: (json['ticker'] as String?)?.trim() ?? '',
      companyName: (json['company_name'] as String?)?.trim() ?? '',
      exchangeLabel: (json['exchange_label'] as String?)?.trim() ?? '',
      priceText: (json['price_text'] as String?)?.trim() ?? '--',
      changeValue: _asDouble(json['change_value']) ?? 0,
      changePercent: _asDouble(json['change_percent']) ?? 0,
      changeLabel: (json['change_label'] as String?)?.trim() ?? 'Latest close',
      chartSeries: chartSeries,
      candleSeries: candleSeries,
      stats: stats,
      newsArticles: fallbackNews ?? const [],
    );
  }
}

MarketStockDetailData? marketStockDetailById(String id) {
  return _mockMarketStockDetails[id];
}

List<MarketStockNewsArticleData> marketStockNewsArticlesById(String id) {
  return List<MarketStockNewsArticleData>.from(
    _mockMarketStockDetails[id]?.newsArticles ?? const [],
  );
}

final _aaplSeries = _normalizeRangeSeries(<String, List<double>>{
  '1D': [201.8, 202.4, 203.1, 202.7, 204.6, 205.2, 206.1, 205.8, 207.4, 208.65],
  '1W': [197.1, 198.8, 199.2, 200.4, 201.6, 203.0, 205.1, 206.4, 207.1, 208.65],
  '1M': [188.4, 189.7, 191.3, 192.8, 194.5, 196.0, 199.4, 202.2, 205.7, 208.65],
  '3M': [176.3, 178.8, 180.1, 183.2, 186.9, 190.4, 194.7, 199.1, 204.2, 208.65],
  'YTD': [
    169.2,
    171.8,
    174.4,
    178.1,
    182.6,
    188.7,
    194.5,
    199.8,
    204.1,
    208.65,
  ],
  '1Y': [164.1, 166.7, 170.9, 175.8, 181.2, 187.0, 193.6, 198.2, 203.9, 208.65],
  'ALL': [
    121.6,
    128.4,
    136.8,
    149.1,
    161.7,
    174.9,
    186.5,
    197.2,
    204.7,
    208.65,
  ],
});

final _tslaSeries = _normalizeRangeSeries(<String, List<double>>{
  '1D': [251.1, 250.4, 249.8, 250.2, 248.9, 248.1, 247.6, 247.1, 246.7, 246.18],
  '1W': [258.8, 257.6, 255.1, 253.7, 251.9, 250.6, 249.4, 248.0, 247.3, 246.18],
  '1M': [241.0, 244.8, 248.4, 252.7, 256.9, 259.2, 255.4, 251.8, 248.2, 246.18],
  '3M': [224.9, 231.7, 236.1, 242.6, 249.1, 255.0, 258.2, 254.4, 250.1, 246.18],
  'YTD': [
    198.8,
    205.6,
    213.1,
    221.5,
    232.2,
    241.6,
    249.9,
    253.0,
    249.1,
    246.18,
  ],
  '1Y': [171.6, 182.3, 194.8, 208.5, 222.1, 236.9, 249.7, 257.2, 251.6, 246.18],
  'ALL': [
    102.4,
    118.2,
    143.8,
    171.1,
    198.6,
    224.2,
    243.4,
    255.7,
    251.0,
    246.18,
  ],
});

final _nvdaSeries = _normalizeRangeSeries(<String, List<double>>{
  '1D': [124.2, 124.8, 125.7, 126.1, 127.6, 128.9, 130.8, 132.3, 133.7, 134.92],
  '1W': [118.6, 119.8, 121.4, 123.2, 125.9, 128.0, 130.7, 132.1, 133.6, 134.92],
  '1M': [109.3, 111.1, 113.8, 116.6, 119.2, 122.4, 126.9, 130.1, 132.8, 134.92],
  '3M': [96.2, 98.5, 101.7, 105.4, 110.0, 115.8, 122.7, 128.4, 132.1, 134.92],
  'YTD': [88.1, 91.4, 95.8, 101.2, 108.5, 116.3, 123.0, 128.6, 132.9, 134.92],
  '1Y': [71.9, 76.4, 83.3, 92.8, 103.1, 114.9, 123.5, 129.4, 132.8, 134.92],
  'ALL': [24.7, 31.8, 39.6, 48.2, 62.9, 81.5, 101.2, 118.6, 129.1, 134.92],
});

final _mockMarketStockDetails = <String, MarketStockDetailData>{
  'aapl': MarketStockDetailData(
    id: 'aapl',
    ticker: 'AAPL',
    companyName: 'Apple Inc.',
    exchangeLabel: 'NASDAQ',
    priceText: '208.65',
    changeValue: 6.08,
    changePercent: 3.00,
    changeLabel: 'Today',
    chartSeries: _aaplSeries,
    candleSeries: _buildCandleSeries(
      _aaplSeries,
      swingFactor: 0.006,
      wickFactor: 0.010,
    ),
    stats: const [
      MarketStockStatData(label: 'Open', value: '\$204.10'),
      MarketStockStatData(label: 'Today\'s High', value: '\$209.02'),
      MarketStockStatData(label: 'Today\'s Low', value: '\$203.84'),
      MarketStockStatData(label: '52 Wk High', value: '\$214.90'),
      MarketStockStatData(label: '52 Wk Low', value: '\$164.08'),
      MarketStockStatData(label: 'Volume', value: '58M'),
      MarketStockStatData(label: 'Average Volume', value: '61M'),
      MarketStockStatData(label: 'Market Cap', value: '\$3.20T'),
      MarketStockStatData(label: 'P/E Ratio', value: '31.2'),
      MarketStockStatData(label: 'Div/Yield', value: '0.53'),
    ],
    newsArticles: const [
      MarketStockNewsArticleData(
        id: 'aapl-news-1',
        category: 'Earnings',
        title:
            'Apple supply chain steadies as investors focus on margin resilience into the next quarter',
        summary:
            'Analysts say steadier component pricing and a richer product mix are helping Apple defend margins even as iPhone upgrade demand remains selective.',
        sourceName: 'Market Wire',
        publishedText: '48 min ago',
        readTimeText: '3 min read',
        thumbnailIcon: Icons.phone_iphone_rounded,
        thumbnailColors: [AppColors.orbBlueLight, AppColors.orbBlueDeep],
        contentParagraphs: [
          'Apple shares moved higher after several sell-side desks highlighted improving visibility around near-term hardware margins. The main argument is that supplier pricing has normalized enough for Apple to protect profitability even without an aggressive unit-growth rebound.',
          'Investors are also watching services growth as a stabilizer. Recurring revenue from subscriptions and platform activity continues to offset some of the volatility tied to upgrade cycles, which keeps the broader earnings profile looking more defensive than many other mega-cap hardware names.',
          'For the stock, the near-term debate is less about whether demand is booming and more about whether Apple can keep revenue quality high while preserving buyback capacity. That combination is still one of the core reasons large funds continue to treat the name as a portfolio anchor.',
        ],
      ),
      MarketStockNewsArticleData(
        id: 'aapl-news-2',
        category: 'AI',
        title:
            'Developers watch Apple AI rollout for signs of deeper ecosystem monetization',
        summary:
            'New platform features are drawing attention not just for user engagement, but for how they might expand paid services and device stickiness.',
        sourceName: 'Tech Ledger',
        publishedText: '2 hrs ago',
        readTimeText: '4 min read',
        thumbnailIcon: Icons.auto_awesome_rounded,
        thumbnailColors: [AppColors.orbViolet, AppColors.orbBlueDeep],
        contentParagraphs: [
          'Apple’s AI positioning is being evaluated through an ecosystem lens rather than a single-product lens. Developers and analysts alike are looking at whether the company can use new intelligence features to deepen engagement across devices, subscriptions, and app workflows.',
          'That matters for the market because Apple rarely needs to win on first-release spectacle. Its advantage usually shows up when new capabilities are folded into an already large installed base, creating retention and monetization opportunities that are hard for competitors to replicate at the same scale.',
          'If adoption metrics come in healthy over the next few product cycles, investors may begin to price in a higher strategic value for services and device bundling rather than treating AI as a pure sentiment story.',
        ],
      ),
      MarketStockNewsArticleData(
        id: 'aapl-news-3',
        category: 'Markets',
        title:
            'Large-cap tech remains a defensive trade as managers rotate toward quality balance sheets',
        summary:
            'Portfolio managers continue to prefer cash-rich leaders such as Apple when macro data is firm but rate expectations stay unstable.',
        sourceName: 'Global Desk',
        publishedText: 'Yesterday',
        readTimeText: '5 min read',
        thumbnailIcon: Icons.shield_rounded,
        thumbnailColors: [AppColors.orbMint, AppColors.accentCyanCard],
        contentParagraphs: [
          'Fund managers say the recent macro backdrop still favors high-quality balance sheets. In that environment, Apple remains one of the more obvious destinations for capital rotation because of its liquidity profile, ecosystem durability, and the optionality investors assign to future categories.',
          'The stock can still be sensitive to valuation questions, especially after strong rallies, but many institutions appear comfortable holding exposure as long as free-cash-flow support and capital returns remain intact.',
          'That positioning does not remove volatility, but it does help explain why dips in mega-cap technology often attract buyers faster than broader cyclical segments during uncertain rate windows.',
        ],
      ),
    ],
  ),
  'tsla': MarketStockDetailData(
    id: 'tsla',
    ticker: 'TSLA',
    companyName: 'Tesla, Inc.',
    exchangeLabel: 'NASDAQ',
    priceText: '246.18',
    changeValue: -3.55,
    changePercent: -1.42,
    changeLabel: 'Today',
    chartSeries: _tslaSeries,
    candleSeries: _buildCandleSeries(
      _tslaSeries,
      swingFactor: 0.010,
      wickFactor: 0.014,
    ),
    stats: const [
      MarketStockStatData(label: 'Open', value: '\$249.70'),
      MarketStockStatData(label: 'Today\'s High', value: '\$252.44'),
      MarketStockStatData(label: 'Today\'s Low', value: '\$245.63'),
      MarketStockStatData(label: '52 Wk High', value: '\$278.98'),
      MarketStockStatData(label: '52 Wk Low', value: '\$138.80'),
      MarketStockStatData(label: 'Volume', value: '101M'),
      MarketStockStatData(label: 'Average Volume', value: '112M'),
      MarketStockStatData(label: 'Market Cap', value: '\$783B'),
      MarketStockStatData(label: 'P/E Ratio', value: '64.8'),
      MarketStockStatData(label: 'Div/Yield', value: '0.00'),
    ],
    newsArticles: const [
      MarketStockNewsArticleData(
        id: 'tsla-news-1',
        category: 'Auto',
        title:
            'Tesla delivery trends face fresh scrutiny as pricing strategy shifts again',
        summary:
            'Investors are reassessing how much of Tesla’s demand profile is volume-driven versus margin-sensitive after another round of pricing adjustments.',
        sourceName: 'Street Focus',
        publishedText: '35 min ago',
        readTimeText: '3 min read',
        thumbnailIcon: Icons.electric_car_rounded,
        thumbnailColors: [AppColors.orbAmberLight, AppColors.orbAmberDeep],
        contentParagraphs: [
          'Tesla remains one of the market’s most debated execution stories because volume growth, pricing, and margins are still tightly linked. Each pricing move can support demand, but it also resets expectations for profitability and competitive intensity.',
          'Analysts following the name are increasingly focused on whether product mix and software-related revenue can eventually reduce the pressure that vehicle price changes place on the gross-margin narrative.',
          'For now, the stock continues to trade on a combination of delivery sentiment, autonomy optimism, and tolerance for near-term earnings volatility.',
        ],
      ),
      MarketStockNewsArticleData(
        id: 'tsla-news-2',
        category: 'AI',
        title:
            'Autonomy updates keep Tesla bulls engaged despite uneven near-term auto fundamentals',
        summary:
            'Supporters argue that progress in self-driving and robotics still carries more valuation weight than quarter-to-quarter vehicle noise.',
        sourceName: 'Future Capital',
        publishedText: '3 hrs ago',
        readTimeText: '4 min read',
        thumbnailIcon: Icons.route_rounded,
        thumbnailColors: [AppColors.orbBlueLight, AppColors.orbBlueDeep],
        contentParagraphs: [
          'Tesla’s valuation case still extends well beyond standard auto metrics for a large part of its shareholder base. The argument is that autonomy, robotics, and software leverage deserve a longer-duration lens than traditional cyclical manufacturers receive.',
          'That belief can keep sentiment supported even when the underlying auto business prints uneven data. It also explains why the stock’s reaction function often differs from what a simple earnings model might suggest.',
          'Skeptics, however, continue to demand measurable commercialization milestones before assigning too much incremental value to those longer-term themes.',
        ],
      ),
      MarketStockNewsArticleData(
        id: 'tsla-news-3',
        category: 'Supply Chain',
        title:
            'Battery input costs ease, but Tesla investors still want proof of margin stabilization',
        summary:
            'Lower raw-material pressure helps, yet the market remains cautious until that benefit is visible in reported automotive profitability.',
        sourceName: 'Macro Mobility',
        publishedText: 'Yesterday',
        readTimeText: '5 min read',
        thumbnailIcon: Icons.battery_charging_full_rounded,
        thumbnailColors: [AppColors.orbMint, AppColors.accentCyanCard],
        contentParagraphs: [
          'A better raw-material backdrop is constructive for Tesla, especially after periods when battery-related costs weighed on profitability expectations. Even so, investors appear reluctant to fully reward that tailwind until it becomes visible in cleaner reported margin trends.',
          'Competitive pricing across EV markets is still intense, which means lower input costs alone may not be enough to reset the earnings narrative.',
          'The near-term read-through is that operational improvements help, but the stock likely needs stronger proof of stabilization before the market becomes more comfortable expanding multiples again.',
        ],
      ),
    ],
  ),
  'nvda': MarketStockDetailData(
    id: 'nvda',
    ticker: 'NVDA',
    companyName: 'NVIDIA Corporation',
    exchangeLabel: 'NASDAQ',
    priceText: '134.92',
    changeValue: 8.65,
    changePercent: 6.85,
    changeLabel: 'Today',
    chartSeries: _nvdaSeries,
    candleSeries: _buildCandleSeries(
      _nvdaSeries,
      swingFactor: 0.012,
      wickFactor: 0.016,
    ),
    stats: const [
      MarketStockStatData(label: 'Open', value: '\$126.01'),
      MarketStockStatData(label: 'Today\'s High', value: '\$136.44'),
      MarketStockStatData(label: 'Today\'s Low', value: '\$124.58'),
      MarketStockStatData(label: '52 Wk High', value: '\$140.76'),
      MarketStockStatData(label: '52 Wk Low', value: '\$86.62'),
      MarketStockStatData(label: 'Volume', value: '287M'),
      MarketStockStatData(label: 'Average Volume', value: '190M'),
      MarketStockStatData(label: 'Market Cap', value: '\$3.33T'),
      MarketStockStatData(label: 'P/E Ratio', value: '38.005'),
      MarketStockStatData(label: 'Div/Yield', value: '0.626'),
    ],
    newsArticles: const [
      MarketStockNewsArticleData(
        id: 'nvda-news-1',
        category: 'Semis',
        title:
            'NVIDIA demand outlook stays firm as data-center buyers keep AI spending elevated',
        summary:
            'Buy-side conversations still point to strong accelerator demand, with supply pacing and customer concentration remaining the key debates.',
        sourceName: 'Chip Brief',
        publishedText: '27 min ago',
        readTimeText: '3 min read',
        thumbnailIcon: Icons.memory_rounded,
        thumbnailColors: [AppColors.orbViolet, AppColors.orbBlueDeep],
        contentParagraphs: [
          'NVIDIA continues to sit at the center of the AI infrastructure trade, and that keeps investors laser-focused on demand durability. Recent checks suggest hyperscale and enterprise appetite for accelerated computing remains robust, even if shipment timing and allocation details still matter.',
          'The bullish case is straightforward: as long as customers keep prioritizing compute buildouts, NVIDIA retains unusual pricing power and revenue visibility relative to the broader semiconductor group.',
          'The main risk questions remain concentration, competition, and whether spending intensity eventually normalizes from exceptionally high levels.',
        ],
      ),
      MarketStockNewsArticleData(
        id: 'nvda-news-2',
        category: 'Cloud',
        title:
            'Cloud commentary reinforces the view that AI capex is moving from experiment to baseline budget',
        summary:
            'For NVIDIA holders, the most important signal is that major buyers increasingly frame AI infrastructure as ongoing rather than optional spending.',
        sourceName: 'Institutional Note',
        publishedText: '2 hrs ago',
        readTimeText: '4 min read',
        thumbnailIcon: Icons.cloud_queue_rounded,
        thumbnailColors: [AppColors.orbBlueLight, AppColors.orbBlueDeep],
        contentParagraphs: [
          'What excites NVIDIA investors is not just strong quarter-to-quarter demand, but the possibility that AI capex is becoming structurally embedded in cloud budgets. If that framing holds, revenue visibility across the ecosystem improves materially.',
          'That said, execution still matters. Product transitions, lead times, and customer mix can shape how efficiently NVIDIA converts backlog and demand signals into reported results.',
          'Even with those normal operational variables, the strategic narrative remains one of the strongest in large-cap technology right now.',
        ],
      ),
      MarketStockNewsArticleData(
        id: 'nvda-news-3',
        category: 'Markets',
        title:
            'Valuation debate returns, but momentum buyers still treat NVIDIA as the flagship AI name',
        summary:
            'Some managers are trimming around strength, yet many still view NVIDIA as the cleanest liquid expression of the AI buildout theme.',
        sourceName: 'Alpha Exchange',
        publishedText: 'Yesterday',
        readTimeText: '5 min read',
        thumbnailIcon: Icons.trending_up_rounded,
        thumbnailColors: [AppColors.orbRose, AppColors.orbAmberDeep],
        contentParagraphs: [
          'NVIDIA’s rally has naturally pulled valuation back into the conversation, especially among funds that are disciplined about concentration and position sizing. Even so, the stock continues to attract momentum and thematic buyers because it remains the clearest public-market proxy for AI infrastructure demand.',
          'That combination can create sharp moves in both directions: profit-taking can appear quickly after strong runs, but so can dip-buying when investors feel the long-term demand thesis is unchanged.',
          'For the market, the stock has become more than a single-company story. It is now a barometer for confidence in the broader AI spending cycle.',
        ],
      ),
    ],
  ),
};

Map<String, List<ChartCandleData>> _buildCandleSeries(
  Map<String, List<double>> closeSeries, {
  required double swingFactor,
  required double wickFactor,
}) {
  return closeSeries.map((range, values) {
    return MapEntry(
      range,
      List<ChartCandleData>.generate(values.length, (index) {
        final close = values[index];
        final previousClose = index == 0 ? close : values[index - 1];
        final oscillation = ((index % 5) - 2) * swingFactor;
        final open = _roundPrice(previousClose * (1 + oscillation * 0.45));
        final high = _roundPrice(
          math.max(open, close) * (1 + wickFactor + (index % 3) * 0.0012),
        );
        final low = _roundPrice(
          math.min(open, close) * (1 - wickFactor - (index % 2) * 0.0008),
        );

        return ChartCandleData(open: open, high: high, low: low, close: close);
      }),
    );
  });
}

const _rangePointTargets = <String, int>{
  '1D': 24,
  '1W': 20,
  '1M': 24,
  '3M': 26,
  'YTD': 28,
  '1Y': 30,
  'ALL': 32,
};

Map<String, List<double>> _normalizeRangeSeries(
  Map<String, List<double>> rawSeries,
) {
  return rawSeries.map((range, values) {
    final targetLength = _rangePointTargets[range] ?? values.length;
    return MapEntry(range, _expandSeries(values, targetLength));
  });
}

List<double> _expandSeries(List<double> values, int targetLength) {
  if (values.length < 2 || values.length >= targetLength) {
    return List<double>.from(values);
  }

  return List<double>.generate(targetLength, (index) {
    final progress = targetLength == 1 ? 0.0 : index / (targetLength - 1);
    return _roundPrice(_sampleSeriesAtProgress(values, progress));
  });
}

double _sampleSeriesAtProgress(List<double> values, double progress) {
  final scaled = progress.clamp(0.0, 1.0) * (values.length - 1);
  final lowerIndex = scaled.floor();
  final upperIndex = scaled.ceil();

  if (lowerIndex == upperIndex) {
    return values[lowerIndex];
  }

  final localProgress = scaled - lowerIndex;
  final lowerValue = values[lowerIndex];
  final upperValue = values[upperIndex];
  return lowerValue + (upperValue - lowerValue) * localProgress;
}

double _roundPrice(double value) {
  return double.parse(value.toStringAsFixed(2));
}

List<Map<String, dynamic>> _moveDefaultRangeFirst(
  List<Map<String, dynamic>> rawRanges,
  String? defaultRange,
) {
  if (defaultRange == null || defaultRange.isEmpty) {
    return rawRanges;
  }

  final prioritized = <Map<String, dynamic>>[];
  final remaining = <Map<String, dynamic>>[];

  for (final range in rawRanges) {
    final rangeLabel = (range['range'] as String?)?.trim();
    if (rangeLabel == defaultRange) {
      prioritized.add(range);
    } else {
      remaining.add(range);
    }
  }

  return [...prioritized, ...remaining];
}

List<T> _asTypedList<T>(Object? raw) {
  if (raw is List) {
    return raw.whereType<T>().toList();
  }
  return <T>[];
}

double? _asDouble(Object? raw) {
  if (raw is num) {
    return raw.toDouble();
  }
  if (raw is String) {
    return double.tryParse(raw);
  }
  return null;
}
