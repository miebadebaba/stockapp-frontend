import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/features/quant/selected_stock.dart';
import 'package:flutter_stockapp/features/watchlist/watchlist_controller.dart';

void main() {
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

  group('WatchlistController', () {
    test('可以添加自选股票', () {
      final controller = WatchlistController();

      final added = controller.add(apple);

      expect(added, isTrue);
      expect(controller.length, 1);
      expect(controller.stocks, contains(apple));
      expect(controller.containsCode('AAPL'), isTrue);
    });

    test('相同代码不能重复添加且忽略大小写和空格', () {
      final controller = WatchlistController(initialStocks: const [apple]);

      final added = controller.add(
        const SelectedStock(
          code: ' aapl ',
          name: 'Apple Inc.',
          market: QuantMarket.unitedStates,
        ),
      );

      expect(added, isFalse);
      expect(controller.length, 1);
    });

    test('可以根据股票删除自选', () {
      final controller = WatchlistController(
        initialStocks: const [apple, tesla],
      );

      final removed = controller.remove(apple);

      expect(removed, isTrue);
      expect(controller.length, 1);
      expect(controller.contains(apple), isFalse);
      expect(controller.contains(tesla), isTrue);
    });

    test('删除不存在的股票不会改变列表', () {
      final controller = WatchlistController(initialStocks: const [apple]);
      var notificationCount = 0;
      controller.addListener(() {
        notificationCount++;
      });

      final removed = controller.remove(tesla);

      expect(removed, isFalse);
      expect(controller.length, 1);
      expect(notificationCount, 0);
    });

    test('初始化和整体替换时自动去重并忽略无效股票', () {
      final controller = WatchlistController(
        initialStocks: const [
          apple,
          SelectedStock(
            code: 'aapl',
            name: 'Duplicate Apple',
            market: QuantMarket.unitedStates,
          ),
          SelectedStock(code: '', name: 'Invalid'),
        ],
      );

      expect(controller.length, 1);

      controller.replaceAll(const [
        tesla,
        SelectedStock(
          code: ' tsla ',
          name: 'Duplicate Tesla',
          market: QuantMarket.unitedStates,
        ),
        SelectedStock(code: '600519', name: '贵州茅台'),
      ]);

      expect(controller.length, 2);
      expect(controller.contains(tesla), isTrue);
      expect(controller.containsCode('600519'), isTrue);
    });

    test('清空股票池后通知监听者', () {
      final controller = WatchlistController(initialStocks: const [apple]);
      var notificationCount = 0;
      controller.addListener(() {
        notificationCount++;
      });

      controller.clear();

      expect(controller.isEmpty, isTrue);
      expect(notificationCount, 1);
    });
  });
}
