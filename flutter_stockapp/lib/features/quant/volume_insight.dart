enum VolumeInsightState { elevated, normal, reduced, unavailable }

class VolumeInsight {
  const VolumeInsight({
    required this.state,
    required this.title,
    required this.explanation,
    required this.riskNotice,
  });

  final VolumeInsightState state;
  final String title;
  final String explanation;
  final String riskNotice;
}
