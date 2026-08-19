import 'package:flutter_stockapp/features/quant/quant_chart_timeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('quantChartXForIndex', () {
    test('places each item at the center of an equal-width slot', () {
      expect(quantChartXForIndex(index: 0, itemCount: 4, width: 200), 25);
      expect(quantChartXForIndex(index: 1, itemCount: 4, width: 200), 75);
      expect(quantChartXForIndex(index: 3, itemCount: 4, width: 200), 175);
    });
  });

  group('quantChartIndexForX', () {
    test('maps pointer positions by slot boundaries', () {
      expect(quantChartIndexForX(x: 0, itemCount: 4, width: 200), 0);
      expect(quantChartIndexForX(x: 49.9, itemCount: 4, width: 200), 0);
      expect(quantChartIndexForX(x: 50, itemCount: 4, width: 200), 1);
      expect(quantChartIndexForX(x: 200, itemCount: 4, width: 200), 3);
    });

    test('returns no index when the timeline is unavailable', () {
      expect(quantChartIndexForX(x: 0, itemCount: 0, width: 200), -1);
      expect(quantChartIndexForX(x: 0, itemCount: 4, width: 0), -1);
    });
  });
}
