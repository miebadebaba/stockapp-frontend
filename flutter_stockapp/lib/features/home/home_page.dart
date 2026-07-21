import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_page_wrapper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedPageWrapper(
      child: ColoredBox(
        color: AppColors.bgPrimary,
      ),
    );
  }
}
