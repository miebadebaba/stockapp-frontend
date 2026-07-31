import 'package:flutter/material.dart';

import 'tutorial_module_detail_page.dart';
import 'widgets/technical_indicator_diagrams.dart';

class RiskPortfolioPage extends StatelessWidget {
  const RiskPortfolioPage({super.key});

  static const topics = [
    TutorialTopicData(
      id: 'risk-basics',
      sequence: '01',
      title: '风险是什么：亏损、波动与不确定性',
      content: [
        TutorialContentBlock.paragraph(
          '投资风险不只是“股价今天下跌”。更完整的理解是：实际结果可能明显偏离原先预期，并造成无法承受或难以恢复的损失。',
        ),
        TutorialContentBlock.heading('价格波动'),
        TutorialContentBlock.paragraph(
          '股票价格每天上下变化，这叫波动。波动较大通常意味着短期涨跌幅可能更大、持仓价值变化更快，投资者也更容易受到恐慌或冲动影响。',
        ),
        TutorialContentBlock.note(
          '波动不一定等于永久损失。一家公司经营正常时，股价可能短期下跌后恢复。反过来，即使每天波动不大，长期持续下跌也可能造成严重损失。',
        ),
        TutorialContentBlock.heading('永久性损失'),
        TutorialContentBlock.paragraph(
          '永久性损失可能来自公司业务长期恶化、无法偿还债务、破产或退市、投资者在大幅亏损后被迫卖出、使用杠杆后被强制平仓，或以严重高估价格买入后长期无法恢复。',
        ),
        TutorialContentBlock.note('短期价格波动不等于永久性损失。'),
        TutorialContentBlock.heading('常见风险类型'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('市场风险', '整个市场或大量股票同时下跌。'),
          TutorialFormulaRow('公司风险', '单家公司经营、管理或财务状况恶化。'),
          TutorialFormulaRow('行业风险', '行业需求、技术或监管环境发生变化。'),
          TutorialFormulaRow('流动性风险', '想卖出时，无法按合理价格及时成交。'),
          TutorialFormulaRow('汇率风险', '持有外币资产时，本币收益受到汇率变化影响。'),
          TutorialFormulaRow('利率风险', '利率变化影响公司融资成本和资产估值。'),
          TutorialFormulaRow('操作风险', '输错股票代码、价格、数量或订单类型。'),
          TutorialFormulaRow('杠杆风险', '使用借款后，损失被放大，并可能触发强制平仓。'),
        ]),
        TutorialContentBlock.note('风险管理不是保证永远不亏损，而是避免一次错误造成无法恢复的损失。'),
      ],
    ),
    TutorialTopicData(
      id: 'position-sizing',
      sequence: '02',
      title: '仓位是什么，为什么不能满仓一只股票',
      content: [
        TutorialContentBlock.paragraph('仓位表示某项投资占账户总资产的比例。'),
        TutorialContentBlock.example(
          '账户总资产：¥100,000\n某只股票持仓市值：¥20,000\n该股票仓位：¥20,000 ÷ ¥100,000 = 20%',
        ),
        TutorialContentBlock.paragraph('如果几乎全部资金都投入同一只股票，可以称为接近满仓这只股票。'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('账户影响', '账户影响 ≈ 股票仓位 × 股票涨跌幅'),
          TutorialFormulaRow('满仓例子', '股票仓位 100%，股票下跌 30%，账户损失约 30%。'),
          TutorialFormulaRow('20% 仓位例子', '股票仓位 20%，股票下跌 30%，账户损失约 6%。'),
        ]),
        TutorialContentBlock.paragraph(
          '满仓风险高，是因为即使非常看好一家公司，也可能遇到财报低于预期、产品问题、管理层变化、行业监管调整、市场整体下跌、分析遗漏或突发事件。',
        ),
        TutorialContentBlock.note('满仓意味着对单一判断的依赖非常高，也意味着账户容错空间很小。'),
        TutorialContentBlock.paragraph(
          '仓位小也不一定自动安全。如果同时持有多只高度相关的股票，整体仍可能集中在相同风险中。',
        ),
        TutorialContentBlock.example('同时持有多只芯片股，仍然高度依赖芯片行业景气。'),
        TutorialContentBlock.custom(PositionImpactDiagram()),
      ],
    ),
    TutorialTopicData(
      id: 'diversification-concentration',
      sequence: '03',
      title: '分散投资与集中投资',
      content: [
        TutorialContentBlock.paragraph(
          '分散投资是把资金配置到多个不同资产或风险来源中，避免单一事件严重破坏整个账户。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow('单一持仓', '只持有一家公司，若公司发生重大问题，整个账户会受到明显影响。'),
          TutorialFormulaRow('分散持仓', '资金分布在多个不同公司和行业，某一家公司出问题时，只影响组合的一部分。'),
        ]),
        TutorialContentBlock.paragraph('分散投资主要降低单一公司风险、单一行业风险和单一事件风险。'),
        TutorialContentBlock.note('分散投资不能消除市场整体风险，也就是整个市场一起下跌的风险。'),
        TutorialContentBlock.heading('分散不等于股票越多越好'),
        TutorialContentBlock.paragraph(
          '持有 30 只股票不一定比持有 10 只股票更分散。如果这些股票属于同一行业、同一国家、相似商业模式或相同风险驱动因素，它们仍可能同时上涨或下跌。',
        ),
        TutorialContentBlock.heading('集中投资'),
        TutorialContentBlock.paragraph(
          '集中投资可能在判断正确时带来更明显的收益贡献，也更容易深入研究少数公司。但判断错误时，损失更集中，也更容易受到个别公司意外事件影响。',
        ),
        TutorialContentBlock.note(
          '集中投资并非天然错误，但必须清楚集中在哪些风险上、最坏情况可能损失多少，以及自己是否能承受该损失。',
        ),
        TutorialContentBlock.paragraph('分散投资的代价是：单只股票大幅上涨时，对整个账户的贡献会被降低。'),
        TutorialContentBlock.note('风险管理的目标不是让每次收益最大，而是让账户能够承受错误并继续参与市场。'),
      ],
    ),
    TutorialTopicData(
      id: 'correlation',
      sequence: '04',
      title: '相关性与真正的分散',
      content: [
        TutorialContentBlock.paragraph('相关性描述两个资产的价格变化是否经常朝相同方向移动。'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('高相关', '两个资产经常一起上涨、一起下跌，分散效果可能有限。'),
          TutorialFormulaRow('低相关', '两个资产变化没有明显同步关系，一个下跌时，另一个不一定同时下跌。'),
          TutorialFormulaRow('负相关', '一个资产上涨时，另一个经常下跌。'),
        ]),
        TutorialContentBlock.note('相关性不是固定不变的。市场恐慌或极端事件中，原本相关性较低的资产也可能一起下跌。'),
        TutorialContentBlock.example(
          '银行 A、银行 B、银行 C、银行 D 虽然是四只股票，但都可能受利率、信贷质量、金融监管和经济周期影响，这不等于真正分散。',
        ),
        TutorialContentBlock.paragraph(
          '检查真正分散时，可以看组合是否分布在不同公司、行业、地区、货币、商业模式、收入来源和风险驱动因素中。',
        ),
        TutorialContentBlock.note('历史相关性只能描述过去，不能保证未来保持不变。'),
        TutorialContentBlock.custom(CorrelationDiagram()),
      ],
    ),
    TutorialTopicData(
      id: 'volatility-drawdown',
      sequence: '05',
      title: '波动率与最大回撤',
      content: [
        TutorialContentBlock.paragraph('波动率用于描述价格或收益变化幅度。'),
        TutorialContentBlock.example(
          '资产 A 每天大约上下变化 1%；资产 B 经常一天变化 5% 或更多。资产 B 通常具有更高波动率。',
        ),
        TutorialContentBlock.paragraph(
          '高波动可能意味着潜在涨幅较大、潜在跌幅也较大、持仓体验更不稳定、止损更容易被普通波动触发，仓位管理也需要更加谨慎。',
        ),
        TutorialContentBlock.note('低波动不代表绝对安全。过去波动较低的资产也可能突然发生重大损失。'),
        TutorialContentBlock.heading('最大回撤'),
        TutorialContentBlock.paragraph('最大回撤表示资产或账户从之前某个高点下降到后续低点时，曾经出现的最大跌幅。'),
        TutorialContentBlock.example(
          '账户高点 ¥120,000，之后低点 ¥90,000。\n最大回撤：(¥120,000 − ¥90,000) ÷ ¥120,000 = 25%。',
        ),
        TutorialContentBlock.note('最大回撤从之前的历史高点计算，不是从最初投入金额计算。'),
        TutorialContentBlock.paragraph(
          '两个策略最终都盈利 20%，过程可能完全不同。策略 A 最大回撤 8%，过程相对平稳；策略 B 曾经回撤 50%，后来才恢复并盈利。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow('下跌 10%', '需要上涨约 11.1% 回到原点。'),
          TutorialFormulaRow('下跌 20%', '需要上涨 25%。'),
          TutorialFormulaRow('下跌 50%', '需要上涨 100%。'),
        ]),
        TutorialContentBlock.custom(VolatilityDrawdownDiagram()),
      ],
    ),
    TutorialTopicData(
      id: 'risk-reward-win-rate',
      sequence: '06',
      title: '风险收益比、盈亏比与胜率',
      content: [
        TutorialContentBlock.heading('风险收益比'),
        TutorialContentBlock.paragraph('交易前可以估计最多愿意承担多少损失，以及计划中的潜在收益是多少。'),
        TutorialContentBlock.example(
          '可能亏损 ¥100，计划潜在收益 ¥200，可以描述为计划收益约为风险的 2 倍。',
        ),
        TutorialContentBlock.note('这只是交易计划，不代表市场一定达到目标价格，也不代表止损一定按预期成交。'),
        TutorialContentBlock.heading('盈亏比'),
        TutorialContentBlock.paragraph('盈亏比比较平均盈利金额和平均亏损金额。'),
        TutorialContentBlock.example('平均盈利 ¥300，平均亏损 ¥100，平均盈利约为平均亏损的 3 倍。'),
        TutorialContentBlock.heading('胜率'),
        TutorialContentBlock.paragraph('胜率表示盈利交易占全部交易的比例。'),
        TutorialContentBlock.example(
          '90 次交易每次盈利 ¥10，10 次交易每次亏损 ¥100。\n总盈利 90 × ¥10 = ¥900，总亏损 10 × ¥100 = ¥1,000，最终仍亏损 ¥100。',
        ),
        TutorialContentBlock.example(
          '40 次盈利，每次盈利 ¥300；60 次亏损，每次亏损 ¥100。\n总盈利 ¥12,000，总亏损 ¥6,000，最终仍可能盈利。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow('交易期望', '≈ 胜率 × 平均盈利 − 亏损概率 × 平均亏损'),
        ]),
        TutorialContentBlock.note('交易期望不是未来收益保证，只是帮助理解胜率、平均盈利和平均亏损需要一起观察。'),
        TutorialContentBlock.paragraph('实际结果还会受到佣金、买卖价差、滑点和税费影响。'),
      ],
    ),
    TutorialTopicData(
      id: 'stop-loss',
      sequence: '07',
      title: '止损的作用与局限',
      content: [
        TutorialContentBlock.paragraph('止损是提前设定一种退出条件，用来限制单笔交易可能造成的损失。'),
        TutorialContentBlock.example(
          '买入价格 ¥100，计划止损价格 ¥92。表示如果价格达到计划中的失效条件，投资者准备退出交易。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow(
            '止损作用',
            '判断失效时退出、防止小亏损扩大、预先估计单笔风险、减少临场情绪影响、配合仓位计算。',
          ),
        ]),
        TutorialContentBlock.note('止损价格不等于保证成交价格。'),
        TutorialContentBlock.paragraph(
          '跳空、流动性不足、市场剧烈波动、临时停牌和极端新闻事件，都可能造成实际成交价偏离。',
        ),
        TutorialContentBlock.example(
          '止损设在 ¥92，但市场价格直接从 ¥95 跳到 ¥85，实际成交价可能明显低于 ¥92。',
        ),
        TutorialContentBlock.paragraph('止损设得太近，普通市场波动可能触发退出；止损设得太远，单股风险可能过大。'),
        TutorialContentBlock.note(
          '如果止损距离扩大，应同时考虑降低买入数量。所有股票统一使用 5% 止损不一定合理，因为不同股票正常波动不同。',
        ),
        TutorialContentBlock.note('止损是一种风险管理工具，不是预测工具，也不能保证避免所有大额损失。'),
      ],
    ),
    TutorialTopicData(
      id: 'leverage-margin',
      sequence: '08',
      title: '杠杆、保证金与强制平仓',
      content: [
        TutorialContentBlock.paragraph('杠杆表示使用借来的资金，建立超过自有资金规模的投资。'),
        TutorialContentBlock.example(
          '自有资金 ¥10,000，借入资金 ¥10,000，总持仓 ¥20,000，相当于用 ¥10,000 自有资金控制 ¥20,000 资产。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow(
            '上涨 10%',
            '¥20,000 × 10% = 盈利 ¥2,000，相对 ¥10,000 自有资金收益约 20%，暂不考虑利息和费用。',
          ),
          TutorialFormulaRow(
            '下跌 10%',
            '¥20,000 × 10% = 亏损 ¥2,000，相对 ¥10,000 自有资金损失约 20%。',
          ),
        ]),
        TutorialContentBlock.note('杠杆同时放大盈利和亏损。'),
        TutorialContentBlock.heading('保证金与强制平仓'),
        TutorialContentBlock.paragraph(
          '保证金是投资者为杠杆仓位提供的自有资金或抵押资产。券商通常要求账户维持一定保证金水平。',
        ),
        TutorialContentBlock.paragraph(
          '保证金不足可能导致追加保证金要求、无法继续开新仓，或券商强制卖出部分或全部资产。',
        ),
        TutorialContentBlock.paragraph('强制平仓是指当账户权益下降到不符合保证金要求时，券商可能自动卖出资产。'),
        TutorialContentBlock.note(
          '强制平仓可能发生在价格已经大幅下跌时。即使价格之后恢复，投资者也可能因为持仓已经被卖出而无法参与恢复。',
        ),
        TutorialContentBlock.paragraph(
          '杠杆还有融资利息、更高波动压力、保证金要求变化、被迫卖出的风险，极端情况下损失甚至可能超过原始投入。',
        ),
        TutorialContentBlock.custom(LeverageMarginDiagram()),
      ],
    ),
    TutorialTopicData(
      id: 'trade-risk-limit',
      sequence: '09',
      title: '如何为一笔交易设置风险上限',
      content: [
        TutorialContentBlock.paragraph('本 Topic 将仓位、止损和风险金额连接起来。'),
        TutorialContentBlock.heading('第一步：确定单笔最多能承受的损失'),
        TutorialContentBlock.example(
          '账户总资产 ¥100,000，本笔交易计划最大损失 ¥1,000。\n¥1,000 是单笔风险上限，不是买入金额，也不是适用于所有用户的建议。',
        ),
        TutorialContentBlock.heading('第二步：确定判断失效位置'),
        TutorialContentBlock.example(
          '买入价 ¥50，止损或判断失效位置 ¥45。\n每股潜在损失：¥50 − ¥45 = ¥5。',
        ),
        TutorialContentBlock.heading('第三步：计算可买数量'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('可买数量', '≈ 单笔最大可承受损失 ÷ 每股潜在损失'),
          TutorialFormulaRow('代入', '¥1,000 ÷ ¥5 = 200 股'),
          TutorialFormulaRow('预计买入金额', '200 × ¥50 = ¥10,000'),
        ]),
        TutorialContentBlock.example(
          '如果买入价 ¥50、止损价 ¥40，每股潜在损失为 ¥10。仍只计划承担 ¥1,000 风险时，可买数量约为 100 股。',
        ),
        TutorialContentBlock.note('止损距离越远，为保持相同风险上限，可买数量通常应越少。'),
        TutorialContentBlock.paragraph(
          '实际损失可能超过计算结果，因为存在滑点、跳空、佣金和税费、流动性不足、无法及时成交，以及多个持仓同时下跌。',
        ),
        TutorialContentBlock.note('风险计算是事前规划，不是损失保证。'),
        TutorialContentBlock.paragraph(
          '组合层面还需要判断是否已有多个相似持仓、多笔交易是否依赖同一行业、极端情况下是否可能同时触发退出，以及总风险是否超过账户承受能力。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow(
            '最终流程',
            '确定账户可承受损失 → 确定判断失效位置 → 计算每股潜在损失 → 决定可买数量 → 预留滑点和费用 → 检查组合整体风险',
          ),
        ]),
        TutorialContentBlock.custom(TradeRiskFlowDiagram()),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const TutorialModuleDetailPage(
      title: '风险与投资组合',
      topics: topics,
      listKey: ValueKey('risk-portfolio-topic-list'),
    );
  }
}
