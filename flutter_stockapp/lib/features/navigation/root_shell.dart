import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';
import '../home/home_page.dart';
import 'floating_bottom_nav.dart';
import 'idea_builder_sheet.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  var _selectedIndex = 1;

  static const _pages = [LoginPage(), HomePage(), RegisterPage()];

  void _showIdeaSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.textPrimary.withValues(alpha: 0.34),
      builder: (_) => const IdeaBuilderSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              selectedIndex: _selectedIndex,
              onChanged: (index) => setState(() => _selectedIndex = index),
              onAdd: _showIdeaSheet,
            ),
          ),
        ],
      ),
    );
  }
}
