import 'package:flutter/material.dart';

import '../../core/widgets/animated_page_wrapper.dart';
import 'auth_remote_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.onSignedIn,
    required this.onRegistered,
    super.key,
  });

  final Future<void> Function(String username, String password) onSignedIn;
  final Future<void> Function(String username, String password) onRegistered;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _username = '';
  bool _submitting = false;
  String? _infoText;
  String? _loginUsernameError;
  String? _loginPasswordError;
  String? _loginFormError;
  String _loginPassword = '';
  bool _loginSheetSubmitting = false;

  Future<void> _showUsernameSheet() async {
    _loginUsernameError = null;
    _loginPasswordError = null;
    _loginFormError = null;
    _loginPassword = '';
    _loginSheetSubmitting = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void rebuildSheet(VoidCallback update) {
              update();
              setSheetState(() {});
            }

            Future<void> submit() async {
              if (_loginSheetSubmitting) {
                return;
              }
              FocusScope.of(sheetContext).unfocus();
              final username = _username.trim();
              final nextUsernameError = username.isEmpty
                  ? 'Please enter a username.'
                  : null;
              final nextPasswordError = _loginPassword.isEmpty
                  ? 'Please enter a password.'
                  : null;
              if (nextUsernameError != null || nextPasswordError != null) {
                rebuildSheet(() {
                  _loginUsernameError = nextUsernameError;
                  _loginPasswordError = nextPasswordError;
                  _loginFormError = null;
                });
                return;
              }

              rebuildSheet(() {
                _loginUsernameError = null;
                _loginPasswordError = null;
                _loginFormError = null;
                _loginSheetSubmitting = true;
              });
              if (mounted) {
                setState(() => _submitting = true);
              }

              try {
                await widget.onSignedIn(username, _loginPassword);
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
              } on AuthException catch (error) {
                if (sheetContext.mounted) {
                  rebuildSheet(() => _loginFormError = error.message);
                }
              } finally {
                if (sheetContext.mounted) {
                  rebuildSheet(() => _loginSheetSubmitting = false);
                }
                if (mounted) {
                  setState(() => _submitting = false);
                }
              }
            }

            return SingleChildScrollView(
              key: const Key('login-sheet-scroll'),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign in',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF17171B),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your username to continue.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Inter',
                          color: const Color(0xFF6B6B70),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        key: const Key('login-username'),
                        initialValue: _username,
                        autofocus: true,
                        enabled: !_loginSheetSubmitting,
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {
                          _username = value;
                          if (_loginUsernameError != null ||
                              _loginFormError != null) {
                            rebuildSheet(() {
                              _loginUsernameError = null;
                              _loginFormError = null;
                            });
                          }
                        },
                        onFieldSubmitted: (_) => submit(),
                        decoration: InputDecoration(
                          hintText: 'Username',
                          errorText: _loginUsernameError,
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          filled: true,
                          fillColor: const Color(0xFFF6F4F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFF4285F4),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('login-password'),
                        enabled: !_loginSheetSubmitting,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {
                          _loginPassword = value;
                          if (_loginPasswordError != null ||
                              _loginFormError != null) {
                            rebuildSheet(() {
                              _loginPasswordError = null;
                              _loginFormError = null;
                            });
                          }
                        },
                        onFieldSubmitted: (_) => submit(),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          errorText: _loginPasswordError,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          filled: true,
                          fillColor: const Color(0xFFF6F4F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFF4285F4),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      if (_loginFormError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _loginFormError!,
                          key: const Key('login-form-error'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFFB3261E),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _LoginActionButton(
                        key: const Key('login-submit'),
                        label: _loginSheetSubmitting
                            ? 'Signing in...'
                            : 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        dark: true,
                        onPressed: _loginSheetSubmitting ? null : submit,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          key: const Key('login-sheet-sign-up'),
                          onPressed: _loginSheetSubmitting
                              ? null
                              : () {
                                  Navigator.of(sheetContext).pop();
                                  _openRegister();
                                },
                          child: const Text("Don't have an account? Sign up"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openRegister() {
    Navigator.of(context)
        .push<String>(
          MaterialPageRoute<String>(
            builder: (_) => RegisterPage(onRegistered: widget.onRegistered),
          ),
        )
        .then((registeredUsername) {
          if (mounted && registeredUsername != null) {
            _username = registeredUsername;
            setState(
              () => _infoText = 'Registration successful. Please sign in.',
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    const canvasColor = Color(0xFFF6F4F2);

    return Scaffold(
      backgroundColor: canvasColor,
      body: AnimatedPageWrapper(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, viewport) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewport.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              const _StockAppArtwork(),
                              const SizedBox(height: 12),
                              Text(
                                'Welcome back',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF707073),
                                    ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                'Stock App.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      fontFamily: 'Inter',
                                      fontSize: 52,
                                      height: 1.02,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF17171B),
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Your personal market workspace.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontFamily: 'Inter',
                                      fontSize: 24,
                                      height: 1.18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF17171B),
                                    ),
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_infoText != null) ...[
                const SizedBox(height: 16),
                Text(
                  _infoText!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: Column(
                  children: [
                    _LoginActionButton(
                      key: const Key('login-open-form'),
                      label: _submitting ? 'Signing in...' : 'Continue',
                      icon: Icons.person_outline_rounded,
                      onPressed: _submitting ? null : _showUsernameSheet,
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      key: const Key('login-sign-up'),
                      onPressed: _submitting ? null : _openRegister,
                      child: Text(
                        "Don't have an account? Sign up",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4285F4),
                        ),
                      ),
                    ),
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

class _StockAppArtwork extends StatelessWidget {
  const _StockAppArtwork();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 94,
            height: 94,
            margin: const EdgeInsets.only(top: 54),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2B2D),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              Icons.stacked_line_chart_rounded,
              color: Color(0xFFF8F8F9),
              size: 54,
              semanticLabel: 'StockApp',
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 96,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00F6F4F2), Color(0xFFF6F4F2)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginActionButton extends StatelessWidget {
  const _LoginActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.dark = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? const Color(0xFFF9F9FA) : const Color(0xFF17171B);
    final background = dark ? const Color(0xFF17171B) : Colors.white;

    return Opacity(
      opacity: onPressed == null ? 0.55 : 1,
      child: CustomPaint(
        painter: _ButtonShadowPainter(
          color: dark ? const Color(0x40000000) : const Color(0x22000000),
        ),
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(32),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(32),
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: dark ? Colors.white : const Color(0xFF4285F4),
                    size: 26,
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonShadowPainter extends CustomPainter {
  const _ButtonShadowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final shadowRect = Rect.fromLTRB(-1, -1, size.width + 1, size.height + 1);
    final shadow = RRect.fromRectAndRadius(
      shadowRect,
      const Radius.circular(33),
    );
    canvas.drawRRect(shadow, paint);
  }

  @override
  bool shouldRepaint(_ButtonShadowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
