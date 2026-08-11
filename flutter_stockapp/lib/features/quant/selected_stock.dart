enum QuantMarket { aShare, hongKong, unitedStates }

extension QuantMarketDisplay on QuantMarket {
  String get label {
    return switch (this) {
      QuantMarket.aShare => 'A股',
      QuantMarket.hongKong => '港股',
      QuantMarket.unitedStates => '美股',
    };
  }

  String get storageValue {
    return switch (this) {
      QuantMarket.aShare => 'aShare',
      QuantMarket.hongKong => 'hongKong',
      QuantMarket.unitedStates => 'unitedStates',
    };
  }

  static QuantMarket fromStorageValue(String? value) {
    return switch (value) {
      'hongKong' => QuantMarket.hongKong,
      'unitedStates' => QuantMarket.unitedStates,
      _ => QuantMarket.aShare,
    };
  }
}

class SelectedStock {
  const SelectedStock({
    required this.code,
    required this.name,
    this.market = QuantMarket.aShare,
  });

  final String code;
  final String name;
  final QuantMarket market;

  Map<String, Object?> toJson() {
    return {'code': code, 'name': name, 'market': market.storageValue};
  }

  static SelectedStock? fromJson(Object? value) {
    if (value is! Map) {
      return null;
    }

    final code = value['code'];
    final name = value['name'];
    final market = value['market'];

    if (code is! String ||
        name is! String ||
        code.trim().isEmpty ||
        name.trim().isEmpty) {
      return null;
    }

    return SelectedStock(
      code: code.trim(),
      name: name.trim(),
      market: QuantMarketDisplay.fromStorageValue(
        market is String ? market : null,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedStock &&
        other.code.toLowerCase() == code.toLowerCase();
  }

  @override
  int get hashCode => code.toLowerCase().hashCode;
}
