import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

typedef AgentSendCallback = void Function(String text);

class AgentInputCard extends StatefulWidget {
  const AgentInputCard({
    required this.placeholderText,
    required this.modelLabel,
    this.animateHeadline = false,
    this.onSend,
    this.onAttachTap,
    this.onModelTap,
    this.onMicTap,
    this.onVoiceTap,
    this.headlineText = 'Welcome back. What would you like to explore today?',
    this.statusText,
    this.statusActionLabel,
    this.onStatusTap,
    this.onHeadlineAnimationCompleted,
    this.initialText = '',
    super.key,
  });

  final String placeholderText;
  final String modelLabel;
  final bool animateHeadline;
  final AgentSendCallback? onSend;
  final VoidCallback? onAttachTap;
  final VoidCallback? onModelTap;
  final VoidCallback? onMicTap;
  final VoidCallback? onVoiceTap;
  final String headlineText;
  final String? statusText;
  final String? statusActionLabel;
  final VoidCallback? onStatusTap;
  final VoidCallback? onHeadlineAnimationCompleted;
  final String initialText;

  @override
  State<AgentInputCard> createState() => _AgentInputCardState();
}

class _AgentInputCardState extends State<AgentInputCard> {
  static const _cardRadius = 28.0;

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _typingTimer;
  var _visibleHeadlineCharacters = 0;
  var _hasFocus = false;
  var _hasInput = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
    _hasInput = widget.initialText.trim().isNotEmpty;
    _controller.addListener(_handleTextChanged);
    _syncHeadlineState(initial: true);
  }

  @override
  void didUpdateWidget(covariant AgentInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.headlineText != widget.headlineText ||
        oldWidget.animateHeadline != widget.animateHeadline) {
      _syncHeadlineState();
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (_hasFocus == _focusNode.hasFocus) {
      return;
    }
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  void _handleTextChanged() {
    final hasInput = _controller.text.trim().isNotEmpty;
    if (_hasInput == hasInput) {
      return;
    }
    setState(() => _hasInput = hasInput);
  }

  void _startHeadlineTyping() {
    _typingTimer?.cancel();
    _visibleHeadlineCharacters = 0;
    if (widget.headlineText.isEmpty) {
      widget.onHeadlineAnimationCompleted?.call();
      return;
    }

    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) {
        return;
      }

      _typingTimer = Timer.periodic(const Duration(milliseconds: 34), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_visibleHeadlineCharacters >= widget.headlineText.length) {
          timer.cancel();
          widget.onHeadlineAnimationCompleted?.call();
          return;
        }
        setState(() => _visibleHeadlineCharacters += 1);
      });
    });
  }

  void _showFullHeadline() {
    _typingTimer?.cancel();
    _visibleHeadlineCharacters = widget.headlineText.length;
  }

  void _syncHeadlineState({bool initial = false}) {
    if (widget.animateHeadline) {
      if (initial) {
        _startHeadlineTyping();
        return;
      }
      setState(_startHeadlineTyping);
      return;
    }

    if (initial) {
      _showFullHeadline();
      return;
    }
    setState(_showFullHeadline);
  }

  void _submitText() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.onSend == null) {
      return;
    }

    widget.onSend!(text);
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headline = widget.headlineText.substring(
      0,
      _visibleHeadlineCharacters.clamp(0, widget.headlineText.length),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.statusText != null || widget.statusActionLabel != null)
            _StatusPill(
              text: widget.statusText,
              actionLabel: widget.statusActionLabel,
              onTap: widget.onStatusTap,
            ),
          if (widget.statusText != null || widget.statusActionLabel != null)
            const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontFamily: 'Georgia',
                  fontFamilyFallback: const [
                    'Times New Roman',
                    'Noto Serif',
                    'Source Han Serif SC',
                  ],
                  fontSize: 38,
                  height: 1.14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEFF4FF),
                  letterSpacing: 0.2,
                ),
                children: [
                  TextSpan(text: headline),
                  TextSpan(
                    text:
                        _visibleHeadlineCharacters < widget.headlineText.length
                            ? '|'
                            : '',
                    style: const TextStyle(
                      color: Color(0x99F4F7FF),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
          const SizedBox(height: 22),
          _GlassCardShell(
            hasFocus: _hasFocus,
            borderRadius: _cardRadius,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 470;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        cursorColor: const Color(0xFFF4F7FF),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 17,
                          height: 1.45,
                          color: const Color(0xFF18212E),
                          fontWeight: FontWeight.w500,
                        ),
                        minLines: 3,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitText(),
                        onTapOutside: (_) => _focusNode.unfocus(),
                        decoration: InputDecoration(
                          hintText: widget.placeholderText,
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0x8A556070),
                            fontWeight: FontWeight.w500,
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(
                            6,
                            10,
                            6,
                            16,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: isCompact ? 10 : 0,
                          children: _buildTrailingActions(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTrailingActions() {
    return [
      _FrostedLabelButton(
        label: widget.modelLabel,
        onTap: widget.onModelTap,
      ),
      _FrostedIconButton(
        icon: Icons.add_rounded,
        tooltip: 'Attach',
        onTap: widget.onAttachTap,
      ),
      _FrostedSendButton(
        enabled: _hasInput,
        onTap: _submitText,
      ),
    ];
  }
}

class _GlassCardShell extends StatelessWidget {
  const _GlassCardShell({
    required this.child,
    required this.borderRadius,
    required this.hasFocus,
  });

  final Widget child;
  final double borderRadius;
  final bool hasFocus;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04101D).withValues(alpha: 0.28),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          if (hasFocus)
            BoxShadow(
              color: const Color(0xFF93C5FD).withValues(alpha: 0.18),
              blurRadius: 36,
              spreadRadius: 2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: hasFocus ? 0.24 : 0.13),
                width: hasFocus ? 1.2 : 0.85,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: hasFocus ? 0.28 : 0.22),
                  Colors.white.withValues(alpha: hasFocus ? 0.18 : 0.12),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.75, -0.95),
                          radius: 1.2,
                          colors: [
                            const Color(0x66FFFFFF),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0x30FFFFFF),
                            const Color(0x16FFFFFF),
                            const Color(0x16DCEEFF),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.actionLabel,
    required this.onTap,
  });

  final String? text;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF050C17).withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              if (text != null)
                Text(
                  text!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xC5D4DBE8),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              if (actionLabel != null)
                _InlineGlassLink(
                  label: actionLabel!,
                  onTap: onTap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineGlassLink extends StatefulWidget {
  const _InlineGlassLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  State<_InlineGlassLink> createState() => _InlineGlassLinkState();
}

class _InlineGlassLinkState extends State<_InlineGlassLink> {
  var _hovering = false;
  var _pressing = false;

  @override
  Widget build(BuildContext context) {
    final accent = _hovering || _pressing
        ? const Color(0xFFE8F4FF)
        : const Color(0xFFBDD8FF);

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() {
        _hovering = false;
        _pressing = false;
      }),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressing = true),
        onTapCancel: () => setState(() => _pressing = false),
        onTapUp: (_) => setState(() => _pressing = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: _pressing ? 0.96 : (_hovering ? 1.02 : 1),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _FrostedLabelButton extends StatefulWidget {
  const _FrostedLabelButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  State<_FrostedLabelButton> createState() => _FrostedLabelButtonState();
}

class _FrostedLabelButtonState extends State<_FrostedLabelButton> {
  var _hovering = false;
  var _pressing = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = _hovering || _pressing;

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() {
        _hovering = false;
        _pressing = false;
      }),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressing = true),
        onTapCancel: () => setState(() => _pressing = false),
        onTapUp: (_) => setState(() => _pressing = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _pressing ? 0.97 : (_hovering ? 1.02 : 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withValues(alpha: highlighted ? 0.28 : 0.18),
              border: Border.all(
                color: Colors.white.withValues(alpha: highlighted ? 0.34 : 0.18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF16202C),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: const Color(0xFF304156).withValues(
                    alpha: highlighted ? 1 : 0.86,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FrostedIconButton extends StatefulWidget {
  const _FrostedIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  State<_FrostedIconButton> createState() => _FrostedIconButtonState();
}

class _FrostedIconButtonState extends State<_FrostedIconButton> {
  var _hovering = false;
  var _pressing = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = _hovering || _pressing;

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() {
        _hovering = false;
        _pressing = false;
      }),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressing = true),
          onTapCancel: () => setState(() => _pressing = false),
          onTapUp: (_) => setState(() => _pressing = false),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: _pressing ? 0.94 : (_hovering ? 1.04 : 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: highlighted ? 0.28 : 0.18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: highlighted ? 0.34 : 0.18),
                ),
                boxShadow: highlighted
                    ? [
                        BoxShadow(
                          color: const Color(0xFFBFD4FF).withValues(alpha: 0.16),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                size: 21,
                color: const Color(0xFF1A2330),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FrostedSendButton extends StatefulWidget {
  const _FrostedSendButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_FrostedSendButton> createState() => _FrostedSendButtonState();
}

class _FrostedSendButtonState extends State<_FrostedSendButton> {
  var _hovering = false;
  var _pressing = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.enabled;
    final highlighted = interactive && (_hovering || _pressing);

    return MouseRegion(
      cursor: interactive
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() {
        _hovering = false;
        _pressing = false;
      }),
      child: Tooltip(
        message: 'Send',
        child: GestureDetector(
          onTap: interactive ? widget.onTap : null,
          onTapDown: interactive ? (_) => setState(() => _pressing = true) : null,
          onTapCancel: interactive ? () => setState(() => _pressing = false) : null,
          onTapUp: interactive ? (_) => setState(() => _pressing = false) : null,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: _pressing ? 0.94 : (_hovering && interactive ? 1.04 : 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: interactive
                      ? [
                          const Color(0xFF1F2D40),
                          const Color(0xFF111A28),
                        ]
                      : [
                          const Color(0xFF566170),
                          const Color(0xFF424B58),
                        ],
                ),
                boxShadow: highlighted
                    ? [
                        BoxShadow(
                          color: const Color(0xFF172233).withValues(alpha: 0.24),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                size: 21,
                color: Colors.white.withValues(alpha: interactive ? 1 : 0.72),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
