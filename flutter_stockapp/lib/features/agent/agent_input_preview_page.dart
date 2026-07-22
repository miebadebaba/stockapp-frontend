import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
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
                          headlineText:
                              'Welcome back. What would you like to build next?',
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
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Text(
                                _lastAction,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: const Color(0xB7333740),
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

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: content,
    );
  }
}

class _PreviewBackdrop extends StatelessWidget {
  const _PreviewBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgPrimary,
            AppColors.bgGradientLavenderStart,
            AppColors.bgGradientLavenderEnd,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: const [
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
          _GridSheen(),
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
  const _GridSheen();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.18),
              Colors.white.withValues(alpha: 0),
            ],
          ),
        ),
        child: CustomPaint(
          painter: _GridSheenPainter(),
        ),
      ),
    );
  }
}

class _GridSheenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111114).withValues(alpha: 0.035)
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
