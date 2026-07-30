import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';

enum TutorialContentBlockType {
  heading,
  paragraph,
  example,
  note,
  formula,
  custom,
}

class TutorialContentBlock {
  const TutorialContentBlock.heading(this.text)
    : type = TutorialContentBlockType.heading,
      rows = const [],
      child = null;

  const TutorialContentBlock.paragraph(this.text)
    : type = TutorialContentBlockType.paragraph,
      rows = const [],
      child = null;

  const TutorialContentBlock.example(this.text)
    : type = TutorialContentBlockType.example,
      rows = const [],
      child = null;

  const TutorialContentBlock.note(this.text)
    : type = TutorialContentBlockType.note,
      rows = const [],
      child = null;

  const TutorialContentBlock.formula(this.rows)
    : type = TutorialContentBlockType.formula,
      text = null,
      child = null;

  const TutorialContentBlock.custom(this.child)
    : type = TutorialContentBlockType.custom,
      text = null,
      rows = const [];

  final TutorialContentBlockType type;
  final String? text;
  final List<TutorialFormulaRow> rows;
  final Widget? child;
}

class TutorialFormulaRow {
  const TutorialFormulaRow(this.label, this.value);

  final String label;
  final String value;
}

class TutorialTopicData {
  const TutorialTopicData({
    required this.id,
    required this.sequence,
    required this.title,
    required this.content,
  });

  final String id;
  final String sequence;
  final String title;
  final List<TutorialContentBlock> content;
}

class TutorialModuleDetailPage extends StatefulWidget {
  const TutorialModuleDetailPage({
    required this.title,
    required this.topics,
    this.listKey,
    super.key,
  });

  final String title;
  final List<TutorialTopicData> topics;
  final Key? listKey;

  @override
  State<TutorialModuleDetailPage> createState() =>
      _TutorialModuleDetailPageState();
}

class _TutorialModuleDetailPageState extends State<TutorialModuleDetailPage> {
  String? _expandedTopicId;

  void _toggleTopic(String id) {
    setState(() {
      _expandedTopicId = _expandedTopicId == id ? null : id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return Scaffold(
      backgroundColor: palette.pageBackground,
      appBar: AppBar(
        backgroundColor: palette.pageBackground,
        foregroundColor: palette.primaryText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedPageWrapper(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SingleChildScrollView(
                key: widget.listKey,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < widget.topics.length;
                      index++
                    ) ...[
                      TutorialTopicRow(
                        topic: widget.topics[index],
                        expanded: _expandedTopicId == widget.topics[index].id,
                        onTap: () => _toggleTopic(widget.topics[index].id),
                      ),
                      if (index != widget.topics.length - 1)
                        const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TutorialTopicRow extends StatelessWidget {
  const TutorialTopicRow({
    required this.topic,
    required this.expanded,
    required this.onTap,
    super.key,
  });

  final TutorialTopicData topic;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Material(
      color: palette.cardBackground,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('tutorial-topic-${topic.id}'),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: palette.divider),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        topic.sequence,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: palette.secondaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        topic.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: palette.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: palette.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: expanded
                    ? Container(
                        key: ValueKey('tutorial-topic-content-${topic.id}'),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: palette.divider),
                          ),
                        ),
                        child: TutorialTopicContent(blocks: topic.content),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TutorialTopicContent extends StatelessWidget {
  const TutorialTopicContent({required this.blocks, super.key});

  final List<TutorialContentBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < blocks.length; index++) ...[
          TutorialContentBlockView(block: blocks[index]),
          if (index != blocks.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class TutorialContentBlockView extends StatelessWidget {
  const TutorialContentBlockView({required this.block, super.key});

  final TutorialContentBlock block;

  @override
  Widget build(BuildContext context) {
    return switch (block.type) {
      TutorialContentBlockType.heading => _SectionHeading(block.text!),
      TutorialContentBlockType.paragraph => _BodyParagraph(block.text!),
      TutorialContentBlockType.example => _CalloutBox(
        text: block.text!,
        icon: Icons.lightbulb_outline_rounded,
      ),
      TutorialContentBlockType.note => _CalloutBox(
        text: block.text!,
        icon: Icons.info_outline_rounded,
        subtle: true,
      ),
      TutorialContentBlockType.formula => _FormulaRows(block.rows),
      TutorialContentBlockType.custom => block.child!,
    };
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        color: palette.primaryText,
        fontWeight: FontWeight.w800,
        height: 1.35,
      ),
    );
  }
}

class _BodyParagraph extends StatelessWidget {
  const _BodyParagraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: palette.secondaryText,
        height: 1.58,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _CalloutBox extends StatelessWidget {
  const _CalloutBox({
    required this.text,
    required this.icon,
    this.subtle = false,
  });

  final String text;
  final IconData icon;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;
    final background = subtle
        ? palette.searchBackground.withValues(alpha: 0.72)
        : palette.segmentBackground.withValues(alpha: 0.72);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: palette.primaryText, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.primaryText,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaRows extends StatelessWidget {
  const _FormulaRows(this.rows);

  final List<TutorialFormulaRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Container(
      decoration: BoxDecoration(
        color: palette.searchBackground.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 86,
                    child: Text(
                      rows[index].label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.primaryText,
                        fontWeight: FontWeight.w800,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      rows[index].value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.secondaryText,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (index != rows.length - 1)
              Divider(height: 1, thickness: 1, color: palette.divider),
          ],
        ],
      ),
    );
  }
}
