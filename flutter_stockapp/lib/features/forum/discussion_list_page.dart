import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import '../navigation/app_top_actions.dart';
import 'services/forum_api.dart';

class DiscussionPostData {
  const DiscussionPostData({
    required this.id,
    required this.userName,
    required this.content,
    required this.publishedText,
    required this.avatarLabel,
    required this.avatarColor,
    this.topicLabel = 'Discussion',
    this.isFavorite = false,
    this.status,
    this.moderationReason,
  });

  final String id;
  final String userName;
  final String content;
  final String publishedText;
  final String avatarLabel;
  final Color avatarColor;
  final String topicLabel;
  final bool isFavorite;
  final String? status;
  final String? moderationReason;
}

class DiscussionCommentData {
  const DiscussionCommentData({
    required this.id,
    required this.userName,
    required this.content,
    required this.publishedText,
    required this.avatarLabel,
    required this.avatarColor,
  });

  final String id;
  final String userName;
  final String content;
  final String publishedText;
  final String avatarLabel;
  final Color avatarColor;
}

class DiscussionListPage extends StatefulWidget {
  const DiscussionListPage({
    required this.posts,
    required this.commentsByPostId,
    this.api,
    this.onSettingsTap,
    this.onProfileTap,
    this.onPostTap,
    this.onNewPostTap,
    this.bottomPadding = 120,
    this.showTopActions = true,
    super.key,
  });

  final List<DiscussionPostData> posts;
  final Map<String, List<DiscussionCommentData>> commentsByPostId;
  final ForumApi? api;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onProfileTap;
  final ValueChanged<String>? onPostTap;
  final VoidCallback? onNewPostTap;
  final double bottomPadding;
  final bool showTopActions;

  factory DiscussionListPage.demo({
    VoidCallback? onSettingsTap,
    VoidCallback? onProfileTap,
    ValueChanged<String>? onPostTap,
    VoidCallback? onNewPostTap,
    double bottomPadding = 120,
    bool showTopActions = true,
    Key? key,
  }) {
    return DiscussionListPage(
      key: key,
      posts: _demoPosts,
      commentsByPostId: _demoCommentsByPostId,
      onSettingsTap: onSettingsTap,
      onProfileTap: onProfileTap,
      onPostTap: onPostTap,
      onNewPostTap: onNewPostTap,
      bottomPadding: bottomPadding,
      showTopActions: showTopActions,
    );
  }

  static const List<DiscussionPostData> _demoPosts = [
    DiscussionPostData(
      id: 'nvda-thread',
      userName: 'Mia Chen',
      content:
          'Anyone else expecting another strong AI infrastructure guide from NVDA? The options chain still looks crowded.',
      publishedText: 'Jul 22, 2026',
      avatarLabel: 'MC',
      avatarColor: AppColors.orbBlueLight,
      topicLabel: 'NVDA',
      isFavorite: true,
    ),
    DiscussionPostData(
      id: 'aapl-thread',
      userName: 'Jordan Park',
      content:
          'I am watching AAPL here for a slower rotation trade. Services remain resilient even if hardware stays flat for a quarter.',
      publishedText: 'Jul 21, 2026',
      avatarLabel: 'JP',
      avatarColor: AppColors.orbMint,
      topicLabel: 'AAPL',
    ),
    DiscussionPostData(
      id: 'tsla-thread',
      userName: 'Sofia Reed',
      content:
          'TSLA sentiment feels split again. Curious whether people are trading the tape or waiting for delivery updates first.',
      publishedText: 'Jul 21, 2026',
      avatarLabel: 'SR',
      avatarColor: AppColors.orbRose,
      topicLabel: 'TSLA',
    ),
    DiscussionPostData(
      id: 'macro-thread',
      userName: 'Leo Grant',
      content:
          'Macro question: if yields stay sticky into August, which growth names are you trimming first and which ones are long-term holds?',
      publishedText: 'Jul 20, 2026',
      avatarLabel: 'LG',
      avatarColor: AppColors.orbAmberLight,
      topicLabel: 'Macro',
    ),
  ];

  static const Map<String, List<DiscussionCommentData>> _demoCommentsByPostId = {
    'nvda-thread': [
      DiscussionCommentData(
        id: 'nvda-c1',
        userName: 'Kai Morgan',
        content: 'I still like the setup, but I would rather scale in after the next earnings call than chase here.',
        publishedText: '2 hrs ago',
        avatarLabel: 'KM',
        avatarColor: AppColors.orbViolet,
      ),
      DiscussionCommentData(
        id: 'nvda-c2',
        userName: 'Olivia Sun',
        content: 'Same. Demand story is still strong, but implied volatility is doing a lot of the work right now.',
        publishedText: '1 hr ago',
        avatarLabel: 'OS',
        avatarColor: AppColors.orbBlueLight,
      ),
    ],
    'aapl-thread': [
      DiscussionCommentData(
        id: 'aapl-c1',
        userName: 'Noah Wright',
        content: 'Services is the reason I keep it in the core bucket. Not exciting, but dependable.',
        publishedText: '3 hrs ago',
        avatarLabel: 'NW',
        avatarColor: AppColors.orbMint,
      ),
      DiscussionCommentData(
        id: 'aapl-c2',
        userName: 'Evelyn Tate',
        content: 'I am waiting for a cleaner entry, but I agree the downside looks more limited than most mega caps.',
        publishedText: '2 hrs ago',
        avatarLabel: 'ET',
        avatarColor: AppColors.orbAmberLight,
      ),
    ],
    'tsla-thread': [
      DiscussionCommentData(
        id: 'tsla-c1',
        userName: 'Aria Cole',
        content: 'Mostly tape trade for me right now. Headlines move it too fast to size up like a core long.',
        publishedText: '5 hrs ago',
        avatarLabel: 'AC',
        avatarColor: AppColors.orbRose,
      ),
    ],
    'macro-thread': [
      DiscussionCommentData(
        id: 'macro-c1',
        userName: 'Ben Foster',
        content: 'I am cutting weaker software first and holding semis unless the guide actually breaks.',
        publishedText: 'Yesterday',
        avatarLabel: 'BF',
        avatarColor: AppColors.orbBlueDeep,
      ),
    ],
  };

  @override
  State<DiscussionListPage> createState() => _DiscussionListPageState();
}

class _DiscussionListPageState extends State<DiscussionListPage> {
  late List<DiscussionPostData> _posts;
  var _showMine = false;
  var _isLoading = false;
  String? _error;

  ForumApi? get _api => widget.api;

  @override
  void initState() {
    super.initState();
    _posts = widget.posts;
    if (_api != null) {
      _loadPosts();
    }
  }

  Future<void> _loadPosts() async {
    final api = _api;
    if (api == null || _isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final posts = _showMine ? await api.loadMyPosts() : await api.loadPublicPosts();
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = posts.map(_postFromApi).toList(growable: false);
        _isLoading = false;
      });
    } on ForumApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = '论坛内容加载失败，请稍后重试。';
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePostTap(DiscussionPostData post) async {
    widget.onPostTap?.call(post.id);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DiscussionDetailPage(
          post: post,
          comments: widget.commentsByPostId[post.id] ?? const [],
          onSubmitComment: (_) {},
        ),
      ),
    );
  }

  Future<void> _handleNewPostTap() async {
    widget.onNewPostTap?.call();
    final text = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => const NewPostPage(),
      ),
    );
    final api = _api;
    final content = text?.trim();
    if (api == null || content == null || content.isEmpty) {
      return;
    }
    try {
      await api.createPost(content: content, topicLabel: 'Discussion');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('内容已提交，等待管理员审核'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      _showMine = true;
      await _loadPosts();
    } on ForumApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(error.message), behavior: SnackBarBehavior.floating),
        );
    }
  }

  void _setScope(bool showMine) {
    if (_showMine == showMine) {
      return;
    }
    setState(() => _showMine = showMine);
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: palette.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: AnimatedPageWrapper(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _ForumCircleButton(
                            icon: Icons.edit_rounded,
                            onTap: _handleNewPostTap,
                          ),
                        ),
                        if (widget.showTopActions)
                          Align(
                            alignment: Alignment.centerRight,
                            child: AppTopActions(
                              onSettingsTap: widget.onSettingsTap,
                              onProfileTap: widget.onProfileTap,
                            ),
                          ),
                        Text(
                          'forum',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize: 32,
                            height: 1.0,
                            fontWeight: FontWeight.w800,
                            color: palette.primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Discussion',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 30,
                        height: 1.04,
                        fontWeight: FontWeight.w800,
                        color: palette.primaryText,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_api != null) ...[
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('公开内容')),
                          ButtonSegment(value: true, label: Text('我的内容')),
                        ],
                        selected: {_showMine},
                        onSelectionChanged: _isLoading
                            ? null
                            : (selection) => _setScope(selection.first),
                      ),
                      const SizedBox(height: 14),
                    ],
                    Expanded(
                      child: _buildPostList(palette),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostList(AppThemePalette palette) {
    if (_isLoading && _posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _posts.isEmpty) {
      return _ForumStateMessage(message: _error!, onRetry: _loadPosts);
    }
    if (_posts.isEmpty) {
      return Center(
        child: Text(
          _showMine ? '暂无已提交内容' : '暂无已通过审核的帖子',
          style: TextStyle(color: palette.secondaryText),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: widget.bottomPadding),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return DiscussionPostItem(
            post: post,
            onTap: () => _handlePostTap(post),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            color: palette.divider,
            height: 1,
            thickness: 1,
          );
        },
      ),
    );
  }
}

DiscussionPostData _postFromApi(ForumPost post) {
  return DiscussionPostData(
    id: post.id.toString(),
    userName: post.authorUsername,
    content: post.content,
    publishedText: _formatForumDate(post.createdAt),
    avatarLabel: _avatarLabel(post.authorUsername),
    avatarColor: _avatarColor(post.authorUsername),
    topicLabel: post.topicLabel,
    status: post.status,
    moderationReason: post.moderationReason,
  );
}

String _avatarLabel(String username) {
  final clean = username.trim();
  if (clean.isEmpty) {
    return '?';
  }
  return (clean.length <= 2 ? clean : clean.substring(0, 2)).toUpperCase();
}

Color _avatarColor(String username) {
  const colors = [
    AppColors.orbBlueLight,
    AppColors.orbMint,
    AppColors.orbRose,
    AppColors.orbAmberLight,
    AppColors.orbViolet,
    AppColors.orbBlueDeep,
  ];
  final index = username.codeUnits.fold<int>(0, (sum, value) => sum + value) % colors.length;
  return colors[index];
}

String _formatForumDate(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

class _ForumStateMessage extends StatelessWidget {
  const _ForumStateMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: palette.primaryText)),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }
}

class DiscussionDetailPage extends StatefulWidget {
  const DiscussionDetailPage({
    required this.post,
    required this.comments,
    this.onBackTap,
    this.onNotificationTap,
    this.onFavoriteToggle,
    this.onSubmitComment,
    super.key,
  });

  final DiscussionPostData post;
  final List<DiscussionCommentData> comments;
  final VoidCallback? onBackTap;
  final VoidCallback? onNotificationTap;
  final ValueChanged<bool>? onFavoriteToggle;
  final ValueChanged<String>? onSubmitComment;

  @override
  State<DiscussionDetailPage> createState() => _DiscussionDetailPageState();
}

class _DiscussionDetailPageState extends State<DiscussionDetailPage> {
  late final TextEditingController _commentController;
  late final List<DiscussionCommentData> _comments;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _comments = List<DiscussionCommentData>.from(widget.comments);
    _isFavorite = widget.post.isFavorite;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).maybePop();
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteToggle?.call(_isFavorite);
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _comments.add(
        const DiscussionCommentData(
          id: 'local-comment',
          userName: 'You',
          content: '',
          publishedText: 'Now',
          avatarLabel: 'YO',
          avatarColor: AppColors.orbBlueLight,
        ),
      );
      final last = _comments.last;
      _comments[_comments.length - 1] = DiscussionCommentData(
        id: last.id,
        userName: last.userName,
        content: text,
        publishedText: last.publishedText,
        avatarLabel: last.avatarLabel,
        avatarColor: last.avatarColor,
      );
    });
    widget.onSubmitComment?.call(text);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: palette.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  _ForumCircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: _handleBack,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.post.topicLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: palette.primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ForumCircleButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: widget.onNotificationTap,
                  ),
                  const SizedBox(width: 8),
                  _ForumCircleButton(
                    icon: _isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    onTap: _toggleFavorite,
                    isHighlighted: _isFavorite,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DiscussionPostItem(
                        post: widget.post,
                        isInteractive: false,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Comments',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: palette.primaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (var i = 0; i < _comments.length; i++) ...[
                        DiscussionCommentItem(comment: _comments[i]),
                        if (i != _comments.length - 1)
                          Divider(
                            color: palette.divider,
                            height: 20,
                            thickness: 1,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _CommentComposer(
              controller: _commentController,
              onSendTap: _submitComment,
            ),
          ],
        ),
      ),
    );
  }
}

class NewPostPage extends StatefulWidget {
  const NewPostPage({
    this.onBackTap,
    this.onPublishTap,
    super.key,
  });

  final VoidCallback? onBackTap;
  final ValueChanged<String>? onPublishTap;

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  late final TextEditingController _postController;

  @override
  void initState() {
    super.initState();
    _postController = TextEditingController();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).maybePop();
  }

  void _handlePublish() {
    final content = _postController.text.trim();
    if (content.isEmpty) {
      return;
    }
    widget.onPublishTap?.call(content);
    Navigator.of(context).pop(content);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: palette.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            children: [
              Row(
                children: [
                  _ForumCircleButton(
                    icon: Icons.close_rounded,
                    onTap: _handleBack,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'New post',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: palette.primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _handlePublish,
                    child: Text(
                      'Publish',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.accentBlueLink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.groupBackground,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: TextField(
                      controller: _postController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      cursorColor: palette.primaryText,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: palette.primaryText,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Share your market view...',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: palette.secondaryText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscussionPostItem extends StatelessWidget {
  const DiscussionPostItem({
    required this.post,
    this.onTap,
    this.isInteractive = true,
    super.key,
  });

  final DiscussionPostData post;
  final VoidCallback? onTap;
  final bool isInteractive;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isInteractive ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: palette.rowPressedOverlay,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DiscussionAvatar(
                label: post.avatarLabel,
                backgroundColor: post.avatarColor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.accentBlueLink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: palette.primaryText,
                        height: 1.38,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          post.publishedText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (post.status != null)
                          _ModerationStatusChip(status: post.status!),
                      ],
                    ),
                    if (post.moderationReason != null &&
                        post.moderationReason!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '审核原因：${post.moderationReason}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscussionCommentItem extends StatelessWidget {
  const DiscussionCommentItem({
    required this.comment,
    super.key,
  });

  final DiscussionCommentData comment;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DiscussionAvatar(
            label: comment.avatarLabel,
            backgroundColor: comment.avatarColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.accentBlueLink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: palette.primaryText,
                    height: 1.38,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  comment.publishedText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscussionAvatar extends StatelessWidget {
  const _DiscussionAvatar({
    required this.label,
    required this.backgroundColor,
  });

  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: backgroundColor.withValues(alpha: 0.92),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.onSendTap,
  });

  final TextEditingController controller;
  final VoidCallback onSendTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    final theme = Theme.of(context);

    return Material(
      color: palette.pageBackground,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: palette.groupBackground,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    cursorColor: palette.primaryText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: palette.primaryText,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Write a comment',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: palette.secondaryText,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _ForumCircleButton(
                icon: Icons.send_rounded,
                onTap: onSendTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModerationStatusChip extends StatelessWidget {
  const _ModerationStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      'PENDING' => ('待审核', colorScheme.tertiary),
      'APPROVED' => ('已通过', colorScheme.primary),
      'REJECTED' => ('已拒绝', colorScheme.error),
      'HIDDEN' => ('已下架', colorScheme.error),
      _ => (status, colorScheme.secondary),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ForumCircleButton extends StatelessWidget {
  const _ForumCircleButton({
    required this.icon,
    this.onTap,
    this.isHighlighted = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.accentBlueLink.withValues(alpha: 0.16)
                : palette.groupBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isHighlighted
                ? AppColors.accentBlueLink
                : palette.primaryText,
            size: 22,
          ),
        ),
      ),
    );
  }
}
