import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stockapp/core/theme/app_theme.dart';
import 'package:flutter_stockapp/features/agent/agent_input_preview_page.dart';
import 'package:flutter_stockapp/features/agent/models/ai_chat_message.dart';
import 'package:flutter_stockapp/features/agent/services/ai_chat_service.dart';
import 'package:flutter_stockapp/features/navigation/floating_bottom_nav.dart';
import 'package:flutter_stockapp/features/navigation/root_shell.dart';

typedef SendHandler = Future<String> Function(
  String message,
  List<AiChatMessage> history,
);

class FakeAiChatService implements AiChatService {
  FakeAiChatService(this.handler);

  final SendHandler handler;
  final List<String> messages = [];
  final List<List<AiChatMessage>> histories = [];

  @override
  Future<String> sendMessage({
    required String message,
    required List<AiChatMessage> history,
  }) {
    messages.add(message);
    histories.add(List<AiChatMessage>.from(history));
    return handler(message, history);
  }

  @override
  void close() {}
}

void main() {
  Future<void> pumpPage(WidgetTester tester, AiChatService service) async {
    tester.view
      ..physicalSize = const Size(900, 1200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: AgentInputPreviewPage(aiChatService: service),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows user and loading immediately, then renders reply', (
    tester,
  ) async {
    final reply = Completer<String>();
    final service = FakeAiChatService((_, _) => reply.future);
    await pumpPage(tester, service);

    await tester.enterText(find.byKey(const ValueKey('agent-input')), '你好');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('agent-send')));
    await tester.pump();

    expect(find.byKey(const ValueKey('agent-message-0-user')), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-loading')), findsOneWidget);
    expect(service.messages, ['你好']);

    reply.complete('连接成功');
    await tester.pumpAndSettle();

    expect(find.text('连接成功'), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-loading')), findsNothing);
    final userBubble = tester.getTopRight(
      find.byKey(const ValueKey('agent-message-0-user')),
    );
    final assistantBubble = tester.getTopLeft(
      find.byKey(const ValueKey('agent-message-1-assistant')),
    );
    expect(userBubble.dx, greaterThan(assistantBubble.dx));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('agent-input'))).dy,
      greaterThan(
        tester
            .getTopLeft(find.byKey(const ValueKey('agent-message-1-assistant')))
            .dy,
      ),
    );
    final input = tester.widget<TextField>(
      find.byKey(const ValueKey('agent-input')),
    );
    expect(input.controller?.text, isEmpty);

    await tester.tap(find.byKey(const ValueKey('agent-clear')));
    await tester.pump();
    expect(find.text('你好'), findsNothing);
    expect(find.text('连接成功'), findsNothing);
    expect(find.text('用三句话解释什么是市盈率'), findsOneWidget);
  });

  testWidgets('does not send twice while a request is pending', (tester) async {
    final reply = Completer<String>();
    final service = FakeAiChatService((_, _) => reply.future);
    await pumpPage(tester, service);

    await tester.enterText(find.byKey(const ValueKey('agent-input')), '只发送一次');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('agent-send')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('agent-send')));
    await tester.pump();

    expect(service.messages, hasLength(1));

    reply.complete('完成');
    await tester.pumpAndSettle();
  });

  testWidgets('shows a safe error and retries the failed message', (
    tester,
  ) async {
    var attempts = 0;
    final service = FakeAiChatService((_, _) async {
      attempts += 1;
      if (attempts == 1) {
        throw const AiChatRequestException('无法连接到后端，请检查服务是否已启动。');
      }
      return '重试成功';
    });
    await pumpPage(tester, service);

    await tester.enterText(find.byKey(const ValueKey('agent-input')), '请重试');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('agent-send')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('agent-error')), findsOneWidget);
    expect(find.text('无法连接到后端，请检查服务是否已启动。'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('agent-retry')));
    await tester.pumpAndSettle();

    expect(service.messages, ['请重试', '请重试']);
    expect(service.histories, everyElement(isEmpty));
    expect(find.text('请重试'), findsOneWidget);
    expect(find.text('重试成功'), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-error')), findsNothing);
  });

  testWidgets('failed messages do not enter later history', (tester) async {
    var attempts = 0;
    final service = FakeAiChatService((_, _) async {
      attempts += 1;
      if (attempts == 1) {
        throw const AiChatRequestException('请求失败');
      }
      return '成功回答';
    });
    await pumpPage(tester, service);

    await tester.enterText(find.byKey(const ValueKey('agent-input')), '失败问题');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('agent-send')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('agent-input')), '新的问题');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('agent-send')));
    await tester.pumpAndSettle();

    expect(service.messages, ['失败问题', '新的问题']);
    expect(service.histories[1], isEmpty);
  });

  testWidgets('sends only the latest nine history messages', (tester) async {
    var replyNumber = 0;
    final service = FakeAiChatService((_, _) async {
      replyNumber += 1;
      return '回答 $replyNumber';
    });
    await pumpPage(tester, service);

    for (var index = 1; index <= 6; index++) {
      await tester.enterText(
        find.byKey(const ValueKey('agent-input')),
        '问题 $index',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('agent-send')));
      await tester.pumpAndSettle();
    }

    expect(service.histories.last, hasLength(9));
    expect(service.histories.first, isEmpty);
    expect(
      service.histories.last.any((message) => message.content == '问题 6'),
      isFalse,
    );
    expect(service.histories.last.map((message) => message.role).toSet(), {
      AiChatRole.user,
      AiChatRole.assistant,
    });
    expect(
      service.histories.last.any((message) => message.role.value == 'system'),
      isFalse,
    );
    final conversation = tester.widget<ListView>(
      find.byKey(const ValueKey('agent-conversation')),
    );
    expect(conversation.controller, isNotNull);
    expect(
      conversation.controller!.position.pixels,
      closeTo(conversation.controller!.position.maxScrollExtent, 0.5),
    );
  });

  testWidgets('hides the floating navigation while the keyboard is visible', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(900, 1200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: RootShell(themeMode: ThemeMode.light, onThemeModeChanged: (_) {}),
      ),
    );
    await tester.pump();

    expect(find.byType(FloatingBottomNav), findsOneWidget);

    tester.view.viewInsets = const FakeViewPadding(bottom: 420);
    await tester.pump();

    expect(find.byType(FloatingBottomNav), findsNothing);

    tester.view.resetViewInsets();
    await tester.pump();

    expect(find.byType(FloatingBottomNav), findsOneWidget);
  });
}
