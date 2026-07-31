class PaperPortfolioSummary {
  const PaperPortfolioSummary({
    required this.totalAssets,
    required this.totalProfitLoss,
    required this.dailyProfitLoss,
    required this.dailyProfitLossPercent,
    required this.totalMarketValue,
    required this.availableCash,
    required this.withdrawableCash,
    required this.positionRatio,
  });

  final double totalAssets;
  final double totalProfitLoss;
  final double dailyProfitLoss;
  final double dailyProfitLossPercent;
  final double totalMarketValue;
  final double availableCash;
  final double withdrawableCash;
  final double positionRatio;
}

class HoldingPosition {
  const HoldingPosition({
    required this.symbol,
    required this.name,
    required this.market,
    required this.marketValue,
    required this.profitLoss,
    required this.profitLossPercent,
    required this.quantity,
    required this.availableQuantity,
    required this.averageCost,
    required this.currentPrice,
  });

  final String symbol;
  final String name;
  final String market;
  final double marketValue;
  final double profitLoss;
  final double profitLossPercent;
  final int quantity;
  final int availableQuantity;
  final double averageCost;
  final double currentPrice;
}

class PaperPortfolio {
  const PaperPortfolio({required this.summary, required this.holdings});

  final PaperPortfolioSummary summary;
  final List<HoldingPosition> holdings;

  // TODO: 未来由 FastAPI 模拟交易账户和持仓接口替换。
  static const mock = PaperPortfolio(
    summary: PaperPortfolioSummary(
      totalAssets: 199885.01,
      totalProfitLoss: -114.99,
      dailyProfitLoss: -17.27,
      dailyProfitLossPercent: -0.01,
      totalMarketValue: 37566.60,
      availableCash: 162318.41,
      withdrawableCash: 0.00,
      positionRatio: 18.8,
    ),
    holdings: [
      HoldingPosition(
        symbol: '00700',
        name: '腾讯控股',
        market: '港股',
        marketValue: 37566.60,
        profitLoss: -114.99,
        profitLossPercent: -0.31,
        quantity: 100,
        availableQuantity: 100,
        averageCost: 436.332,
        currentPrice: 435.000,
      ),
    ],
  );
}

class PaperTradingFormatters {
  const PaperTradingFormatters._();

  static String amount(double value) => value.toStringAsFixed(2);

  static String price(double value) => value.toStringAsFixed(3);

  static String percentage(double value, {int fractionDigits = 2}) {
    return '${value.toStringAsFixed(fractionDigits)}%';
  }

  static String quantity(int value) => value.toString();
}
