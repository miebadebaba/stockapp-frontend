import 'package:flutter/material.dart';

import '../../../core/widgets/app_text_field.dart';

class AuthFormField extends StatelessWidget {
  const AuthFormField({
    required this.hintText,
    required this.icon,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.errorText,
    super.key,
  });

  final String hintText;
  final IconData icon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hintText: hintText,
      icon: icon,
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      errorText: errorText,
    );
  }
}
