import 'package:flutter/material.dart';

import 'tutorial_module_detail_page.dart';

class TradingBasicsPage extends StatelessWidget {
  const TradingBasicsPage({super.key});

  static const topics = [
    TutorialTopicData(
      id: 'getting-started',
      sequence: '01',
      title: '如何开始交易：开户、入金与账户选择',
      content: [
        TutorialContentBlock.paragraph('普通投资者通常需要通过受监管的券商开立证券账户，才能提交股票买卖订单。'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('1', '选择券商'),
          TutorialFormulaRow('2', '提交身份和税务资料'),
          TutorialFormulaRow('3', '开立证券账户'),
          TutorialFormulaRow('4', '绑定银行账户'),
          TutorialFormulaRow('5', '转入资金'),
          TutorialFormulaRow('6', '获得相应市场的交易权限'),
        ]),
        TutorialContentBlock.heading('银行账户与证券账户'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('银行账户', '存款、转账、支付'),
          TutorialFormulaRow(
            '证券账户',
            '持有待投资资金和股票、ETF 等证券；提交订单、接收分红，并查看持仓、交易记录和盈亏。',
          ),
        ]),
        TutorialContentBlock.paragraph('入金是把资金从银行账户转入证券账户；出金是把资金从证券账户转回银行账户。'),
        TutorialContentBlock.heading('选择券商时关注什么'),
        TutorialContentBlock.paragraph(
          '先看正规监管：是否由金融监管机构授权、客户资金和证券如何保管。不要只因为开户奖励、高收益宣传或所谓内部机会而转入资金。',
        ),
        TutorialContentBlock.paragraph(
          '再看支持的市场和产品，例如 A 股、港股、美股、ETF、基金、债券、碎股，以及期权等复杂产品。',
        ),
        TutorialContentBlock.paragraph(
          '费用也很重要，可能包括交易佣金、平台费、交易所或监管费用、税费、换汇费用、行情数据费用、出入金费用和保证金融资利息。',
        ),
        TutorialContentBlock.note('“零佣金”只表示某一项佣金可能为零，不代表交易完全没有成本。'),
        TutorialContentBlock.paragraph(
          '还要考虑下单是否稳定、行情是否清楚、出入金是否方便、客服是否可靠、是否提供模拟交易，以及对账单和税务文件是否容易理解。',
        ),
        TutorialContentBlock.paragraph(
          '不同地区的开户资格、身份和税务资料、可交易市场、使用货币、交易规则、税费和投资者保护机制都可能不同。不要把某一家券商当前的按钮或步骤当作通用规则。',
        ),
        TutorialContentBlock.heading('账户类型'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('现金账户', '主要使用自己已经转入的资金进行交易。'),
          TutorialFormulaRow('保证金账户', '在一定条件下可以向券商借钱交易，会产生利息，也会放大盈利和亏损。'),
        ]),
        TutorialContentBlock.note('保证金不是券商免费赠送的资金，而是借款。'),
        TutorialContentBlock.note(
          '开户只是获得交易能力，不代表入金后必须立即买股票。保证金和杠杆的更深入风险会在后续模块说明。',
        ),
      ],
    ),
    TutorialTopicData(
      id: 'decisions-before-buying',
      sequence: '02',
      title: '买入前需要决定什么：股票、价格与数量',
      content: [
        TutorialContentBlock.formula([
          TutorialFormulaRow('买什么', '确认公司、证券和市场。'),
          TutorialFormulaRow('什么价格买', '选择愿意接受的价格和订单类型。'),
          TutorialFormulaRow('买多少', '结合可用资金、成本和风险集中度决定数量。'),
        ]),
        TutorialContentBlock.heading('买什么'),
        TutorialContentBlock.paragraph(
          '下单前确认公司名称、股票代码、上市市场和交易货币。公司名称可能相似，同一家公司也可能在不同市场上市，不能只看简称就下单。',
        ),
        TutorialContentBlock.heading('以什么价格买'),
        TutorialContentBlock.paragraph(
          '页面当前价通常是最近一笔成交价，不是系统保证的买入价格。实际成交价还取决于当前卖方报价、订单类型、市场波动、订单大小和股票流动性。',
        ),
        TutorialContentBlock.heading('买多少'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('总买入金额', '每股价格 × 买入股数'),
          TutorialFormulaRow('例子', '每股 ¥50，买入 100 股，股票金额约为 ¥5,000。'),
        ]),
        TutorialContentBlock.paragraph(
          '实际交易还可能产生佣金、税费和其他成本。下单前应确认可用资金、买入后剩余现金、是否过度集中在一只股票、是否无意中使用保证金融资、市场是否要求按一手或固定单位交易，以及券商是否支持碎股。',
        ),
        TutorialContentBlock.note(
          '股价只有 ¥5，不代表它一定比每股 ¥500 的股票更便宜。单股价格不能独立说明公司估值或风险。',
        ),
      ],
    ),
    TutorialTopicData(
      id: 'market-and-limit-orders',
      sequence: '03',
      title: '市价单与限价单',
      content: [
        TutorialContentBlock.paragraph('订单类型决定你更重视尽快成交，还是控制成交价格。'),
        TutorialContentBlock.heading('市价单'),
        TutorialContentBlock.paragraph(
          '市价单会按市场当前能够获得的价格尽快成交。它优先保证成交速度，但不保证最终成交价格；当前显示价格不是成交承诺。',
        ),
        TutorialContentBlock.example(
          '最近成交价显示 ¥100，但一笔市价买单可能分别成交在 ¥100.00、¥100.20 和 ¥100.50。',
        ),
        TutorialContentBlock.paragraph(
          '在交易活跃、买卖价差较小的股票中，市价单通常更接近预期价格。市场快速波动、股票交易冷清、价差较大或订单数量较大时，实际成交价可能明显偏离。',
        ),
        TutorialContentBlock.heading('限价单'),
        TutorialContentBlock.paragraph('限价单由用户设定自己可以接受的价格范围。'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('限价买单', '只愿意以设定价格或更低价格买入。'),
          TutorialFormulaRow('例子', '限价买入 ¥90，只有出现 ¥90 或更低的卖单时才可能成交。'),
          TutorialFormulaRow('限价卖单', '只愿意以设定价格或更高价格卖出。'),
          TutorialFormulaRow('例子', '限价卖出 ¥110，只有买方愿意支付 ¥110 或更高价格时才可能成交。'),
        ]),
        TutorialContentBlock.note('市价单：优先成交，但不保证价格。\n限价单：控制价格，但不保证成交。'),
        TutorialContentBlock.note('即使价格曾短暂到达限价，订单也不一定全部成交，因为可能有其他订单排在前面。'),
      ],
    ),
    TutorialTopicData(
      id: 'bid-ask-order-book',
      sequence: '04',
      title: '买一、卖一、盘口与买卖价差',
      content: [
        TutorialContentBlock.paragraph('买一是当前买方愿意支付的最高价格，也叫最佳买价。'),
        TutorialContentBlock.example('买一：¥99.90\n表示当前等待中的买方，最高愿意以 ¥99.90 买入。'),
        TutorialContentBlock.paragraph('卖一是当前卖方愿意接受的最低价格，也叫最佳卖价。'),
        TutorialContentBlock.example(
          '卖一：¥100.10\n表示当前等待中的卖方，最低愿意以 ¥100.10 卖出。',
        ),
        TutorialContentBlock.heading('买卖价差'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('买卖价差', '卖一 − 买一'),
          TutorialFormulaRow('例子', '¥100.10 − ¥99.90 = ¥0.20'),
        ]),
        TutorialContentBlock.paragraph(
          '交易活跃、流动性好的股票通常价差较小；交易冷清或波动剧烈时，价差可能较大。立即买入通常面对卖一价格，立即卖出通常面对买一价格。',
        ),
        TutorialContentBlock.note(
          '刚买入后，即使市场没有明显变化，账户也可能立刻显示轻微亏损，因为立即卖出的买一价格可能低于刚才买入的卖一价格。',
        ),
        TutorialContentBlock.heading('盘口'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('卖三', '¥100.30'),
          TutorialFormulaRow('卖二', '¥100.20'),
          TutorialFormulaRow('卖一', '¥100.10'),
          TutorialFormulaRow('买一', '¥99.90'),
          TutorialFormulaRow('买二', '¥99.80'),
          TutorialFormulaRow('买三', '¥99.70'),
        ]),
        TutorialContentBlock.paragraph(
          '盘口显示部分正在等待成交的买卖报价。它不能单独预测下一步涨跌，挂单可能随时被撤销，也不是未来成交的保证。',
        ),
      ],
    ),
    TutorialTopicData(
      id: 'orders-and-slippage',
      sequence: '05',
      title: '挂单、部分成交、撤单与滑点',
      content: [
        TutorialContentBlock.heading('挂单'),
        TutorialContentBlock.paragraph('订单提交后，如果暂时没有匹配的交易对手，订单会处于等待状态。'),
        TutorialContentBlock.example('以 ¥90 买入 100 股，当前最低卖价为 ¥100，这张订单不会立即成交。'),
        TutorialContentBlock.heading('部分成交'),
        TutorialContentBlock.paragraph('一张订单不一定一次性全部成交。'),
        TutorialContentBlock.example(
          '用户希望以 ¥100 买入 500 股，当前只有 200 股愿意以 ¥100 卖出。结果可能是已成交 200 股，未成交 300 股。',
        ),
        TutorialContentBlock.paragraph('剩余部分可能继续等待，也可能根据订单规则到期或取消。'),
        TutorialContentBlock.heading('撤单'),
        TutorialContentBlock.paragraph('尚未成交的部分通常可以申请撤销；已经成交的部分不能通过撤单恢复。'),
        TutorialContentBlock.note('撤单不等于撤销已经完成的交易。'),
        TutorialContentBlock.heading('滑点'),
        TutorialContentBlock.paragraph('滑点是实际成交价格与用户原本预期价格之间的差异。'),
        TutorialContentBlock.example(
          '看到价格为 ¥100，提交市价买单，最终平均成交价为 ¥100.40，差额 ¥0.40 可理解为滑点。',
        ),
        TutorialContentBlock.paragraph(
          '市场快速波动、股票成交不活跃、买卖价差较大、订单数量较大或重大新闻发布时，更容易出现滑点。',
        ),
        TutorialContentBlock.note('滑点不一定是系统错误，也可能是可成交报价在订单进入市场后发生变化。'),
      ],
    ),
    TutorialTopicData(
      id: 'positions-and-cash',
      sequence: '06',
      title: '持仓、成本、市值与可用资金',
      content: [
        TutorialContentBlock.heading('持仓与成本'),
        TutorialContentBlock.paragraph('持仓表示当前拥有的证券和数量，例如持有某股票 100 股。'),
        TutorialContentBlock.example(
          '第一次以 ¥100 买入 10 股，第二次以 ¥120 买入 10 股。不考虑费用时，平均成本 = (¥100 × 10 + ¥120 × 10) ÷ 20 = ¥110。',
        ),
        TutorialContentBlock.note('实际券商显示的成本可能根据佣金、税费或平台规则调整。'),
        TutorialContentBlock.heading('持仓市值'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('持仓市值', '当前价 × 持有股数'),
          TutorialFormulaRow('例子', '当前价 ¥115，持有 20 股，持仓市值 ¥2,300。'),
        ]),
        TutorialContentBlock.paragraph('持仓市值会随价格变化，不代表已经收到现金；卖出成交后才会转化为账户现金。'),
        TutorialContentBlock.heading('可用资金与总资产'),
        TutorialContentBlock.paragraph(
          '可用资金是当前可以继续使用的现金。它可能与现金总额不同，因为部分资金可能被未成交买单占用、正在处理中、需要预留费用，或受账户规则限制。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow('总资产', '现金 + 当前持仓市值'),
          TutorialFormulaRow('有融资负债时', '还需要扣除相关负债'),
        ]),
      ],
    ),
    TutorialTopicData(
      id: 'profit-and-loss',
      sequence: '07',
      title: '浮动盈亏、已实现盈亏与当日盈亏',
      content: [
        TutorialContentBlock.heading('浮动盈亏'),
        TutorialContentBlock.paragraph('浮动盈亏表示仍在持有的股票，相对于持仓成本暂时赚了或亏了多少。'),
        TutorialContentBlock.example(
          '持有 10 股，平均成本 ¥100，当前价 ¥110。浮动盈利 = (¥110 − ¥100) × 10 = ¥100。',
        ),
        TutorialContentBlock.paragraph('因为还没有卖出，股价变化后，浮动盈亏也会变化。'),
        TutorialContentBlock.heading('已实现盈亏'),
        TutorialContentBlock.paragraph('已实现盈亏是股票卖出后已经完成的收益或亏损。'),
        TutorialContentBlock.example(
          '以 ¥100 买入，以 ¥120 卖出 10 股。已实现盈利 = (¥120 − ¥100) × 10 = ¥200。',
        ),
        TutorialContentBlock.note('实际结果还需要扣除交易费用。'),
        TutorialContentBlock.heading('当日盈亏'),
        TutorialContentBlock.paragraph('当日盈亏通常反映账户资产相对上一交易日的变化。'),
        TutorialContentBlock.example(
          '买入成本 ¥80，昨收价 ¥100，当前价 ¥95。今天相对昨收下跌，但用户相对 ¥80 的成本仍然盈利。',
        ),
        TutorialContentBlock.note('当日盈亏 ≠ 持仓总盈亏。'),
        TutorialContentBlock.paragraph(
          '不同平台对分红、入金、出金、汇率和费用的处理方式可能不同，具体数字以平台规则为准。',
        ),
      ],
    ),
    TutorialTopicData(
      id: 'trading-costs',
      sequence: '08',
      title: '佣金、税费、平台费与换汇成本',
      content: [
        TutorialContentBlock.paragraph('投资净收益不能只计算买入价和卖出价。'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('净收益大致为', '卖出所得 − 买入成本 − 交易费用 − 税费 − 换汇等其他成本'),
        ]),
        TutorialContentBlock.heading('佣金和平台费'),
        TutorialContentBlock.paragraph('券商可能按每笔订单、每股数量、成交金额比例或固定月费收费。'),
        TutorialContentBlock.note('“零佣金”可能只免除某一项费用，不代表没有其他成本。'),
        TutorialContentBlock.heading('交易所、监管费用和税费'),
        TutorialContentBlock.paragraph(
          '部分市场可能收取交易所费用、结算费用或监管费用。根据市场和投资者身份，也可能涉及交易税、印花税、股息预扣税或资本收益税。',
        ),
        TutorialContentBlock.note('不要把某个税率当成固定规则。具体规则可能变化，也取决于个人身份。'),
        TutorialContentBlock.heading('换汇成本'),
        TutorialContentBlock.paragraph(
          '例如把人民币换成美元后买美股，可能涉及明示换汇手续费、买入汇率和卖出汇率之间的差价，以及汇率本身变化。',
        ),
        TutorialContentBlock.note('即使股票上涨，用本币计算的最终收益也可能受到汇率影响。'),
        TutorialContentBlock.paragraph('买一和卖一之间的价差也属于真实交易成本，即使平台没有把它单独显示为手续费。'),
      ],
    ),
    TutorialTopicData(
      id: 'trade-lifecycle',
      sequence: '09',
      title: '从买入到卖出：完成一笔交易',
      content: [
        TutorialContentBlock.heading('第一步：选择证券'),
        TutorialContentBlock.paragraph('确认公司名称、股票代码、上市市场、交易货币，并确保自己理解所购买的资产。'),
        TutorialContentBlock.heading('第二步：确认账户情况'),
        TutorialContentBlock.paragraph(
          '检查可用资金、现金账户还是保证金账户、买入后还剩多少现金，以及是否把过多资金集中到一只股票。',
        ),
        TutorialContentBlock.heading('第三步：决定价格和数量'),
        TutorialContentBlock.example(
          '最多以每股 ¥100 买入 20 股，预计股票金额为 ¥100 × 20 = ¥2,000，并预留交易费用。',
        ),
        TutorialContentBlock.heading('第四步：选择订单类型'),
        TutorialContentBlock.paragraph('限价 ¥100、数量 20 股，表示只愿意以 ¥100 或更低价格买入。'),
        TutorialContentBlock.heading('第五步：查看订单状态'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('订单状态', '等待成交、部分成交、全部成交、已撤销或已拒绝'),
        ]),
        TutorialContentBlock.note('点击“买入”不代表已经形成持仓，必须查看实际成交状态。'),
        TutorialContentBlock.heading('第六步：形成持仓'),
        TutorialContentBlock.paragraph('成交后账户会更新持有股数、平均成本、当前市值、可用资金和浮动盈亏。'),
        TutorialContentBlock.heading('第七步：持有期间观察'),
        TutorialContentBlock.paragraph('区分今日涨跌、个人持仓盈亏、公司基本面变化和短期市场波动。'),
        TutorialContentBlock.heading('第八步：卖出'),
        TutorialContentBlock.paragraph(
          '决定卖出多少股、选择市价单还是限价单、是否接受当前买卖价差，以及是否可能部分成交。',
        ),
        TutorialContentBlock.heading('第九步：复盘'),
        TutorialContentBlock.paragraph(
          '记录为什么买入、实际买入和卖出价格、支付了多少费用、最终净收益或亏损、是否符合原计划，以及错误来自分析还是执行。',
        ),
        TutorialContentBlock.note(
          '可以先使用 App 的 Simulation 模拟交易功能练习流程，避免直接使用真实资金。',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const TutorialModuleDetailPage(
      title: '交易入门',
      topics: topics,
      listKey: ValueKey('trading-basics-topic-list'),
    );
  }
}
