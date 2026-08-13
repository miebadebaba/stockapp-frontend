import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/forum/discussion_list_page.dart';
import 'package:flutter_stockapp/features/forum/services/forum_api.dart';

void main() {
  testWidgets('loads approved public content and shows own moderation state', (
    tester,
  ) async {
    final api = FakeForumApi();
    await _pumpForum(tester, api);

    expect(find.text('公开帖子'), findsOneWidget);
    expect(find.text('待审核帖子'), findsNothing);
    expect(api.publicLoads, 1);

    await tester.tap(find.text('我的内容'));
    await tester.pump();
    await tester.pump();

    expect(find.text('待审核帖子'), findsOneWidget);
    expect(find.text('待审核'), findsOneWidget);
    expect(find.text('已拒绝帖子'), findsOneWidget);
    expect(find.text('已拒绝'), findsOneWidget);
    expect(find.text('审核原因：内容依据不足'), findsOneWidget);
    expect(api.myLoads, 1);
  });
}

Future<void> _pumpForum(WidgetTester tester, FakeForumApi api) async {
  tester.view
    ..physicalSize = const Size(390, 760)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: DiscussionListPage(
        posts: const [],
        commentsByPostId: const {},
        api: api,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

class FakeForumApi implements ForumApi {
  int publicLoads = 0;
  int myLoads = 0;

  @override
  Future<List<ForumPost>> loadPublicPosts() async {
    publicLoads += 1;
    return [_post(id: 1, content: '公开帖子', status: 'APPROVED')];
  }

  @override
  Future<List<ForumPost>> loadMyPosts() async {
    myLoads += 1;
    return [
      _post(id: 2, content: '待审核帖子', status: 'PENDING'),
      _post(
        id: 3,
        content: '已拒绝帖子',
        status: 'REJECTED',
        moderationReason: '内容依据不足',
      ),
    ];
  }

  @override
  Future<ForumPost> createPost({
    required String content,
    required String topicLabel,
  }) async {
    return _post(id: 4, content: content, status: 'PENDING');
  }
}

ForumPost _post({
  required int id,
  required String content,
  required String status,
  String? moderationReason,
}) {
  return ForumPost(
    id: id,
    authorUserId: 10,
    authorUsername: '测试用户',
    content: content,
    topicLabel: 'Discussion',
    status: status,
    moderationReason: moderationReason,
    createdAt: DateTime.utc(2026, 8, 13, 8),
    updatedAt: DateTime.utc(2026, 8, 13, 8),
  );
}
