enum QuantMarket { aShare, hongKong, unitedStates }

extension QuantMarketDisplay on QuantMarket {
  String get label {
    return switch (this) {
      QuantMarket.aShare => 'A股',
      QuantMarket.hongKong => '港股',
      QuantMarket.unitedStates => '美股',
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
}
