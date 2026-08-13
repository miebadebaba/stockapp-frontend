import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/navigation/root_shell.dart';
import 'package:flutter_stockapp/features/paper_trading/models/paper_portfolio.dart';
import 'package:flutter_stockapp/features/paper_trading/paper_trading_page.dart';
import 'package:flutter_stockapp/features/paper_trading/services/paper_trading_api.dart';

void main() {
  tearDown(() {
    PaperTradingPage.debugApiOverride = null;
  });

  testWidgets('Simulation opens the paper trading page through RootShell', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(820, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: RootShell(
          themeMode: ThemeMode.light,
          onThemeModeChanged: (_) {},
          paperTradingApi: FakePaperTradingApi(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(find.text('Simulation'), findsOneWidget);

    await tester.tap(find.text('Simulation'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(PaperTradingPage), findsOneWidget);
    expect(find.text('模拟交易'), findsOneWidget);
    expect(find.text('Tencent Holdings'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows initial loading state', (tester) async {
    final completer = Completer<PaperPortfolio>();
    await pumpPage(tester, api: FakePaperTradingApi(loadCompleter: completer));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(samplePortfolio);
    await tester.pump();
    await tester.pump();
  });

  testWidgets('renders backend portfolio data', (tester) async {
    await pumpPage(tester);

    expect(find.text('总资产'), findsOneWidget);
    expect(find.text('202000.00'), findsOneWidget);
    expect(find.text('Tencent Holdings'), findsOneWidget);
    expect(find.text('00700.HK / HKD'), findsOneWidget);
    expect(find.text('400.000'), findsOneWidget);
    expect(find.text('腾讯控股'), findsNothing);
    expect(find.text('199885.01'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports empty portfolio state', (tester) async {
    await pumpPage(tester, api: FakePaperTradingApi(portfolio: emptyPortfolio));

    expect(find.text('暂无持仓'), findsOneWidget);
    expect(find.text('Tencent Holdings'), findsNothing);
  });

  testWidgets('shows backend error and retries loading', (tester) async {
    final api = FakePaperTradingApi(
      loadErrors: [const PaperTradingApiException('无法连接后端，请确认本地服务已启动。')],
    );
    await pumpPage(tester, api: api);

    expect(find.text('无法连接后端，请确认本地服务已启动。'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Tencent Holdings'), findsOneWidget);
    expect(api.loadPortfolioCalls, 2);
  });

  testWidgets('validates buy quantity locally', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('买入'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('提交'));
    await tester.pump();

    expect(find.text('请输入正整数数量。'), findsOneWidget);
  });

  testWidgets('successful buy submits request and refreshes portfolio', (
    tester,
  ) async {
    final api = FakePaperTradingApi();
    await pumpPage(tester, api: api);

    await tester.tap(find.text('买入'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '00700.HK');
    await tester.enterText(find.byType(TextField).at(1), '100');
    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();

    expect(api.submittedOrders, [
      const SubmittedOrder(symbol: '00700.HK', side: 'buy', quantity: 100),
    ]);
    expect(api.loadPortfolioCalls, 2);
    expect(find.textContaining('成交价 380.000'), findsOneWidget);
  });

  testWidgets('insufficient cash error is displayed', (tester) async {
    final api = FakePaperTradingApi(
      submitError: const PaperTradingApiException('可用资金不足，无法买入。'),
    );
    await pumpPage(tester, api: api);

    await tester.tap(find.text('买入'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), '9999');
    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();

    expect(find.text('可用资金不足，无法买入。'), findsOneWidget);
    expect(api.loadPortfolioCalls, 1);
  });

  testWidgets('successful sell submits request and refreshes portfolio', (
    tester,
  ) async {
    final api = FakePaperTradingApi();
    await pumpPage(tester, api: api);

    await tester.tap(find.text('卖出'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), '20');
    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();

    expect(api.submittedOrders, [
      const SubmittedOrder(symbol: '00700.HK', side: 'sell', quantity: 20),
    ]);
    expect(api.loadPortfolioCalls, 2);
  });

  testWidgets('insufficient holdings error is displayed', (tester) async {
    final api = FakePaperTradingApi(
      submitError: const PaperTradingApiException('持仓数量不足，无法卖出。'),
    );
    await pumpPage(tester, api: api);

    await tester.tap(find.text('卖出'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), '9999');
    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();

    expect(find.text('持仓数量不足，无法卖出。'), findsOneWidget);
  });

  testWidgets('order history renders newest orders', (tester) async {
    final api = FakePaperTradingApi(
      orders: [
        sampleOrder.copyWith(id: 2, side: 'sell'),
        sampleOrder.copyWith(id: 1, side: 'buy'),
      ],
    );
    await pumpPage(tester, api: api);

    await tester.tap(find.text('查询'));
    await tester.pumpAndSettle();

    expect(find.text('委托查询'), findsOneWidget);
    expect(find.text('00700.HK · 卖出'), findsOneWidget);
    expect(find.text('00700.HK · 买入'), findsOneWidget);
    expect(find.text('成交价：--'), findsNWidgets(2));
    expect(api.loadOrdersCalls, 1);
  });

  testWidgets('cancel action explains immediate-fill market orders', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.text('撤单'));
    await tester.pump();

    expect(find.text('当前市价单立即成交，暂无可撤订单。'), findsOneWidget);
  });
  testWidgets('reset account requires acknowledgement before calling API', (
    tester,
  ) async {
    final api = FakePaperTradingApi(resetPortfolio: emptyPortfolio);
    await pumpPage(tester, api: api);

    await tester.tap(find.byTooltip('模拟账户设置'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('重置模拟账户'));
    await tester.pumpAndSettle();

    expect(find.text('确认重置模拟账户？'), findsOneWidget);
    final resetButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '确认重置'),
    );
    expect(resetButton.onPressed, isNull);
    expect(api.resetCalls, 0);

    await tester.tap(find.text('我了解此操作无法撤销'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认重置'));
    await tester.pumpAndSettle();

    expect(api.resetCalls, 1);
    expect(find.text('模拟账户已重置。'), findsOneWidget);
    expect(find.text('暂无持仓'), findsOneWidget);
  });
}

Future<void> pumpPage(
  WidgetTester tester, {
  FakePaperTradingApi? api,
}) async {
  tester.view
    ..physicalSize = const Size(390, 760)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: PaperTradingPage(api: api ?? FakePaperTradingApi()),
    ),
  );
  await tester.pump();
  await tester.pump();
}

const sampleAccount = PaperAccount(
  id: 1,
  accountKey: 'demo',
  currency: 'HKD',
  initialCash: 200000,
  availableCash: 162000,
);

const sampleSummary = PaperPortfolioSummary(
  initialCash: 200000,
  totalAssets: 202000,
  totalProfitLoss: 2000,
  totalProfitLossPercent: 1,
  totalMarketValue: 40000,
  availableCash: 162000,
  positionRatio: 19.8,
);

const sampleHolding = HoldingPosition(
  symbol: '00700.HK',
  name: 'Tencent Holdings',
  market: 'HKD',
  currency: 'HKD',
  marketValue: 40000,
  profitLoss: 2000,
  profitLossPercent: 5.26,
  quantity: 100,
  availableQuantity: 100,
  averageCost: 380,
  currentPrice: 400,
);

const samplePortfolio = PaperPortfolio(
  account: sampleAccount,
  summary: sampleSummary,
  holdings: [sampleHolding],
);

const emptyPortfolio = PaperPortfolio(
  account: sampleAccount,
  summary: PaperPortfolioSummary(
    initialCash: 200000,
    totalAssets: 200000,
    totalProfitLoss: 0,
    totalProfitLossPercent: 0,
    totalMarketValue: 0,
    availableCash: 200000,
    positionRatio: 0,
  ),
  holdings: [],
);

final sampleOrder = PaperOrder(
  id: 1,
  symbol: '00700.HK',
  side: 'buy',
  orderType: 'market',
  quantity: 100,
  status: 'filled',
  submittedAt: DateTime.parse('2026-08-03T09:30:00Z'),
  filledAt: DateTime.parse('2026-08-03T09:30:01Z'),
);

final sampleExecution = PaperExecution(
  id: 1,
  orderId: 1,
  symbol: '00700.HK',
  side: 'buy',
  quantity: 100,
  price: 380,
  executedAt: DateTime.parse('2026-08-03T09:30:01Z'),
);

class SubmittedOrder {
  const SubmittedOrder({
    required this.symbol,
    required this.side,
    required this.quantity,
  });

  final String symbol;
  final String side;
  final int quantity;

  @override
  bool operator ==(Object other) {
    return other is SubmittedOrder &&
        other.symbol == symbol &&
        other.side == side &&
        other.quantity == quantity;
  }

  @override
  int get hashCode => Object.hash(symbol, side, quantity);
}

class FakePaperTradingApi implements PaperTradingApi {
  FakePaperTradingApi({
    this.portfolio = samplePortfolio,
    this.orders = const [],
    this.submitError,
    this.resetPortfolio,
    this.resetError,
    this.loadCompleter,
    List<PaperTradingApiException>? loadErrors,
  }) : loadErrors = loadErrors ?? [];

  final PaperPortfolio portfolio;
  final List<PaperOrder> orders;
  final PaperTradingApiException? submitError;
  final PaperPortfolio? resetPortfolio;
  final PaperTradingApiException? resetError;
  final Completer<PaperPortfolio>? loadCompleter;
  final List<PaperTradingApiException> loadErrors;
  final submittedOrders = <SubmittedOrder>[];
  int loadPortfolioCalls = 0;
  int loadOrdersCalls = 0;
  int resetCalls = 0;

  @override
  Future<PaperPortfolio> loadPortfolio() async {
    loadPortfolioCalls += 1;
    if (loadErrors.isNotEmpty) {
      throw loadErrors.removeAt(0);
    }
    if (loadCompleter != null) {
      return loadCompleter!.future;
    }
    return portfolio;
  }

  @override
  Future<List<HoldingPosition>> loadPositions() async {
    return portfolio.holdings;
  }

  @override
  Future<List<PaperOrder>> loadOrders({
    String? side,
    String? status,
    int limit = 50,
  }) async {
    loadOrdersCalls += 1;
    return orders;
  }

  @override
  Future<PaperOrderSubmission> submitOrder({
    required String symbol,
    required String side,
    required int quantity,
  }) async {
    if (submitError != null) {
      throw submitError!;
    }
    submittedOrders.add(
      SubmittedOrder(symbol: symbol, side: side, quantity: quantity),
    );
    final execution = PaperExecution(
      id: sampleExecution.id,
      orderId: sampleExecution.orderId,
      symbol: symbol,
      side: side,
      quantity: quantity,
      price: sampleExecution.price,
      executedAt: sampleExecution.executedAt,
    );
    return PaperOrderSubmission(
      order: sampleOrder.copyWith(id: 10, side: side, executionPrice: 380),
      execution: execution,
      summary: sampleSummary,
    );
  }

  @override
  Future<PaperPortfolio> resetAccount() async {
    resetCalls += 1;
    if (resetError != null) {
      throw resetError!;
    }
    return resetPortfolio ?? portfolio;
  }
}

extension on PaperOrder {
  PaperOrder copyWith({
    int? id,
    String? side,
    double? executionPrice,
  }) {
    return PaperOrder(
      id: id ?? this.id,
      symbol: symbol,
      side: side ?? this.side,
      orderType: orderType,
      quantity: quantity,
      status: status,
      submittedAt: submittedAt,
      filledAt: filledAt,
      rejectionReason: rejectionReason,
      executionPrice: executionPrice ?? this.executionPrice,
    );
  }
}
