import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../agent/agent_page.dart';
import '../home/home_page.dart';
import 'app_top_actions.dart';
import 'floating_bottom_nav.dart';
import 'idea_builder_sheet.dart';

class RootShell extends StatefulWidget {
  const RootShell({this.username, super.key});

  final String? username;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  var _selectedIndex = 1;
  var _isIdeaOverlayOpen = false;
  var _hasPlayedAgentHeadline = false;

  void _toggleIdeaOverlay() {
    setState(() => _isIdeaOverlayOpen = !_isIdeaOverlayOpen);
  }

  void _handleNavChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  void _handleAgentHeadlineAnimationCompleted() {
    if (_hasPlayedAgentHeadline) {
      return;
    }
    setState(() => _hasPlayedAgentHeadline = true);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      AgentPage(
        animateHeadline: _selectedIndex == 0 && !_hasPlayedAgentHeadline,
        onHeadlineAnimationCompleted: _handleAgentHeadlineAnimationCompleted,
      ),
      const HomePage(),
      const _EmptyShellPage(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(index: _selectedIndex, children: pages),
          ),
          if (_isIdeaOverlayOpen)
            Positioned.fill(
              child: _GlassPageOverlay(
                onDismiss: () => setState(() => _isIdeaOverlayOpen = false),
              ),
            ),
          if (_selectedIndex != 0)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: const AppTopActions(),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              selectedIndex: _selectedIndex,
              onChanged: _handleNavChanged,
              onAdd: _toggleIdeaOverlay,
              addActive: _isIdeaOverlayOpen,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPageOverlay extends StatelessWidget {
  const _GlassPageOverlay({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDismiss,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: ColoredBox(
                color: AppColors.textPrimary.withValues(alpha: 0.08),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {},
                child: const IdeaBuilderSheet(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyShellPage extends StatelessWidget {
  const _EmptyShellPage();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: AppColors.bgPrimary);
  }
}
