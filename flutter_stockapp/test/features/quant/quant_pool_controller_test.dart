import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/features/quant/quant_pool_controller.dart';
import 'package:flutter_stockapp/features/quant/quant_pool_storage.dart';
import 'package:flutter_stockapp/features/quant/selected_stock.dart';

void main() {
  late Directory temporaryDirectory;
  late File storageFile;
  late QuantPoolStorage storage;

  const apple = SelectedStock(
    code: 'AAPL',
    name: 'Apple',
    market: QuantMarket.unitedStates,
  );

  const tesla = SelectedStock(
    code: 'TSLA',
    name: 'Tesla',
    market: QuantMarket.unitedStates,
  );

  const moutai = SelectedStock(
    code: '600519',
    name: '贵州茅台',
    market: QuantMarket.aShare,
  );

  setUp(() {
    temporaryDirectory = Directory.systemTemp.createTempSync(
      'flutter_stockapp_quant_pool_test_',
    );
    storageFile = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}quant_pool.json',
    );
    storage = QuantPoolStorage(storageFile: storageFile);
  });

  tearDown(() {
    if (temporaryDirectory.existsSync()) {
      temporaryDirectory.deleteSync(recursive: true);
    }
  });

  test('第一次加载时使用默认分析池并保存', () async {
    final controller = QuantPoolController(storage: storage);

    await controller.load(defaultStocks: const [apple, tesla]);

    expect(controller.isLoaded, isTrue);
    expect(controller.stocks, const [apple, tesla]);
    expect(await storage.load(), const [apple, tesla]);
  });

  test('用户清空分析池后不会恢复默认股票', () async {
    final controller = QuantPoolController(storage: storage);

    await controller.load(defaultStocks: const [apple, tesla]);
    await controller.clearAndSave();

    final restoredController = QuantPoolController(storage: storage);
    await restoredController.load(defaultStocks: const [apple, tesla]);

    expect(restoredController.isLoaded, isTrue);
    expect(restoredController.stocks, isEmpty);
  });

  test('添加和移除分析股票会保存到本地', () async {
    final controller = QuantPoolController(storage: storage);
    await controller.load(defaultStocks: const []);

    final added = await controller.addAndSave(apple);
    expect(added, isTrue);
    expect(controller.containsCode('aapl'), isTrue);

    final removed = await controller.removeAndSave(apple);
    expect(removed, isTrue);
    expect(controller.isEmpty, isTrue);

    expect(await storage.load(), isEmpty);
  });

  test('相同代码不能重复加入分析池', () async {
    final controller = QuantPoolController(storage: storage);
    await controller.load(defaultStocks: const [moutai]);

    final added = await controller.addAndSave(
      const SelectedStock(
        code: ' 600519 ',
        name: '重复股票',
        market: QuantMarket.aShare,
      ),
    );

    expect(added, isFalse);
    expect(controller.length, 1);
  });

  test('分析池和 Stock 自选使用独立的存储文件', () async {
    final controller = QuantPoolController(storage: storage);

    await controller.load(defaultStocks: const [apple]);
    await controller.addAndSave(tesla);

    final stored = await storage.load();

    expect(stored, const [apple, tesla]);
    expect(storageFile.path, isNot(contains('watchlist')));
  });
}
