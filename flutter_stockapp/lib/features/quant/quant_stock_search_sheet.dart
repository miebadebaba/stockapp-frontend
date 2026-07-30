import 'package:flutter/material.dart';

import 'quant_stock_catalog.dart';
import 'selected_stock.dart';

class QuantStockSearchSheet extends StatefulWidget {
  const QuantStockSearchSheet({super.key});

  @override
  State<QuantStockSearchSheet> createState() => _QuantStockSearchSheetState();
}

class _QuantStockSearchSheetState extends State<QuantStockSearchSheet> {
  String _query = '';
  String get _normalizedQuery => _query.trim();

  bool get _canAnalyzeCustomCode {
    return RegExp(r'^\d{6}$').hasMatch(_normalizedQuery) &&
        !quantStockCatalog.any((stock) => stock.code == _normalizedQuery);
  }

  SelectedStock get _customStock {
    return SelectedStock(code: _normalizedQuery, name: 'A股代码');
  }

  List<SelectedStock> get _displayedStocks {
    return [if (_canAnalyzeCustomCode) _customStock, ..._filteredStocks];
  }

  List<SelectedStock> get _filteredStocks {
    final keyword = _query.trim().toLowerCase();

    if (keyword.isEmpty) {
      return quantStockCatalog;
    }

    return quantStockCatalog.where((stock) {
      return stock.code.contains(keyword) ||
          stock.name.toLowerCase().contains(keyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '选择分析股票',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  tooltip: '关闭',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: '输入股票代码或名称',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _query = value);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _displayedStocks.isEmpty
                  ? const Center(child: Text('未找到匹配的 A 股'))
                  : ListView.separated(
                      itemCount: _displayedStocks.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final stock = _displayedStocks[index];

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(stock.name),
                          subtitle: Text(stock.code),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () =>
                              Navigator.of(context).pop<SelectedStock>(stock),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
