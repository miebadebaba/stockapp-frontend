import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_session.dart';
import 'features/auth/auth_remote_service.dart';
import 'features/auth/login_page.dart';
import 'features/auth/token_storage.dart';
import 'features/navigation/root_shell.dart';

class AppNameDemo extends StatefulWidget {
  const AppNameDemo({this.authApi, this.tokenStorage, super.key});

  final AuthApi? authApi;
  final TokenStorage? tokenStorage;

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
        authApi: widget.authApi,
        tokenStorage: widget.tokenStorage,
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({
    required this.themeMode,
    required this.onThemeModeChanged,
    this.authApi,
    this.tokenStorage,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final AuthApi? authApi;
  final TokenStorage? tokenStorage;

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late Future<AuthSession> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _loadSession();
  }

  Future<AuthSession> _loadSession() {
    return AuthSession.load(
      api: widget.authApi,
      tokenStorage: widget.tokenStorage,
    );
  }

  void _retryLoadSession() {
    setState(() {
      _sessionFuture = _loadSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthSession>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _AuthLoadingPage();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _AuthLoadErrorPage(onRetry: _retryLoadSession);
        }

        final session = snapshot.data!;
        return AnimatedBuilder(
          animation: session,
          builder: (context, _) {
            if (session.isLoggedIn) {
              return RootShell(
                username: session.username,
                accessTokenProvider: session.readAccessToken,
                themeMode: widget.themeMode,
                onThemeModeChanged: widget.onThemeModeChanged,
                onSignOut: () {
                  session.signOut();
                },
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
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _AuthLoadErrorPage extends StatelessWidget {
  const _AuthLoadErrorPage({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unable to load your session.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Local app data may be invalid. Retry to continue.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
