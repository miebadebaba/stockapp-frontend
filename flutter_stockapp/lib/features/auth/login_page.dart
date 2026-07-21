import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import '../../core/widgets/app_button.dart';
import 'register_page.dart';
import 'widgets/auth_form_field.dart';
import 'widgets/auth_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
              54,
              AppSpacing.page,
              138,
            ),
            children: [
              const AuthHeader(
                title: 'Meet AppName.',
                subtitle: 'A personal workspace for ideas, signals, and calm daily focus.',
              ),
              const SizedBox(height: AppSpacing.xxl),
              const AuthFormField(
                hintText: 'Email or username',
                icon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),
              const AuthFormField(
                hintText: 'Password',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Continue', onPressed: () {}),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Continue with Search ID',
                icon: const Icon(Icons.g_mobiledata_rounded),
                variant: AppButtonVariant.secondary,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Continue with Device ID',
                icon: const Icon(Icons.phone_iphone_rounded),
                variant: AppButtonVariant.dark,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
                ),
                child: Text(
                  'No account? Create one',
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
