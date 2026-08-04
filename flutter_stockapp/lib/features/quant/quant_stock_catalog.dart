import 'selected_stock.dart';

const quantStockCatalog = <SelectedStock>[
  SelectedStock(code: '600519', name: '贵州茅台', market: QuantMarket.aShare),
  SelectedStock(code: '000001', name: '平安银行', market: QuantMarket.aShare),
  SelectedStock(code: '300750', name: '宁德时代', market: QuantMarket.aShare),
  SelectedStock(code: '601318', name: '中国平安', market: QuantMarket.aShare),
  SelectedStock(code: '000858', name: '五粮液', market: QuantMarket.aShare),
  SelectedStock(code: '600036', name: '招商银行', market: QuantMarket.aShare),
  SelectedStock(code: '002594', name: '比亚迪', market: QuantMarket.aShare),
  SelectedStock(code: '600276', name: '恒瑞医药', market: QuantMarket.aShare),
  SelectedStock(code: '00700.HK', name: '腾讯控股', market: QuantMarket.hongKong),
  SelectedStock(
    code: '09988.HK',
    name: '阿里巴巴-SW',
    market: QuantMarket.hongKong,
  ),
  SelectedStock(code: '03690.HK', name: '美团-W', market: QuantMarket.hongKong),
  SelectedStock(code: '01810.HK', name: '小米集团-W', market: QuantMarket.hongKong),
  SelectedStock(code: 'AAPL', name: 'Apple', market: QuantMarket.unitedStates),
  SelectedStock(
    code: 'MSFT',
    name: 'Microsoft',
    market: QuantMarket.unitedStates,
  ),
  SelectedStock(code: 'NVDA', name: 'NVIDIA', market: QuantMarket.unitedStates),
  SelectedStock(code: 'TSLA', name: 'Tesla', market: QuantMarket.unitedStates),
];
