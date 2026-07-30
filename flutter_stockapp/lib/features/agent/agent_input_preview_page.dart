import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import 'models/ai_chat_message.dart';
import 'services/ai_chat_service.dart';
import 'widgets/agent_input_card.dart';

class AgentInputPreviewPage extends StatefulWidget {
  const AgentInputPreviewPage({
    this.embedInScaffold = true,
    this.animateHeadline = false,
    this.onHeadlineAnimationCompleted,
    this.aiChatService,
    super.key,
  });

  final bool embedInScaffold;
  final bool animateHeadline;
  final VoidCallback? onHeadlineAnimationCompleted;
  final AiChatService? aiChatService;

  @override
  State<AgentInputPreviewPage> createState() => _AgentInputPreviewPageState();
}

class _AgentInputPreviewPageState extends State<AgentInputPreviewPage>
    with WidgetsBindingObserver {
  late final AiChatService _aiChatService;
  late final bool _ownsAiChatService;
  final ScrollController _scrollController = ScrollController();
  final List<_ChatEntry> _messages = [];
  var _isSending = false;
  var _clearInputRevision = 0;
  String? _errorMessage;
  _ChatEntry? _failedEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownsAiChatService = widget.aiChatService == null;
    _aiChatService = widget.aiChatService ?? HttpAiChatService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    if (_ownsAiChatService) {
      _aiChatService.close();
    }
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _scrollToLatest();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _showInteraction(String label) {
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

  Future<bool> _sendMessage(String text) async {
    final message = text.trim();
    if (message.isEmpty || _isSending) {
      return false;
    }

    final history = _recentHistory();
    final entry = _ChatEntry(
      message: AiChatMessage(role: AiChatRole.user, content: message),
    );
    setState(() {
      _messages.add(entry);
      _isSending = true;
      _errorMessage = null;
      _failedEntry = null;
    });
    _scrollToLatest();

    return _requestReply(message: message, history: history, entry: entry);
  }

  Future<bool> _requestReply({
    required String message,
    required List<AiChatMessage> history,
    required _ChatEntry entry,
  }) async {
    try {
      final reply = await _aiChatService.sendMessage(
        message: message,
        history: history,
      );
      if (!mounted) {
        return false;
      }
      setState(() {
        entry.failed = false;
        _messages.add(
          _ChatEntry(
            message: AiChatMessage(role: AiChatRole.assistant, content: reply),
          ),
        );
        _isSending = false;
        _errorMessage = null;
        if (identical(_failedEntry, entry)) {
          _failedEntry = null;
        }
      });
      _scrollToLatest();
      return true;
    } on AiChatRequestException catch (error) {
      if (!mounted) {
        return false;
      }
      setState(() {
        entry.failed = true;
        _failedEntry = entry;
        _isSending = false;
        _errorMessage = error.message;
      });
      _scrollToLatest();
      return false;
    } catch (_) {
      if (!mounted) {
        return false;
      }
      setState(() {
        entry.failed = true;
        _failedEntry = entry;
        _isSending = false;
        _errorMessage = '发送失败，请稍后重试。';
      });
      _scrollToLatest();
      return false;
    }
  }

  Future<void> _retry() async {
    final entry = _failedEntry;
    if (entry == null || _isSending) {
      return;
    }

    setState(() {
      entry.failed = false;
      _isSending = true;
      _errorMessage = null;
    });
    _scrollToLatest();
    final sent = await _requestReply(
      message: entry.message.content,
      history: _recentHistory(excluding: entry),
      entry: entry,
    );
    if (sent && mounted) {
      setState(() => _clearInputRevision += 1);
    }
  }

  List<AiChatMessage> _recentHistory({_ChatEntry? excluding}) {
    final history = _messages
        .where((entry) => !entry.failed && !identical(entry, excluding))
        .map((entry) => entry.message)
        .toList();
    if (history.length <= HttpAiChatService.maxHistoryMessages) {
      return history;
    }
    return history.sublist(
      history.length - HttpAiChatService.maxHistoryMessages,
    );
  }

  void _startNewChat() {
    if (_isSending) {
      return;
    }
    setState(() {
      _messages.clear();
      _failedEntry = null;
      _errorMessage = null;
      _clearInputRevision += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final topPadding = widget.embedInScaffold ? 88.0 : 104.0;
    final bottomPadding = keyboardVisible
        ? 12.0
        : (widget.embedInScaffold ? 108.0 : 144.0);
    final content = AnimatedPageWrapper(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _PreviewBackdrop(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                topPadding,
                20,
                bottomPadding,
              ),
              child: Column(
                children: [
                  _ChatHeader(
                    canClear: _messages.isNotEmpty && !_isSending,
                    onClear: _startNewChat,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _messages.isEmpty
                        ? _EmptyConversation(
                            animateHeadline: widget.animateHeadline,
                            onSend: _sendMessage,
                            isSending: _isSending,
                            clearInputRevision: _clearInputRevision,
                            onAttachTap: () => _showInteraction('Attachment coming soon'),
                            onModelTap: () => _showInteraction('Using configured backend AI model'),
                            onHeadlineAnimationCompleted:
                                widget.onHeadlineAnimationCompleted,
                          )
                        : _Conversation(
                            controller: _scrollController,
                            messages: _messages,
                            isSending: _isSending,
                            errorMessage: _errorMessage,
                            onRetry: _retry,
                          ),
                  ),
                  if (_messages.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    AgentInputCard(
                      showIntro: false,
                      animateHeadline: false,
                      headlineText: '',
                      placeholderText: 'Input message',
                      modelLabel: 'AI Chat',
                      onSend: _sendMessage,
                      isSending: _isSending,
                      clearInputRevision: _clearInputRevision,
                      onAttachTap: () => _showInteraction('Attachment coming soon'),
                      onModelTap: () => _showInteraction('Using configured backend AI model'),
                    ),
                  ],
                ],
              ),
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

class _ChatEntry {
  _ChatEntry({required this.message});

  final AiChatMessage message;
  bool failed = false;
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.canClear, required this.onClear});

  final bool canClear;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 助手',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '临时会话',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: palette.secondaryText),
                ),
              ],
            ),
          ),
          TextButton.icon(
            key: const ValueKey('agent-clear'),
            onPressed: canClear ? onClear : null,
            icon: const Icon(Icons.delete_outline_rounded, size: 19),
            label: const Text('清空对话'),
          ),
        ],
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation({
    required this.animateHeadline,
    required this.onSend,
    required this.isSending,
    required this.clearInputRevision,
    required this.onAttachTap,
    required this.onModelTap,
    required this.onHeadlineAnimationCompleted,
  });

  final bool animateHeadline;
  final Future<bool> Function(String text) onSend;
  final bool isSending;
  final int clearInputRevision;
  final VoidCallback onAttachTap;
  final VoidCallback onModelTap;
  final VoidCallback? onHeadlineAnimationCompleted;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 36),
                  AgentInputCard(
                    animateHeadline: animateHeadline,
                    headlineText:
                        'Welcome back. What would you like to build next?',
                    placeholderText: 'Input message',
                    modelLabel: 'AI Chat',
                    onSend: onSend,
                    isSending: isSending,
                    clearInputRevision: clearInputRevision,
                    onAttachTap: onAttachTap,
                    onModelTap: onModelTap,
                    onHeadlineAnimationCompleted:
                        onHeadlineAnimationCompleted,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Conversation extends StatelessWidget {
  const _Conversation({
    required this.controller,
    required this.messages,
    required this.isSending,
    required this.errorMessage,
    required this.onRetry,
  });

  final ScrollController controller;
  final List<_ChatEntry> messages;
  final bool isSending;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('agent-conversation'),
      controller: controller,
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (var index = 0; index < messages.length; index++) ...[
          _CenteredConversationItem(
            child: _MessageBubble(entry: messages[index], index: index),
          ),
          const SizedBox(height: 10),
        ],
        if (isSending) const _CenteredConversationItem(child: _LoadingReply()),
        if (errorMessage != null)
          _CenteredConversationItem(
            child: _ChatError(message: errorMessage!, onRetry: onRetry),
          ),
      ],
    );
  }
}

class _CenteredConversationItem extends StatelessWidget {
  const _CenteredConversationItem({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.entry, required this.index});

  final _ChatEntry entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final isUser = entry.message.role == AiChatRole.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        key: ValueKey('agent-message-$index-${entry.message.role.value}'),
        constraints: const BoxConstraints(maxWidth: 620),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? (isDark ? const Color(0xFF245C91) : const Color(0xFFE2ECFA))
              : palette.groupBackground.withValues(alpha: isDark ? 0.9 : 0.74),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: entry.failed
                ? Theme.of(context).colorScheme.error.withValues(alpha: 0.55)
                : palette.secondaryText.withValues(alpha: 0.14),
          ),
        ),
        child: Text(
          entry.message.content,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: palette.primaryText, height: 1.45),
        ),
      ),
    );
  }
}

class _LoadingReply extends StatelessWidget {
  const _LoadingReply();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        key: const ValueKey('agent-loading'),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(
              '正在思考…',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: palette.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatError extends StatelessWidget {
  const _ChatError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('agent-error'),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
          TextButton.icon(
            key: const ValueKey('agent-retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('重试'),
          ),
        ],
      ),
    );
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
