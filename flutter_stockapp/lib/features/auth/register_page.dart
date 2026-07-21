import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/auth_form_field.dart';
import 'widgets/auth_header.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool get _mismatch =>
      _confirm.text.isNotEmpty && _password.text != _confirm.text;

  void _refresh(String _) => setState(() {});

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPageWrapper(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgGradientLavenderStart,
              AppColors.bgGradientLavenderEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              42,
              AppSpacing.page,
              138,
            ),
            children: [
              const AuthHeader(
                title: 'Create AppName.',
                subtitle: 'Set up the front door for a bright, floating product shell.',
              ),
              const SizedBox(height: AppSpacing.xxl),
              const AuthFormField(
                hintText: 'Username',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),
              const AuthFormField(
                hintText: 'Email',
                icon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthFormField(
                hintText: 'Password',
                icon: Icons.lock_outline_rounded,
                controller: _password,
                onChanged: _refresh,
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthFormField(
                hintText: 'Confirm password',
                icon: Icons.verified_user_outlined,
                controller: _confirm,
                onChanged: _refresh,
                obscureText: true,
                errorText: _mismatch ? 'Passwords do not match.' : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Create account', onPressed: () {}),
              const SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(
                  'Already have an account? Sign in',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.accentBlueLink,
                    fontWeight: FontWeight.w800,
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
