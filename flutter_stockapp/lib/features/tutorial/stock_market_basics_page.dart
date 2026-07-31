import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';

enum TutorialContentBlockType {
  heading,
  paragraph,
  example,
  note,
  formula,
  diagram,
}

enum TutorialDiagramType { kLine, intradayComparison }

class TutorialContentBlock {
  const TutorialContentBlock.heading(this.text)
    : type = TutorialContentBlockType.heading,
      rows = const [],
      diagramType = null;

  const TutorialContentBlock.paragraph(this.text)
    : type = TutorialContentBlockType.paragraph,
      rows = const [],
      diagramType = null;

  const TutorialContentBlock.example(this.text)
    : type = TutorialContentBlockType.example,
      rows = const [],
      diagramType = null;

  const TutorialContentBlock.note(this.text)
    : type = TutorialContentBlockType.note,
      rows = const [],
      diagramType = null;

  const TutorialContentBlock.formula(this.rows)
    : type = TutorialContentBlockType.formula,
      text = null,
      diagramType = null;

  const TutorialContentBlock.diagram(this.diagramType)
    : type = TutorialContentBlockType.diagram,
      text = null,
      rows = const [];

  final TutorialContentBlockType type;
  final String? text;
  final List<TutorialFormulaRow> rows;
  final TutorialDiagramType? diagramType;
}

class TutorialFormulaRow {
  const TutorialFormulaRow(this.label, this.value);

  final String label;
  final String value;
}

class TutorialTopicData {
  const TutorialTopicData({
    required this.id,
    required this.sequence,
    required this.title,
    required this.content,
  });

  final String id;
  final String sequence;
  final String title;
  final List<TutorialContentBlock> content;
}

class StockMarketBasicsPage extends StatefulWidget {
  const StockMarketBasicsPage({super.key});

  static const topics = [
    TutorialTopicData(
      id: 'what-is-a-stock',
      sequence: '01',
      title: '股票到底是什么',
      content: [
        TutorialContentBlock.paragraph(
          '股票代表你持有一家公司的一部分所有权。成为股东后，你拥有的是公司中的经济权益和股东权利，而不是公司某一台设备、某一间办公室或某一笔现金。',
        ),
        TutorialContentBlock.paragraph(
          '公司发行股票，是为了募集资金用于发展业务。普通投资者在交易 App 里买卖股票时，大多数时候是在二级市场与其他投资者交易，并不是直接把钱交给公司。',
        ),
        TutorialContentBlock.heading('股东可能得到什么'),
        TutorialContentBlock.paragraph(
          '股东回报通常来自股价上涨和分红。分红不是保证收益，公司是否分红、分多少，要看经营情况、资金安排和公司决策。',
        ),
        TutorialContentBlock.note(
          '一家暂时不分红的公司，仍可能通过保留利润、扩张业务、积累资产、回购股份，或未来再分红来创造股东价值。',
        ),
        TutorialContentBlock.paragraph(
          '股票价值最终需要和能够到达股东的利益相关，例如分红、股份回购、被收购时的支付，或清算后的剩余资产。',
        ),
        TutorialContentBlock.note(
          '如果一家公司永远不会以任何形式给股东带来经济利益或股东权利，它的股票就缺少基本价值，价格主要依赖“还有别人愿意出更高价”。',
        ),
        TutorialContentBlock.heading('常见误解'),
        TutorialContentBlock.paragraph('买股票不是把钱借给公司，股票和债券不是一回事。'),
        TutorialContentBlock.paragraph('股东不能直接拿走公司的资产。'),
        TutorialContentBlock.paragraph('公司赚钱了，也不一定要把全部利润分给股东。'),
        TutorialContentBlock.paragraph('好公司不等于任何价格买入都是好投资。'),
      ],
    ),
    TutorialTopicData(
      id: 'how-stocks-are-traded',
      sequence: '02',
      title: '股票是怎样被买卖的',
      content: [
        TutorialContentBlock.paragraph(
          '股票市场可以分成一级市场和二级市场。一级市场是公司新发行股票并募集资金的地方；二级市场是已经发行的股票在投资者之间买卖的地方。',
        ),
        TutorialContentBlock.paragraph(
          '普通交易 App 里的买入和卖出，通常发生在二级市场。你提交订单后，券商负责接收、检查和管理订单，交易所负责组织市场并撮合买卖双方。',
        ),
        TutorialContentBlock.note('券商和交易所通常不是那笔股票交易里的真正卖方或买方。'),
        TutorialContentBlock.heading('一笔交易大致怎么发生'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('1', '投资者提交订单'),
          TutorialFormulaRow('2', '券商检查订单'),
          TutorialFormulaRow('3', '订单进入市场'),
          TutorialFormulaRow('4', '市场找到可匹配的买价和卖价'),
          TutorialFormulaRow('5', '成交发生'),
          TutorialFormulaRow('6', '现金和持仓更新'),
        ]),
        TutorialContentBlock.example(
          '如果买方只愿意出 ¥90，而最低卖方要价是 ¥100，价格没有匹配，订单就可能无法成交。',
        ),
        TutorialContentBlock.paragraph(
          '页面上显示的当前价，通常是最近一笔成交价。它不保证此刻一定还能以完全相同的价格买到或卖出。',
        ),
        TutorialContentBlock.note('开户流程属于后续“交易入门”模块，这里只理解股票如何被买卖。'),
      ],
    ),
    TutorialTopicData(
      id: 'why-prices-change',
      sequence: '03',
      title: '为什么股票价格会变化',
      content: [
        TutorialContentBlock.paragraph(
          '屏幕上看到的股票价格来自真实成交。每一笔完成的交易，同时都有买方和卖方，所以“买的人比卖的人多”只是一个过度简化的说法。',
        ),
        TutorialContentBlock.paragraph(
          '真正影响价格的是：哪一方更愿意改变自己的报价来成交。当买方愿意不断出更高价格，或卖方不愿低价卖出时，成交价可能上升；反过来则可能下降。',
        ),
        TutorialContentBlock.heading('影响出价意愿的因素'),
        TutorialContentBlock.paragraph(
          '常见因素包括公司业绩、市场预期、公司新闻、行业景气度、宏观经济、利率变化和市场情绪。',
        ),
        TutorialContentBlock.example(
          '一家公司利润增长 20%，股价仍可能下跌，因为投资者原本期待增长 40%。市场反应的往往是“实际结果相对之前预期”的差异。',
        ),
        TutorialContentBlock.paragraph(
          '好消息也可能已经提前反映在价格里。二级市场股价上涨，并不自动意味着公司获得了新的现金。',
        ),
        TutorialContentBlock.note('短期股价和企业内在价值有关联，但并不完全相同。'),
      ],
    ),
    TutorialTopicData(
      id: 'reading-stock-details',
      sequence: '04',
      title: '股票详情页上的数字怎么看',
      content: [
        TutorialContentBlock.paragraph(
          '股票详情页通常会展示股票名称、股票代码、当前价、昨收价、涨跌额、涨跌幅、开盘价、最高价、最低价、成交量和成交额。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow('股票名称', '公司或证券的展示名称'),
          TutorialFormulaRow('股票代码', '用于识别这只股票的代码'),
          TutorialFormulaRow('当前价', '最新完成的一笔成交价格'),
          TutorialFormulaRow('昨收价', '上一交易日的收盘价'),
          TutorialFormulaRow('涨跌额 / 涨跌幅', '通常以昨收价作为比较基准'),
          TutorialFormulaRow('开盘价 / 最高价 / 最低价', '当前交易日或所选周期内的关键成交价'),
        ]),
        TutorialContentBlock.paragraph(
          '成交量表示某段时间内成交了多少股。成交额表示这些交易涉及的总金额。成交量更大，通常说明交易更活跃，但它本身并不等于股价一定会上涨。',
        ),
        TutorialContentBlock.note('股票当天的涨跌，不等于你个人账户的盈亏。'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('今日涨跌', '当前价 vs 昨收价'),
          TutorialFormulaRow('个人盈亏', '当前价 vs 买入成本'),
          TutorialFormulaRow('股票贵不贵', '市场价格 vs 对合理价值的判断'),
        ]),
      ],
    ),
    TutorialTopicData(
      id: 'price-change-percent',
      sequence: '05',
      title: '涨跌额与涨跌幅',
      content: [
        TutorialContentBlock.paragraph(
          '涨跌额是价格变化的绝对金额。涨跌幅是这个变化相对于比较价格的比例。日内涨跌通常用昨收价作为比较基准。',
        ),
        TutorialContentBlock.example('昨收价：¥100\n当前价：¥105\n涨跌额：+¥5\n涨跌幅：+5%'),
        TutorialContentBlock.note('涨跌幅不自动等于你的个人收益率。你的收益率还要看买入成本、交易费用和持仓数量。'),
        TutorialContentBlock.note(
          '一只股票下跌 50% 后，需要从新的低价上涨 100% 才能回到原价，因为计算基准变了。',
        ),
      ],
    ),
    TutorialTopicData(
      id: 'ohlc-prices',
      sequence: '06',
      title: '开盘价、收盘价、最高价与最低价',
      content: [
        TutorialContentBlock.paragraph(
          '开盘价是所选周期内第一笔完成的成交价，收盘价是最后一笔完成的成交价，最高价和最低价分别是该周期内成交过的最高和最低价格。',
        ),
        TutorialContentBlock.note('在交易周期结束前，当前价还不是最终收盘价。今天的开盘价也不一定等于昨天的收盘价。'),
        TutorialContentBlock.paragraph('如果今天开盘价高于昨收价，通常叫高开；如果低于昨收价，通常叫低开。'),
        TutorialContentBlock.example('例：某日开盘 ¥100，最高 ¥108，最低 ¥96，收盘 ¥104。'),
        TutorialContentBlock.note('说涨跌幅时要讲清楚比较基准：是收盘价相对昨收价，还是收盘价相对开盘价。'),
      ],
    ),
    TutorialTopicData(
      id: 'candlestick-basics',
      sequence: '07',
      title: 'K线是什么',
      content: [
        TutorialContentBlock.paragraph(
          '一根 K 线代表一个选定时间周期。日 K 线代表一个交易日，也可以有 5 分钟 K 线、周 K 线或月 K 线。',
        ),
        TutorialContentBlock.paragraph(
          '每根 K 线都由开盘价、收盘价、最高价和最低价组成。实体连接开盘价和收盘价，上影线连接到最高价，下影线连接到最低价。',
        ),
        TutorialContentBlock.paragraph(
          '收盘价高于开盘价，说明这个周期上涨；收盘价低于开盘价，说明这个周期下跌。红绿颜色在不同市场和 App 中可能相反，要以当前 App 的说明为准。',
        ),
        TutorialContentBlock.diagram(TutorialDiagramType.kLine),
        TutorialContentBlock.note('单根 K 线只描述过去价格，不能保证下一步一定怎么走。'),
      ],
    ),
    TutorialTopicData(
      id: 'intraday-vs-candlestick',
      sequence: '08',
      title: '分时图与K线图的区别',
      content: [
        TutorialContentBlock.paragraph('分时图展示一个交易日内价格连续变化的路径。横轴通常是交易时间，纵轴是价格。'),
        TutorialContentBlock.paragraph(
          'K 线图会把每个选定周期压缩成一根 K 线。日 K、周 K、月 K 更适合观察更长时间的价格变化。',
        ),
        TutorialContentBlock.diagram(TutorialDiagramType.intradayComparison),
        TutorialContentBlock.note('分时图更适合看今天怎么走；K 线图更适合看一段时间里的结构。'),
      ],
    ),
    TutorialTopicData(
      id: 'market-cap-pe-pb',
      sequence: '09',
      title: '市值、PE与PB',
      content: [
        TutorialContentBlock.heading('市值'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('市值', '当前股价 × 已发行股票总数'),
        ]),
        TutorialContentBlock.paragraph(
          '市值是股东权益在市场上的总价格，不等于公司银行账户里的现金。单股价格高，不代表公司一定更大，还要看总股数。成交量也不用于计算市值。',
        ),
        TutorialContentBlock.heading('PE'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('PE', '市值 ÷ 净利润'),
          TutorialFormulaRow('每股口径', '每股价格 ÷ 每股收益'),
        ]),
        TutorialContentBlock.paragraph(
          'PE 用来比较市场价格和公司盈利。高 PE 可能代表市场期待增长、认为风险较低、当前利润暂时偏低，也可能只是过度乐观。',
        ),
        TutorialContentBlock.paragraph(
          '低 PE 可能代表估值较低，也可能反映增长弱、风险高、未来利润下滑，或当前利润不可持续。亏损公司通常没有有意义的 PE。',
        ),
        TutorialContentBlock.note(
          '不要把 PE 简单理解成“多少年回本”的精确数字。TTM PE 使用过去十二个月利润，Forward PE 使用预期未来利润。',
        ),
        TutorialContentBlock.heading('PB'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('PB', '市值 ÷ 净资产'),
          TutorialFormulaRow('净资产', '资产 − 负债'),
        ]),
        TutorialContentBlock.paragraph(
          'PB 比较的是市场价值和会计账面权益。品牌、技术、客户、数据和未来盈利能力，未必都会完整记录在账面资产里。',
        ),
        TutorialContentBlock.paragraph(
          'PB 对重资产行业或金融行业可能更容易解释。PB 低于 1，也不自动代表股票便宜。',
        ),
        TutorialContentBlock.note(
          '市值：整家公司当前在市场上值多少钱\nPE：市场价格相对于公司利润有多高\nPB：市场价格相对于账面净资产有多高',
        ),
      ],
    ),
  ];

  @override
  State<StockMarketBasicsPage> createState() => _StockMarketBasicsPageState();
}

class _StockMarketBasicsPageState extends State<StockMarketBasicsPage> {
  String? _expandedTopicId;

  void _toggleTopic(String id) {
    setState(() {
      _expandedTopicId = _expandedTopicId == id ? null : id;
    });
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
        title: Text(
          '股票与行情基础',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedPageWrapper(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SingleChildScrollView(
                key: const ValueKey('stock-market-basics-topic-list'),
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < StockMarketBasicsPage.topics.length;
                      index++
                    ) ...[
                      _TutorialTopicRow(
                        topic: StockMarketBasicsPage.topics[index],
                        expanded:
                            _expandedTopicId ==
                            StockMarketBasicsPage.topics[index].id,
                        onTap: () => _toggleTopic(
                          StockMarketBasicsPage.topics[index].id,
                        ),
                      ),
                      if (index != StockMarketBasicsPage.topics.length - 1)
                        const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorialTopicRow extends StatelessWidget {
  const _TutorialTopicRow({
    required this.topic,
    required this.expanded,
    required this.onTap,
  });

  final TutorialTopicData topic;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Material(
      color: palette.cardBackground,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('tutorial-topic-${topic.id}'),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: palette.divider),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        topic.sequence,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: palette.secondaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        topic.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: palette.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: palette.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: expanded
                    ? Container(
                        key: ValueKey('tutorial-topic-content-${topic.id}'),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: palette.divider),
                          ),
                        ),
                        child: _TutorialTopicContent(blocks: topic.content),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialTopicContent extends StatelessWidget {
  const _TutorialTopicContent({required this.blocks});

  final List<TutorialContentBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < blocks.length; index++) ...[
          _TutorialContentBlockView(block: blocks[index]),
          if (index != blocks.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _TutorialContentBlockView extends StatelessWidget {
  const _TutorialContentBlockView({required this.block});

  final TutorialContentBlock block;

  @override
  Widget build(BuildContext context) {
    return switch (block.type) {
      TutorialContentBlockType.heading => _SectionHeading(block.text!),
      TutorialContentBlockType.paragraph => _BodyParagraph(block.text!),
      TutorialContentBlockType.example => _CalloutBox(
        text: block.text!,
        icon: Icons.lightbulb_outline_rounded,
      ),
      TutorialContentBlockType.note => _CalloutBox(
        text: block.text!,
        icon: Icons.info_outline_rounded,
        subtle: true,
      ),
      TutorialContentBlockType.formula => _FormulaRows(block.rows),
      TutorialContentBlockType.diagram => _TutorialDiagram(
        type: block.diagramType!,
      ),
    };
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        color: palette.primaryText,
        fontWeight: FontWeight.w800,
        height: 1.35,
      ),
    );
  }
}

class _BodyParagraph extends StatelessWidget {
  const _BodyParagraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: palette.secondaryText,
        height: 1.58,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _CalloutBox extends StatelessWidget {
  const _CalloutBox({
    required this.text,
    required this.icon,
    this.subtle = false,
  });

  final String text;
  final IconData icon;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;
    final background = subtle
        ? palette.searchBackground.withValues(alpha: 0.72)
        : palette.segmentBackground.withValues(alpha: 0.72);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: palette.primaryText, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.primaryText,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaRows extends StatelessWidget {
  const _FormulaRows(this.rows);

  final List<TutorialFormulaRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Container(
      decoration: BoxDecoration(
        color: palette.searchBackground.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 86,
                    child: Text(
                      rows[index].label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.primaryText,
                        fontWeight: FontWeight.w800,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      rows[index].value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.secondaryText,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (index != rows.length - 1)
              Divider(height: 1, thickness: 1, color: palette.divider),
          ],
        ],
      ),
    );
  }
}

class _TutorialDiagram extends StatelessWidget {
  const _TutorialDiagram({required this.type});

  final TutorialDiagramType type;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      TutorialDiagramType.kLine => const _KLineDiagram(),
      TutorialDiagramType.intradayComparison =>
        const _IntradayComparisonDiagram(),
    };
  }
}

class _KLineDiagram extends StatelessWidget {
  const _KLineDiagram();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Semantics(
      label: 'K线结构示意图：标出最高价、最低价、开盘价、收盘价、实体、上影线和下影线。',
      child: _DiagramFrame(
        key: const ValueKey('k-line-educational-diagram'),
        child: CustomPaint(
          painter: _KLineDiagramPainter(palette: palette),
          child: const SizedBox(height: 220),
        ),
      ),
    );
  }
}

class _IntradayComparisonDiagram extends StatelessWidget {
  const _IntradayComparisonDiagram();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Semantics(
      label: '分时图与K线图对比示意图：左侧为分时线，右侧为多根K线。',
      child: _DiagramFrame(
        key: const ValueKey('intraday-kline-comparison-diagram'),
        child: CustomPaint(
          painter: _IntradayComparisonPainter(palette: palette),
          child: const SizedBox(height: 190),
        ),
      ),
    );
  }
}

class _DiagramFrame extends StatelessWidget {
  const _DiagramFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.searchBackground.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: palette.divider),
      ),
      child: child,
    );
  }
}

class _KLineDiagramPainter extends CustomPainter {
  const _KLineDiagramPainter({required this.palette});

  final AppThemePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final risingColor = Colors.red.shade500;
    final fallingColor = Colors.green.shade600;
    final guidePaint = Paint()
      ..color = palette.divider
      ..strokeWidth = 1;
    final textStyle = TextStyle(
      color: palette.primaryText,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );
    final mutedStyle = TextStyle(
      color: palette.secondaryText,
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    _drawLabel(canvas, '上涨K线', Offset(size.width * 0.22, 6), textStyle);
    _drawLabel(canvas, '下跌K线', Offset(size.width * 0.62, 6), textStyle);
    _drawCandle(
      canvas: canvas,
      centerX: size.width * 0.32,
      high: 46,
      open: 128,
      close: 82,
      low: 178,
      color: risingColor,
      width: 36,
    );
    _drawCandle(
      canvas: canvas,
      centerX: size.width * 0.72,
      high: 46,
      open: 82,
      close: 132,
      low: 178,
      color: fallingColor,
      width: 36,
    );

    final leftX = size.width * 0.32;
    final rightX = size.width * 0.72;
    for (final y in [46.0, 82.0, 128.0, 178.0]) {
      canvas.drawLine(Offset(8, y), Offset(size.width - 8, y), guidePaint);
    }
    _drawLabel(canvas, '最高价', const Offset(10, 39), mutedStyle);
    _drawLabel(canvas, '最低价', const Offset(10, 171), mutedStyle);
    _drawLabel(canvas, '收盘价', Offset(leftX - 96, 75), mutedStyle);
    _drawLabel(canvas, '开盘价', Offset(leftX - 96, 121), mutedStyle);
    _drawLabel(canvas, '开盘价', Offset(rightX + 34, 75), mutedStyle);
    _drawLabel(canvas, '收盘价', Offset(rightX + 34, 125), mutedStyle);
    _drawLabel(canvas, '上影线', Offset(size.width * 0.44, 50), mutedStyle);
    _drawLabel(canvas, '实体', Offset(size.width * 0.44, 101), mutedStyle);
    _drawLabel(canvas, '下影线', Offset(size.width * 0.44, 158), mutedStyle);
  }

  void _drawCandle({
    required Canvas canvas,
    required double centerX,
    required double high,
    required double open,
    required double close,
    required double low,
    required Color color,
    required double width,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final bodyPaint = Paint()..color = color.withValues(alpha: 0.82);
    final bodyTop = math.min(open, close);
    final bodyBottom = math.max(open, close);

    canvas.drawLine(Offset(centerX, high), Offset(centerX, bodyTop), paint);
    canvas.drawLine(Offset(centerX, bodyBottom), Offset(centerX, low), paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - width / 2,
          bodyTop,
          width,
          bodyBottom - bodyTop,
        ),
        const Radius.circular(5),
      ),
      bodyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _KLineDiagramPainter oldDelegate) =>
      oldDelegate.palette != palette;
}

class _IntradayComparisonPainter extends CustomPainter {
  const _IntradayComparisonPainter({required this.palette});

  final AppThemePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: palette.primaryText,
      fontSize: 11,
      fontWeight: FontWeight.w800,
    );
    final mutedStyle = TextStyle(
      color: palette.secondaryText,
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    final borderPaint = Paint()
      ..color = palette.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = palette.secondaryText.withValues(alpha: 0.45)
      ..strokeWidth = 1;

    final left = Rect.fromLTWH(4, 28, size.width * 0.44, 126);
    final right = Rect.fromLTWH(size.width * 0.53, 28, size.width * 0.43, 126);
    canvas.drawRRect(
      RRect.fromRectAndRadius(left, const Radius.circular(10)),
      borderPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(right, const Radius.circular(10)),
      borderPaint,
    );

    _drawLabel(canvas, '分时图', Offset(left.left + 8, 6), textStyle);
    _drawLabel(canvas, 'K线图', Offset(right.left + 8, 6), textStyle);
    _drawLabel(
      canvas,
      '时间',
      Offset(left.right - 34, left.bottom + 8),
      mutedStyle,
    );
    _drawLabel(canvas, '价格', Offset(left.left + 8, left.top + 8), mutedStyle);

    canvas.drawLine(
      Offset(left.left + 18, left.bottom - 18),
      Offset(left.right - 14, left.bottom - 18),
      axisPaint,
    );
    canvas.drawLine(
      Offset(left.left + 18, left.bottom - 18),
      Offset(left.left + 18, left.top + 16),
      axisPaint,
    );

    final linePath = Path()
      ..moveTo(left.left + 22, left.bottom - 42)
      ..cubicTo(
        left.left + 48,
        left.bottom - 72,
        left.left + 70,
        left.bottom - 28,
        left.left + 96,
        left.bottom - 58,
      )
      ..cubicTo(
        left.left + 124,
        left.bottom - 88,
        left.left + 142,
        left.bottom - 48,
        left.right - 20,
        left.bottom - 76,
      );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = Colors.blue.shade500
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (var index = 0; index < 5; index++) {
      final centerX = right.left + 28 + index * 28;
      final open = right.bottom - (48 + index * 8);
      final close = index.isEven ? open - 24 : open + 20;
      final high = math.min(open, close) - 18;
      final low = math.max(open, close) + 20;
      final color = index.isEven ? Colors.red.shade500 : Colors.green.shade600;
      _drawMiniCandle(canvas, centerX, high, open, close, low, color);
    }
    _drawLabel(
      canvas,
      '每根代表一个周期',
      Offset(right.left + 8, right.bottom + 8),
      mutedStyle,
    );
  }

  void _drawMiniCandle(
    Canvas canvas,
    double centerX,
    double high,
    double open,
    double close,
    double low,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final bodyTop = math.min(open, close);
    final bodyBottom = math.max(open, close);
    canvas.drawLine(Offset(centerX, high), Offset(centerX, low), paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 7, bodyTop, 14, bodyBottom - bodyTop),
        const Radius.circular(3),
      ),
      Paint()..color = color.withValues(alpha: 0.82),
    );
  }

  @override
  bool shouldRepaint(covariant _IntradayComparisonPainter oldDelegate) =>
      oldDelegate.palette != palette;
}

void _drawLabel(Canvas canvas, String text, Offset offset, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  painter.paint(canvas, offset);
}
