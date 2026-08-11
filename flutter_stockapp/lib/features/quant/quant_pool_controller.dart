import 'package:flutter/foundation.dart';

import 'quant_pool_storage.dart';
import 'selected_stock.dart';

class QuantPoolController extends ChangeNotifier {
  QuantPoolController({
    QuantPoolStorage? storage,
    Iterable<SelectedStock> initialStocks = const [],
  }) : _storage = storage ?? QuantPoolStorage(),
       _stocks = List.unmodifiable(_removeDuplicates(initialStocks));

  final QuantPoolStorage _storage;

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

  bool add(SelectedStock stock) {
    final code = stock.code.trim();
    final name = stock.name.trim();

    if (code.isEmpty || name.isEmpty || containsCode(code)) {
      return false;
    }

    _stocks = List.unmodifiable([
      ..._stocks,
      SelectedStock(code: code, name: name, market: stock.market),
    ]);
    notifyListeners();
    return true;
  }

  Future<bool> addAndSave(SelectedStock stock) async {
    final code = stock.code.trim();
    final name = stock.name.trim();

    if (code.isEmpty || name.isEmpty || containsCode(code)) {
      return false;
    }

    final updatedStocks = [
      ..._stocks,
      SelectedStock(code: code, name: name, market: stock.market),
    ];

    await _storage.save(updatedStocks);
    _stocks = List.unmodifiable(updatedStocks);
    notifyListeners();
    return true;
  }

  bool remove(SelectedStock stock) {
    return removeByCode(stock.code);
  }

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

  Future<bool> removeAndSave(SelectedStock stock) {
    return removeByCodeAndSave(stock.code);
  }

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

  void clear() {
    if (_stocks.isEmpty) {
      return;
    }

    _stocks = const [];
    notifyListeners();
  }

  Future<void> clearAndSave() async {
    await _storage.save(const []);

    if (_stocks.isEmpty) {
      return;
    }

    _stocks = const [];
    notifyListeners();
  }

  /// 第一次使用时加载默认分析池。
  ///
  /// 如果本地已经保存过数据，则优先使用本地数据。
  /// 即使本地保存的是空列表，也不会恢复默认股票。
  Future<void> load({required Iterable<SelectedStock> defaultStocks}) async {
    final storedStocks = await _storage.load();
    final stocksToUse = storedStocks ?? defaultStocks;
    final restoredStocks = List<SelectedStock>.unmodifiable(
      _removeDuplicates(stocksToUse),
    );

    if (storedStocks == null) {
      await _storage.save(restoredStocks);
    }

    _stocks = restoredStocks;
    _isLoaded = true;
    notifyListeners();
  }

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
