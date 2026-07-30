import 'package:flutter/material.dart';

import 'tutorial_module_detail_page.dart';

class FundamentalAnalysisPage extends StatelessWidget {
  const FundamentalAnalysisPage({super.key});

  static const topics = [
    TutorialTopicData(
      id: 'business-model',
      sequence: '01',
      title: '公司靠什么赚钱：商业模式',
      content: [
        TutorialContentBlock.paragraph(
          '分析公司时，首先要问：这家公司向谁提供什么产品或服务，并通过什么方式收钱？这就是公司的商业模式。',
        ),
        TutorialContentBlock.example(
          '苹果销售手机、电脑和服务；奈飞通过订阅收费；银行主要通过利息差和手续费赚钱；广告平台向广告主收费；电商平台可能通过商品销售、佣金、广告和物流赚钱。',
        ),
        TutorialContentBlock.heading('客户是谁'),
        TutorialContentBlock.paragraph(
          '客户可能是普通消费者、企业、政府或金融机构。不同客户决定了销售方式、付款周期和业务风险。',
        ),
        TutorialContentBlock.heading('客户为什么愿意付钱'),
        TutorialContentBlock.paragraph(
          '原因可能来自更好的产品、更低的成本、更方便的服务、品牌影响力、技术优势、网络效应或较高的替换成本。',
        ),
        TutorialContentBlock.heading('收入是一次性的还是重复性的'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('一次性收入', '卖出一台设备，收取一次费用。'),
          TutorialFormulaRow('重复性收入', '用户每月支付订阅费。'),
        ]),
        TutorialContentBlock.note('重复性收入通常更容易预测，但仍需判断客户是否容易取消。'),
        TutorialContentBlock.heading('公司依赖什么继续赚钱'),
        TutorialContentBlock.paragraph(
          '公司可能依赖原材料价格、广告市场、利率、用户增长、技术更新、监管许可或少数大型客户。',
        ),
        TutorialContentBlock.note('不要只问公司现在赚多少钱，还要问它为什么能赚钱，以及这种赚钱方式能持续多久。'),
      ],
    ),
    TutorialTopicData(
      id: 'revenue-cost-profit',
      sequence: '02',
      title: '营业收入、成本与利润',
      content: [
        TutorialContentBlock.heading('营业收入'),
        TutorialContentBlock.paragraph('营业收入是公司通过主营业务获得的销售金额。'),
        TutorialContentBlock.example(
          '一家商店卖出 1,000 件商品，每件 ¥100：营业收入 = ¥100 × 1,000 = ¥100,000。',
        ),
        TutorialContentBlock.heading('成本和费用'),
        TutorialContentBlock.paragraph(
          '成本和费用可能包括原材料、商品采购、员工工资、运输、租金、研发、广告、服务器、利息和税费。',
        ),
        TutorialContentBlock.heading('利润'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('利润', '收入 − 各类成本和费用'),
          TutorialFormulaRow('例子', '收入 ¥100,000，总成本和费用 ¥80,000，利润 ¥20,000。'),
        ]),
        TutorialContentBlock.heading('不能只看收入增长'),
        TutorialContentBlock.example(
          '去年收入 ¥1 亿元，利润 ¥1,000 万元；今年收入 ¥1.5 亿元，利润 ¥300 万元。收入增长了，但利润大幅下降。',
        ),
        TutorialContentBlock.paragraph(
          '可能原因包括降价促销、原材料价格上涨、获客成本增加、研发投入上升，或为追求增长而过度支出。',
        ),
        TutorialContentBlock.note('分析公司应同时观察收入是否增长、利润是否增长，以及为获得增长付出了多少成本。'),
      ],
    ),
    TutorialTopicData(
      id: 'margins-and-profitability',
      sequence: '03',
      title: '毛利率、净利率与盈利能力',
      content: [
        TutorialContentBlock.paragraph('单看利润金额，无法公平比较不同规模的公司，因此需要观察利润率。'),
        TutorialContentBlock.heading('毛利率'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('毛利润', '营业收入 − 直接产品成本'),
          TutorialFormulaRow('毛利率', '毛利润 ÷ 营业收入'),
          TutorialFormulaRow('例子', '收入 ¥100，直接成本 ¥60，毛利润 ¥40，毛利率 40%。'),
        ]),
        TutorialContentBlock.paragraph('毛利率可能反映产品定价能力、品牌或技术优势，以及直接成本水平。'),
        TutorialContentBlock.note(
          '不同行业不能直接使用相同标准比较毛利率。软件、零售、制造和金融行业的正常水平可能差异很大。',
        ),
        TutorialContentBlock.heading('净利率'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('净利率', '净利润 ÷ 营业收入'),
          TutorialFormulaRow('例子', '收入 ¥100，净利润 ¥10，净利率 10%。'),
        ]),
        TutorialContentBlock.paragraph('净利率综合反映产品成本、研发、营销、管理、利息和税费等影响。'),
        TutorialContentBlock.heading('ROE'),
        TutorialContentBlock.paragraph('ROE 中文为净资产收益率，用来衡量公司使用股东资本创造利润的能力。'),
        TutorialContentBlock.formula([TutorialFormulaRow('ROE', '净利润 ÷ 股东权益')]),
        TutorialContentBlock.note(
          'ROE 高不一定总是好事。公司大量借债后，股东权益可能变小，使 ROE 看起来很高，但财务风险也可能上升。',
        ),
        TutorialContentBlock.paragraph(
          '合理比较方式包括观察同一家公司过去几年的变化、比较同行业公司、检查利润率是否稳定，并判断高利润是否依赖一次性事件。',
        ),
      ],
    ),
    TutorialTopicData(
      id: 'assets-liabilities-equity',
      sequence: '04',
      title: '资产、负债与股东权益',
      content: [
        TutorialContentBlock.heading('资产'),
        TutorialContentBlock.paragraph(
          '资产是公司拥有或控制、预计能带来经济利益的资源，例如现金、存货、厂房、机器、房产、应收账款、投资、专利等无形资产。',
        ),
        TutorialContentBlock.heading('负债'),
        TutorialContentBlock.paragraph(
          '负债是公司需要承担的义务，例如银行借款、公司债券、应付供应商款项、租赁义务、尚未支付的工资和税费。',
        ),
        TutorialContentBlock.heading('股东权益'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('股东权益', '资产 − 负债'),
          TutorialFormulaRow('会计关系', '资产 = 负债 + 股东权益'),
          TutorialFormulaRow('例子', '资产 ¥100 亿元，负债 ¥60 亿元，股东权益 ¥40 亿元。'),
        ]),
        TutorialContentBlock.heading('负债是否越少越好'),
        TutorialContentBlock.paragraph(
          '不一定。合理借款可能用于建设工厂、扩大业务、收购其他公司，或提高资本使用效率。',
        ),
        TutorialContentBlock.paragraph(
          '真正需要判断的是：借来的钱能否创造足够收益，公司能否支付利息和本金，收入下降时是否仍能承担债务，债务何时到期，以及债务利率是否会上升。',
        ),
        TutorialContentBlock.note('有负债不代表公司一定危险。负债过高且缺乏偿还能力，才会形成较大的财务风险。'),
      ],
    ),
    TutorialTopicData(
      id: 'cash-flow',
      sequence: '05',
      title: '现金流为什么重要',
      content: [
        TutorialContentBlock.paragraph('净利润是会计计算结果，现金流反映现金实际流入和流出的情况。'),
        TutorialContentBlock.heading('为什么有利润却可能没有现金'),
        TutorialContentBlock.example(
          '公司销售了 ¥100 万商品，但允许客户半年后付款。会计上可能已经确认收入和利润，但现金尚未收到，形成应收账款。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow('利润表', '显示盈利'),
          TutorialFormulaRow('银行账户', '现金仍可能不足'),
        ]),
        TutorialContentBlock.heading('经营现金流'),
        TutorialContentBlock.paragraph(
          '经营现金流反映主营业务带来的现金流动，例如向客户收款、向供应商付款、支付工资和日常经营费用。',
        ),
        TutorialContentBlock.note('如果公司长期报告较高净利润，但经营现金流一直很弱，需要进一步调查盈利质量。'),
        TutorialContentBlock.heading('投资现金流'),
        TutorialContentBlock.paragraph(
          '投资现金流可能包括购买设备、建设厂房、收购公司或出售长期资产。投资现金流为负不一定是坏事，也可能表示公司正在扩张，关键在于投资未来能否创造回报。',
        ),
        TutorialContentBlock.heading('融资现金流'),
        TutorialContentBlock.paragraph('融资现金流可能包括借入资金、偿还债务、发行股票、回购股票和支付分红。'),
        TutorialContentBlock.heading('自由现金流'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('自由现金流', '经营现金流 − 资本性支出'),
        ]),
        TutorialContentBlock.paragraph(
          '自由现金流反映公司维持和投资业务后，还剩多少现金可以用于还债、分红、回购股票、收购或留作储备。',
        ),
      ],
    ),
    TutorialTopicData(
      id: 'financial-statements',
      sequence: '06',
      title: '三张财务报表怎么看',
      content: [
        TutorialContentBlock.heading('利润表'),
        TutorialContentBlock.paragraph('利润表回答：公司在一段时间里获得多少收入、付出多少成本，最后产生多少利润？'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('主要项目', '营业收入、毛利润、营业利润、净利润、每股收益'),
        ]),
        TutorialContentBlock.heading('资产负债表'),
        TutorialContentBlock.paragraph('资产负债表回答：在某个时间点，公司拥有什么、欠了什么，股东权益是多少？'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('主要项目', '现金、存货、应收账款、总资产、短期和长期债务、股东权益'),
        ]),
        TutorialContentBlock.heading('现金流量表'),
        TutorialContentBlock.paragraph('现金流量表回答：公司的现金从哪里来，又流向哪里？'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('现金流分类', '经营活动现金流、投资活动现金流、融资活动现金流'),
        ]),
        TutorialContentBlock.heading('为什么三张报表要一起看'),
        TutorialContentBlock.example(
          '利润表显示盈利，但应收账款大幅增加、经营现金流很弱、债务不断上升，则公司的盈利质量可能没有表面上那么好。',
        ),
        TutorialContentBlock.note(
          '利润表：公司是否赚钱\n资产负债表：财务基础是否稳健\n现金流量表：利润是否真正转化成现金',
        ),
      ],
    ),
    TutorialTopicData(
      id: 'quality-of-growth',
      sequence: '07',
      title: '增长是否健康、利润是否真实',
      content: [
        TutorialContentBlock.heading('收入增长来自哪里'),
        TutorialContentBlock.paragraph(
          '收入增长可能来自销量增加、产品涨价、新产品、新市场、收购其他公司或汇率变化。',
        ),
        TutorialContentBlock.example('公司收入增长 20%，但增长全部来自收购另一家公司，原有业务可能没有增长。'),
        TutorialContentBlock.heading('利润增长是否可持续'),
        TutorialContentBlock.paragraph(
          '利润增长可能来自正常经营改善，也可能来自出售资产、一次性补贴、减少研发、裁员降本、会计估计变化或税务收益。',
        ),
        TutorialContentBlock.note('一次性因素可能使某一年利润很好看，但通常不能长期重复。'),
        TutorialContentBlock.heading('每股收益、股数与稀释'),
        TutorialContentBlock.paragraph(
          '如果公司大量发行新股，公司总利润可能增加，但股票数量也增加，每股收益可能增长很少，甚至下降。',
        ),
        TutorialContentBlock.paragraph('股权稀释是指新增股票使现有股东持股比例和每股对应权益下降。'),
        TutorialContentBlock.paragraph('股票回购可能减少股票数量、提高每股对应权益，但前提是回购价格合理。'),
        TutorialContentBlock.heading('健康增长通常是什么样'),
        TutorialContentBlock.paragraph(
          '收入持续增长、利润率稳定或改善、经营现金流与利润相匹配、债务没有失控、每股收益同步增长，并且不依赖长期大量烧钱维持增长。',
        ),
      ],
    ),
    TutorialTopicData(
      id: 'good-company-good-stock',
      sequence: '08',
      title: '好公司为什么不一定是好股票',
      content: [
        TutorialContentBlock.paragraph('一家优秀公司可能有好产品、强品牌、高增长、稳定利润和优秀管理层。'),
        TutorialContentBlock.paragraph('但如果股票价格已经包含极其乐观的预期，投资回报仍可能不好。'),
        TutorialContentBlock.heading('价格和价值的区别'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('公司经营质量', '回答：这家公司好不好？'),
          TutorialFormulaRow('估值', '回答：以当前价格购买是否合理？'),
        ]),
        TutorialContentBlock.example(
          '市场预期公司利润增长 50%，股价因此已经很高。公司最终利润增长 30%，经营表现仍然不错，但低于原有预期，股价可能下跌。',
        ),
        TutorialContentBlock.heading('PE 和 PB 怎么用'),
        TutorialContentBlock.paragraph(
          'PE（市盈率）比较市场价格与利润，PB（市净率）比较市场价格与净资产。基本面分析中，还需要结合公司增长、行业特点、风险、盈利稳定性、利润质量和市场预期。',
        ),
        TutorialContentBlock.note('好公司不一定是好投资：好公司 + 过高价格，不一定是好投资。'),
        TutorialContentBlock.note(
          '普通公司 + 极低价格，也不一定是坏投资。投资结果同时取决于公司未来表现和买入时支付的价格。',
        ),
      ],
    ),
    TutorialTopicData(
      id: 'financial-report-warning-signs',
      sequence: '09',
      title: '阅读财报时要警惕什么',
      content: [
        TutorialContentBlock.paragraph('阅读财报不是寻找一个完美数字，而是检查各项信息是否彼此一致。'),
        TutorialContentBlock.heading('常见风险信号'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('应收账款增长快于收入', '可能表示客户付款速度变慢，或公司放宽信用条件。'),
          TutorialFormulaRow('存货增长快于销售', '可能是提前备货，也可能是产品卖不出去或需求低于预期。'),
          TutorialFormulaRow('净利润增长但经营现金流恶化', '可能说明利润尚未真正转化成现金。'),
          TutorialFormulaRow('债务持续快速上升', '需要检查借款用途、利率、到期时间和偿还能力。'),
          TutorialFormulaRow('依赖一次性收益', '例如出售资产使净利润突然增加，但主营业务没有改善。'),
          TutorialFormulaRow('持续发行新股', '可能帮助融资，也可能稀释持股比例和每股收益。'),
          TutorialFormulaRow('只强调调整后利润', '如果每年都排除大量所谓特殊项目，需要判断这些项目是否真的特殊。'),
        ]),
        TutorialContentBlock.heading('还可以看哪些信息'),
        TutorialContentBlock.paragraph('公司公告、管理层电话会议、行业数据、竞争对手表现、风险披露和审计意见。'),
        TutorialContentBlock.heading('零基础阅读顺序'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('1', '公司靠什么赚钱'),
          TutorialFormulaRow('2', '收入和利润是否增长'),
          TutorialFormulaRow('3', '利润率是否稳定'),
          TutorialFormulaRow('4', '利润是否转化成现金'),
          TutorialFormulaRow('5', '资产和债务是否健康'),
          TutorialFormulaRow('6', '增长是否可持续'),
          TutorialFormulaRow('7', '当前估值是否已经过高'),
        ]),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const TutorialModuleDetailPage(
      title: '公司与基本面分析',
      topics: topics,
      listKey: ValueKey('fundamental-analysis-topic-list'),
    );
  }
}
