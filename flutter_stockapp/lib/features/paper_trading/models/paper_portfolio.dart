class PaperAccount {
  const PaperAccount({
    required this.id,
    required this.accountKey,
    required this.currency,
    required this.initialCash,
    required this.availableCash,
  });

  final int id;
  final String accountKey;
  final String currency;
  final double initialCash;
  final double availableCash;

  factory PaperAccount.fromJson(Map<String, dynamic> json) {
    return PaperAccount(
      id: _readInt(json, 'id'),
      accountKey: _readString(json, 'account_key'),
      currency: _readString(json, 'currency'),
      initialCash: _readDouble(json, 'initial_cash'),
      availableCash: _readDouble(json, 'available_cash'),
    );
  }
}

class PaperPortfolioSummary {
  const PaperPortfolioSummary({
    required this.initialCash,
    required this.totalAssets,
    required this.totalProfitLoss,
    required this.totalProfitLossPercent,
    required this.totalMarketValue,
    required this.availableCash,
    required this.positionRatio,
  });

  final double initialCash;
  final double totalAssets;
  final double totalProfitLoss;
  final double totalProfitLossPercent;
  final double totalMarketValue;
  final double availableCash;
  final double positionRatio;

  factory PaperPortfolioSummary.fromJson(Map<String, dynamic> json) {
    return PaperPortfolioSummary(
      initialCash: _readDouble(json, 'initial_cash'),
      totalAssets: _readDouble(json, 'total_assets'),
      totalProfitLoss: _readDouble(json, 'total_profit_loss'),
      totalProfitLossPercent: _readDouble(json, 'total_profit_loss_percent'),
      totalMarketValue: _readDouble(json, 'market_value'),
      availableCash: _readDouble(json, 'available_cash'),
      positionRatio: _readDouble(json, 'position_ratio'),
    );
  }
}

class HoldingPosition {
  const HoldingPosition({
    required this.symbol,
    required this.name,
    required this.market,
    required this.currency,
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
  final String currency;
  final double marketValue;
  final double profitLoss;
  final double profitLossPercent;
  final int quantity;
  final int availableQuantity;
  final double averageCost;
  final double currentPrice;

  factory HoldingPosition.fromJson(Map<String, dynamic> json) {
    final symbol = _readString(json, 'symbol');
    final currency = _readString(json, 'currency');
    return HoldingPosition(
      symbol: symbol,
      name: _readNullableString(json, 'name') ?? symbol,
      market: currency,
      currency: currency,
      marketValue: _readDouble(json, 'market_value'),
      profitLoss: _readDouble(json, 'unrealized_profit_loss'),
      profitLossPercent: _readDouble(json, 'unrealized_profit_loss_percent'),
      quantity: _readInt(json, 'quantity'),
      availableQuantity: _readInt(json, 'quantity'),
      averageCost: _readDouble(json, 'average_cost'),
      currentPrice: _readDouble(json, 'current_price'),
    );
  }
}

class PaperPortfolio {
  const PaperPortfolio({
    required this.account,
    required this.summary,
    required this.holdings,
  });

  final PaperAccount account;
  final PaperPortfolioSummary summary;
  final List<HoldingPosition> holdings;

  factory PaperPortfolio.fromJson(Map<String, dynamic> json) {
    return PaperPortfolio(
      account: PaperAccount.fromJson(_readMap(json, 'account')),
      summary: PaperPortfolioSummary.fromJson(_readMap(json, 'summary')),
      holdings: _readList(json, 'positions')
          .map((item) => HoldingPosition.fromJson(_asMap(item, 'positions')))
          .toList(growable: false),
    );
  }
}

class PaperOrder {
  const PaperOrder({
    required this.id,
    required this.symbol,
    required this.side,
    required this.orderType,
    required this.quantity,
    required this.status,
    required this.submittedAt,
    this.filledAt,
    this.rejectionReason,
    this.executionPrice,
  });

  final int id;
  final String symbol;
  final String side;
  final String orderType;
  final int quantity;
  final String status;
  final DateTime submittedAt;
  final DateTime? filledAt;
  final String? rejectionReason;
  final double? executionPrice;

  factory PaperOrder.fromJson(Map<String, dynamic> json) {
    return PaperOrder(
      id: _readInt(json, 'id'),
      symbol: _readString(json, 'symbol'),
      side: _readString(json, 'side'),
      orderType: _readString(json, 'order_type'),
      quantity: _readInt(json, 'quantity'),
      status: _readString(json, 'status'),
      submittedAt: _readDateTime(json, 'submitted_at'),
      filledAt: _readNullableDateTime(json, 'filled_at'),
      rejectionReason: _readNullableString(json, 'rejection_reason'),
      executionPrice: _readNullableDouble(json, 'execution_price'),
    );
  }
}

class PaperExecution {
  const PaperExecution({
    required this.id,
    required this.orderId,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.price,
    required this.executedAt,
  });

  final int id;
  final int orderId;
  final String symbol;
  final String side;
  final int quantity;
  final double price;
  final DateTime executedAt;

  factory PaperExecution.fromJson(Map<String, dynamic> json) {
    return PaperExecution(
      id: _readInt(json, 'id'),
      orderId: _readInt(json, 'order_id'),
      symbol: _readString(json, 'symbol'),
      side: _readString(json, 'side'),
      quantity: _readInt(json, 'quantity'),
      price: _readDouble(json, 'price'),
      executedAt: _readDateTime(json, 'executed_at'),
    );
  }
}

class PaperOrderSubmission {
  const PaperOrderSubmission({
    required this.order,
    required this.execution,
    required this.summary,
  });

  final PaperOrder order;
  final PaperExecution execution;
  final PaperPortfolioSummary summary;

  factory PaperOrderSubmission.fromJson(Map<String, dynamic> json) {
    final execution = PaperExecution.fromJson(_readMap(json, 'execution'));
    final order = PaperOrder.fromJson(
      _readMap(json, 'order'),
    ).copyWithExecutionPrice(execution.price);
    return PaperOrderSubmission(
      order: order,
      execution: execution,
      summary: PaperPortfolioSummary.fromJson(_readMap(json, 'summary')),
    );
  }
}

extension on PaperOrder {
  PaperOrder copyWithExecutionPrice(double price) {
    return PaperOrder(
      id: id,
      symbol: symbol,
      side: side,
      orderType: orderType,
      quantity: quantity,
      status: status,
      submittedAt: submittedAt,
      filledAt: filledAt,
      rejectionReason: rejectionReason,
      executionPrice: price,
    );
  }
}

class PaperTradingFormatters {
  const PaperTradingFormatters._();

  static String amount(double value) => value.toStringAsFixed(2);

  static String price(double value) => value.toStringAsFixed(3);

  static String percentage(double value, {int fractionDigits = 2}) {
    return '${value.toStringAsFixed(fractionDigits)}%';
  }

  static String quantity(int value) => value.toString();

  static String orderSide(String value) {
    return switch (value) {
      'buy' => '买入',
      'sell' => '卖出',
      _ => value,
    };
  }

  static String orderStatus(String value) {
    return switch (value) {
      'filled' => '已成交',
      'rejected' => '已拒绝',
      _ => value,
    };
  }

  static String dateTime(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, String key) {
  return _asMap(json[key], key);
}

Map<String, dynamic> _asMap(Object? value, String key) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  throw FormatException('Expected $key to be a JSON object.');
}

List<dynamic> _readList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is List) {
    return value;
  }
  throw FormatException('Expected $key to be a JSON array.');
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Expected $key to be a non-empty string.');
}

String? _readNullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value.isEmpty ? null : value;
  }
  throw FormatException('Expected $key to be a string.');
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  throw FormatException('Expected $key to be an integer.');
}

double _readDouble(Map<String, dynamic> json, String key) {
  final value = _readNullableDouble(json, key);
  if (value == null) {
    throw FormatException('Expected $key to be a number.');
  }
  return value;
}

double? _readNullableDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  throw FormatException('Expected $key to be a number.');
}

DateTime _readDateTime(Map<String, dynamic> json, String key) {
  final value = _readNullableDateTime(json, key);
  if (value == null) {
    throw FormatException('Expected $key to be an ISO datetime.');
  }
  return value;
}

DateTime? _readNullableDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  throw FormatException('Expected $key to be an ISO datetime.');
}
