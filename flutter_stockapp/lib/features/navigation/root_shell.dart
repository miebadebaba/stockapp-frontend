import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme_palette.dart';
import '../account/account_page.dart';
import '../agent/agent_page.dart';
import '../forum/discussion_list_page.dart';
import '../home/home_page.dart';
import '../home/market_stock_list_api.dart';
import '../home/stocks_page.dart';
import '../news/news_feed_page.dart';
import '../paper_trading/paper_trading_page.dart';
import '../quant/quant_page.dart';
import '../tutorial/tutorial_category_page.dart';
import 'app_top_actions.dart';
import 'floating_bottom_nav.dart';
import 'idea_builder_sheet.dart';
import '../watchlist/watchlist_controller.dart';

class RootShell extends StatefulWidget {
  const RootShell({
    this.username,
    this.onSignOut,
    required this.themeMode,
    required this.onThemeModeChanged,
    super.key,
  });

  final String? username;
  final VoidCallback? onSignOut;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  var _selectedIndex = 1;
  var _isIdeaOverlayOpen = false;
  var _isAccountPageOpen = false;
  var _isNewsPageOpen = false;
  var _isTutorialPageOpen = false;
  var _isForumPageOpen = false;
  var _hasPlayedAgentHeadline = false;

  late final WatchlistController _watchlistController;

  @override
  void initState() {
    super.initState();
    _watchlistController = WatchlistController();
    _watchlistController.load();
  }

  @override
  void dispose() {
    _watchlistController.dispose();
    super.dispose();
  }

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
      _isNewsPageOpen = false;
      _isTutorialPageOpen = false;
      _isForumPageOpen = false;
    });
  }

  void _handleAgentHeadlineAnimationCompleted() {
    if (_hasPlayedAgentHeadline) {
      return;
    }
    setState(() => _hasPlayedAgentHeadline = true);
  }

  void _openAccountPage() {
    setState(() => _isAccountPageOpen = true);
  }

  void _closeAccountPage() {
    if (!_isAccountPageOpen) {
      return;
    }
    setState(() => _isAccountPageOpen = false);
  }

  void _openNewsPage() {
    setState(() {
      _isNewsPageOpen = true;
      _isIdeaOverlayOpen = false;
      _isAccountPageOpen = false;
    });
  }

  void _closeNewsPage() {
    if (!_isNewsPageOpen) {
      return;
    }
    setState(() => _isNewsPageOpen = false);
  }

  void _openTutorialPage() {
    setState(() {
      _isTutorialPageOpen = true;
      _isIdeaOverlayOpen = false;
      _isNewsPageOpen = false;
    });
  }

  void _closeTutorialPage() {
    if (!_isTutorialPageOpen) {
      return;
    }
    setState(() => _isTutorialPageOpen = false);
  }

  void _openForumPage() {
    setState(() {
      _isForumPageOpen = true;
      _isIdeaOverlayOpen = false;
      _isNewsPageOpen = false;
      _isTutorialPageOpen = false;
    });
  }

  void _closeForumPage() {
    if (!_isForumPageOpen) {
      return;
    }
    setState(() => _isForumPageOpen = false);
  }

  void _openSimulationPage() {
    _closeIdeaOverlay();

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (routeContext) => PaperTradingPage(
          onClose: () {
            Navigator.of(routeContext).pop();
          },
        ),
      ),
    );
  }

  Future<void> _openWatchlistPage() async {
    final stocks = await const MarketStockListApi().fetchStocks();
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => StocksPage(
          stocks: stocks,
          watchlistController: _watchlistController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final pages = [
      AgentPage(
        animateHeadline: _selectedIndex == 0 && !_hasPlayedAgentHeadline,
        onHeadlineAnimationCompleted: _handleAgentHeadlineAnimationCompleted,
      ),
      HomePage(watchlistController: _watchlistController),
      const QuantPage(),
    ];

    return PopScope(
      canPop:
          !_isIdeaOverlayOpen &&
          !_isAccountPageOpen &&
          !_isNewsPageOpen &&
          !_isTutorialPageOpen &&
          !_isForumPageOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        if (_isForumPageOpen) {
          _closeForumPage();
          return;
        }
        if (_isTutorialPageOpen) {
          _closeTutorialPage();
          return;
        }
        if (_isNewsPageOpen) {
          _closeNewsPage();
          return;
        }
        if (_isIdeaOverlayOpen) {
          _closeIdeaOverlay();
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
            if (_isForumPageOpen)
              Positioned.fill(
                child: DiscussionListPage.demo(
                  bottomPadding: 140,
                  showTopActions: false,
                  onProfileTap: _openAccountPage,
                  onPostTap: (_) {},
                  onNewPostTap: () {},
                ),
              ),
            if (_isTutorialPageOpen)
              Positioned.fill(
                child: TutorialCategoryPage.demo(
                  topPadding: 96,
                  bottomPadding: 140,
                  onSearchChanged: (_) {},
                  onCategoryTap: (_) {},
                ),
              ),
            if (_isAccountPageOpen)
              Positioned.fill(
                child: AccountPage(
                  userName: widget.username ?? 'Account',
                  watchlistController: _watchlistController,
                  onRateUsTap: () {},
                  onHelpCenterTap: () {},
                  onAboutTap: () {},
                  onPrimaryActionTap: () {},
                  onSecondaryActionTap: _openWatchlistPage,
                  onProfileTap: () {},
                  onTopProfileTap: _closeAccountPage,
                  onSignOutTap: widget.onSignOut,
                  initialThemeMode: widget.themeMode,
                  onThemeModeChanged: widget.onThemeModeChanged,
                ),
              ),
            if (!_isAccountPageOpen && !_isNewsPageOpen)
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
                        onProfileTap: _openAccountPage,
                      ),
                    ),
                  ),
                ),
              ),
            if (_isIdeaOverlayOpen)
              Positioned.fill(
                child: _GlassPageOverlay(
                  onDismiss: _closeIdeaOverlay,
                  onNewsTap: _openNewsPage,
                  onTutorialTap: _openTutorialPage,
                  onForumTap: _openForumPage,
                  onSimulationTap: _openSimulationPage,
                ),
              ),
            if (!keyboardVisible)
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
            if (_isNewsPageOpen)
              Positioned.fill(child: NewsFeedPage(onCloseTap: _closeNewsPage)),
          ],
        ),
      ),
    );
  }
}

class _GlassPageOverlay extends StatelessWidget {
  const _GlassPageOverlay({
    required this.onDismiss,
    this.onNewsTap,
    this.onTutorialTap,
    this.onForumTap,
    this.onSimulationTap,
  });

  final VoidCallback onDismiss;
  final VoidCallback? onNewsTap;
  final VoidCallback? onTutorialTap;
  final VoidCallback? onForumTap;
  final VoidCallback? onSimulationTap;

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
                child: IdeaBuilderSheet(
                  onNewsTap: onNewsTap,
                  onTutorialTap: onTutorialTap,
                  onForumTap: onForumTap,
                  onSimulationTap: onSimulationTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
