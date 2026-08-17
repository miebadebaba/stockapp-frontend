import 'package:flutter_stockapp/features/quant/quant_factor_ic_dashboard.dart';
import 'package:flutter_stockapp/features/quant/quant_factor_ic_response_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps backend IC response to dashboard result', () {
    final result = mapQuantFactorIcAnalysisResponse({
      'market': 'united_states',
      'symbols': ['AAPL', 'MSFT', 'NVDA'],
      'history_limit': 120,
      'holding_period': 5,
      'minimum_lookback': 35,
      'minimum_sample_size': 3,
      'factor_results': [
        {
          'factor_id': 'trend',
          'periods': [
            {
              'date': '2026-01-05',
              'sample_size': 3,
              'information_coefficient': 0.4,
              'rank_information_coefficient': 0.5,
            },
            {
              'date': '2026-01-06',
              'sample_size': 3,
              'information_coefficient': 0.2,
              'rank_information_coefficient': 0.3,
            },
          ],
          'available_period_count': 2,
          'average_information_coefficient': 0.3,
          'average_rank_information_coefficient': 0.4,
          'positive_information_coefficient_rate': 1.0,
          'positive_rank_information_coefficient_rate': 1.0,
          'ic_information_ratio': 2.12,
          'rank_ic_information_ratio': 2.83,
          'average_sample_size': 3.0,
          'reliability': 'insufficient',
        },
      ],
    });

    expect(result.status, QuantFactorIcDashboardStatus.available);
    expect(result.realStockCount, 3);

    final trend = result.resultFor('trend');

    expect(trend, isNotNull);
    expect(trend!.periods, hasLength(2));
    expect(trend.periods.first.date, DateTime(2026, 1, 5));
    expect(trend.periods.first.sampleSize, 3);
    expect(trend.averageInformationCoefficient, closeTo(0.3, 0.000001));
    expect(trend.averageRankInformationCoefficient, closeTo(0.4, 0.000001));
    expect(trend.positiveInformationCoefficientRate, 1.0);
  });

  test('rejects malformed factor periods', () {
    expect(
      () => mapQuantFactorIcAnalysisResponse({
        'symbols': ['AAPL', 'MSFT', 'NVDA'],
        'factor_results': [
          {
            'factor_id': 'trend',
            'periods': [
              {
                'date': 'invalid-date',
                'sample_size': 3,
                'information_coefficient': 0.4,
                'rank_information_coefficient': 0.5,
              },
            ],
          },
        ],
      }),
      throwsFormatException,
    );
  });
}
