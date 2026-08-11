import 'dart:convert';
import 'dart:io';

import 'selected_stock.dart';

class QuantPoolStorage {
  QuantPoolStorage({File? storageFile})
    : _storageFile = storageFile ?? _defaultStorageFile();

  static const _fileName = 'flutter_stockapp_quant_pool_v2.json';

  final File _storageFile;

  /// 返回 null 表示第一次使用或文件无法读取。
  /// 返回空列表表示用户主动清空了分析池。
  Future<List<SelectedStock>?> load() async {
    try {
      if (!await _storageFile.exists()) {
        return null;
      }

      final raw = await _storageFile.readAsString();

      if (raw.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return null;
      }

      return decoded
          .map(SelectedStock.fromJson)
          .whereType<SelectedStock>()
          .toList(growable: false);
    } on FileSystemException {
      return null;
    } on FormatException {
      return null;
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
