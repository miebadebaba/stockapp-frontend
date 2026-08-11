import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/features/quant/selected_stock.dart';
import 'package:flutter_stockapp/features/watchlist/watchlist_storage.dart';

void main() {
  late Directory temporaryDirectory;
  late File storageFile;
  late WatchlistStorage storage;

  setUp(() {
    temporaryDirectory = Directory.systemTemp.createTempSync(
      'flutter_stockapp_watchlist_test_',
    );
    storageFile = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}watchlist.json',
    );
    storage = WatchlistStorage(storageFile: storageFile);
  });

  tearDown(() {
    if (temporaryDirectory.existsSync()) {
      temporaryDirectory.deleteSync(recursive: true);
    }
  });

  test('文件不存在时返回空列表', () async {
    final stocks = await storage.load();

    expect(stocks, isEmpty);
  });

  test('可以保存并恢复自选股票', () async {
    const stocks = [
      SelectedStock(
        code: 'AAPL',
        name: 'Apple',
        market: QuantMarket.unitedStates,
      ),
      SelectedStock(code: '600519', name: '贵州茅台', market: QuantMarket.aShare),
    ];

    await storage.save(stocks);
    final restored = await storage.load();

    expect(restored, stocks);
    expect(restored[0].market, QuantMarket.unitedStates);
    expect(restored[1].market, QuantMarket.aShare);
  });

  test('损坏的 JSON 返回空列表', () async {
    await storageFile.writeAsString('{invalid json');

    final stocks = await storage.load();

    expect(stocks, isEmpty);
  });

  test('JSON 不是股票数组时返回空列表', () async {
    await storageFile.writeAsString('{"stocks": []}');

    final stocks = await storage.load();

    expect(stocks, isEmpty);
  });

  test('数组中无效股票会被忽略', () async {
    await storageFile.writeAsString(
      '[{"code":"AAPL","name":"Apple","market":"unitedStates"},'
      '{"code":"","name":"Invalid"},'
      'null]',
    );

    final stocks = await storage.load();

    expect(stocks, hasLength(1));
    expect(stocks.single.code, 'AAPL');
  });
}
