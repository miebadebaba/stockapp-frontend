import 'package:flutter/material.dart';

import 'quant_stock_catalog.dart';
import 'selected_stock.dart';

class QuantStockSearchSheet extends StatefulWidget {
  const QuantStockSearchSheet({super.key});

  @override
  State<QuantStockSearchSheet> createState() => _QuantStockSearchSheetState();
}

class _QuantStockSearchSheetState extends State<QuantStockSearchSheet> {
  QuantMarket _selectedMarket = QuantMarket.aShare;
  String _query = '';

  String get _normalizedQuery => _query.trim().toUpperCase();

  String? get _customCode {
    final query = _normalizedQuery;

    if (query.isEmpty) {
      return null;
    }

    return switch (_selectedMarket) {
      QuantMarket.aShare => RegExp(r'^\d{6}$').hasMatch(query) ? query : null,
      QuantMarket.hongKong => _normalizeHongKongCode(query),
      QuantMarket.unitedStates =>
        RegExp(r'^[A-Z][A-Z0-9.-]{0,9}$').hasMatch(query) ? query : null,
    };
  }

  SelectedStock? get _customStock {
    final code = _customCode;

    if (code == null || quantStockCatalog.any((stock) => stock.code == code)) {
      return null;
    }

    return SelectedStock(
      code: code,
      name: '${_selectedMarket.label}代码',
      market: _selectedMarket,
    );
  }

  List<SelectedStock> get _filteredStocks {
    final keyword = _normalizedQuery.toLowerCase();

    return quantStockCatalog.where((stock) {
      if (stock.market != _selectedMarket) {
        return false;
      }

      if (keyword.isEmpty) {
        return true;
      }

      return stock.code.toLowerCase().contains(keyword) ||
          stock.name.toLowerCase().contains(keyword);
    }).toList();
  }

  List<SelectedStock> get _displayedStocks {
    return [?_customStock, ..._filteredStocks];
  }

  String get _searchHint {
    return switch (_selectedMarket) {
      QuantMarket.aShare => '输入6位股票代码或名称',
      QuantMarket.hongKong => '输入港股代码或名称',
      QuantMarket.unitedStates => '输入美股代码或名称',
    };
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<QuantMarket>(
                segments: QuantMarket.values
                    .map(
                      (market) => ButtonSegment<QuantMarket>(
                        value: market,
                        label: Text(market.label),
                      ),
                    )
                    .toList(),
                selected: {_selectedMarket},
                onSelectionChanged: (selection) {
                  setState(() {
                    _selectedMarket = selection.first;
                    _query = '';
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: ValueKey(_selectedMarket),
              autofocus: true,
              textInputAction: TextInputAction.search,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: _searchHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _query = value);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _displayedStocks.isEmpty
                  ? Center(child: Text('未找到匹配的${_selectedMarket.label}股票'))
                  : ListView.separated(
                      itemCount: _displayedStocks.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final stock = _displayedStocks[index];

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(stock.name),
                          subtitle: Text(
                            '${stock.code} · ${stock.market.label}',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.of(context).pop<SelectedStock>(stock);
                          },
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

String? _normalizeHongKongCode(String value) {
  final withoutSuffix = value.endsWith('.HK')
      ? value.substring(0, value.length - 3)
      : value;

  if (!RegExp(r'^\d{1,5}$').hasMatch(withoutSuffix)) {
    return null;
  }

  return '${withoutSuffix.padLeft(5, '0')}.HK';
}
