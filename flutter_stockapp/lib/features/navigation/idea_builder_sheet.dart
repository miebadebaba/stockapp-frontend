import 'package:flutter/material.dart';

import '../../core/widgets/glass_container.dart';

class IdeaBuilderSheet extends StatelessWidget {
  const IdeaBuilderSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return GlassContainer(
      width: screenSize.width > 384 ? 320 : screenSize.width - 64,
      height: screenSize.height > 760 ? 280 : screenSize.height * 0.34,
      blur: 32,
      opacity: 0.28,
      borderRadius: 28,
      showShadow: false,
      child: const SizedBox.expand(),
    );
  }
}
