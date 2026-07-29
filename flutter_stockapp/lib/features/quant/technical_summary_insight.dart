enum TechnicalSummaryInsightState {
  upwardAligned,
  downwardAligned,
  divergent,
  unavailable,
}

class TechnicalSummaryInsight {
  const TechnicalSummaryInsight({
    required this.state,
    required this.title,
    required this.overview,
    required this.trendText,
    required this.momentumText,
    required this.strengthText,
    required this.participationText,
    required this.consistencyText,
    required this.riskMessages,
    required this.riskNotice,
  });

  final TechnicalSummaryInsightState state;
  final String title;
  final String overview;
  final String trendText;
  final String momentumText;
  final String strengthText;
  final String participationText;
  final String consistencyText;
  final List<String> riskMessages;
  final String riskNotice;
}
