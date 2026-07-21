import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_session.dart';
import 'features/auth/login_page.dart';
import 'features/navigation/root_shell.dart';

class AppNameDemo extends StatelessWidget {
  const AppNameDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppName',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final Future<AuthSession> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = AuthSession.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthSession>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _AuthLoadingPage();
        }

        final session = snapshot.data!;
        return AnimatedBuilder(
          animation: session,
          builder: (context, _) {
            if (session.isLoggedIn) {
              return RootShell(username: session.username);
            }

            return LoginPage(
              onSignedIn: session.signIn,
              onRegistered: session.register,
            );
          },
        );
      },
    );
  }
}

class _AuthLoadingPage extends StatelessWidget {
  const _AuthLoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: ColoredBox(color: AppColors.bgPrimary),
    );
  }
}
