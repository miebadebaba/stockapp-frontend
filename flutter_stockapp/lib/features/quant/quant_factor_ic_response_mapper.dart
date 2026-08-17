import 'quant_factor_ic.dart';
import 'quant_factor_ic_dashboard.dart';

QuantFactorIcDashboardResult mapQuantFactorIcAnalysisResponse(
  Map<String, dynamic> json,
) {
  final symbols = _readList(json, 'symbols');
  final factorResultsJson = _readMapList(json, 'factor_results');

  final factorResults = <String, QuantFactorIcResult>{};

  for (final factorJson in factorResultsJson) {
    final result = _mapFactorResult(factorJson);
    factorResults[result.factorId] = result;
  }

  final hasAvailableResult = factorResults.values.any(
    (result) => result.availablePeriodCount > 0,
  );

  final realStockCount = symbols.length;

  return QuantFactorIcDashboardResult(
    status: realStockCount < 3
        ? QuantFactorIcDashboardStatus.insufficientRealStocks
        : hasAvailableResult
        ? QuantFactorIcDashboardStatus.available
        : QuantFactorIcDashboardStatus.insufficientHistory,
    realStockCount: realStockCount,
    factorResults: Map.unmodifiable(factorResults),
  );
}

QuantFactorIcResult _mapFactorResult(Map<String, dynamic> json) {
  final factorId = _readString(json, 'factor_id');
  final periodsJson = _readMapList(json, 'periods');

  return QuantFactorIcResult(
    factorId: factorId,
    periods: List.unmodifiable(
      periodsJson.map(
        (periodJson) => QuantFactorIcPeriodResult(
          date: _readDate(periodJson, 'date'),
          sampleSize: _readInt(periodJson, 'sample_size'),
          informationCoefficient: _readNullableDouble(
            periodJson,
            'information_coefficient',
          ),
          rankInformationCoefficient: _readNullableDouble(
            periodJson,
            'rank_information_coefficient',
          ),
        ),
      ),
    ),
  );
}

List<dynamic> _readList(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is! List) {
    throw FormatException('Expected "$key" to be a list.');
  }

  return value;
}

List<Map<String, dynamic>> _readMapList(Map<String, dynamic> json, String key) {
  return _readList(
    json,
    key,
  ).map((value) => _asMap(value, key)).toList(growable: false);
}

Map<String, dynamic> _asMap(dynamic value, String key) {
  if (value is! Map) {
    throw FormatException('Expected "$key" to contain objects.');
  }

  return Map<String, dynamic>.from(value);
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected "$key" to be a non-empty string.');
  }

  return value.trim();
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is! num) {
    throw FormatException('Expected "$key" to be a number.');
  }

  return value.toInt();
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

DateTime _readDate(Map<String, dynamic> json, String key) {
  final value = _readString(json, key);
  final result = DateTime.tryParse(value);

  if (result == null) {
    throw FormatException('Expected "$key" to be a valid date.');
  }

  return result;
}
