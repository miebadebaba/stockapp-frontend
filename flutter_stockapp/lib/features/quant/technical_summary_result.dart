enum TrendState { upward, downward, mixed, unavailable }

enum MomentumState { positive, negative, mixed, unavailable }

enum StrengthState {
  overextendedHigh,
  relativelyStrong,
  balanced,
  relativelyWeak,
  overextendedLow,
  unavailable,
}

enum ParticipationState {
  confirming,
  contradicting,
  inconclusive,
  low,
  unavailable,
}

enum EvidenceConsistency { high, moderate, divergent, unavailable }

enum TechnicalRiskFlag { rsiHigh, rsiLow, priceExtended, dataInsufficient }

class TechnicalSummaryResult {
  const TechnicalSummaryResult({
    required this.trend,
    required this.momentum,
    required this.strength,
    required this.participation,
    required this.consistency,
    required this.riskFlags,
  });

  final TrendState trend;
  final MomentumState momentum;
  final StrengthState strength;
  final ParticipationState participation;
  final EvidenceConsistency consistency;
  final List<TechnicalRiskFlag> riskFlags;
}
