import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/navigation/root_shell.dart';

class AppNameDemo extends StatelessWidget {
  const AppNameDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppName',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const RootShell(),
    );
  }
}
