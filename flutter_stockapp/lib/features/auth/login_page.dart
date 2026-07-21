import 'package:flutter/material.dart';

import '../../core/widgets/animated_page_wrapper.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.onSignedIn,
    required this.onRegistered,
    super.key,
  });

  final Future<void> Function(String username) onSignedIn;
  final Future<void> Function(String username) onRegistered;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  Future<void> _showUsernameSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        String? errorText;
        var isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> submit() async {
              final username = _username.text.trim();
              if (username.isEmpty) {
                setSheetState(() => errorText = 'Please enter a username.');
                return;
              }

              setSheetState(() {
                errorText = null;
                isSubmitting = true;
              });
              setState(() => _submitting = true);

              try {
                await widget.onSignedIn(username);
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
              } finally {
                if (mounted) {
                  setState(() => _submitting = false);
                }
              }
            }

            return Padding(
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
                      TextField(
                        controller: _username,
                        autofocus: true,
                        enabled: !isSubmitting,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) {
                          if (errorText != null) {
                            setSheetState(() => errorText = null);
                          }
                        },
                        onSubmitted: (_) => submit(),
                        decoration: InputDecoration(
                          hintText: 'Username',
                          errorText: errorText,
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
                      const SizedBox(height: 16),
                      _LoginActionButton(
                        label: isSubmitting ? 'Signing in...' : 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        dark: true,
                        onPressed: isSubmitting ? null : submit,
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegisterPage(onRegistered: widget.onRegistered),
      ),
    );
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
                        constraints: BoxConstraints(minHeight: viewport.maxHeight),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 86),
                child: Column(
                  children: [
                    _LoginActionButton(
                      label: _submitting ? 'Signing in...' : 'Continue',
                      icon: Icons.person_outline_rounded,
                      onPressed: _submitting ? null : _showUsernameSheet,
                    ),
                    const SizedBox(height: 32),
                    _LoginActionButton(
                      label: 'Create an account',
                      icon: Icons.person_add_alt_1_rounded,
                      dark: true,
                      onPressed: _submitting ? null : _openRegister,
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
            margin: const EdgeInsets.only(top: 24),
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
    final shadowRect = Rect.fromLTRB(
      -1,
      -1,
      size.width + 1,
      size.height + 1,
    );
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
