import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme_palette.dart';
import '../account/account_page.dart';
import '../agent/agent_page.dart';
import '../home/home_page.dart';
import '../settings/settings_preview_page.dart';
import 'app_top_actions.dart';
import 'floating_bottom_nav.dart';
import 'idea_builder_sheet.dart';

class RootShell extends StatefulWidget {
  const RootShell({
    this.username,
    required this.themeMode,
    required this.onThemeModeChanged,
    super.key,
  });

  final String? username;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  var _selectedIndex = 1;
  var _isIdeaOverlayOpen = false;
  var _isAccountPageOpen = false;
  var _isSettingsPageOpen = false;
  var _hasPlayedAgentHeadline = false;

  void _toggleIdeaOverlay() {
    setState(() => _isIdeaOverlayOpen = !_isIdeaOverlayOpen);
  }

  void _closeIdeaOverlay() {
    if (!_isIdeaOverlayOpen) {
      return;
    }
    setState(() => _isIdeaOverlayOpen = false);
  }

  void _handleNavChanged(int index) {
    setState(() {
      _selectedIndex = index;
      _isIdeaOverlayOpen = false;
      _isAccountPageOpen = false;
      _isSettingsPageOpen = false;
    });
  }

  void _handleAgentHeadlineAnimationCompleted() {
    if (_hasPlayedAgentHeadline) {
      return;
    }
    setState(() => _hasPlayedAgentHeadline = true);
  }

  void _openAccountPage() {
    setState(() {
      _isAccountPageOpen = true;
      _isSettingsPageOpen = false;
    });
  }

  void _closeAccountPage() {
    if (!_isAccountPageOpen) {
      return;
    }
    setState(() => _isAccountPageOpen = false);
  }

  void _openSettingsPage() {
    setState(() => _isSettingsPageOpen = true);
  }

  void _closeSettingsPage() {
    if (!_isSettingsPageOpen) {
      return;
    }
    setState(() => _isSettingsPageOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final pages = [
      AgentPage(
        animateHeadline: _selectedIndex == 0 && !_hasPlayedAgentHeadline,
        onHeadlineAnimationCompleted: _handleAgentHeadlineAnimationCompleted,
      ),
      const HomePage(),
      const _EmptyShellPage(),
    ];

    return PopScope(
      canPop:
          !_isIdeaOverlayOpen && !_isAccountPageOpen && !_isSettingsPageOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        if (_isIdeaOverlayOpen) {
          _closeIdeaOverlay();
          return;
        }
        if (_isSettingsPageOpen) {
          _closeSettingsPage();
          return;
        }
        if (_isAccountPageOpen) {
          _closeAccountPage();
        }
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: palette.pageBackground,
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(index: _selectedIndex, children: pages),
            ),
            if (_isSettingsPageOpen)
              Positioned.fill(
                child: SettingsPreviewPage(
                  themeMode: widget.themeMode,
                  onThemeModeChanged: widget.onThemeModeChanged,
                  onSettingsTap: () {},
                  onAvatarTap: () {
                    _closeSettingsPage();
                    _openAccountPage();
                  },
                ),
              ),
            if (_isAccountPageOpen)
              Positioned.fill(
                child: AccountPage(
                  onRateUsTap: () {},
                  onHelpCenterTap: () {},
                  onPreferencesTap: () {},
                  onAboutTap: () {},
                  onPrimaryActionTap: () {},
                  onSecondaryActionTap: () {},
                  onProfileTap: () {},
                  onSettingsTap: _openSettingsPage,
                  onTopProfileTap: _closeAccountPage,
                  onSignOutTap: () {},
                ),
              ),
            if (!_isAccountPageOpen && !_isSettingsPageOpen)
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
                      child: AppTopActions(
                        onSettingsTap: _openSettingsPage,
                        onProfileTap: _openAccountPage,
                      ),
                    ),
                  ),
                ),
              ),
            if (_isIdeaOverlayOpen)
              Positioned.fill(
                child: _GlassPageOverlay(onDismiss: _closeIdeaOverlay),
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
      ),
    );
  }
}

class _GlassPageOverlay extends StatelessWidget {
  const _GlassPageOverlay({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
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
                color: palette.primaryText.withValues(alpha: 0.08),
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
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return ColoredBox(color: palette.pageBackground);
  }
}
