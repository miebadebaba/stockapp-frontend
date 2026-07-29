enum RsiInsightState { high, neutral, low, unavailable }

class RsiInsight {
  const RsiInsight({
    required this.state,
    required this.title,
    required this.explanation,
    required this.riskNotice,
  });

  final RsiInsightState state;
  final String title;
  final String explanation;
  final String riskNotice;
}
