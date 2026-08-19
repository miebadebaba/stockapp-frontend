const quantChartScaleWidth = 66.0;

double quantChartXForIndex({
  required int index,
  required int itemCount,
  required double width,
}) {
  if (itemCount <= 0 || width <= 0) {
    return 0;
  }

  final safeIndex = index.clamp(0, itemCount - 1);
  final slotWidth = width / itemCount;
  return slotWidth * safeIndex + slotWidth / 2;
}

int quantChartIndexForX({
  required double x,
  required int itemCount,
  required double width,
}) {
  if (itemCount <= 0 || width <= 0) {
    return -1;
  }

  final slotWidth = width / itemCount;
  return (x.clamp(0.0, width) / slotWidth).floor().clamp(0, itemCount - 1);
}
