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
              child: _filteredStocks.isEmpty
                  ? const Center(child: Text('未找到匹配的 A 股'))
                  : ListView.separated(
                      itemCount: _filteredStocks.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final stock = _filteredStocks[index];

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
