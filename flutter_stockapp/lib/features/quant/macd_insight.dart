enum MacdInsightState { positive, neutral, cautious, unavailable }

class MacdInsight {
  const MacdInsight({
    required this.state,
    required this.title,
    required this.explanation,
    required this.riskNotice,
  });

  final MacdInsightState state;
  final String title;
  final String explanation;
  final String riskNotice;
}
