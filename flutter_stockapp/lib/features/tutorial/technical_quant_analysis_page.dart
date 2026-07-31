import 'package:flutter/material.dart';

import 'tutorial_module_detail_page.dart';
import 'widgets/technical_indicator_diagrams.dart';

class TechnicalQuantAnalysisPage extends StatelessWidget {
  const TechnicalQuantAnalysisPage({super.key});

  static const topics = [
    TutorialTopicData(
      id: 'indicator-factor-signal-strategy',
      sequence: '01',
      title: '技术分析、技术指标、因子与策略有什么区别',
      content: [
        TutorialContentBlock.paragraph(
          '技术分析主要研究历史和当前市场数据，例如价格、成交量、波动和趋势。它试图根据过去和当前的市场表现，描述市场目前处于什么状态。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow('基本面分析', '主要研究公司经营、利润、资产、现金流和估值。'),
          TutorialFormulaRow('技术分析', '主要研究价格和交易行为。'),
        ]),
        TutorialContentBlock.heading('技术指标'),
        TutorialContentBlock.paragraph(
          '技术指标是根据价格、成交量等市场数据计算出来的数字或曲线，例如 MA 移动平均线、MACD 指数平滑异同移动平均线、RSI 相对强弱指标、VWAP 成交量加权平均价格和成交量均值。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow(
            '流程',
            '历史价格或成交量 → 根据公式处理 → 得到指标数值或曲线 → 帮助描述趋势、动量、波动或交易活跃度',
          ),
        ]),
        TutorialContentBlock.heading('因子'),
        TutorialContentBlock.paragraph('因子是量化分析中用于描述股票某种特征的变量。'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('动量因子', '股票过去上涨或下跌的程度。'),
          TutorialFormulaRow('价值因子', '股票估值相对较高还是较低。'),
          TutorialFormulaRow('波动率因子', '价格波动是否剧烈。'),
          TutorialFormulaRow('质量因子', '盈利和财务状况是否较好。'),
          TutorialFormulaRow('流动性因子', '股票是否容易交易。'),
        ]),
        TutorialContentBlock.paragraph(
          '技术指标可以被设计成因子，但因子不只来自技术指标，也可以来自财务报表、公司估值、新闻、分析师预测和宏观经济数据。',
        ),
        TutorialContentBlock.heading('信号'),
        TutorialContentBlock.paragraph(
          '信号是根据指标或因子形成的判断结果，例如短期均线上穿长期均线、RSI 高于某个参考区间，或当前价格高于 VWAP。',
        ),
        TutorialContentBlock.note('信号只是某个规则产生的结果，不是必然正确的预测。'),
        TutorialContentBlock.heading('策略'),
        TutorialContentBlock.paragraph('策略是一套完整的交易规则，需要把信号、交易规则和风险管理组合起来。'),
        TutorialContentBlock.example(
          '当短期均线上穿长期均线时买入；当短期均线下穿长期均线时卖出；每次最多投入总资金的 10%；出现特定亏损条件时退出。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow(
            '策略需要包含',
            '什么时候买、什么时候卖、买多少、如何控制风险、如何计算费用、如何处理无法成交。',
          ),
        ]),
        TutorialContentBlock.note(
          '技术指标：描述市场数据\n因子：描述股票特征\n信号：根据指标或因子形成判断\n策略：把信号、交易规则和风险管理组合起来',
        ),
        TutorialContentBlock.note('指标本身不是自动赚钱的方法。即使某个指标过去有效，也不代表未来一定继续有效。'),
      ],
    ),
    TutorialTopicData(
      id: 'ma-trend',
      sequence: '02',
      title: '移动平均线 MA 与趋势',
      content: [
        TutorialContentBlock.paragraph(
          'MA 是 Moving Average，中文为移动平均线。移动平均线计算过去一段时间的平均价格，用来减少短期价格噪声，使趋势更容易观察。',
        ),
        TutorialContentBlock.example(
          '过去 5 个交易日收盘价：¥10、¥11、¥12、¥11、¥13\n5 日移动平均线：(10 + 11 + 12 + 11 + 13) ÷ 5 = ¥11.4',
        ),
        TutorialContentBlock.paragraph(
          '下一交易日计算时，会加入最新价格、删除最早价格，并重新计算平均值，因此平均线会随时间移动。',
        ),
        TutorialContentBlock.heading('常见周期'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('5 日、10 日', '较短期。'),
          TutorialFormulaRow('20 日', '大致一个交易月。'),
          TutorialFormulaRow('60 日', '中期观察。'),
          TutorialFormulaRow('120 日、250 日', '较长期观察。'),
        ]),
        TutorialContentBlock.heading('周期差异'),
        TutorialContentBlock.paragraph('短周期均线对价格变化更敏感，反应更快，也更容易受短期噪声影响。'),
        TutorialContentBlock.paragraph('长周期均线更平滑，反应较慢，可能在趋势发生一段时间后才改变。'),
        TutorialContentBlock.heading('金叉和死叉'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('金叉', '短期均线上穿长期均线。'),
          TutorialFormulaRow('死叉', '短期均线下穿长期均线。'),
        ]),
        TutorialContentBlock.note('金叉不等于一定上涨。死叉不等于一定下跌。均线来自历史价格，具有滞后性。'),
        TutorialContentBlock.paragraph(
          '均线适合观察当前价格相对过去平均水平偏高还是偏低、市场近期大致方向，以及短期趋势与长期趋势是否一致。',
        ),
        TutorialContentBlock.custom(MaTrendDiagram()),
      ],
    ),
    TutorialTopicData(
      id: 'macd',
      sequence: '03',
      title: 'MACD 是什么',
      content: [
        TutorialContentBlock.paragraph(
          'MACD 是 Moving Average Convergence Divergence，中文通常称为指数平滑异同移动平均线。它的核心思想是比较较快的价格趋势与较慢的价格趋势，观察当前动量是在增强还是减弱。',
        ),
        TutorialContentBlock.heading('DIF 线'),
        TutorialContentBlock.paragraph(
          'DIF 通常由短期指数移动平均线与长期指数移动平均线之差得到。常见设置可能比较 12 日 EMA 和 26 日 EMA。EMA 是指数移动平均线，会给予较新的价格更高权重。',
        ),
        TutorialContentBlock.heading('DEA 或信号线'),
        TutorialContentBlock.paragraph(
          'DEA 是对 DIF 的进一步平滑。DIF 与 DEA 的相对位置变化，常被用于观察短期动量变化。',
        ),
        TutorialContentBlock.heading('柱状图'),
        TutorialContentBlock.paragraph(
          '柱状图通常表示 DIF 与 DEA 之间的差距。柱体扩大表示差距增加，柱体缩小表示两条线逐渐靠近。',
        ),
        TutorialContentBlock.paragraph(
          'MACD 可以帮助观察趋势方向、短期动量、动量是否增强，以及动量是否开始减弱。',
        ),
        TutorialContentBlock.note(
          'MACD 由历史价格计算而来，因此具有滞后性。上涨已经发生后 MACD 才转强、震荡行情中反复交叉、不同参数产生不同结果，都是可能出现的情况。',
        ),
        TutorialContentBlock.note(
          '不要把 DIF 上穿 DEA 写成必然买入信号，也不要把 DIF 下穿 DEA 写成必然卖出信号。',
        ),
        TutorialContentBlock.custom(MacdDiagram()),
      ],
    ),
    TutorialTopicData(
      id: 'rsi',
      sequence: '04',
      title: 'RSI 与超买、超卖',
      content: [
        TutorialContentBlock.paragraph(
          'RSI 是 Relative Strength Index，中文为相对强弱指标。它比较一段时间内上涨和下跌的相对强度，数值通常位于 0 到 100 之间。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow('RSI 较高', '近期上涨动量较强。'),
          TutorialFormulaRow('RSI 较低', '近期下跌动量较强。'),
          TutorialFormulaRow('70', '部分平台将 RSI 高于 70 视为可能处于超买区域。'),
          TutorialFormulaRow('30', '部分平台将 RSI 低于 30 视为可能处于超卖区域。'),
        ]),
        TutorialContentBlock.note('超买不代表马上下跌。超卖不代表马上上涨。'),
        TutorialContentBlock.paragraph(
          '更准确地说，超买或超卖说明价格近期向某个方向移动得较强，可能已经出现较明显的延伸，需要结合趋势和其他信息继续观察。',
        ),
        TutorialContentBlock.paragraph(
          '强劲上涨趋势中，RSI 可能长时间维持高位；持续下跌趋势中，RSI 也可能长时间维持低位。',
        ),
        TutorialContentBlock.heading('RSI 背离'),
        TutorialContentBlock.paragraph(
          '价格创出新高但 RSI 没有同步创出新高，可能称为顶背离；价格创出新低但 RSI 没有同步创出新低，可能称为底背离。',
        ),
        TutorialContentBlock.note('背离可能提示动量减弱，但不能保证价格马上反转。'),
        TutorialContentBlock.custom(RsiDiagram()),
      ],
    ),
    TutorialTopicData(
      id: 'volume-price',
      sequence: '05',
      title: '成交量与量价关系',
      content: [
        TutorialContentBlock.paragraph(
          '模块一已经解释：成交量表示某段时间内成交了多少股，成交额表示这些交易涉及的总金额。本 Topic 进一步解释成交量相对近期水平的变化，以及它与价格走势的配合。',
        ),
        TutorialContentBlock.heading('放量、缩量与量比'),
        TutorialContentBlock.paragraph(
          '放量表示当前成交量明显高于近期可比较周期的正常成交水平。缩量表示当前成交量明显低于近期可比较周期的正常成交水平。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow('量比', '当前周期成交量 ÷ 近期平均成交量'),
          TutorialFormulaRow(
            '放量例子',
            '过去 20 日平均成交量 100 万股，今天 180 万股，量比 180 ÷ 100 = 1.8。',
          ),
          TutorialFormulaRow(
            '缩量例子',
            '过去 20 日平均成交量 100 万股，今天 60 万股，量比 60 ÷ 100 = 0.6。',
          ),
        ]),
        TutorialContentBlock.note(
          '放量和缩量是相对概念，不由某个固定的成交股数决定，也不存在适用于所有股票的统一绝对阈值。',
        ),
        TutorialContentBlock.paragraph(
          '比较周期会影响结果。与过去 5 日、20 日或 60 日平均比较，可能得到不同判断。盘中不能直接与完整交易日比较，例如上午 10 点的累计成交量不能直接与过去完整一天的日均成交量比较。',
        ),
        TutorialContentBlock.note(
          '盘中判断应与过去相同时间点比较，或使用经过交易时间调整的量比数据。不同股票正常成交量差别很大，应比较同一只股票自己的历史水平。',
        ),
        TutorialContentBlock.heading('常见量价组合'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('放量上涨', '价格上涨且成交量明显高于近期水平，不代表之后一定继续上涨。'),
          TutorialFormulaRow('放量下跌', '价格下跌且成交量增加，可能表示卖方急于退出或市场分歧加大。'),
          TutorialFormulaRow('缩量上涨', '价格上涨但成交量较低，可能表示参与度有限，也可能是卖方供应较少。'),
          TutorialFormulaRow('缩量下跌', '价格下跌但成交量较低，可能表示抛售压力有限，也可能只是市场缺乏交易。'),
        ]),
        TutorialContentBlock.note(
          '放量不等于利好。缩量不等于利空。成交量需要结合价格、趋势、新闻、市场环境和股票流动性解释。',
        ),
        TutorialContentBlock.custom(VolumeDiagram()),
      ],
    ),
    TutorialTopicData(
      id: 'vwap',
      sequence: '06',
      title: 'VWAP 是什么',
      content: [
        TutorialContentBlock.paragraph(
          'VWAP 是 Volume Weighted Average Price，中文为成交量加权平均价格。普通平均价格会把不同价格看作同等重要，VWAP 会让成交量较大的价格占更高权重。',
        ),
        TutorialContentBlock.example(
          '在 ¥10 成交 100 股，在 ¥12 成交 900 股。简单平均价：(¥10 + ¥12) ÷ 2 = ¥11，但大部分成交发生在 ¥12。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow('VWAP', '所有“成交价格 × 成交数量”的合计 ÷ 总成交数量'),
          TutorialFormulaRow(
            '示例计算',
            '(¥10 × 100 + ¥12 × 900) ÷ (100 + 900) = ¥11.8',
          ),
        ]),
        TutorialContentBlock.paragraph(
          'VWAP 可用于观察当天大部分成交发生在哪个价格附近、当前价格相对当天成交量加权平均水平偏高还是偏低，以及大额交易执行价格是否优于市场平均水平。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow('当前价高于 VWAP', '当前价格高于当日成交量加权平均水平。'),
          TutorialFormulaRow('当前价低于 VWAP', '当前价格低于当日成交量加权平均水平。'),
        ]),
        TutorialContentBlock.note('当前价高于 VWAP 不等于必须买入。当前价低于 VWAP 不等于必须卖出。'),
        TutorialContentBlock.paragraph(
          '移动平均线主要对不同时间点的价格进行平均；VWAP 同时考虑价格和成交量，成交量越大的价格影响越大。',
        ),
        TutorialContentBlock.note('经典 VWAP 通常在每个交易日重新开始计算，但不同平台可能提供不同变体。'),
        TutorialContentBlock.custom(VwapDiagram()),
      ],
    ),
    TutorialTopicData(
      id: 'regime-conflict',
      sequence: '07',
      title: '趋势、震荡与指标冲突',
      content: [
        TutorialContentBlock.paragraph(
          '技术指标不会在所有市场环境中表现相同。使用指标前，需要先判断市场大致处于趋势行情还是震荡行情。',
        ),
        TutorialContentBlock.heading('趋势行情'),
        TutorialContentBlock.paragraph(
          '趋势行情是价格在一段时间内持续向上或向下。MA 和 MACD 等趋势类指标更容易表达方向，但可能反应较慢。',
        ),
        TutorialContentBlock.heading('震荡行情'),
        TutorialContentBlock.paragraph(
          '震荡行情是价格反复在一定范围内上下波动，没有持续方向。均线和 MACD 可能频繁产生信号，RSI 高低区间有时更适合观察短期延伸。',
        ),
        TutorialContentBlock.heading('指标冲突'),
        TutorialContentBlock.example(
          '均线显示长期趋势仍向上，MACD 显示短期动量正在减弱，RSI 处于较高区域，成交量近期逐渐下降。',
        ),
        TutorialContentBlock.paragraph(
          '这些结果不一定真正矛盾，它们可能分别描述长期趋势、短期动量、当前上涨强度和市场参与度。',
        ),
        TutorialContentBlock.formula([
          TutorialFormulaRow('1', '每个指标实际测量什么？'),
          TutorialFormulaRow('2', '不同指标使用的时间周期是否一致？'),
          TutorialFormulaRow('3', '当前市场是趋势还是震荡？'),
          TutorialFormulaRow('4', '多个指标是否只是重复使用同一份价格信息？'),
          TutorialFormulaRow('5', '是否存在公司新闻或宏观事件？'),
          TutorialFormulaRow('6', '信号是否与交易成本和风险控制相匹配？'),
        ]),
        TutorialContentBlock.note('多个指标一致，可以提高判断信心，但不能消除风险。'),
        TutorialContentBlock.custom(MarketRegimeDiagram()),
      ],
    ),
    TutorialTopicData(
      id: 'backtest',
      sequence: '08',
      title: '回测是什么，怎样判断策略是否有效',
      content: [
        TutorialContentBlock.paragraph('回测是把一套交易规则应用到历史数据中，观察这套规则在过去可能产生什么结果。'),
        TutorialContentBlock.example(
          '短期均线上穿长期均线时买入，短期均线下穿长期均线时卖出。回测系统会按照历史数据，模拟每次买入、卖出和账户变化。',
        ),
        TutorialContentBlock.note('历史回测结果不是未来收益承诺。'),
        TutorialContentBlock.heading('常见回测指标'),
        TutorialContentBlock.formula([
          TutorialFormulaRow('总收益', '策略最终赚了多少。总收益高不代表策略一定好。'),
          TutorialFormulaRow('最大回撤', '账户资产从某个高点下降到之后低点时，曾出现的最大损失比例。'),
          TutorialFormulaRow('波动与稳定性', '检查收益是否稳定，是否只靠少数幸运交易，是否出现长时间亏损。'),
          TutorialFormulaRow('胜率', '盈利交易占全部交易的比例。高胜率不等于高收益。'),
          TutorialFormulaRow('收益与风险关系', '判断为了获得收益承担了多大波动、回撤和亏损风险。'),
          TutorialFormulaRow('交易次数与样本', '交易次数太少时，结果可能只是偶然。'),
        ]),
        TutorialContentBlock.example(
          '账户从 ¥100,000 上升到 ¥120,000，之后下降到 ¥90,000。最大回撤约为 (¥120,000 − ¥90,000) ÷ ¥120,000 = 25%。',
        ),
        TutorialContentBlock.example(
          '90 次交易每次盈利 ¥1，10 次交易每次亏损 ¥20。虽然胜率为 90%，最终仍然亏损。',
        ),
        TutorialContentBlock.paragraph(
          '回测必须考虑现实成本，包括佣金、买卖价差、滑点、税费、流动性，以及订单是否真的能够成交。',
        ),
        TutorialContentBlock.note('忽略交易成本和成交限制，会让回测结果显得过度乐观。'),
        TutorialContentBlock.custom(BacktestDrawdownDiagram()),
      ],
    ),
    TutorialTopicData(
      id: 'quant-limitations',
      sequence: '09',
      title: '过拟合、未来函数与量化分析的局限',
      content: [
        TutorialContentBlock.paragraph('这是整个技术指标与量化分析模块最重要的风险提醒。'),
        TutorialContentBlock.heading('过拟合'),
        TutorialContentBlock.paragraph('过拟合表示策略过度迎合历史数据中的细节和偶然现象。'),
        TutorialContentBlock.example(
          '不断调整参数，直到历史回测表现非常好：使用 17 日均线、RSI 低于 32.7、只在星期二买入、只在某几个月份交易，或加入大量缺乏经济逻辑的条件。',
        ),
        TutorialContentBlock.note(
          '结果可能是历史回测表现很好，真实未来表现很差。策略可能只记住了过去数据，而没有找到稳定、可重复的市场规律。',
        ),
        TutorialContentBlock.paragraph(
          '减少过拟合的方法包括使用简单且有逻辑的规则、区分训练期和测试期、在未参与调参的数据上验证、检查不同年份和不同股票、避免不断调参直到结果最好，并加入合理交易成本。',
        ),
        TutorialContentBlock.heading('未来函数或前视偏差'),
        TutorialContentBlock.paragraph('未来函数表示回测不小心使用了当时尚不可能知道的信息。'),
        TutorialContentBlock.example(
          '使用当天最终收盘价，却假设可以在收盘前按这个价格下单；使用后来修订的数据，假设过去已经知道；用下一交易日信息决定今天的订单。',
        ),
        TutorialContentBlock.note('这种回测相当于偷看答案，结果没有现实意义。'),
        TutorialContentBlock.heading('幸存者偏差和数据质量'),
        TutorialContentBlock.paragraph(
          '幸存者偏差是指只测试今天仍然上市的股票，忽略历史上已经退市、破产或表现很差的公司，从而让历史结果看起来更好。',
        ),
        TutorialContentBlock.paragraph(
          '数据质量问题包括数据缺失、错误价格、股票拆分未调整、分红处理错误、时间戳不一致、不同市场交易日不同，以及使用了后来才公布的数据。',
        ),
        TutorialContentBlock.heading('技术指标的根本限制'),
        TutorialContentBlock.paragraph(
          '多数技术指标都来自历史价格和成交量。MA 依赖历史价格，MACD 依赖移动平均线，RSI 依赖近期涨跌幅，同时使用很多指标不一定获得很多独立信息。',
        ),
        TutorialContentBlock.heading('App 中 Quant 结果的正确理解'),
        TutorialContentBlock.paragraph(
          'App 的 Quant 页面可能显示 MA、MACD、RSI、成交量分析和技术总结。用户应理解为系统根据当前历史数据，对趋势、动量和交易活跃度进行结构化描述。',
        ),
        TutorialContentBlock.note(
          '不应理解为系统已经准确预测股票接下来一定上涨或下跌。量化分析可以帮助用户更有纪律地描述市场，但不能消除数据问题、市场变化、模型失效、交易成本、极端事件和未来不确定性。',
        ),
        TutorialContentBlock.custom(QuantBiasDiagram()),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const TutorialModuleDetailPage(
      title: '技术指标与量化分析',
      topics: topics,
      listKey: ValueKey('technical-quant-analysis-topic-list'),
    );
  }
}
