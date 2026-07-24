enum MovingAverageInsightState { positive, neutral, cautious, unavailable }

class MovingAverageInsight {
  const MovingAverageInsight({
    required this.state,
    required this.title,
    required this.explanation,
    required this.riskNotice,
  });

  final MovingAverageInsightState state;
  final String title;
  final String explanation;
  final String riskNotice;
}
