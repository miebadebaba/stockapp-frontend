import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import 'models/paper_portfolio.dart';
import 'services/paper_trading_api.dart';
import 'widgets/holdings_list.dart';
import 'widgets/portfolio_summary.dart';

class PaperTradingPage extends StatefulWidget {
  const PaperTradingPage({this.api, super.key});

  final PaperTradingApi? api;

  @visibleForTesting
  static PaperTradingApi? debugApiOverride;

  @override
  State<PaperTradingPage> createState() => _PaperTradingPageState();
}

class _PaperTradingPageState extends State<PaperTradingPage> {
  late final PaperTradingApi _api;
  late final bool _ownsApi;
  PaperPortfolio? _portfolio;
  List<PaperOrder> _orders = const [];
  String? _loadError;
  String? _ordersError;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isSubmitting = false;
  bool _isOrdersLoading = false;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    final injectedApi = widget.api ?? PaperTradingPage.debugApiOverride;
    _api = injectedApi ?? HttpPaperTradingApi();
    _ownsApi = injectedApi == null;
    _loadPortfolio();
  }

  @override
  void dispose() {
    final api = _api;
    if (_ownsApi && api is HttpPaperTradingApi) {
      api.close();
    }
    super.dispose();
  }

  Future<void> _loadPortfolio({bool keepExisting = false}) async {
    if (_isLoading || _isRefreshing) {
      return;
    }
    setState(() {
      if (_portfolio == null || !keepExisting) {
        _isLoading = true;
      } else {
        _isRefreshing = true;
      }
      _loadError = null;
    });

    try {
      final portfolio = await _api.loadPortfolio();
      if (!mounted) {
        return;
      }
      setState(() {
        _portfolio = portfolio;
        _isLoading = false;
        _isRefreshing = false;
      });
    } on PaperTradingApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        if (_portfolio == null) {
          _loadError = error.message;
        }
      });
      if (_portfolio != null) {
        _showSnack(error.message);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      const message = '加载模拟交易账户失败，请稍后重试。';
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        if (_portfolio == null) {
          _loadError = message;
        }
      });
      if (_portfolio != null) {
        _showSnack(message);
      }
    }
  }

  Future<void> _loadOrders() async {
    if (_isOrdersLoading) {
      return;
    }
    setState(() {
      _isOrdersLoading = true;
      _ordersError = null;
    });

    try {
      final orders = await _api.loadOrders(limit: 50);
      if (!mounted) {
        return;
      }
      setState(() {
        _orders = orders;
        _isOrdersLoading = false;
      });
    } on PaperTradingApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _ordersError = error.message;
        _isOrdersLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _ordersError = '加载委托记录失败，请稍后重试。';
        _isOrdersLoading = false;
      });
    }
  }

  Future<void> _showOrderDialog(String side) async {
    if (_isSubmitting) {
      return;
    }
    final defaultSymbol = side == 'sell' && (_portfolio?.holdings.isNotEmpty ?? false)
        ? _portfolio!.holdings.first.symbol
        : '00700.HK';
    final result = await showDialog<_OrderDraft>(
      context: context,
      builder: (context) => _OrderDialog(side: side, initialSymbol: defaultSymbol),
    );
    if (result == null || !mounted) {
      return;
    }
    await _submitOrder(result);
  }

  Future<void> _submitOrder(_OrderDraft draft) async {
    if (_isSubmitting) {
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final result = await _api.submitOrder(
        symbol: draft.symbol,
        side: draft.side,
        quantity: draft.quantity,
      );
      if (!mounted) {
        return;
      }
      _showSnack(
        '${PaperTradingFormatters.orderSide(draft.side)} ${result.execution.symbol} '
        '${result.execution.quantity} 股，成交价 ${PaperTradingFormatters.price(result.execution.price)}',
      );
      await _loadPortfolio(keepExisting: true);
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = false);
    } on PaperTradingApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = false);
      _showSnack(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = false);
      _showSnack('提交委托失败，请稍后重试。');
    }
  }

  Future<void> _showOrderHistory() async {
    await _loadOrders();
    if (!mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _OrderHistorySheet(
        orders: _orders,
        error: _ordersError,
        isLoading: _isOrdersLoading,
        onRetry: _loadOrders,
      ),
    );
  }

  Future<void> _confirmResetAccount() async {
    if (_isResetting || _isSubmitting) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _ResetAccountDialog(),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isResetting = true);
    try {
      final portfolio = await _api.resetAccount();
      if (!mounted) {
        return;
      }
      setState(() {
        _portfolio = portfolio;
        _orders = const [];
        _ordersError = null;
        _isResetting = false;
      });
      _showSnack('模拟账户已重置。');
    } on PaperTradingApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isResetting = false);
      _showSnack(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isResetting = false);
      _showSnack('重置失败，请稍后重试。');
    }
  }

  void _showCancelUnavailable() {
    _showSnack('当前市价单立即成交，暂无可撤订单。');
  }

  void _showSnack(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Scaffold(
      backgroundColor: palette.pageBackground,
      appBar: AppBar(
        backgroundColor: palette.pageBackground,
        foregroundColor: palette.primaryText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '模拟交易',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '市价单会立即按后端报价成交',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: palette.secondaryText, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '刷新',
            onPressed: _isLoading || _isRefreshing || _isResetting
                ? null
                : () => _loadPortfolio(keepExisting: true),
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: '模拟账户设置',
            enabled: !_isLoading && !_isResetting,
            onSelected: (value) {
              if (value == 'reset') {
                _confirmResetAccount();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'reset',
                child: Text('重置模拟账户'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(top: false, child: _buildBody(palette)),
    );
  }

  Widget _buildBody(AppThemePalette palette) {
    if (_isLoading && _portfolio == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null && _portfolio == null) {
      return _InitialLoadError(message: _loadError!, onRetry: _loadPortfolio);
    }

    final portfolio = _portfolio;
    if (portfolio == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: () => _loadPortfolio(keepExisting: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TradingActionBar(
                  disabled: _isSubmitting || _isResetting,
                  onBuy: () => _showOrderDialog('buy'),
                  onSell: () => _showOrderDialog('sell'),
                  onCancel: _showCancelUnavailable,
                  onQuery: _showOrderHistory,
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionTitle(title: '资产概览', palette: palette),
                const SizedBox(height: AppSpacing.md),
                PortfolioSummary(summary: portfolio.summary),
                const SizedBox(height: AppSpacing.xl),
                _SectionTitle(title: '持仓股票', palette: palette),
                const SizedBox(height: AppSpacing.md),
                HoldingsList(holdings: portfolio.holdings),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.palette});

  final String title;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(color: palette.primaryText, fontWeight: FontWeight.w800),
    );
  }
}

class _TradingActionBar extends StatelessWidget {
  const _TradingActionBar({
    required this.disabled,
    required this.onBuy,
    required this.onSell,
    required this.onCancel,
    required this.onQuery,
  });

  final bool disabled;
  final VoidCallback onBuy;
  final VoidCallback onSell;
  final VoidCallback onCancel;
  final VoidCallback onQuery;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final actions = [
      _TradingActionData(
        label: '买入',
        icon: Icons.add_shopping_cart_rounded,
        onTap: onBuy,
      ),
      _TradingActionData(
        label: '卖出',
        icon: Icons.sell_outlined,
        onTap: onSell,
      ),
      _TradingActionData(
        label: '撤单',
        icon: Icons.cancel_schedule_send_rounded,
        onTap: onCancel,
      ),
      const _TradingActionData(
        label: '持仓',
        icon: Icons.pie_chart_outline_rounded,
        selected: true,
      ),
      _TradingActionData(
        label: '查询',
        icon: Icons.manage_search_rounded,
        onTap: onQuery,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.groupBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        children: [
          for (final action in actions)
            Expanded(
              child: _TradingActionButton(
                action: action,
                palette: palette,
                onTap: action.selected || disabled ? null : action.onTap,
              ),
            ),
        ],
      ),
    );
  }
}

class _TradingActionData {
  const _TradingActionData({
    required this.label,
    required this.icon,
    this.onTap,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool selected;
}

class _TradingActionButton extends StatelessWidget {
  const _TradingActionButton({
    required this.action,
    required this.palette,
    required this.onTap,
  });

  final _TradingActionData action;
  final AppThemePalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;
    return Material(
      color: action.selected
          ? selectedColor.withValues(alpha: 0.12)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                action.icon,
                size: 21,
                color: action.selected ? selectedColor : palette.secondaryText,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: action.selected
                      ? selectedColor
                      : palette.secondaryText,
                  fontWeight: action.selected
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InitialLoadError extends StatelessWidget {
  const _InitialLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: palette.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderDraft {
  const _OrderDraft({
    required this.side,
    required this.symbol,
    required this.quantity,
  });

  final String side;
  final String symbol;
  final int quantity;
}

class _OrderDialog extends StatefulWidget {
  const _OrderDialog({required this.side, required this.initialSymbol});

  final String side;
  final String initialSymbol;

  @override
  State<_OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<_OrderDialog> {
  late final TextEditingController _symbolController;
  late final TextEditingController _quantityController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _symbolController = TextEditingController(text: widget.initialSymbol);
    _quantityController = TextEditingController();
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    final symbol = _symbolController.text.trim().toUpperCase();
    final quantity = int.tryParse(_quantityController.text.trim());
    if (symbol.isEmpty) {
      setState(() => _error = '请输入股票代码。');
      return;
    }
    if (quantity == null || quantity <= 0) {
      setState(() => _error = '请输入正整数数量。');
      return;
    }

    Navigator.of(context).pop(
      _OrderDraft(side: widget.side, symbol: symbol, quantity: quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.side == 'buy';
    return AlertDialog(
      title: Text(isBuy ? '买入股票' : '卖出股票'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _symbolController,
            decoration: const InputDecoration(
              labelText: '股票代码',
              hintText: '例如 00700.HK',
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: '数量'),
            keyboardType: TextInputType.number,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('提交')),
      ],
    );
  }
}

class _OrderHistorySheet extends StatelessWidget {
  const _OrderHistorySheet({
    required this.orders,
    required this.error,
    required this.isLoading,
    required this.onRetry,
  });

  final List<PaperOrder> orders;
  final String? error;
  final bool isLoading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '委托查询',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: palette.primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '刷新',
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(child: _buildContent(context, palette)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppThemePalette palette) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }
    if (orders.isEmpty) {
      return const Center(child: Text('暂无委托记录'));
    }
    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final order = orders[index];
        return DecoratedBox(
          decoration: BoxDecoration(
            color: palette.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: palette.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.symbol} · ${PaperTradingFormatters.orderSide(order.side)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '数量：${order.quantity} · 状态：${PaperTradingFormatters.orderStatus(order.status)}',
                ),
                Text(
                  '提交：${PaperTradingFormatters.dateTime(order.submittedAt)}',
                ),
                Text(
                  '成交：${order.filledAt == null ? '--' : PaperTradingFormatters.dateTime(order.filledAt!)}',
                ),
                Text(
                  '成交价：${order.executionPrice == null ? '--' : PaperTradingFormatters.price(order.executionPrice!)}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResetAccountDialog extends StatefulWidget {
  const _ResetAccountDialog();

  @override
  State<_ResetAccountDialog> createState() => _ResetAccountDialogState();
}

class _ResetAccountDialogState extends State<_ResetAccountDialog> {
  var _understood = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('确认重置模拟账户？'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '此操作将清空当前资金状态、持仓、订单、成交和盈亏记录，并恢复初始模拟资金。操作完成后无法撤销。',
          ),
          const SizedBox(height: AppSpacing.md),
          CheckboxListTile(
            value: _understood,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text('我了解此操作无法撤销'),
            onChanged: (value) => setState(() => _understood = value ?? false),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _understood ? () => Navigator.of(context).pop(true) : null,
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          child: const Text('确认重置'),
        ),
      ],
    );
  }
}
