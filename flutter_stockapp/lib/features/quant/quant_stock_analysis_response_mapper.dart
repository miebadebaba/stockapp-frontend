import 'macd_result.dart';
import 'quant_stock_analysis.dart';
import 'stock_daily_bar.dart';
import 'stock_quote.dart';
import 'technical_summary_response_mapper.dart';
import 'volume_analysis_result.dart';

QuantStockAnalysis mapQuantStockAnalysisResponse(Map<String, dynamic> json) {
  final barsJson = _readMapList(json, 'bars');
  final latestBarJson = _readMap(json, 'latest_bar');

  return QuantStockAnalysis(
    symbol: _readString(json, 'symbol'),
    bars: List.unmodifiable(barsJson.map(_mapDailyBar)),
    latestBar: _mapStockQuote(latestBarJson),
    ma5: _readNullableDouble(json, 'ma5'),
    ma10: _readNullableDouble(json, 'ma10'),
    ma20: _readNullableDouble(json, 'ma20'),
    macd: _mapNullableMacd(json['macd']),
    rsi14: _readNullableDouble(json, 'rsi14'),
    volume: _mapNullableVolume(json['volume']),
    technicalSummary: mapTechnicalSummaryResponse(
      _readMap(json, 'technical_summary'),
    ),
  );
}

StockDailyBar _mapDailyBar(Map<String, dynamic> json) {
  return StockDailyBar(
    tradingDate: _readDate(json, 'trade_date'),
    open: _readDouble(json, 'open'),
    high: _readDouble(json, 'high'),
    low: _readDouble(json, 'low'),
    close: _readDouble(json, 'close'),
    volume: _readInt(json, 'volume'),
  );
}

StockQuote _mapStockQuote(Map<String, dynamic> json) {
  return StockQuote(
    tradingDate: _readDate(json, 'trade_date'),
    open: _readDouble(json, 'open'),
    high: _readDouble(json, 'high'),
    low: _readDouble(json, 'low'),
    close: _readDouble(json, 'close'),
    previousClose: _readDouble(json, 'previous_close'),
    volume: _readInt(json, 'volume'),
  );
}

MacdResult? _mapNullableMacd(dynamic value) {
  if (value == null) {
    return null;
  }

  final json = _asMap(value, 'macd');

  return MacdResult(
    dif: _readDouble(json, 'dif'),
    dea: _readDouble(json, 'dea'),
    histogram: _readDouble(json, 'histogram'),
  );
}

VolumeAnalysisResult? _mapNullableVolume(dynamic value) {
  if (value == null) {
    return null;
  }

  final json = _asMap(value, 'volume');

  return VolumeAnalysisResult(
    latestVolume: _readInt(json, 'latest_volume'),
    averageVolume: _readDouble(json, 'average_volume'),
    volumeRatio: _readDouble(json, 'volume_ratio'),
    priceDirection: _parsePriceDirection(_readString(json, 'price_direction')),
  );
}

PriceDirection _parsePriceDirection(String value) {
  return switch (value) {
    'up' => PriceDirection.up,
    'flat' => PriceDirection.flat,
    'down' => PriceDirection.down,
    _ => throw FormatException('Unknown price direction: $value'),
  };
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, String key) {
  return _asMap(json[key], key);
}

Map<String, dynamic> _asMap(dynamic value, String key) {
  if (value is! Map) {
    throw FormatException('Expected "$key" to be an object.');
  }

  return Map<String, dynamic>.from(value);
}

List<Map<String, dynamic>> _readMapList(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is! List) {
    throw FormatException('Expected "$key" to be a list.');
  }

  return value.map((item) => _asMap(item, key)).toList(growable: false);
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is! String) {
    throw FormatException('Expected "$key" to be a string.');
  }

  return value;
}

double _readDouble(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is! num) {
    throw FormatException('Expected "$key" to be a number.');
  }

  return value.toDouble();
}

double? _readNullableDouble(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value == null) {
    return null;
  }

  if (value is! num) {
    throw FormatException('Expected "$key" to be a number or null.');
  }

  return value.toDouble();
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is! num) {
    throw FormatException('Expected "$key" to be a number.');
  }

  return value.toInt();
}

DateTime _readDate(Map<String, dynamic> json, String key) {
  final value = _readString(json, key);
  final date = DateTime.tryParse(value);

  if (date == null) {
    throw FormatException('Expected "$key" to be a valid date.');
  }

  return date;
}
