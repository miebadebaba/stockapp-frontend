import 'dart:convert';
import 'dart:io';

import '../quant/selected_stock.dart';

class WatchlistStorage {
  WatchlistStorage({File? storageFile})
    : _storageFile = storageFile ?? _defaultStorageFile();

  static const _fileName = 'flutter_stockapp_watchlist.json';

  final File _storageFile;

  Future<List<SelectedStock>> load() async {
    try {
      if (!await _storageFile.exists()) {
        return const [];
      }

      final raw = await _storageFile.readAsString();

      if (raw.trim().isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return const [];
      }

      return decoded
          .map(SelectedStock.fromJson)
          .whereType<SelectedStock>()
          .toList(growable: false);
    } on FileSystemException {
      return const [];
    } on FormatException {
      return const [];
    }
  }

  Future<void> save(Iterable<SelectedStock> stocks) async {
    final data = stocks.map((stock) => stock.toJson()).toList(growable: false);
    const encoder = JsonEncoder.withIndent('  ');

    await _storageFile.parent.create(recursive: true);
    await _storageFile.writeAsString(encoder.convert(data), flush: true);
  }

  static File _defaultStorageFile() {
    return File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}$_fileName',
    );
  }
}
