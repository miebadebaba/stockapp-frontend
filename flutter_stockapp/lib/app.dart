import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_session.dart';
import 'features/auth/login_page.dart';
import 'features/navigation/root_shell.dart';

class AppNameDemo extends StatefulWidget {
  const AppNameDemo({super.key});

  @override
  State<AppNameDemo> createState() => _AppNameDemoState();
}

class _AppNameDemoState extends State<AppNameDemo> {
  var _themeMode = ThemeMode.light;

  void _handleThemeModeChanged(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppName',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: _AuthGate(
        themeMode: _themeMode,
        onThemeModeChanged: _handleThemeModeChanged,
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({required this.themeMode, required this.onThemeModeChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

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
              return RootShell(
                username: session.username,
                themeMode: widget.themeMode,
                onThemeModeChanged: widget.onThemeModeChanged,
              );
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
