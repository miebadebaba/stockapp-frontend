import 'package:flutter/material.dart';

import 'quant_pool_controller.dart';
import 'quant_stock_catalog.dart';
import 'selected_stock.dart';

class QuantStockSearchSheet extends StatefulWidget {
  const QuantStockSearchSheet({
    this.quantPoolController,
    this.onQuantPoolChanged,
    super.key,
  });

  final QuantPoolController? quantPoolController;
  final Future<void> Function()? onQuantPoolChanged;

  @override
  State<QuantStockSearchSheet> createState() => _QuantStockSearchSheetState();
}

class _QuantStockSearchSheetState extends State<QuantStockSearchSheet> {
  QuantMarket _selectedMarket = QuantMarket.aShare;
  String _query = '';
  String? _updatingCode;
  bool _isBatchMode = false;
  bool _isBatchUpdating = false;
  final Set<String> _selectedCodes = <String>{};

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

    if (code == null ||
        quantStockCatalog.any(
          (stock) => _normalizeCode(stock.code) == _normalizeCode(code),
        ) ||
        (widget.quantPoolController?.containsCode(code) ?? false)) {
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
    final stocks = <SelectedStock>[...quantStockCatalog];

    if (_isBatchMode) {
      final knownCodes = stocks
          .map((stock) => _normalizeCode(stock.code))
          .toSet();

      for (final stock
          in widget.quantPoolController?.stocks ?? const <SelectedStock>[]) {
        if (knownCodes.add(_normalizeCode(stock.code))) {
          stocks.add(stock);
        }
      }
    }

    return stocks.where((stock) {
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

  bool _isInQuantPool(SelectedStock stock) {
    return widget.quantPoolController?.contains(stock) ?? false;
  }

  String _normalizeCode(String code) {
    return code.trim().toUpperCase();
  }

  bool _isSelected(SelectedStock stock) {
    return _selectedCodes.contains(_normalizeCode(stock.code));
  }

  bool get _isAllDisplayedSelected {
    final stocks = _displayedStocks;

    if (stocks.isEmpty) {
      return false;
    }

    return stocks.every(_isSelected);
  }

  void _toggleSelected(SelectedStock stock) {
    final code = _normalizeCode(stock.code);

    setState(() {
      if (_selectedCodes.contains(code)) {
        _selectedCodes.remove(code);
      } else {
        _selectedCodes.add(code);
      }
    });
  }

  void _toggleSelectAll() {
    final displayedStocks = _displayedStocks;
    final displayedCodes = displayedStocks
        .map((stock) => _normalizeCode(stock.code))
        .toSet();

    setState(() {
      if (_isAllDisplayedSelected) {
        _selectedCodes.removeAll(displayedCodes);
      } else {
        _selectedCodes.addAll(displayedCodes);
      }
    });
  }

  void _enterBatchMode() {
    setState(() {
      _isBatchMode = true;
      _selectedCodes.clear();
    });
  }

  void _exitBatchMode() {
    setState(() {
      _isBatchMode = false;
      _selectedCodes.clear();
    });
  }

  Future<void> _toggleQuantPool(SelectedStock stock) async {
    final controller = widget.quantPoolController;

    if (controller == null || _updatingCode != null) {
      return;
    }

    setState(() {
      _updatingCode = stock.code;
    });

    try {
      if (controller.contains(stock)) {
        await controller.removeAndSave(stock);
      } else {
        await controller.addAndSave(stock);
      }

      if (!mounted) {
        return;
      }

      setState(() {});
      await widget.onQuantPoolChanged?.call();
    } finally {
      if (mounted) {
        setState(() {
          _updatingCode = null;
        });
      }
    }
  }

  Future<void> _applyBatchUpdate({required bool add}) async {
    final controller = widget.quantPoolController;

    if (controller == null || _isBatchUpdating || _selectedCodes.isEmpty) {
      return;
    }

    final selectedStocks = _displayedStocks
        .where(_isSelected)
        .toList(growable: false);

    if (selectedStocks.isEmpty) {
      return;
    }

    setState(() {
      _isBatchUpdating = true;
    });

    try {
      final updatedStocks = [...controller.stocks];

      if (add) {
        for (final stock in selectedStocks) {
          if (!controller.contains(stock)) {
            updatedStocks.add(stock);
          }
        }
      } else {
        final selectedCodes = selectedStocks
            .map((stock) => _normalizeCode(stock.code))
            .toSet();

        updatedStocks.removeWhere(
          (stock) => selectedCodes.contains(_normalizeCode(stock.code)),
        );
      }

      await controller.replaceAllAndSave(updatedStocks);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedCodes.clear();
      });

      await widget.onQuantPoolChanged?.call();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(add ? '已加入分析池' : '已移出分析池')));
    } finally {
      if (mounted) {
        setState(() {
          _isBatchUpdating = false;
        });
      }
    }
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
                Expanded(
                  child: Text(
                    _isBatchMode ? '批量管理分析池' : '选择分析股票',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (widget.quantPoolController != null)
                  _isBatchMode
                      ? TextButton(
                          onPressed: _isBatchUpdating ? null : _exitBatchMode,
                          child: const Text('完成'),
                        )
                      : OutlinedButton.icon(
                          onPressed: _enterBatchMode,
                          icon: const Icon(
                            Icons.playlist_add_check_rounded,
                            size: 18,
                          ),
                          label: const Text('批量管理'),
                        ),
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
                onSelectionChanged: _isBatchUpdating
                    ? null
                    : (selection) {
                        setState(() {
                          _selectedMarket = selection.first;
                          _query = '';
                          _selectedCodes.clear();
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
                setState(() {
                  _query = value;
                  _selectedCodes.clear();
                });
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
                        final isInQuantPool = _isInQuantPool(stock);
                        final isUpdating = _updatingCode == stock.code;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: _isBatchMode
                              ? Checkbox(
                                  value: _isSelected(stock),
                                  onChanged: _isBatchUpdating
                                      ? null
                                      : (_) => _toggleSelected(stock),
                                )
                              : null,
                          title: Text(stock.name),
                          subtitle: Text(
                            '${stock.code} · ${stock.market.label}'
                            '${_isBatchMode && isInQuantPool ? ' · 已在池中' : ''}',
                          ),
                          trailing: _isBatchMode
                              ? null
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.quantPoolController != null)
                                      IconButton(
                                        tooltip: isInQuantPool
                                            ? '移出分析池'
                                            : '加入分析池',
                                        onPressed: isUpdating
                                            ? null
                                            : () => _toggleQuantPool(stock),
                                        icon: isUpdating
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Icon(
                                                isInQuantPool
                                                    ? Icons.check_circle_rounded
                                                    : Icons
                                                          .add_circle_outline_rounded,
                                              ),
                                      ),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                          onTap: _isBatchMode
                              ? () => _toggleSelected(stock)
                              : () {
                                  Navigator.of(
                                    context,
                                  ).pop<SelectedStock>(stock);
                                },
                        );
                      },
                    ),
            ),
            if (_isBatchMode) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isBatchUpdating || _displayedStocks.isEmpty
                          ? null
                          : _toggleSelectAll,
                      icon: const Icon(Icons.select_all_rounded),
                      label: Text(_isAllDisplayedSelected ? '取消全选' : '全选当前市场'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isBatchUpdating || _selectedCodes.isEmpty
                          ? null
                          : () => _applyBatchUpdate(add: true),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('加入分析池'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isBatchUpdating || _selectedCodes.isEmpty
                          ? null
                          : () => _applyBatchUpdate(add: false),
                      icon: const Icon(Icons.remove_rounded),
                      label: const Text('移出分析池'),
                    ),
                  ),
                ],
              ),
            ],
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
