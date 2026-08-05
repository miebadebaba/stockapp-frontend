import 'package:flutter/material.dart';

import '../../core/widgets/animated_page_wrapper.dart';
import 'auth_remote_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({required this.onRegistered, super.key});

  final Future<void> Function(String username, String password) onRegistered;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _formError;
  bool _submitting = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    FocusScope.of(context).unfocus();
    final username = _username.text.trim();
    final password = _password.text;
    final confirmPassword = _confirmPassword.text;
    final usernameError = username.isEmpty ? 'Please enter a username.' : null;
    final passwordError = password.isEmpty
        ? 'Please enter a password.'
        : password.length < 8
        ? 'Password must be at least 8 characters.'
        : null;
    final confirmPasswordError = confirmPassword.isEmpty
        ? 'Please confirm your password.'
        : password != confirmPassword
        ? 'Passwords do not match.'
        : null;
    if (usernameError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      setState(() {
        _usernameError = usernameError;
        _passwordError = passwordError;
        _confirmPasswordError = confirmPasswordError;
        _formError = null;
      });
      return;
    }

    setState(() {
      _usernameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _formError = null;
      _submitting = true;
    });

    try {
      await widget.onRegistered(username, password);
      if (mounted) {
        _password.clear();
        _confirmPassword.clear();
        Navigator.of(context).pop(username);
      }
    } on AuthException catch (error) {
      if (mounted) {
        setState(() => _formError = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const canvasColor = Color(0xFFF6F4F2);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: canvasColor,
      body: AnimatedPageWrapper(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) {
              return SingleChildScrollView(
                key: const Key('register-scroll'),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  24,
                  0,
                  24,
                  MediaQuery.viewInsetsOf(context).bottom + 44,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewport.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        const _RegisterArtwork(),
                        const SizedBox(height: 12),
                        Text(
                          'Create your account',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontFamily: 'Inter',
                                fontSize: 42,
                                height: 1.06,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF17171B),
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Start your personal market workspace.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontFamily: 'Inter',
                                fontSize: 22,
                                height: 1.18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF17171B),
                              ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          key: const Key('register-username'),
                          controller: _username,
                          enabled: !_submitting,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) =>
                              FocusScope.of(context).nextFocus(),
                          onChanged: (_) {
                            if (_usernameError != null || _formError != null) {
                              setState(() {
                                _usernameError = null;
                                _formError = null;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Username',
                            errorText: _usernameError,
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                            ),
                            filled: true,
                            fillColor: Colors.white,
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
                        TextField(
                          key: const Key('register-password'),
                          controller: _password,
                          enabled: !_submitting,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) =>
                              FocusScope.of(context).nextFocus(),
                          onChanged: (_) {
                            if (_passwordError != null ||
                                _confirmPasswordError != null ||
                                _formError != null) {
                              setState(() {
                                _passwordError = null;
                                _confirmPasswordError = null;
                                _formError = null;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Password',
                            errorText: _passwordError,
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            filled: true,
                            fillColor: Colors.white,
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
                        TextField(
                          key: const Key('register-confirm-password'),
                          controller: _confirmPassword,
                          enabled: !_submitting,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          onChanged: (_) {
                            if (_confirmPasswordError != null ||
                                _formError != null) {
                              setState(() {
                                _confirmPasswordError = null;
                                _formError = null;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Confirm password',
                            errorText: _confirmPasswordError,
                            prefixIcon: const Icon(Icons.lock_reset_rounded),
                            filled: true,
                            fillColor: Colors.white,
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
                        const Spacer(),
                        const SizedBox(height: 24),
                        if (_formError != null) ...[
                          Text(
                            _formError!,
                            key: const Key('register-form-error'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFFB3261E),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        _RegisterActionButton(
                          key: const Key('register-submit'),
                          label: _submitting
                              ? 'Creating...'
                              : 'Create an account',
                          icon: Icons.person_add_alt_1_rounded,
                          dark: true,
                          onPressed: _submitting ? null : _submit,
                        ),
                        const SizedBox(height: 28),
                        TextButton(
                          key: const Key('register-sign-in'),
                          onPressed: _submitting
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          child: Text(
                            'Already have an account? Sign in',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4285F4),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RegisterArtwork extends StatelessWidget {
  const _RegisterArtwork();

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
            margin: const EdgeInsets.only(top: 62),
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

class _RegisterActionButton extends StatelessWidget {
  const _RegisterActionButton({
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
        painter: _RegisterButtonShadowPainter(
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

class _RegisterButtonShadowPainter extends CustomPainter {
  const _RegisterButtonShadowPainter({required this.color});

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
  bool shouldRepaint(_RegisterButtonShadowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
