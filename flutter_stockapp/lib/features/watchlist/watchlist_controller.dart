import 'package:flutter/foundation.dart';

import '../quant/selected_stock.dart';
import 'watchlist_storage.dart';

class WatchlistController extends ChangeNotifier {
  WatchlistController({
    WatchlistStorage? storage,
    Iterable<SelectedStock> initialStocks = const [],
  }) : _storage = storage ?? WatchlistStorage(),
       _stocks = List.unmodifiable(_removeDuplicates(initialStocks));

  final WatchlistStorage _storage;

  List<SelectedStock> _stocks;
  bool _isLoaded = false;

  List<SelectedStock> get stocks => _stocks;

  bool get isEmpty => _stocks.isEmpty;

  bool get isNotEmpty => _stocks.isNotEmpty;

  int get length => _stocks.length;

  bool get isLoaded => _isLoaded;

  bool contains(SelectedStock stock) {
    return containsCode(stock.code);
  }

  bool containsCode(String code) {
    final normalizedCode = _normalizeCode(code);

    return _stocks.any((stock) => _normalizeCode(stock.code) == normalizedCode);
  }

  // 仅修改内存中的股票列表，不保存到本地。
  // 适合测试和初始化数据处理。
  bool add(SelectedStock stock) {
    final code = stock.code.trim();
    final name = stock.name.trim();

    if (code.isEmpty || name.isEmpty || containsCode(code)) {
      return false;
    }

    final normalizedStock = SelectedStock(
      code: code,
      name: name,
      market: stock.market,
    );

    _stocks = List.unmodifiable([..._stocks, normalizedStock]);
    notifyListeners();
    return true;
  }

  // 添加并保存到本地。
  Future<bool> addAndSave(SelectedStock stock) async {
    final code = stock.code.trim();
    final name = stock.name.trim();

    if (code.isEmpty || name.isEmpty || containsCode(code)) {
      return false;
    }

    final normalizedStock = SelectedStock(
      code: code,
      name: name,
      market: stock.market,
    );
    final updatedStocks = [..._stocks, normalizedStock];

    await _storage.save(updatedStocks);

    _stocks = List.unmodifiable(updatedStocks);
    notifyListeners();
    return true;
  }

  // 仅修改内存中的股票列表，不保存到本地。
  bool remove(SelectedStock stock) {
    return removeByCode(stock.code);
  }

  // 仅修改内存中的股票列表，不保存到本地。
  bool removeByCode(String code) {
    final normalizedCode = _normalizeCode(code);
    final updatedStocks = _stocks
        .where((stock) => _normalizeCode(stock.code) != normalizedCode)
        .toList();

    if (updatedStocks.length == _stocks.length) {
      return false;
    }

    _stocks = List.unmodifiable(updatedStocks);
    notifyListeners();
    return true;
  }

  // 删除并保存到本地。
  Future<bool> removeAndSave(SelectedStock stock) {
    return removeByCodeAndSave(stock.code);
  }

  // 根据代码删除并保存到本地。
  Future<bool> removeByCodeAndSave(String code) async {
    final normalizedCode = _normalizeCode(code);
    final updatedStocks = _stocks
        .where((stock) => _normalizeCode(stock.code) != normalizedCode)
        .toList();

    if (updatedStocks.length == _stocks.length) {
      return false;
    }

    await _storage.save(updatedStocks);

    _stocks = List.unmodifiable(updatedStocks);
    notifyListeners();
    return true;
  }

  // 仅修改内存中的股票列表，不保存到本地。
  void replaceAll(Iterable<SelectedStock> stocks) {
    final updatedStocks = List<SelectedStock>.unmodifiable(
      _removeDuplicates(stocks),
    );

    if (_hasSameStocks(_stocks, updatedStocks)) {
      return;
    }

    _stocks = updatedStocks;
    notifyListeners();
  }

  // 替换并保存到本地。
  Future<void> replaceAllAndSave(Iterable<SelectedStock> stocks) async {
    final updatedStocks = List<SelectedStock>.unmodifiable(
      _removeDuplicates(stocks),
    );

    await _storage.save(updatedStocks);

    if (_hasSameStocks(_stocks, updatedStocks)) {
      return;
    }

    _stocks = updatedStocks;
    notifyListeners();
  }

  // 仅清空内存中的股票列表，不保存到本地。
  void clear() {
    if (_stocks.isEmpty) {
      return;
    }

    _stocks = const [];
    notifyListeners();
  }

  // 清空并保存到本地。
  Future<void> clearAndSave() async {
    if (_stocks.isEmpty) {
      await _storage.save(const []);
      return;
    }

    await _storage.save(const []);

    _stocks = const [];
    notifyListeners();
  }

  // App 启动时从本地恢复自选股票。
  Future<void> load() async {
    final storedStocks = await _storage.load();
    final restoredStocks = List<SelectedStock>.unmodifiable(
      _removeDuplicates(storedStocks),
    );

    _stocks = restoredStocks;
    _isLoaded = true;
    notifyListeners();
  }

  // 手动保存当前内存中的股票列表。
  Future<void> save() {
    return _storage.save(_stocks);
  }

  static List<SelectedStock> _removeDuplicates(Iterable<SelectedStock> stocks) {
    final uniqueStocks = <SelectedStock>[];
    final knownCodes = <String>{};

    for (final stock in stocks) {
      final code = stock.code.trim();
      final name = stock.name.trim();
      final normalizedCode = _normalizeCode(code);

      if (code.isEmpty || name.isEmpty || knownCodes.contains(normalizedCode)) {
        continue;
      }

      knownCodes.add(normalizedCode);
      uniqueStocks.add(
        SelectedStock(code: code, name: name, market: stock.market),
      );
    }

    return uniqueStocks;
  }

  static bool _hasSameStocks(
    List<SelectedStock> first,
    List<SelectedStock> second,
  ) {
    if (first.length != second.length) {
      return false;
    }

    for (var index = 0; index < first.length; index++) {
      final left = first[index];
      final right = second[index];

      if (_normalizeCode(left.code) != _normalizeCode(right.code) ||
          left.name != right.name ||
          left.market != right.market) {
        return false;
      }
    }

    return true;
  }

  static String _normalizeCode(String code) {
    return code.trim().toUpperCase();
  }
}
