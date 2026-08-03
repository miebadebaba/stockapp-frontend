import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import 'market_snapshot_api.dart';
import 'market_snapshot_data.dart';
import 'widgets/market_snapshot_section.dart';

class MarketsPage extends StatefulWidget {
  const MarketsPage({
    super.key,
    this.initialData,
  });

  final MarketSnapshotOverviewData? initialData;

  @override
  State<MarketsPage> createState() => _MarketsPageState();
}

class _MarketsPageState extends State<MarketsPage> {
  late final Future<MarketSnapshotOverviewData> _overviewFuture;

  @override
  void initState() {
    super.initState();
    _overviewFuture =
        widget.initialData == null
            ? const MarketSnapshotApi().fetchOverview()
            : Future.value(widget.initialData);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Scaffold(
      backgroundColor: palette.pageBackground,
      body: ColoredBox(
        color: palette.pageBackground,
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: FutureBuilder<MarketSnapshotOverviewData>(
                future: _overviewFuture,
                builder: (context, snapshot) {
                  final overview = snapshot.data;
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            AnimatedPageWrapper(
                              child: _MarketsHeader(
                                onBackTap:
                                    () => Navigator.of(context).maybePop(),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            AnimatedPageWrapper(
                              delay: const Duration(milliseconds: 40),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Markets',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontSize: 36,
                                            height: 1.06,
                                            color: palette.primaryText,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Live A-share index snapshots from PandaAI, using the same sparkline language from home.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: palette.secondaryText,
                                            height: 1.45,
                                            fontSize: 16,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            if (overview != null && overview.groups.isNotEmpty)
                              for (var i = 0; i < overview.groups.length; i++) ...[
                                AnimatedPageWrapper(
                                  delay: Duration(milliseconds: 80 + i * 40),
                                  child: _MarketGroupSection(
                                    group: overview.groups[i],
                                  ),
                                ),
                                if (i != overview.groups.length - 1)
                                  const SizedBox(height: AppSpacing.xxl),
                              ]
                            else if (snapshot.hasError)
                              const _MarketsStatusCard(
                                message:
                                    'Live market indexes are temporarily unavailable.',
                              )
                            else
                              const _MarketsLoadingCard(),
                            const SizedBox(height: 120),
                          ]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketsLoadingCard extends StatelessWidget {
  const _MarketsLoadingCard();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return _MarketsStatusCard(
      message: 'Loading live market indexes...',
      trailing: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(palette.primaryText),
        ),
      ),
    );
  }
}

class _MarketsStatusCard extends StatelessWidget {
  const _MarketsStatusCard({
    required this.message,
    this.trailing,
  });

  final String message;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: palette.groupBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: palette.secondaryText,
                height: 1.45,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _MarketsHeader extends StatelessWidget {
  const _MarketsHeader({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: palette.groupBackground,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: onBackTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: palette.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketGroupSection extends StatelessWidget {
  const _MarketGroupSection({required this.group});

  final MarketSnapshotGroupData group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            group.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: palette.secondaryText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: palette.pageBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: palette.divider.withValues(alpha: 0.72),
            ),
          ),
          child: GridView.builder(
            itemCount: group.items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 146,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemBuilder: (context, index) {
              final item = group.items[index];
              final isLeftColumn = index.isEven;
              final itemsInLastRow = group.items.length.isEven ? 2 : 1;
              final isLastRow = index >= group.items.length - itemsInLastRow;
              return _MarketsDetailCard(
                item: item,
                isLeftColumn: isLeftColumn,
                isLastRow: isLastRow,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MarketsDetailCard extends StatelessWidget {
  const _MarketsDetailCard({
    required this.item,
    required this.isLeftColumn,
    required this.isLastRow,
  });

  final MarketSnapshotItemData item;
  final bool isLeftColumn;
  final bool isLastRow;

  Color get _trendColor {
    return item.changePercent >= 0
        ? const Color(0xFFE3515A)
        : const Color(0xFF2C9D69);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;
    final borderColor = palette.divider.withValues(alpha: 0.72);

    return Container(
      decoration: BoxDecoration(
        color: palette.pageBackground,
        border: Border(
          right: isLeftColumn
              ? BorderSide(color: borderColor, width: 1)
              : BorderSide.none,
          bottom: isLastRow
              ? BorderSide.none
              : BorderSide(color: borderColor, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.assetName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.valueText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: palette.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          Row(
            children: [
              Icon(
                item.changePercent >= 0
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 16,
                color: _trendColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.changePercent >= 0 ? '+' : ''}${item.changePercent.toStringAsFixed(2)}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _trendColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 72,
                height: 28,
                child: CustomPaint(
                  painter: _MarketsSparklinePainter(
                    values: item.sparklineValues,
                    lineColor: _trendColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarketsSparklinePainter extends CustomPainter {
  const _MarketsSparklinePainter({
    required this.values,
    required this.lineColor,
  });

  final List<double> values;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final span = math.max(maxValue - minValue, 1.0);

    final points = List<Offset>.generate(values.length, (index) {
      final x = size.width * index / math.max(values.length - 1, 1);
      final normalized = (values[index] - minValue) / span;
      final y = size.height - normalized * size.height;
      return Offset(x, y);
    });

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final midX = (current.dx + next.dx) / 2;
      path.cubicTo(midX, current.dy, midX, next.dy, next.dx, next.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = lineColor,
    );
  }

  @override
  bool shouldRepaint(covariant _MarketsSparklinePainter oldDelegate) {
    if (lineColor != oldDelegate.lineColor ||
        values.length != oldDelegate.values.length) {
      return true;
    }

    for (var i = 0; i < values.length; i++) {
      if (values[i] != oldDelegate.values[i]) {
        return true;
      }
    }

    return false;
  }
}
