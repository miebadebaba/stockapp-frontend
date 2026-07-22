import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import 'widgets/agent_input_card.dart';

class AgentInputPreviewPage extends StatefulWidget {
  const AgentInputPreviewPage({
    this.embedInScaffold = true,
    this.animateHeadline = false,
    this.onHeadlineAnimationCompleted,
    super.key,
  });

  final bool embedInScaffold;
  final bool animateHeadline;
  final VoidCallback? onHeadlineAnimationCompleted;

  @override
  State<AgentInputPreviewPage> createState() => _AgentInputPreviewPageState();
}

class _AgentInputPreviewPageState extends State<AgentInputPreviewPage> {
  String _lastAction = 'Preview ready';

  void _setLastAction(String value) {
    setState(() => _lastAction = value);
  }

  void _showInteraction(String label) {
    _setLastAction(label);
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xCC111827),
          content: Text(label),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = AnimatedPageWrapper(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _PreviewBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final topPadding = widget.embedInScaffold ? 36.0 : 108.0;
                final bottomPadding = widget.embedInScaffold ? 36.0 : 132.0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    topPadding,
                    20,
                    bottomPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight - topPadding - bottomPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AgentInputCard(
                          animateHeadline: widget.animateHeadline,
                          statusText: 'Pro plan active',
                          statusActionLabel: 'Upgrade',
                          headlineText: 'Welcome back. What would you like to build next?',
                          placeholderText: 'How can I help you today?',
                          modelLabel: 'GPT-5 Pro / Balanced',
                          onSend: (text) =>
                              _showInteraction('Send pressed: "$text"'),
                          onAttachTap: () =>
                              _showInteraction('Attach action tapped'),
                          onModelTap: () =>
                              _showInteraction('Model selector tapped'),
                          onMicTap: () =>
                              _showInteraction('Microphone action tapped'),
                          onVoiceTap: () =>
                              _showInteraction('Voice mode tapped'),
                          onStatusTap: () =>
                              _showInteraction('Upgrade action tapped'),
                          onHeadlineAnimationCompleted:
                              widget.onHeadlineAnimationCompleted,
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? palette.groupBackground.withValues(
                                        alpha: 0.74,
                                      )
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.14)
                                      : Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Text(
                                _lastAction,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: isDark
                                          ? palette.secondaryText
                                          : const Color(0xB7333740),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (!widget.embedInScaffold) {
      return content;
    }

    return Scaffold(backgroundColor: palette.pageBackground, body: content);
  }
}

class _PreviewBackdrop extends StatelessWidget {
  const _PreviewBackdrop();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF020305), Color(0xFF0B1320), Color(0xFF111A2A)]
              : const [
                  AppColors.bgPrimary,
                  AppColors.bgGradientLavenderStart,
                  AppColors.bgGradientLavenderEnd,
                ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isDark) ...const [
            _BlurredOrb(
              alignment: Alignment(-0.92, -0.88),
              diameter: 260,
              colors: [Color(0x2048C8FF), Color(0x0048C8FF)],
            ),
            _BlurredOrb(
              alignment: Alignment(0.95, -0.72),
              diameter: 300,
              colors: [Color(0x1A6EE7FF), Color(0x006EE7FF)],
            ),
            _BlurredOrb(
              alignment: Alignment(0.08, -0.16),
              diameter: 420,
              colors: [Color(0x12FFFFFF), Color(0x00FFFFFF)],
            ),
            _BlurredOrb(
              alignment: Alignment(-0.55, 0.62),
              diameter: 280,
              colors: [Color(0x1648C8FF), Color(0x0048C8FF)],
            ),
          ] else ...const [
            _BlurredOrb(
              alignment: Alignment(-0.92, -0.88),
              diameter: 260,
              colors: [Color(0x44BEEFF3), Color(0x00BEEFF3)],
            ),
            _BlurredOrb(
              alignment: Alignment(0.95, -0.72),
              diameter: 300,
              colors: [Color(0x2CB6A7FF), Color(0x00B6A7FF)],
            ),
            _BlurredOrb(
              alignment: Alignment(0.08, -0.16),
              diameter: 420,
              colors: [Color(0x40FFFFFF), Color(0x00FFFFFF)],
            ),
            _BlurredOrb(
              alignment: Alignment(-0.55, 0.62),
              diameter: 280,
              colors: [Color(0x26C6E8F7), Color(0x00C6E8F7)],
            ),
          ],
          _GridSheen(
            lineColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFF111114).withValues(alpha: 0.035),
            fadeColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.18),
            baseColor: palette.pageBackground,
          ),
        ],
      ),
    );
  }
}

class _BlurredOrb extends StatelessWidget {
  const _BlurredOrb({
    required this.alignment,
    required this.diameter,
    required this.colors,
  });

  final Alignment alignment;
  final double diameter;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: colors),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridSheen extends StatelessWidget {
  const _GridSheen({
    required this.lineColor,
    required this.fadeColor,
    required this.baseColor,
  });

  final Color lineColor;
  final Color fadeColor;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [fadeColor, baseColor.withValues(alpha: 0)],
          ),
        ),
        child: CustomPaint(painter: _GridSheenPainter(lineColor: lineColor)),
      ),
    );
  }
}

class _GridSheenPainter extends CustomPainter {
  const _GridSheenPainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    const spacing = 42.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridSheenPainter oldDelegate) {
    return lineColor != oldDelegate.lineColor;
  }
}
