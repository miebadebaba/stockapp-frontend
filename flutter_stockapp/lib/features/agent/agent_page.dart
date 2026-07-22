import 'package:flutter/material.dart';

import 'agent_input_preview_page.dart';

class AgentPage extends StatelessWidget {
  const AgentPage({
    this.animateHeadline = false,
    this.onHeadlineAnimationCompleted,
    super.key,
  });

  final bool animateHeadline;
  final VoidCallback? onHeadlineAnimationCompleted;

  @override
  Widget build(BuildContext context) {
    return AgentInputPreviewPage(
      embedInScaffold: false,
      animateHeadline: animateHeadline,
      onHeadlineAnimationCompleted: onHeadlineAnimationCompleted,
    );
  }
}
