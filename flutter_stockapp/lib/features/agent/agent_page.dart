import 'package:flutter/material.dart';

import 'agent_input_preview_page.dart';
import 'services/ai_chat_service.dart';

class AgentPage extends StatelessWidget {
  const AgentPage({
    this.animateHeadline = false,
    this.onHeadlineAnimationCompleted,
    this.aiChatService,
    super.key,
  });

  final bool animateHeadline;
  final VoidCallback? onHeadlineAnimationCompleted;
  final AiChatService? aiChatService;

  @override
  Widget build(BuildContext context) {
    return AgentInputPreviewPage(
      embedInScaffold: false,
      animateHeadline: animateHeadline,
      onHeadlineAnimationCompleted: onHeadlineAnimationCompleted,
      aiChatService: aiChatService,
    );
  }
}
