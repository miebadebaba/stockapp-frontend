import 'technical_summary_result.dart';

TechnicalSummaryResult mapTechnicalSummaryResponse(Map<String, dynamic> json) {
  return TechnicalSummaryResult(
    trend: _parseTrend(_readString(json, 'trend')),
    momentum: _parseMomentum(_readString(json, 'momentum')),
    strength: _parseStrength(_readString(json, 'strength')),
    participation: _parseParticipation(_readString(json, 'participation')),
    consistency: _parseConsistency(_readString(json, 'consistency')),
    riskFlags: List.unmodifiable(_parseRiskFlags(json['risk_flags'])),
  );
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is! String) {
    throw FormatException('Expected "$key" to be a string.');
  }

  return value;
}

TrendState _parseTrend(String value) {
  return switch (value) {
    'upward' => TrendState.upward,
    'downward' => TrendState.downward,
    'mixed' => TrendState.mixed,
    'insufficient_data' => TrendState.unavailable,
    _ => throw FormatException('Unknown trend state: $value'),
  };
}

MomentumState _parseMomentum(String value) {
  return switch (value) {
    'positive' => MomentumState.positive,
    'negative' => MomentumState.negative,
    'mixed' => MomentumState.mixed,
    'insufficient_data' => MomentumState.unavailable,
    _ => throw FormatException('Unknown momentum state: $value'),
  };
}

StrengthState _parseStrength(String value) {
  return switch (value) {
    'high' => StrengthState.overextendedHigh,
    'relatively_strong' => StrengthState.relativelyStrong,
    'balanced' => StrengthState.balanced,
    'relatively_weak' => StrengthState.relativelyWeak,
    'low' => StrengthState.overextendedLow,
    'insufficient_data' => StrengthState.unavailable,
    _ => throw FormatException('Unknown strength state: $value'),
  };
}

ParticipationState _parseParticipation(String value) {
  return switch (value) {
    'confirming' => ParticipationState.confirming,
    'contradicting' => ParticipationState.contradicting,
    'inconclusive' => ParticipationState.inconclusive,
    'low' => ParticipationState.low,
    'insufficient_data' => ParticipationState.unavailable,
    _ => throw FormatException('Unknown participation state: $value'),
  };
}

EvidenceConsistency _parseConsistency(String value) {
  return switch (value) {
    'high' => EvidenceConsistency.high,
    'moderate' => EvidenceConsistency.moderate,
    'divergent' => EvidenceConsistency.divergent,
    'unavailable' => EvidenceConsistency.unavailable,
    _ => throw FormatException('Unknown consistency state: $value'),
  };
}

List<TechnicalRiskFlag> _parseRiskFlags(dynamic value) {
  if (value is! List) {
    throw const FormatException('Expected "risk_flags" to be a list.');
  }

  return value
      .map((item) {
        if (item is! String) {
          throw const FormatException(
            'Expected every risk flag to be a string.',
          );
        }

        return switch (item) {
          'rsi_high' => TechnicalRiskFlag.rsiHigh,
          'rsi_low' => TechnicalRiskFlag.rsiLow,
          'price_extended' => TechnicalRiskFlag.priceExtended,
          'data_insufficient' => TechnicalRiskFlag.dataInsufficient,
          _ => throw FormatException('Unknown risk flag: $item'),
        };
      })
      .toList(growable: false);
}
